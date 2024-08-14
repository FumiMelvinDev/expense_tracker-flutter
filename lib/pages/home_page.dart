import 'package:expense_tracker/components/expense_tile.dart';
import 'package:expense_tracker/database/expense_database.dart';
import 'package:expense_tracker/graph/bar_graph.dart';
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

  Future<Map<int, double>>? _monthlyTotalsFuture;
  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();

    refreshData();

    super.initState();
  }

  void refreshData() {
    _monthlyTotalsFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlyTotals();

    _calculateCurrentMonthTotal =
        Provider.of<ExpenseDatabase>(context, listen: false)
            .calculateCurrenttMonthTotal();
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

                        refreshData();

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

                        refreshData();

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

                      refreshData();
                    },
                    child: const Text('Delete')),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(builder: (context, value, child) {
      int startMonth = value.getStartMonth();
      int startYear = value.getStartYear();
      int currentMonth = DateTime.now().month;
      int currentYear = DateTime.now().year;

      int monthCount =
          calculateMonthCount(startYear, startMonth, currentYear, currentMonth);

      List<Expense> currentMonthExpenses = value.allExpense.where((expense) {
        return expense.dateTime.month == currentMonth &&
            expense.dateTime.year == currentYear;
      }).toList();

      return Scaffold(
        backgroundColor: Colors.grey.shade300,
        floatingActionButton: FloatingActionButton(
          onPressed: addExpense,
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: FutureBuilder<double>(
            future: _calculateCurrentMonthTotal,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatCurrency(snapshot.data!),
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.black38,
                      ),
                    ),
                    Text(
                      getCurrentMonthName(),
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 300,
                child: FutureBuilder(
                  future: _monthlyTotalsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      final monthTotals = snapshot.data ?? {};

                      List<double> monthlySummary = List.generate(
                        monthCount,
                        (index) => monthTotals[startMonth + index] ?? 0.0,
                      );

                      return MyBarGraph(
                        monthlySummary: monthlySummary,
                        startMonth: startMonth,
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: currentMonthExpenses.length,
                  itemBuilder: (context, index) {
                    int reverseIndex = currentMonthExpenses.length - index - 1;

                    Expense eachExpense = currentMonthExpenses[reverseIndex];

                    return ExpenseTile(
                      title: eachExpense.name,
                      trailing: formatCurrency(eachExpense.amount),
                      onEditPressed: (context) => openEdit(eachExpense),
                      onDeletePressed: (context) => openDelete(eachExpense),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
