import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class GuruOnboardingScreen extends StatefulWidget {
  const GuruOnboardingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<GuruOnboardingScreen> createState() => _GuruOnboardingScreenState();
}

class _GuruOnboardingScreenState extends State<GuruOnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  final _nameController = TextEditingController(text: 'DK');
  String _trainerId = SeedData.aaravId;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final member = SeedData.dk.copyWith(name: _nameController.text.trim());
    await AppServices.instance.auth.completeOnboarding(
      member: member,
      trainerId: _trainerId,
    );
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome, Guru')),
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _page = i),
        children: [
          _slide(
            'Train with your coach',
            'Chat, schedule video calls, and track sessions — all in one place.',
            Icons.fitness_center,
          ),
          _slide(
            'Meet DK',
            'Your profile is ready. Pick your lead trainer to get started.',
            Icons.person,
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: _page == 0
            ? FilledButton(
                onPressed: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                ),
                child: const Text('Next'),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Your name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _trainerId,
                    decoration: const InputDecoration(
                      labelText: 'Choose trainer',
                      border: OutlineInputBorder(),
                    ),
                    items: SeedData.trainers
                        .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _trainerId = v ?? SeedData.aaravId),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _finish,
                    child: const Text('Get Started'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _slide(String title, String body, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.guruPrimary),
          const SizedBox(height: 24),
          Text(title, style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(body, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
