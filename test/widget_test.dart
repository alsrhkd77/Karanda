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
    Stream<int> listener(int value) async*{
      yield value;
    }
    final publisher = Publisher();
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

class Publisher{
  final controller = BehaviorSubject<int>();
  Stream<int> get stream => controller.delay(Duration(seconds: 1));
  Publisher(){
    for(int i=0;i<100;i++){
      controller.sink.add(i);
    }
  }
}
