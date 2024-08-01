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
