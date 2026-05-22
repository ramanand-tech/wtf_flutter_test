import 'package:flutter/material.dart';

import '../models/call_request.dart';
import '../models/enums.dart';

class JoinCallArgs {
  const JoinCallArgs({
    required this.callRequest,
    required this.currentUserId,
    required this.currentRole,
    required this.userName,
    required this.primaryColor,
    required this.roomId,
    required this.hmsRole,
  });

  final CallRequest callRequest;
  final String currentUserId;
  final UserRole currentRole;
  final String userName;
  final Color primaryColor;
  final String roomId;
  final String hmsRole;
}
