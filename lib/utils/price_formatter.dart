import 'package:intl/intl.dart';

/// Formats a price as a currency string with thousand separators.
/// e.g., 528000.0 → "$528,000" and 29.99 → "$29.99"
String formatPrice(double price) {
  if (price == price.truncateToDouble()) {
    // Whole number — drop the decimals for cleaner look
    return NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(price);
  }
  return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(price);
}
