import 'package:expense_tracker/components/expense_tile.dart';
import 'package:expense_tracker/database/expense_database.dart';
import 'package:expense_tracker/helpers/helper_functions.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();

    super.initState();
  }

  void addExpense() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Add Expense'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: 'Expense Name'),
                  ),
                  TextField(
                    controller: amountController,
                    decoration:
                        const InputDecoration(hintText: 'Expense Amount'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      nameController.clear();
                      amountController.clear();
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () async {
                      if (nameController.text.isNotEmpty &&
                          amountController.text.isNotEmpty) {
                        Navigator.of(context).pop();

                        Expense addedExpense = Expense(
                          name: nameController.text,
                          amount: convertStringToDouble(amountController.text),
                          dateTime: DateTime.now(),
                        );

                        await context
                            .read<ExpenseDatabase>()
                            .createExpense(addedExpense);

                        nameController.clear();
                        amountController.clear();
                      }
                    },
                    child: const Text('Add')),
              ],
            ));
  }

  void openEdit(Expense expense) {
    // pre-fill
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Edit Expense'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(hintText: existingName),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(hintText: existingAmount),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      nameController.clear();
                      amountController.clear();
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () async {
                      if (nameController.text.isNotEmpty ||
                          amountController.text.isNotEmpty) {
                        Navigator.of(context).pop();

                        Expense updatedExpense = Expense(
                          name: nameController.text.isNotEmpty
                              ? nameController.text
                              : expense.name,
                          amount: amountController.text.isNotEmpty
                              ? convertStringToDouble(amountController.text)
                              : expense.amount,
                          dateTime: DateTime.now(),
                        );

                        int existingId = expense.id;

                        await context
                            .read<ExpenseDatabase>()
                            .updateExpense(existingId, updatedExpense);

                        nameController.clear();
                        amountController.clear();
                      }
                    },
                    child: const Text('Edit')),
              ],
            ));
  }

  void openDelete(Expense expense) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Delete Expense'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      nameController.clear();
                      amountController.clear();
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () async {
                      Navigator.pop(context);

                      await context
                          .read<ExpenseDatabase>()
                          .deleteExpense(expense.id);
                    },
                    child: const Text('Delete')),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) => Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: addExpense,
          child: const Icon(Icons.add),
        ),
        body: ListView.builder(
          itemCount: value.allExpense.length,
          itemBuilder: (context, index) {
            Expense eachExpense = value.allExpense[index];

            return ExpenseTile(
              title: eachExpense.name,
              trailing: formatCurrency(eachExpense.amount),
              onEditPressed: (context) => openEdit(eachExpense),
              onDeletePressed: (context) => openDelete(eachExpense),
            );
          },
        ),
      ),
    );
  }
}
