import 'package:intl/intl.dart';

class DateUtilsCustom {
  static String formatToDDMMYYYY(String date) {
    return DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
  }
}