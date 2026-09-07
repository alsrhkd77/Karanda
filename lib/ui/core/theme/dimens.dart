import 'package:flutter/widgets.dart';

abstract final class Dimens {
  static const double pageMaxWidth = 1200.0;
  static const double pagePaddingValue = 12.0;
  static const double snackBarMarginValue = 24.0;

  /// 반응형 레이아웃 분기 기준 폭. 이 값 미만이면 좁은 화면 배치로 전환한다.
  static const double breakpointExtraNarrow = 400.0;
  static const double breakpointNarrow = 440.0;
  static const double breakpointCompact = 460.0;
  static const double breakpointMedium = 600.0;
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
