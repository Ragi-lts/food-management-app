import 'package:intl/intl.dart';

class DateTimeHelper {
  static String format({required String value, String format = "yyyy/MM/dd HH:mm:ss"}) {
    DateTime datetime = DateTime.parse(value);
    DateFormat formatter = DateFormat(format);
    return formatter.format(datetime);
  }
}
