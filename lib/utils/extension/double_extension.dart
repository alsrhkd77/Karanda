import 'package:intl/intl.dart';

extension DoubleExtension on double {
  /// format with [NumberFormat]
  ///
  /// see also https://api.flutter.dev/flutter/intl/NumberFormat-class.html
  String format([String pattern = "###,###,###,###,##0.0#"]){
    final format = NumberFormat(pattern);
    return format.format(this);
  }
}