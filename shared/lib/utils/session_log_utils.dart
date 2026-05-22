import 'package:intl/intl.dart';

import '../models/session_log.dart';

enum SessionLogFilter { all, last7Days, thisMonth }

List<SessionLog> filterSessionLogs(List<SessionLog> logs, SessionLogFilter filter) {
  final now = DateTime.now();
  return logs.where((log) {
    switch (filter) {
      case SessionLogFilter.all:
        return true;
      case SessionLogFilter.last7Days:
        return log.startedAt.isAfter(now.subtract(const Duration(days: 7)));
      case SessionLogFilter.thisMonth:
        return log.startedAt.year == now.year && log.startedAt.month == now.month;
    }
  }).toList();
}

String formatDurationSec(int seconds) {
  if (seconds < 60) return '${seconds}s';
  final m = seconds ~/ 60;
  final s = seconds % 60;
  if (m < 60) return s > 0 ? '${m}m ${s}s' : '${m}m';
  final h = m ~/ 60;
  final rm = m % 60;
  return '${h}h ${rm}m';
}

String sessionLogShareText(SessionLog log) {
  final date = DateFormat('MMM d, yyyy h:mm a').format(log.startedAt);
  final buffer = StringBuffer()
    ..writeln('WTF Session Summary')
    ..writeln('Date: $date')
    ..writeln('Duration: ${formatDurationSec(log.durationSec)}');
  if (log.rating != null) buffer.writeln('Rating: ${log.rating}/5');
  if (log.memberNotes != null && log.memberNotes!.isNotEmpty) {
    buffer.writeln('Member note: ${log.memberNotes}');
  }
  if (log.trainerNotes != null && log.trainerNotes!.isNotEmpty) {
    buffer.writeln('Trainer notes: ${log.trainerNotes}');
  }
  return buffer.toString().trim();
}
