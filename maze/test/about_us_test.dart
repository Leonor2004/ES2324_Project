import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maze/pages/about_us.dart'; // Update this with the correct path to your AboutUs widget file

void main() {
  // Basic widget test to ensure the widget builds
  testWidgets('AboutUs builds correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutUs()));

    // Verify the widget exists
    expect(find.byType(AboutUs), findsOneWidget);
  });

  // Test the presence and properties of the AppBar
  // Test the static text content of the widget
  testWidgets('Static text content is correct', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutUs()));

    // Verify text content is present
    expect(find.text('ABOUT US'), findsOneWidget);
    expect(find.text('Maze: Navigating Public Transit Together'), findsOneWidget);
    expect(find.textContaining('Welcome to Maze'), findsOneWidget);
    expect(find.text('© 2024 Maze. All rights reserved. Trademarks belong to their respective owners.'), findsOneWidget);

    // You can add more detailed text style checking if needed
  });
}
