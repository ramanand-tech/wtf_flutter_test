import 'dart:async';

import '../models/enums.dart';
import '../models/message.dart';
import '../utils/app_logger.dart';
import '../utils/perf_tracker.dart';
import '../utils/seed_data.dart';
import 'chat_sync_client.dart';
import 'local_store.dart';

abstract class ChatService {
  Stream<List<Message>> watchMessages(String chatId);
  Stream<bool> get typingStream;
  Future<Message> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
    bool isSystem = false,
  });
  Future<void> markRead(String chatId, String readerId);
  Future<void> pullRemote();
  void startPolling();
  void stopPolling();
}

class SyncChatService implements ChatService {
  SyncChatService(
    this._store, {
    required ChatSyncClient syncClient,
    Future<void> Function()? onPollTick,
  })  : _sync = syncClient,
        _onPollTick = onPollTick;

  final LocalStore _store;
  final ChatSyncClient _sync;
  final Future<void> Function()? _onPollTick;
  final _typingController = StreamController<bool>.broadcast();
  Timer? _pollTimer;
  TypingState? _remoteTyping;

  /// Latest typing state from sync server.
  TypingState? get remoteTyping => _remoteTyping;

  @override
  Stream<bool> get typingStream => _typingController.stream;

  List<Message> _all() {
    return _store.messages.map(Message.fromJson).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      unawaited(_pull());
    });
    unawaited(_pull());
  }

  @override
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  Future<void> pullRemote() => _pull();

  Future<void> _pull() async {
    final remote = await _sync.fetchMessages();
    if (remote.isNotEmpty) {
      await _mergeMessages(remote);
    }
    _remoteTyping = await _sync.fetchTyping();
    final active = _remoteTyping!.isActive && _remoteTyping!.userId.isNotEmpty;
    _typingController.add(active);
    await _onPollTick?.call();
  }

  Future<void> _mergeMessages(List<Map<String, dynamic>> remote) async {
    final byId = <String, Map<String, dynamic>>{
      for (final m in _store.messages) m['id'] as String: m,
    };
    var changed = false;
    for (final r in remote) {
      final id = r['id'] as String;
      final existing = byId[id];
      if (existing == null) {
        byId[id] = r;
        changed = true;
        _logPeerSyncLatency(r);
      } else {
        final existingMsg = Message.fromJson(existing);
        final remoteMsg = Message.fromJson(r);
        if (remoteMsg.createdAt.isAfter(existingMsg.createdAt) ||
            remoteMsg.status.index > existingMsg.status.index) {
          byId[id] = r;
          changed = true;
        }
      }
    }
    if (!changed) return;
    final merged = byId.values.toList()
      ..sort((a, b) {
        final ad = DateTime.parse(a['createdAt'] as String);
        final bd = DateTime.parse(b['createdAt'] as String);
        return ad.compareTo(bd);
      });
    await _store.setMessages(merged);
  }

  void _logPeerSyncLatency(Map<String, dynamic> raw) {
    final createdRaw = raw['createdAt'] as String?;
    if (createdRaw == null) return;
    final created = DateTime.tryParse(createdRaw);
    if (created == null) return;
    final ms = DateTime.now().difference(created).inMilliseconds;
    PerfTracker.logInstant(
      'peer_message_sync',
      ms,
      budgetMs: PerfBudgets.chatPeerMs,
    );
  }

  Future<void> _pushLocal() async {
    await _sync.pushMessages(_store.messages);
  }

  @override
  Stream<List<Message>> watchMessages(String chatId) async* {
    yield _all().where((m) => m.chatId == chatId).toList();
    await for (final _ in _store.onMessagesChanged) {
      yield _all().where((m) => m.chatId == chatId).toList();
    }
  }

  @override
  Future<Message> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
    bool isSystem = false,
  }) async {
    final msg = Message(
      id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
      chatId: chatId,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
      isSystem: isSystem,
    );
    final list = _store.messages..add(msg.toJson());
    await _store.setMessages(list);
    AppLogger.instance.log(LogTag.chat, 'Sent: $text');

    if (!isSystem) {
      await _sync.broadcastTyping(chatId: chatId, userId: senderId);
      await Future<void>.delayed(
        Duration(milliseconds: 400 + (DateTime.now().millisecond % 400)),
      );
    }
    await _pushLocal();
    return msg;
  }

  @override
  Future<void> markRead(String chatId, String readerId) async {
    final updated = _all().map((m) {
      if (m.chatId == chatId &&
          m.receiverId == readerId &&
          m.status != MessageStatus.read) {
        return m.copyWith(status: MessageStatus.read);
      }
      return m;
    }).map((m) => m.toJson()).toList();
    await _store.setMessages(updated);
    await _pushLocal();
  }
}

String defaultChatId() => SeedData.defaultChatId;
