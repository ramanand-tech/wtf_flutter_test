import 'package:flutter/material.dart';

import '../models/call_request.dart';
import '../models/enums.dart';
import '../rtc/join_call_flow.dart';
import '../services/app_services.dart';

class JoinCallButton extends StatelessWidget {
  const JoinCallButton({
    super.key,
    required this.request,
    required this.currentUserId,
    required this.currentRole,
    required this.primaryColor,
  });

  final CallRequest request;
  final String currentUserId;
  final UserRole currentRole;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final canJoin = AppServices.instance.calls.canJoin(request);
    if (!canJoin) return const SizedBox.shrink();

    return FilledButton.icon(
      onPressed: () => JoinCallFlow.open(
        context: context,
        request: request,
        currentUserId: currentUserId,
        currentRole: currentRole,
        userName: JoinCallFlow.displayName(currentRole),
        primaryColor: primaryColor,
      ),
      icon: const Icon(Icons.videocam),
      label: const Text('Join Call'),
      style: FilledButton.styleFrom(backgroundColor: primaryColor),
    );
  }
}
