import 'package:flutter/foundation.dart';

enum LogTag { auth, chat, rtc, schedule }

extension LogTagLabel on LogTag {
  /// DevPanel tags: [AUTH], [CHAT], [RTC], [SCHEDULE]
  String get bracket => '[${name.toUpperCase()}]';
}

class LogEntry {
  const LogEntry({
    required this.at,
    required this.tag,
    required this.message,
  });

  final DateTime at;
  final LogTag tag;
  final String message;

  String get line => '${at.toIso8601String()} ${tag.bracket} $message';
}

/// Structured in-app logs for DevPanel (last 20 entries).
class AppLogger {
  AppLogger._();
  static final AppLogger instance = AppLogger._();

  final List<LogEntry> _entries = [];
  static const int maxEntries = 20;

  List<LogEntry> get logEntries => List.unmodifiable(_entries);

  /// Legacy string lines (newest last).
  List<String> get entries => _entries.map((e) => e.line).toList();

  List<LogEntry> entriesForTag(LogTag? tag) {
    if (tag == null) return logEntries;
    return logEntries.where((e) => e.tag == tag).toList();
  }

  void log(LogTag tag, String message) {
    final entry = LogEntry(at: DateTime.now(), tag: tag, message: message);
    debugPrint(entry.line);
    _entries.add(entry);
    if (_entries.length > maxEntries) {
      _entries.removeAt(0);
    }
  }

  void clear() => _entries.clear();
}
