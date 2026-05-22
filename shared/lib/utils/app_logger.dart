import 'package:flutter/foundation.dart';

enum LogTag { auth, chat, rtc, schedule }

/// Structured in-app logs for DevPanel (last 20 entries).
class AppLogger {
  AppLogger._();
  static final AppLogger instance = AppLogger._();

  final List<String> _entries = [];
  static const int maxEntries = 20;

  List<String> get entries => List.unmodifiable(_entries);

  void log(LogTag tag, String message) {
    final line = '[${tag.name.toUpperCase()}] $message';
    debugPrint(line);
    _entries.add('${DateTime.now().toIso8601String()} $line');
    if (_entries.length > maxEntries) {
      _entries.removeAt(0);
    }
  }

  void clear() => _entries.clear();
}
