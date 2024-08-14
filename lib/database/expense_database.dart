import 'dart:async';

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

  // calc total monthly expenses
  Future<Map<int, double>> calculateMonthlyTotals() async {
    await readExpenses();

    Map<int, double> monthlyTotals = {};

    for (var expense in _allExpenses) {
      int month = expense.dateTime.month;

      if (!monthlyTotals.containsKey(month)) {
        monthlyTotals[month] = 0;
      }

      monthlyTotals[month] = monthlyTotals[month]! + expense.amount;
    }

    return monthlyTotals;
  }

  Future<double> calculateCurrenttMonthTotal() async {
    await readExpenses();

    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    List<Expense> currentMonthExpenses = _allExpenses.where((expense) {
      return expense.dateTime.month == currentMonth &&
          expense.dateTime.year == currentYear;
    }).toList();

    double total =
        currentMonthExpenses.fold(0, (sum, expense) => sum + expense.amount);

    return total;
  }

  int getStartMonth() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().month;
    }

    _allExpenses.sort(
      (a, b) => a.dateTime.compareTo(b.dateTime),
    );

    return _allExpenses.first.dateTime.month;
  }

  int getStartYear() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().year;
    }

    _allExpenses.sort(
      (a, b) => a.dateTime.compareTo(b.dateTime),
    );

    return _allExpenses.first.dateTime.year;
  }
}
