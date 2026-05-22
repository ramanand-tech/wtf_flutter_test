import 'auth_service.dart';
import 'call_service.dart';
import 'chat_service.dart';
import 'chat_sync_client.dart';
import 'local_store.dart';
import 'log_service.dart';
import 'sync_config.dart';

/// Bundles all local services after [LocalStore.init].
class AppServices {
  AppServices._({
    required this.store,
    required this.auth,
    required this.chat,
    required this.calls,
    required this.logs,
  });

  final LocalStore store;
  final AuthService auth;
  final SyncChatService chat;
  final SyncCallService calls;
  final LogService logs;

  static AppServices? _instance;

  static AppServices get instance {
    final i = _instance;
    if (i == null) {
      throw StateError('Call AppServices.init() first');
    }
    return i;
  }

  static Future<AppServices> init({
    required String hiveBoxName,
    String? syncBaseUrl,
  }) async {
    final store = await LocalStore.init(boxName: hiveBoxName);
    final sync = ChatSyncClient(baseUrl: syncBaseUrl ?? SyncConfig.defaultBaseUrl);
    late final SyncCallService calls;
    final chat = SyncChatService(
      store,
      syncClient: sync,
      onPollTick: () => calls.pullRemote(),
    );
    calls = SyncCallService(store, chat, sync);
    chat.startPolling();
    _instance = AppServices._(
      store: store,
      auth: LocalAuthService(store),
      chat: chat,
      calls: calls,
      logs: LocalLogService(store),
    );
    return _instance!;
  }
}
