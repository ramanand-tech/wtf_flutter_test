import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/app_logger.dart';

class TypingState {
  const TypingState({required this.chatId, required this.userId, required this.expiresAt});

  final String chatId;
  final String userId;
  final int expiresAt;

  bool get isActive => DateTime.now().millisecondsSinceEpoch < expiresAt;

  factory TypingState.fromJson(Map<String, dynamic>? json) {
    if (json == null || json['userId'] == null) {
      return const TypingState(chatId: '', userId: '', expiresAt: 0);
    }
    return TypingState(
      chatId: json['chatId'] as String? ?? '',
      userId: json['userId'] as String,
      expiresAt: json['expiresAt'] as int? ?? 0,
    );
  }
}

class ChatSyncClient {
  ChatSyncClient({required this.baseUrl});

  final String baseUrl;
  bool lastMessagesOk = true;
  bool lastCallsOk = true;
  bool lastSessionsOk = true;

  Future<List<Map<String, dynamic>>> fetchMessages() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/sync/messages')).timeout(
        const Duration(seconds: 3),
      );
      if (res.statusCode != 200) {
        lastMessagesOk = false;
        return [];
      }
      lastMessagesOk = true;
      final list = jsonDecode(res.body) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      lastMessagesOk = false;
      AppLogger.instance.log(LogTag.chat, 'Sync fetch failed: $e');
      return [];
    }
  }

  Future<void> pushMessages(List<Map<String, dynamic>> messages) async {
    try {
      await http
          .post(
            Uri.parse('$baseUrl/sync/messages'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'messages': messages}),
          )
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      AppLogger.instance.log(LogTag.chat, 'Sync push failed: $e');
    }
  }

  Future<void> broadcastTyping({required String chatId, required String userId}) async {
    try {
      await http
          .post(
            Uri.parse('$baseUrl/sync/typing'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'chatId': chatId, 'userId': userId}),
          )
          .timeout(const Duration(seconds: 2));
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> fetchCalls() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/sync/calls')).timeout(
        const Duration(seconds: 3),
      );
      if (res.statusCode != 200) {
        lastCallsOk = false;
        return [];
      }
      lastCallsOk = true;
      final list = jsonDecode(res.body) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      lastCallsOk = false;
      AppLogger.instance.log(LogTag.schedule, 'Sync calls fetch failed: $e');
      return [];
    }
  }

  Future<void> pushCalls(List<Map<String, dynamic>> calls) async {
    try {
      await http
          .post(
            Uri.parse('$baseUrl/sync/calls'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'callRequests': calls}),
          )
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      AppLogger.instance.log(LogTag.schedule, 'Sync calls push failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchSessions() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/sync/sessions')).timeout(
        const Duration(seconds: 3),
      );
      if (res.statusCode != 200) {
        lastSessionsOk = false;
        return [];
      }
      lastSessionsOk = true;
      final list = jsonDecode(res.body) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      lastSessionsOk = false;
      AppLogger.instance.log(LogTag.rtc, 'Sync sessions fetch failed: $e');
      return [];
    }
  }

  Future<void> pushSessions(List<Map<String, dynamic>> sessions) async {
    try {
      await http
          .post(
            Uri.parse('$baseUrl/sync/sessions'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'sessionLogs': sessions}),
          )
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      AppLogger.instance.log(LogTag.rtc, 'Sync sessions push failed: $e');
    }
  }

  Future<TypingState> fetchTyping() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/sync/typing')).timeout(
        const Duration(seconds: 2),
      );
      if (res.statusCode != 200) return const TypingState(chatId: '', userId: '', expiresAt: 0);
      final json = jsonDecode(res.body) as Map<String, dynamic>?;
      return TypingState.fromJson(json);
    } catch (_) {
      return const TypingState(chatId: '', userId: '', expiresAt: 0);
    }
  }
}
