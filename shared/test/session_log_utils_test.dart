import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/session_log.dart';
import 'package:shared/utils/extensions.dart';
import 'package:shared/utils/session_log_utils.dart';

void main() {
  test('durationSecondsTo matches session log duration', () {
    final start = DateTime(2026, 5, 23, 10, 0);
    final end = start.add(const Duration(minutes: 30));
    expect(start.durationSecondsTo(end), 1800);
  });

  test('filterSessionLogs last7Days and thisMonth', () {
    final now = DateTime(2026, 5, 23, 12);
    final logs = [
      SessionLog(
        id: '1',
        memberId: 'm',
        trainerId: 't',
        startedAt: now.subtract(const Duration(days: 2)),
        endedAt: now.subtract(const Duration(days: 2, minutes: -30)),
        durationSec: 1800,
      ),
      SessionLog(
        id: '2',
        memberId: 'm',
        trainerId: 't',
        startedAt: now.subtract(const Duration(days: 10)),
        endedAt: now.subtract(const Duration(days: 10, minutes: -20)),
        durationSec: 1200,
      ),
      SessionLog(
        id: '3',
        memberId: 'm',
        trainerId: 't',
        startedAt: DateTime(2026, 4, 15),
        endedAt: DateTime(2026, 4, 15, 0, 45),
        durationSec: 2700,
      ),
    ];

    expect(filterSessionLogs(logs, SessionLogFilter.all).length, 3);
    expect(filterSessionLogs(logs, SessionLogFilter.last7Days).length, 1);
    expect(filterSessionLogs(logs, SessionLogFilter.thisMonth).length, 2);
  });

  test('formatDurationSec and share text', () {
    expect(formatDurationSec(45), '45s');
    expect(formatDurationSec(125), '2m 5s');
    final log = SessionLog(
      id: 'x',
      memberId: 'dk',
      trainerId: 'aarav',
      startedAt: DateTime(2026, 5, 23, 10),
      endedAt: DateTime(2026, 5, 23, 10, 30),
      durationSec: 1800,
      rating: 4,
      memberNotes: 'Great session',
      trainerNotes: 'Focus on form',
    );
    final text = sessionLogShareText(log);
    expect(text, contains('4/5'));
    expect(text, contains('Great session'));
    expect(text, contains('Focus on form'));
  });
}
