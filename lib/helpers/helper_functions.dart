// convert string to double
import 'package:intl/intl.dart';

double convertStringToDouble(String value) {
  double? amount = double.tryParse(value);

  return amount ?? 0.0;
}

// format currency
String formatCurrency(double amount) {
  final formattedAmount = NumberFormat.currency(locale: "en_ZA", symbol: "R");
  return formattedAmount.format(amount);
}

// calculate month count
int calculateMonthCount(int startYear, startMonth, currentYear, currentMonth) {
  int monthCount =
      (currentYear - startYear) * 12 + currentMonth - startMonth + 1;

  return monthCount;
}

String getCurrentMonthName() {
  DateTime now = DateTime.now();

  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  return months[now.month - 1];
}
