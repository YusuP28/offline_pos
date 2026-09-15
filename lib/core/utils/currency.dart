import 'package:intl/intl.dart';

class Currency {
  static final NumberFormat _format =
      NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(num value) {
    return _format.format(value);
  }
}
