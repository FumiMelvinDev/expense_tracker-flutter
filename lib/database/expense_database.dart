import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  final List<Expense> _allExpenses = [];

  // INIT DB
  static Future<void> initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  // GETTERS
  List<Expense> get allExpense => _allExpenses;

  // CRUD OPERATIONS
  // Create
  Future<void> createExpense(Expense newExpense) async {
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    // read from db
    await readExpenses();
  }

  // Read
  Future<void> readExpenses() async {
    List<Expense> fetchExpenses = await isar.expenses.where().findAll();

    _allExpenses.clear();
    _allExpenses.addAll(fetchExpenses);

    // update UI
    notifyListeners();
  }

  // Update
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    updatedExpense.id = id;

    // update
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));

    // read from db
    await readExpenses();
  }

  // Delete
  Future<void> deleteExpense(int id) async {
    await isar.writeTxn(() => isar.expenses.delete(id));

    // read from db
    await readExpenses();
  }
}
