import 'package:flutter_test/flutter_test.dart';
import 'package:shared/utils/validators.dart';

void main() {
  test('scheduler rejects past datetime', () {
    final past = DateTime.now().subtract(const Duration(minutes: 5));
    expect(Validators.isPastDateTime(past), isTrue);
  });

  test('scheduler accepts future datetime', () {
    final future = DateTime.now().add(const Duration(hours: 2));
    expect(Validators.isPastDateTime(future), isFalse);
  });

  test('conflict blocks duplicate approved slot', () {
    final slot = DateTime(2030, 6, 15, 18, 0);
    expect(
      Validators.hasSlotConflict(
        scheduledFor: slot,
        approvedSlots: [DateTime(2030, 6, 15, 18, 0)],
      ),
      isTrue,
    );
  });
}
