// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quick_task_flutter/main.dart'; // Adjust if your main.dart is elsewhere

void main() {
  testWidgets('App starts and shows a title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify that our app has a title.
    // This test assumes TaskListScreen will have an AppBar with a title.
    // You might need to adjust this depending on your TaskListScreen implementation.
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'QuickTask'), findsOneWidget);

    // Example: Verify that a placeholder text for no tasks is shown initially (if applicable)
    // This depends on the initial state of TaskListScreen
    // expect(find.text('No tasks yet!'), findsOneWidget);
  });
}
