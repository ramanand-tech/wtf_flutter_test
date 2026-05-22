import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class TrainerLoginScreen extends StatelessWidget {
  const TrainerLoginScreen({super.key, required this.onLoggedIn});

  final VoidCallback onLoggedIn;

  Future<void> _login(BuildContext context) async {
    await AppServices.instance.auth.loginTrainer(SeedData.aarav);
    onLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.trainerPrimary.withValues(alpha: 0.1),
                child: const Icon(Icons.school, size: 48, color: AppColors.trainerPrimary),
              ),
              const SizedBox(height: 24),
              Text('Trainer Login', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              const Text('Mock login — seeded Aarav (Lead Trainer)'),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => _login(context),
                child: const Text('Continue as Aarav'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
