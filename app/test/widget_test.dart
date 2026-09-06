// This is a basic Flutter widget test for the Farmer App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farmer_app/main.dart';

void main() {
  testWidgets('Farmer App login screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FarmerApp());

    // Verify that the login screen is displayed
    expect(find.text('Farmer App'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    
    // Verify that email and password fields are present
    expect(find.byType(TextFormField), findsNWidgets(2));
    
    // Verify that the demo credentials info is displayed
    expect(find.text('Demo Credentials'), findsOneWidget);
    expect(find.text('Email: farmer@example.com'), findsOneWidget);
  });
}
