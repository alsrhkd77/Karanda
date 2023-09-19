import 'package:flutter/material.dart';

class GlobalProperties {

  static get scrollViewPadding => const EdgeInsets.all(12.0);

  static get scrollViewVerticalPadding => 12.0;

  static double scrollViewHorizontalPadding(double width){
    return width > 1212.0 ? (width-1200.0) / 2 : 12.0;
  }
}