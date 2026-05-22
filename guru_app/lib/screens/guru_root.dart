import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'guru_home_screen.dart';
import 'guru_onboarding_screen.dart';

class GuruRootScreen extends StatefulWidget {
  const GuruRootScreen({super.key});

  @override
  State<GuruRootScreen> createState() => _GuruRootScreenState();
}

class _GuruRootScreenState extends State<GuruRootScreen> {
  bool _loading = true;
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = AppServices.instance.auth;
    final user = await auth.getCurrentUser();
    setState(() {
      _showOnboarding = !auth.isOnboardingDone || user == null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_showOnboarding) {
      return GuruOnboardingScreen(onComplete: () => setState(() => _showOnboarding = false));
    }
    return const GuruHomeScreen();
  }
}
