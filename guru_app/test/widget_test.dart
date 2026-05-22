import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guru_app/screens/guru_home_screen.dart';
import 'package:shared/shared.dart';
import 'test_bootstrap.dart';

void main() {
  setUpAll(() async {
    await initTestAppServices(hiveBoxName: 'test_guru_widget_box');
  });

  testWidgets('Guru home shows chat, schedule, and sessions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(primary: AppColors.guruPrimary, appName: 'Guru'),
        home: const GuruHomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chat with Trainer'), findsOneWidget);
    expect(find.text('Schedule Call'), findsOneWidget);
    expect(find.text('My Sessions'), findsOneWidget);
    expect(find.text('Guru Home'), findsOneWidget);
  });

  testWidgets('Guru home opens schedule screen from card', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(primary: AppColors.guruPrimary, appName: 'Guru'),
        home: const GuruHomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Schedule Call'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Schedule Call'), findsOneWidget);
    expect(find.text('My Requests'), findsOneWidget);
  });
}
