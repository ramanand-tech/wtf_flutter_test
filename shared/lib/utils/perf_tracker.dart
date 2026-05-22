import 'app_logger.dart';

/// Performance budgets from assessment Section 10.
abstract class PerfBudgets {
  static const int coldStartMs = 2500;
  static const int chatPeerMs = 400;
  static const int rtcJoinMs = 4000;
}

abstract class PerfMarks {
  static const coldStart = 'cold_start';
  static const rtcJoin = 'rtc_join';
  static const rtcRoomJoin = 'rtc_room_join';
}

/// Lightweight timing helper — results appear in DevPanel as [PERF] logs.
class PerfTracker {
  PerfTracker._();

  static final Map<String, int> _startsMicros = {};

  static void mark(String label) {
    _startsMicros[label] = DateTime.now().microsecondsSinceEpoch;
  }

  static void report(String label, {required int budgetMs}) {
    final start = _startsMicros.remove(label);
    if (start == null) return;
    final ms = (DateTime.now().microsecondsSinceEpoch - start) ~/ 1000;
    final ok = ms <= budgetMs;
    AppLogger.instance.log(
      LogTag.perf,
      '$label ${ms}ms (budget ${budgetMs}ms) ${ok ? 'OK' : 'SLOW'}',
    );
  }

  static void logInstant(String label, int elapsedMs, {required int budgetMs}) {
    final ok = elapsedMs <= budgetMs;
    AppLogger.instance.log(
      LogTag.perf,
      '$label ${elapsedMs}ms (budget ${budgetMs}ms) ${ok ? 'OK' : 'SLOW'}',
    );
  }
}
