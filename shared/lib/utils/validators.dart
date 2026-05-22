/// Scheduler validation — no past date/time (assessment requirement).
class Validators {
  static String? scheduleNote(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please add a short note';
    }
    if (value.length > 140) {
      return 'Note must be 140 characters or less';
    }
    return null;
  }

  static bool isPastDateTime(DateTime scheduled) {
    return scheduled.isBefore(DateTime.now());
  }

  static bool hasSlotConflict({
    required DateTime scheduledFor,
    required List<DateTime> approvedSlots,
  }) {
    for (final slot in approvedSlots) {
      if (slot.year == scheduledFor.year &&
          slot.month == scheduledFor.month &&
          slot.day == scheduledFor.day &&
          slot.hour == scheduledFor.hour &&
          slot.minute == scheduledFor.minute) {
        return true;
      }
    }
    return false;
  }
}
