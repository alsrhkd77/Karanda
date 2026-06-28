import 'package:flutter/widgets.dart';

abstract final class Dimens {
  static const double pageMaxWidth = 1200.0;
  static const double pagePaddingValue = 12.0;
  static const double snackBarMarginValue = 24.0;
  static const EdgeInsetsGeometry pagePadding =
      EdgeInsets.all(pagePaddingValue);

  static double pageHorizontalPaddingValue(double width) {
    return width > pageMaxWidth + (pagePaddingValue * 2)
        ? (width - pageMaxWidth) / 2
        : pagePaddingValue;
  }

  static double snackBarHorizontalMarginValue(double width) {
    return width > pageMaxWidth + (snackBarMarginValue * 2)
        ? (width - pageMaxWidth) / 2
        : snackBarMarginValue;
  }

  static EdgeInsetsGeometry constrainedPagePadding(double width) {
    return EdgeInsets.only(
      left: pageHorizontalPaddingValue(width),
      right: pageHorizontalPaddingValue(width),
      top: pagePaddingValue,
      bottom: pagePaddingValue * 2,
    );
  }

  static EdgeInsetsGeometry snackBarMargin(double width) {
    return EdgeInsets.only(
      left: snackBarHorizontalMarginValue(width),
      right: snackBarHorizontalMarginValue(width),
      top: 0,
      bottom: snackBarMarginValue,
    );
  }

  static EdgeInsetsGeometry listTileContentsPadding() {
    return const EdgeInsets.symmetric(
      vertical: 4.0,
      horizontal: 16.0,
    );
  }
}
