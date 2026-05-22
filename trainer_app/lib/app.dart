import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'screens/trainer_home_screen.dart';
import 'screens/trainer_login_screen.dart';

class TrainerApp extends ConsumerStatefulWidget {
  const TrainerApp({super.key});

  @override
  ConsumerState<TrainerApp> createState() => _TrainerAppState();
}

class _TrainerAppState extends ConsumerState<TrainerApp> {
  bool _loggedIn = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final user = await AppServices.instance.auth.getCurrentUser();
    setState(() {
      _loggedIn = user != null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trainer App — Aarav',
      theme: buildAppTheme(primary: AppColors.trainerPrimary, appName: 'Trainer'),
      home: _loading
          ? const Scaffold(body: CardListSkeleton())
          : _loggedIn
              ? const TrainerHomeScreen()
              : TrainerLoginScreen(onLoggedIn: () => setState(() => _loggedIn = true)),
      debugShowCheckedModeBanner: false,
    );
  }
}
