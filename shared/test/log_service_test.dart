import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/session_log.dart';
import 'package:shared/utils/extensions.dart';

void main() {
  group('Session log duration (Phase 11)', () {
    test('durationSec from startedAt/endedAt via extension', () {
      final start = DateTime(2026, 5, 23, 18, 0);
      final end = start.add(const Duration(minutes: 45));
      expect(start.durationSecondsTo(end), 2700);
    });

    test('SessionLog stores durationSec on create shape', () {
      final start = DateTime(2026, 5, 23, 10, 0);
      final end = start.add(const Duration(seconds: 90));
      final log = SessionLog(
        id: 's1',
        memberId: 'dk',
        trainerId: 'aarav',
        startedAt: start,
        endedAt: end,
        durationSec: start.durationSecondsTo(end),
      );
      expect(log.durationSec, 90);
      final roundTrip = SessionLog.fromJson(log.toJson());
      expect(roundTrip.durationSec, 90);
    });
  });
}
