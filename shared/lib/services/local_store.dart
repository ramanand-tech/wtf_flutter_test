import 'dart:async';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Local-first persistence + broadcast streams for cross-screen updates.
class LocalStore {
  static LocalStore? _instance;

  static Future<LocalStore> init({required String boxName}) async {
    if (_instance != null) return _instance!;
    await Hive.initFlutter();
    final box = await Hive.openBox<String>(boxName);
    _instance = LocalStore._(box);
    return _instance!;
  }

  LocalStore._(this._box);

  final Box<String> _box;
  final _messageController = StreamController<void>.broadcast();
  final _callController = StreamController<void>.broadcast();
  final _sessionController = StreamController<void>.broadcast();

  Stream<void> get onMessagesChanged => _messageController.stream;
  Stream<void> get onCallsChanged => _callController.stream;
  Stream<void> get onSessionsChanged => _sessionController.stream;

  static const _messagesKey = 'messages';
  static const _callsKey = 'call_requests';
  static const _sessionsKey = 'session_logs';
  static const _roomsKey = 'room_meta';
  static const _currentUserKey = 'current_user';
  static const _onboardingKey = 'onboarding_done';

  void _notifyMessages() => _messageController.add(null);
  void _notifyCalls() => _callController.add(null);
  void _notifySessions() => _sessionController.add(null);

  List<Map<String, dynamic>> _readList(String key) {
    final raw = _box.get(key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> _writeList(String key, List<Map<String, dynamic>> list) async {
    await _box.put(key, jsonEncode(list));
  }

  // --- Messages ---
  List<Map<String, dynamic>> get messages => _readList(_messagesKey);

  Future<void> setMessages(List<Map<String, dynamic>> list) async {
    await _writeList(_messagesKey, list);
    _notifyMessages();
  }

  // --- Calls ---
  List<Map<String, dynamic>> get callRequests => _readList(_callsKey);

  Future<void> setCallRequests(List<Map<String, dynamic>> list) async {
    await _writeList(_callsKey, list);
    _notifyCalls();
  }

  // --- Sessions ---
  List<Map<String, dynamic>> get sessionLogs => _readList(_sessionsKey);

  Future<void> setSessionLogs(List<Map<String, dynamic>> list) async {
    await _writeList(_sessionsKey, list);
    _notifySessions();
  }

  // --- Rooms ---
  List<Map<String, dynamic>> get roomMeta => _readList(_roomsKey);

  Future<void> setRoomMeta(List<Map<String, dynamic>> list) async {
    await _writeList(_roomsKey, list);
  }

  // --- Auth ---
  Map<String, dynamic>? get currentUserJson {
    final raw = _box.get(_currentUserKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> setCurrentUser(Map<String, dynamic>? user) async {
    if (user == null) {
      await _box.delete(_currentUserKey);
    } else {
      await _box.put(_currentUserKey, jsonEncode(user));
    }
  }

  bool get onboardingDone => _box.get(_onboardingKey) == 'true';

  Future<void> setOnboardingDone(bool value) async {
    await _box.put(_onboardingKey, value.toString());
  }
}
