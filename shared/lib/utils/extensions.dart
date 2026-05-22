import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime {
  String toRelativeTime() {
    final diff = DateTime.now().difference(this);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(this);
  }

  String toScheduleLabel() {
    return DateFormat('MMM d, h:mm a').format(this);
  }
}

extension DurationCalc on DateTime {
  int durationSecondsTo(DateTime end) {
    return end.difference(this).inSeconds;
  }
}
