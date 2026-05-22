import '../models/session_log.dart';
import '../utils/app_logger.dart';
import '../utils/extensions.dart';
import 'local_store.dart';

abstract class LogService {
  Stream<List<SessionLog>> watchLogs();
  Future<SessionLog> createFromCall({
    required String memberId,
    required String trainerId,
    required DateTime startedAt,
    required DateTime endedAt,
    String? callRequestId,
  });
  Future<void> addMemberRating(String logId, int rating, String? note);
  Future<void> addTrainerNotes(String logId, String notes);
}

class LocalLogService implements LogService {
  LocalLogService(this._store);

  final LocalStore _store;

  List<SessionLog> _all() {
    final logs = _store.sessionLogs.map(SessionLog.fromJson).toList();
    logs.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return logs;
  }

  @override
  Stream<List<SessionLog>> watchLogs() async* {
    yield _all();
    await for (final _ in _store.onSessionsChanged) {
      yield _all();
    }
  }

  @override
  Future<SessionLog> createFromCall({
    required String memberId,
    required String trainerId,
    required DateTime startedAt,
    required DateTime endedAt,
    String? callRequestId,
  }) async {
    final log = SessionLog(
      id: 'session_${DateTime.now().microsecondsSinceEpoch}',
      memberId: memberId,
      trainerId: trainerId,
      startedAt: startedAt,
      endedAt: endedAt,
      durationSec: startedAt.durationSecondsTo(endedAt),
      callRequestId: callRequestId,
    );
    final list = _store.sessionLogs..add(log.toJson());
    await _store.setSessionLogs(list);
    AppLogger.instance.log(LogTag.rtc, 'Session log saved (${log.durationSec}s)');
    return log;
  }

  @override
  Future<void> addMemberRating(String logId, int rating, String? note) async {
    await _update(logId, (l) => l.copyWith(rating: rating, memberNotes: note));
  }

  @override
  Future<void> addTrainerNotes(String logId, String notes) async {
    await _update(logId, (l) => l.copyWith(trainerNotes: notes));
  }

  Future<void> _update(
    String logId,
    SessionLog Function(SessionLog) transform,
  ) async {
    final list = _all();
    final index = list.indexWhere((l) => l.id == logId);
    if (index < 0) return;
    list[index] = transform(list[index]);
    await _store.setSessionLogs(list.map((l) => l.toJson()).toList());
  }
}
