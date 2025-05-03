import 'package:flutter/material.dart';

abstract class AppTheme {
  static const snackBarDuration = Duration(seconds: 6);

  static final overlayAppTheme = ThemeData(
    colorSchemeSeed: Colors.indigo,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    cardTheme: CardTheme(
      color: Colors.black.withAlpha(175),
      elevation: 0.0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 22.0, horizontal: 69.0),
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo.shade400,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      contentTextStyle: const TextStyle(color: Colors.white),
      backgroundColor: Colors.black.withAlpha(175),
      elevation: 0.0,
      insetPadding: const EdgeInsets.symmetric(vertical: 70),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    ),
  );

  static final lightTheme = ThemeData(
    fontFamily: 'Maplestory',
    colorSchemeSeed: const Color.fromRGBO(87, 132, 193, 1.0),
    appBarTheme: const AppBarTheme(
      actionsPadding: EdgeInsets.only(right: 12.0),
    ),
    inputDecorationTheme: _inputDecorationThemeData,
    dropdownMenuTheme: _dropdownMenuThemeData,
    actionIconTheme: _actionIconThemeData,
    cardTheme: _cardThemeData,
    snackBarTheme: _snackBarThemeData,
    expansionTileTheme: _expansionTileThemeData,
    listTileTheme: _listTileThemeData,
    //pageTransitionsTheme: _pageTransitionsThemeData,
    progressIndicatorTheme: _progressIndicatorThemeData,
    sliderTheme: _sliderThemeData,
  );

  static final darkTheme = ThemeData(
    fontFamily: 'Maplestory',
    colorSchemeSeed: Colors.indigo,
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      actionsPadding: EdgeInsets.only(right: 12.0),
      backgroundColor: Color.fromRGBO(24, 24, 26, 1.0),
    ),
    scaffoldBackgroundColor: const Color.fromRGBO(24, 24, 26, 1.0),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo.shade400,
      ),
    ),
    inputDecorationTheme: _inputDecorationThemeData,
    dropdownMenuTheme: _dropdownMenuThemeData,
    actionIconTheme: _actionIconThemeData,
    cardTheme: _cardThemeData,
    snackBarTheme: _snackBarThemeData,
    expansionTileTheme: _expansionTileThemeData,
    listTileTheme: _listTileThemeData,
    //pageTransitionsTheme: _pageTransitionsThemeData,
    progressIndicatorTheme: _progressIndicatorThemeData,
    sliderTheme: _sliderThemeData,
  );

  static final _inputDecorationThemeData = InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: Colors.blue),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
  );

  static final _dropdownMenuThemeData = DropdownMenuThemeData(
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 4.0,
        horizontal: 12.0,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
  );

  static const _cardThemeData = CardThemeData(margin: EdgeInsets.all(8.0));

  static final _actionIconThemeData = ActionIconThemeData(
    backButtonIconBuilder: (BuildContext context) {
      return const Icon(Icons.arrow_back_ios_new);
    },
  );

  static const _snackBarThemeData = SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
  );

  static const _expansionTileThemeData = ExpansionTileThemeData(
    childrenPadding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
  );

  /// style from [Typography.englishLike2021] bodyLarge
  static const _listTileThemeData = ListTileThemeData(
    leadingAndTrailingTextStyle: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.50,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  static final _pageTransitionsThemeData = PageTransitionsTheme(
    builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
      TargetPlatform.values,
      value: (_) => const FadeForwardsPageTransitionsBuilder(),
    ),
  );

  static const _progressIndicatorThemeData = ProgressIndicatorThemeData(
    year2023: false,
  );

  static const _sliderThemeData = SliderThemeData(year2023: false);
}
