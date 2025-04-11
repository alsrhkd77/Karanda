// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/main.dart';
import 'package:rxdart/rxdart.dart';



void main() {
  test('playground', () async {
    Map<OverlayFeatures, bool> original = {
      OverlayFeatures.clock : true,
      OverlayFeatures.bossHpScaleIndicator :  false,
      OverlayFeatures.worldBoss : true
    };
    final json = jsonEncode(original);
    print(json);
    Map<OverlayFeatures, bool> data = jsonDecode(json);
    print(data);
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());
    /*
    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
     */
  });
}
