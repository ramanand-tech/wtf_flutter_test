import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/call_request.dart';
import '../models/enums.dart';
import '../models/room_meta.dart';
import '../utils/app_logger.dart';
import '../utils/extensions.dart';
import '../utils/seed_data.dart';
import '../config/hms_secrets.dart';
import '../utils/validators.dart';
import 'chat_service.dart';
import 'chat_sync_client.dart';
import 'local_store.dart';

export '../config/hms_secrets.dart' show kDefaultHmsRoomId;

abstract class CallService {
  Stream<List<CallRequest>> watchRequests();
  Future<CallRequest> createRequest({
    required String memberId,
    required String trainerId,
    required DateTime scheduledFor,
    required String note,
  });
  Future<CallRequest> approve(String requestId, {String? hmsRoomId});
  Future<CallRequest> decline(String requestId, String reason);
  List<DateTime> approvedSlots();
  bool canJoin(CallRequest request);
  Future<void> pullRemote();
  List<CallRequest> upcomingForMember(String memberId);
  List<CallRequest> upcomingForTrainer(String trainerId);
  RoomMeta? roomMetaFor(String callRequestId);
}

class SyncCallService implements CallService {
  SyncCallService(this._store, this._chat, this._sync);

  final LocalStore _store;
  final SyncChatService _chat;
  final ChatSyncClient _sync;

  List<CallRequest> _all() =>
      _store.callRequests.map(CallRequest.fromJson).toList();

  Future<void> _pushLocal() async {
    await _sync.pushCalls(_store.callRequests);
  }

  Future<void> _mergeRemote(List<Map<String, dynamic>> remote) async {
    if (remote.isEmpty) return;
    final byId = <String, Map<String, dynamic>>{
      for (final m in _store.callRequests) m['id'] as String: m,
    };
    var changed = false;
    for (final r in remote) {
      final id = r['id'] as String;
      final existing = byId[id];
      if (existing == null) {
        byId[id] = r;
        changed = true;
      } else {
        final existingReq = CallRequest.fromJson(existing);
        final remoteReq = CallRequest.fromJson(r);
        if (remoteReq.requestedAt.isAfter(existingReq.requestedAt) ||
            remoteReq.status.index != existingReq.status.index) {
          byId[id] = r;
          changed = true;
        }
      }
    }
    if (!changed) return;
    final merged = byId.values.toList()
      ..sort((a, b) {
        final ad = DateTime.parse(a['requestedAt'] as String);
        final bd = DateTime.parse(b['requestedAt'] as String);
        return ad.compareTo(bd);
      });
    await _store.setCallRequests(merged);
  }

  @override
  Future<void> pullRemote() async {
    final remote = await _sync.fetchCalls();
    await _mergeRemote(remote);
  }

  @override
  Stream<List<CallRequest>> watchRequests() async* {
    yield _sorted();
    await for (final _ in _store.onCallsChanged) {
      yield _sorted();
    }
  }

  List<CallRequest> _sorted() {
    final list = _all();
    list.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    return list;
  }

  @override
  List<DateTime> approvedSlots() {
    return _all()
        .where((r) => r.status == CallRequestStatus.approved)
        .map((r) => r.scheduledFor)
        .toList();
  }

  @override
  RoomMeta? roomMetaFor(String callRequestId) {
    for (final raw in _store.roomMeta) {
      final meta = RoomMeta.fromJson(raw);
      if (meta.callRequestId == callRequestId) return meta;
    }
    return null;
  }

  @override
  List<CallRequest> upcomingForTrainer(String trainerId) {
    return _all()
        .where(
          (r) =>
              r.trainerId == trainerId &&
              r.status == CallRequestStatus.approved &&
              r.scheduledFor.isAfter(DateTime.now().subtract(const Duration(hours: 1))),
        )
        .toList()
      ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
  }

  @override
  List<CallRequest> upcomingForMember(String memberId) {
    return _all()
        .where(
          (r) =>
              r.memberId == memberId &&
              r.status == CallRequestStatus.approved &&
              r.scheduledFor.isAfter(DateTime.now().subtract(const Duration(hours: 1))),
        )
        .toList()
      ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
  }

  @override
  Future<CallRequest> createRequest({
    required String memberId,
    required String trainerId,
    required DateTime scheduledFor,
    required String note,
  }) async {
    if (Validators.isPastDateTime(scheduledFor)) {
      throw StateError('Cannot schedule in the past');
    }
    if (Validators.hasSlotConflict(
      scheduledFor: scheduledFor,
      approvedSlots: approvedSlots(),
    )) {
      throw StateError('This time slot is already booked');
    }

    final req = CallRequest(
      id: 'call_${DateTime.now().microsecondsSinceEpoch}',
      memberId: memberId,
      trainerId: trainerId,
      requestedAt: DateTime.now(),
      scheduledFor: scheduledFor,
      note: note,
      status: CallRequestStatus.pending,
    );
    final list = _store.callRequests..add(req.toJson());
    await _store.setCallRequests(list);
    await _pushLocal();
    AppLogger.instance.log(LogTag.schedule, 'Call requested for ${scheduledFor.toIso8601String()}');
    return req;
  }

  @override
  Future<CallRequest> approve(String requestId, {String? hmsRoomId}) async {
    final list = _all();
    final index = list.indexWhere((r) => r.id == requestId);
    if (index < 0) throw StateError('Request not found');

    final roomId = hmsRoomId ?? kDefaultHmsRoomId;
    final updated = list[index].copyWith(status: CallRequestStatus.approved);
    final jsonList = list.map((r) => r.toJson()).toList();
    jsonList[index] = updated.toJson();
    await _store.setCallRequests(jsonList);

    final room = RoomMeta(
      id: 'room_${updated.id}',
      callRequestId: updated.id,
      hmsRoomId: roomId,
      hmsRoleMember: 'member',
      hmsRoleTrainer: 'trainer',
    );
    final rooms = _store.roomMeta..add(room.toJson());
    await _store.setRoomMeta(rooms);

    await _chat.sendMessage(
      chatId: SeedData.defaultChatId,
      senderId: updated.trainerId,
      receiverId: updated.memberId,
      text: 'Call approved for ${updated.scheduledFor.toScheduleLabel()}.',
      isSystem: true,
    );
    await _pushLocal();
    AppLogger.instance.log(LogTag.schedule, 'Approved call $requestId');
    return updated;
  }

  @override
  Future<CallRequest> decline(String requestId, String reason) async {
    final list = _all();
    final index = list.indexWhere((r) => r.id == requestId);
    if (index < 0) throw StateError('Request not found');

    final updated = list[index].copyWith(
      status: CallRequestStatus.declined,
      declineReason: reason,
    );
    final jsonList = list.map((r) => r.toJson()).toList();
    jsonList[index] = updated.toJson();
    await _store.setCallRequests(jsonList);

    await _chat.sendMessage(
      chatId: SeedData.defaultChatId,
      senderId: updated.trainerId,
      receiverId: updated.memberId,
      text: 'Call request declined. Reason: $reason',
      isSystem: true,
    );
    await _pushLocal();
    return updated;
  }

  @override
  bool canJoin(CallRequest request) {
    if (request.status != CallRequestStatus.approved) return false;
    final diff = request.scheduledFor.difference(DateTime.now());
    if (kDebugMode) {
      // Easier manual testing: any approved call within ~48h window
      return diff.inHours <= 48 && diff.inHours >= -2;
    }
    return diff.inMinutes <= 10 && diff.inMinutes >= -60;
  }
}
