import 'dart:io' show Platform;

/// Base URL for token_server sync (cross-app chat).
class SyncConfig {
  SyncConfig._();

  static String get defaultBaseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://127.0.0.1:3000';
  }
}
