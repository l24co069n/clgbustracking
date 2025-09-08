// This is a basic Flutter widget test for the College Bus Tracking app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:upashtit2/main.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app shows loading or login screen initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
