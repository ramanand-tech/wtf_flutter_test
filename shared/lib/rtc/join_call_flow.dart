import 'package:flutter/material.dart';

import '../models/call_request.dart';
import '../models/enums.dart';
import '../services/app_services.dart';
import '../services/call_service.dart';
import '../utils/seed_data.dart';
import 'join_call_args.dart';
import 'prejoin_screen.dart';

/// Opens pre-join → meeting for an approved [CallRequest].
class JoinCallFlow {
  static Future<void> open({
    required BuildContext context,
    required CallRequest request,
    required String currentUserId,
    required UserRole currentRole,
    required String userName,
    required Color primaryColor,
  }) async {
    final roomMeta = AppServices.instance.calls.roomMetaFor(request.id);
    final roomId = roomMeta?.hmsRoomId ?? kDefaultHmsRoomId;
    final hmsRole = currentRole == UserRole.trainer
        ? (roomMeta?.hmsRoleTrainer ?? 'trainer')
        : (roomMeta?.hmsRoleMember ?? 'member');

    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PreJoinScreen(
          args: JoinCallArgs(
            callRequest: request,
            currentUserId: currentUserId,
            currentRole: currentRole,
            userName: userName,
            primaryColor: primaryColor,
            roomId: roomId,
            hmsRole: hmsRole,
          ),
        ),
      ),
    );
  }

  static String displayName(UserRole role) =>
      role == UserRole.member ? SeedData.dk.name : SeedData.aarav.name;
}
