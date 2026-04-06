import 'package:intl/intl.dart';

class Formatters {
  static final _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final _date = DateFormat('dd MMM yyyy', 'id_ID');
  static final _dateShort = DateFormat('dd/MM', 'id_ID');
  static final _monthYear = DateFormat('MMMM yyyy', 'id_ID');

  static String rupiah(int amount) => _rupiah.format(amount);
  static String date(DateTime d) => _date.format(d);
  static String dateShort(DateTime d) => _dateShort.format(d);
  static String monthYear(DateTime d) => _monthYear.format(d);
}
