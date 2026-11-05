import 'package:intl/intl.dart';

/// Hours as a decimal with one or two decimals: `4,0`, `5,25`, `3,5`.
String formatHours(int minutes, String locale) =>
    NumberFormat('0.0#', locale).format(minutes / 60);

/// Short weekday without a trailing dot: `Mo`, `Di` / `Mon`, `Tue`.
String shortWeekday(DateTime day, String locale) {
  final name = DateFormat.E(locale).format(day);
  return name.endsWith('.') ? name.substring(0, name.length - 1) : name;
}

/// Euros, with cents only when they aren't zero: `40 €`, `42,50 €` /
/// `€40`, `€42.50`.
String formatEuros(int cents, String locale) => NumberFormat.currency(
  locale: locale,
  symbol: '€',
  decimalDigits: cents % 100 == 0 ? 0 : 2,
).format(cents / 100);
