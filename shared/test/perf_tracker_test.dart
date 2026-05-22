import 'package:flutter_test/flutter_test.dart';
import 'package:shared/utils/app_logger.dart';
import 'package:shared/utils/perf_tracker.dart';

void main() {
  test('PerfTracker reports OK when under budget', () {
    AppLogger.instance.clear();
    PerfTracker.mark(PerfMarks.coldStart);
    PerfTracker.report(PerfMarks.coldStart, budgetMs: PerfBudgets.coldStartMs);
    expect(AppLogger.instance.logEntries.last.tag, LogTag.perf);
    expect(AppLogger.instance.logEntries.last.message, contains('OK'));
  });

  test('PerfTracker logInstant flags slow peer budget', () {
    AppLogger.instance.clear();
    PerfTracker.logInstant('peer_message_sync', 900, budgetMs: PerfBudgets.chatPeerMs);
    expect(AppLogger.instance.logEntries.last.message, contains('SLOW'));
  });
}
