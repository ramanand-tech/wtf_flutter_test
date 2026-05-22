import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../utils/theme.dart';

class RequestStatusChip extends StatelessWidget {
  const RequestStatusChip({super.key, required this.status});

  final CallRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      CallRequestStatus.pending => ('Pending', AppColors.warning),
      CallRequestStatus.approved => ('Approved', AppColors.success),
      CallRequestStatus.declined => ('Declined', AppColors.error),
      CallRequestStatus.cancelled => ('Cancelled', AppColors.neutral700),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
