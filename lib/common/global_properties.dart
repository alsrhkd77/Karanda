import 'package:flutter/material.dart';

class GlobalProperties {
  static double get _scrollViewPadding => 12.0;

  static EdgeInsetsGeometry get scrollViewPadding =>
      EdgeInsets.all(_scrollViewPadding);

  static double get scrollViewVerticalPadding => _scrollViewPadding;

  static double get widthConstrains => 1200.0;

  static double scrollViewHorizontalPadding(double width) {
    return width > widthConstrains + scrollViewVerticalPadding
        ? (width - widthConstrains) / 2
        : scrollViewVerticalPadding;
  }
}
