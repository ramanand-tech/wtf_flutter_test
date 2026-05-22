import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/sync_config.dart';
import '../utils/app_logger.dart';
import '../utils/perf_tracker.dart';

class RtcTokenResponse {
  const RtcTokenResponse({
    required this.token,
    required this.roomId,
    required this.role,
    required this.userId,
  });

  final String token;
  final String roomId;
  final String role;
  final String userId;

  factory RtcTokenResponse.fromJson(Map<String, dynamic> json) {
    return RtcTokenResponse(
      token: json['token'] as String,
      roomId: json['roomId'] as String,
      role: json['role'] as String,
      userId: json['userId'] as String,
    );
  }
}

class RtcTokenService {
  RtcTokenService({String? baseUrl}) : _baseUrl = baseUrl ?? SyncConfig.defaultBaseUrl;

  final String _baseUrl;

  Future<RtcTokenResponse> fetchToken({
    required String userId,
    required String role,
    required String roomId,
  }) async {
    final uri = Uri.parse('$_baseUrl/token').replace(
      queryParameters: {
        'userId': userId,
        'role': role,
        'roomId': roomId,
      },
    );
    AppLogger.instance.log(LogTag.rtc, 'Fetching token for $userId as $role');
    PerfTracker.mark(PerfMarks.rtcJoin);
    final res = await http.get(uri).timeout(const Duration(seconds: 8));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      PerfTracker.report(PerfMarks.rtcJoin, budgetMs: PerfBudgets.rtcJoinMs);
      return RtcTokenResponse.fromJson(json);
    }
    final body = res.body;
    Map<String, dynamic>? err;
    try {
      err = jsonDecode(body) as Map<String, dynamic>?;
    } catch (_) {}
    final message = err?['error'] as String? ?? 'Token server error (${res.statusCode})';
    final hint = err?['hint'] as String?;
    throw RtcTokenException('$message${hint != null ? '\n$hint' : ''}');
  }
}

class RtcTokenException implements Exception {
  RtcTokenException(this.message);
  final String message;
  @override
  String toString() => message;
}
