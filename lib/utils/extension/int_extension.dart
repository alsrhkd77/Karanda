import 'package:intl/intl.dart';

extension IntegerExtension on int {
  /// format with [NumberFormat]
  ///
  /// see also https://api.flutter.dev/flutter/intl/NumberFormat-class.html
  String format([String pattern = "###,###,###,###,###"]){
    final format = NumberFormat(pattern);
    return format.format(this);
  }
}