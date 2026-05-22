import '../models/session_log.dart';
import '../utils/app_logger.dart';
import '../utils/extensions.dart';
import 'chat_sync_client.dart';
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
  Future<void> pullRemote();
  List<SessionLog> forUser(String userId, {required bool isTrainer});
}

class SyncLogService implements LogService {
  SyncLogService(this._store, this._sync);

  final LocalStore _store;
  final ChatSyncClient _sync;

  List<SessionLog> _all() {
    final logs = _store.sessionLogs.map(SessionLog.fromJson).toList();
    logs.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return logs;
  }

  Future<void> _pushLocal() async {
    await _sync.pushSessions(_store.sessionLogs);
  }

  Future<void> _mergeRemote(List<Map<String, dynamic>> remote) async {
    if (remote.isEmpty) return;
    final byId = <String, Map<String, dynamic>>{
      for (final m in _store.sessionLogs) m['id'] as String: m,
    };
    var changed = false;
    for (final r in remote) {
      final id = r['id'] as String;
      final existing = byId[id];
      if (existing == null) {
        byId[id] = r;
        changed = true;
      } else {
        final a = SessionLog.fromJson(existing);
        final b = SessionLog.fromJson(r);
        if (b.endedAt.isAfter(a.endedAt) ||
            (b.rating ?? 0) != (a.rating ?? 0) ||
            b.trainerNotes != a.trainerNotes ||
            b.memberNotes != a.memberNotes) {
          byId[id] = r;
          changed = true;
        }
      }
    }
    if (!changed) return;
    final merged = byId.values.toList()
      ..sort((a, b) {
        final ad = DateTime.parse(a['startedAt'] as String);
        final bd = DateTime.parse(b['startedAt'] as String);
        return ad.compareTo(bd);
      });
    await _store.setSessionLogs(merged);
  }

  @override
  Future<void> pullRemote() async {
    final remote = await _sync.fetchSessions();
    await _mergeRemote(remote);
  }

  @override
  Stream<List<SessionLog>> watchLogs() async* {
    yield _all();
    await for (final _ in _store.onSessionsChanged) {
      yield _all();
    }
  }

  @override
  List<SessionLog> forUser(String userId, {required bool isTrainer}) {
    return _all().where((l) {
      return isTrainer ? l.trainerId == userId : l.memberId == userId;
    }).toList();
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
    await _pushLocal();
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
    await _pushLocal();
  }
}
