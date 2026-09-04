import 'package:intl/intl.dart';

extension NumFormatting on num {
  String toPrice() {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(this);
  }
}
