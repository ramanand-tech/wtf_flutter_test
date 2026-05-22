import '../models/call_request.dart';
import '../models/enums.dart';
import '../models/room_meta.dart';
import '../utils/app_logger.dart';
import '../utils/extensions.dart';
import '../utils/validators.dart';
import 'chat_service.dart';
import 'local_store.dart';

abstract class CallService {
  Stream<List<CallRequest>> watchRequests();
  Future<CallRequest> createRequest({
    required String memberId,
    required String trainerId,
    required DateTime scheduledFor,
    required String note,
  });
  Future<CallRequest> approve(String requestId, {required String hmsRoomId});
  Future<CallRequest> decline(String requestId, String reason);
  List<DateTime> approvedSlots();
  bool canJoin(CallRequest request);
}

class LocalCallService implements CallService {
  LocalCallService(this._store, this._chat);

  final LocalStore _store;
  final SyncChatService _chat;

  List<CallRequest> _all() =>
      _store.callRequests.map(CallRequest.fromJson).toList();

  @override
  Stream<List<CallRequest>> watchRequests() async* {
    yield _all();
    await for (final _ in _store.onCallsChanged) {
      yield _all();
    }
  }

  @override
  List<DateTime> approvedSlots() {
    return _all()
        .where((r) => r.status == CallRequestStatus.approved)
        .map((r) => r.scheduledFor)
        .toList();
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
    AppLogger.instance.log(LogTag.schedule, 'Call requested for ${scheduledFor.toIso8601String()}');
    return req;
  }

  @override
  Future<CallRequest> approve(String requestId, {required String hmsRoomId}) async {
    final list = _all();
    final index = list.indexWhere((r) => r.id == requestId);
    if (index < 0) throw StateError('Request not found');

    final updated = list[index].copyWith(status: CallRequestStatus.approved);
    final jsonList = list.map((r) => r.toJson()).toList();
    jsonList[index] = updated.toJson();
    await _store.setCallRequests(jsonList);

    final room = RoomMeta(
      id: 'room_${updated.id}',
      callRequestId: updated.id,
      hmsRoomId: hmsRoomId,
      hmsRoleMember: 'member',
      hmsRoleTrainer: 'trainer',
    );
    final rooms = _store.roomMeta..add(room.toJson());
    await _store.setRoomMeta(rooms);

    await _chat.sendMessage(
      chatId: 'chat_dk_aarav',
      senderId: updated.trainerId,
      receiverId: updated.memberId,
      text: 'Call approved for ${updated.scheduledFor.toScheduleLabel()}.',
      isSystem: true,
    );
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
      chatId: 'chat_dk_aarav',
      senderId: updated.trainerId,
      receiverId: updated.memberId,
      text: 'Call request declined. Reason: $reason',
      isSystem: true,
    );
    return updated;
  }

  @override
  bool canJoin(CallRequest request) {
    if (request.status != CallRequestStatus.approved) return false;
    final diff = request.scheduledFor.difference(DateTime.now());
    return diff.inMinutes <= 10 && diff.inMinutes >= -60;
  }
}
