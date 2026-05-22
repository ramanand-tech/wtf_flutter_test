import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';
import 'test_bootstrap.dart';
import 'package:trainer_app/screens/trainer_home_screen.dart';
import 'package:trainer_app/screens/trainer_login_screen.dart';

void main() {
  setUpAll(() async {
    await initTestAppServices(hiveBoxName: 'test_trainer_widget_box');
  });

  testWidgets('Trainer login screen shows Aarav login', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(primary: AppColors.trainerPrimary, appName: 'Trainer'),
        home: TrainerLoginScreen(onLoggedIn: () {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Aarav'), findsWidgets);
  });

  testWidgets('Trainer home shows grid actions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(primary: AppColors.trainerPrimary, appName: 'Trainer'),
        home: const TrainerHomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('Sessions'), findsOneWidget);
    expect(find.text('Trainer Home'), findsOneWidget);
  });
}
