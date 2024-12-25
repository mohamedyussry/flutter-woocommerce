import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'ar_AE',
    symbol: 'د.إ',
    decimalDigits: 2,
  );

  static String format(String price) {
    try {
      final double value = double.parse(price.replaceAll(RegExp(r'[^\d.]'), ''));
      return _currencyFormat.format(value);
    } catch (e) {
      return 'د.إ 0.00';
    }
  }

  static String formatWithoutSymbol(String price) {
    try {
      final double value = double.parse(price.replaceAll(RegExp(r'[^\d.]'), ''));
      return value.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }
}
