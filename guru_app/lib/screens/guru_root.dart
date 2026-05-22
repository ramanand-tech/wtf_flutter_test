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
  bool _coldStartReported = false;

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
    _reportColdStartIfReady();
  }

  void _reportColdStartIfReady() {
    if (_coldStartReported || _loading || _showOnboarding) return;
    _coldStartReported = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PerfTracker.report(PerfMarks.coldStart, budgetMs: PerfBudgets.coldStartMs);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: CardListSkeleton());
    }
    if (_showOnboarding) {
      return GuruOnboardingScreen(
        onComplete: () {
          setState(() => _showOnboarding = false);
          _reportColdStartIfReady();
        },
      );
    }
    _reportColdStartIfReady();
    return const GuruHomeScreen();
  }
}
