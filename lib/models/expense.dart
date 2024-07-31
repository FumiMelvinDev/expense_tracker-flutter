import 'package:isar/isar.dart';

// generate file
// run in terminal: dart run build_runner build
part 'expense.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement;
  final String name;
  final double amount;
  final DateTime dateTime;

  Expense({
    required this.name,
    required this.amount,
    required this.dateTime,
  });
}
