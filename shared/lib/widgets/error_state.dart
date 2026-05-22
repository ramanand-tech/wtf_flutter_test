import 'package:flutter/material.dart';

import '../utils/spacing.dart';
import 'app_buttons.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Something went wrong',
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 56, color: Colors.grey.shade500),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            AppPrimaryButton(label: 'Retry', onPressed: onRetry, icon: Icons.refresh),
            const SizedBox(height: AppSpacing.xs),
            AppTertiaryButton(
              label: 'Dismiss',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}
