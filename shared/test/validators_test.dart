import 'package:flutter_test/flutter_test.dart';
import 'package:shared/utils/extensions.dart';
import 'package:shared/utils/validators.dart';

void main() {
  test('rejects past schedule time', () {
    final past = DateTime.now().subtract(const Duration(hours: 1));
    expect(Validators.isPastDateTime(past), isTrue);
  });

  test('detects slot conflict', () {
    final slot = DateTime(2026, 5, 23, 18, 0);
    expect(
      Validators.hasSlotConflict(
        scheduledFor: slot,
        approvedSlots: [DateTime(2026, 5, 23, 18, 0)],
      ),
      isTrue,
    );
  });

  test('duration via extension', () {
    final start = DateTime(2026, 5, 23, 18, 0);
    final end = start.add(const Duration(minutes: 30));
    expect(start.durationSecondsTo(end), 1800);
  });
}
