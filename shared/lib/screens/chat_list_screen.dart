import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/message.dart';
import '../services/app_services.dart';
import '../utils/app_page_route.dart';
import '../utils/chat_helpers.dart';
import '../utils/extensions.dart';
import '../utils/seed_data.dart';
import '../utils/spacing.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_skeleton.dart';
import 'conversation_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({
    super.key,
    required this.currentUserId,
    required this.currentRole,
    required this.primaryColor,
    required this.appBarBadge,
  });

  final String currentUserId;
  final UserRole currentRole;
  final Color primaryColor;
  final String appBarBadge;

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Message> _messages = [];
  bool _loading = true;
  bool _syncError = false;

  @override
  void initState() {
    super.initState();
    _listen();
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  void _listen() {
    AppServices.instance.chat.watchMessages(SeedData.defaultChatId).listen((msgs) {
      if (mounted) {
        setState(() {
          _messages = msgs;
          _loading = false;
        });
      }
    });
  }

  void _openConversation({ChatSummary? summary}) {
    final peer = peerForRole(widget.currentRole);
    Navigator.of(context).push(
      appPageRoute(
        ConversationScreen(
          currentUserId: widget.currentUserId,
          currentRole: widget.currentRole,
          peerId: peer.id,
          peerName: peer.name,
          primaryColor: widget.primaryColor,
          chatId: SeedData.defaultChatId,
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    await AppServices.instance.chat.pullRemote();
    if (!mounted) return;
    setState(() {
      _syncError = !AppServices.instance.syncClient.lastMessagesOk;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_syncError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chats')),
        body: ErrorState(
          message: 'Could not reach the sync server. Start token_server and retry.',
          onRetry: () async {
            setState(() => _syncError = false);
            await _refresh();
          },
        ),
      );
    }

    final summaries = buildChatSummaries(
      messages: _messages,
      currentUserId: widget.currentUserId,
      currentRole: widget.currentRole,
    );
    final hasMessages = _messages.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Center(
              child: Text(
                widget.appBarBadge,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openConversation(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const ChatListSkeleton()
          : RefreshIndicator(
              onRefresh: _refresh,
              child: hasMessages
                  ? ListView.builder(
                      itemCount: summaries.length,
                      itemBuilder: (_, i) {
                        final s = summaries[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: s.peerAvatarUrl != null
                                ? NetworkImage(s.peerAvatarUrl!)
                                : null,
                            child: s.peerAvatarUrl == null ? Text(s.peerName[0]) : null,
                          ),
                          title: Text(
                            s.peerName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            s.lastPreview ?? 'No messages yet. Start the conversation.',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (s.lastAt != null)
                                Text(
                                  s.lastAt!.toRelativeTime(),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              if (s.unreadCount > 0) ...[
                                const SizedBox(height: AppSpacing.xs / 2),
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: widget.primaryColor,
                                  child: Text(
                                    '${s.unreadCount}',
                                    style: const TextStyle(color: Colors.white, fontSize: 11),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          onTap: () => _openConversation(summary: s),
                        );
                      },
                    )
                  : ListView(
                      children: [
                        SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                        EmptyState(
                          title: 'No messages yet',
                          subtitle: 'No messages yet. Start the conversation.',
                          actionLabel: 'Say hi',
                          onAction: () => _openConversation(),
                        ),
                      ],
                    ),
            ),
    );
  }
}
