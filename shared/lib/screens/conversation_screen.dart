import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/message.dart';
import '../services/app_services.dart';
import '../utils/theme.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.currentUserId,
    required this.currentRole,
    required this.peerId,
    required this.peerName,
    required this.primaryColor,
    required this.chatId,
  });

  final String currentUserId;
  final UserRole currentRole;
  final String peerId;
  final String peerName;
  final Color primaryColor;
  final String chatId;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _peerTyping = false;
  static const _quickReplies = [
    'Got it 👍',
    'Can we talk at 6?',
    'Share plan?',
  ];

  @override
  void initState() {
    super.initState();
    _bindStreams();
    _markRead();
  }

  void _bindStreams() {
    final chat = AppServices.instance.chat;
    chat.watchMessages(widget.chatId).listen((msgs) {
      if (!mounted) return;
      setState(() => _messages = msgs);
      _scrollToBottom();
      _markRead();
    });
    chat.typingStream.listen((_) {
      if (!mounted) return;
      final remote = chat.remoteTyping;
      final show = remote != null &&
          remote.isActive &&
          remote.userId.isNotEmpty &&
          remote.userId != widget.currentUserId;
      setState(() => _peerTyping = show);
    });
  }

  Future<void> _markRead() async {
    await AppServices.instance.chat.markRead(widget.chatId, widget.currentUserId);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _inputController.clear();
    await AppServices.instance.chat.sendMessage(
      chatId: widget.chatId,
      senderId: widget.currentUserId,
      receiverId: widget.peerId,
      text: trimmed,
    );
  }

  Future<void> _onRefresh() async {
    await AppServices.instance.chat.pullRemote();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerName),
        actions: [
          IconButton(
            icon: Badge(
              label: const Text(' '),
              smallSize: 8,
              child: const Icon(Icons.videocam_outlined),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video call — Phase 6')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _messages.length + (_peerTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_peerTyping && index == _messages.length) {
                    return const TypingIndicator();
                  }
                  final msg = _messages[index];
                  final isMine = msg.senderId == widget.currentUserId;
                  return TweenAnimationBuilder<double>(
                    key: ValueKey(msg.id),
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, (1 - value) * 12),
                          child: child,
                        ),
                      );
                    },
                    child: MessageBubble(
                      message: msg,
                      isMine: isMine,
                      memberColor: AppColors.memberBubble,
                      trainerColor: AppColors.trainerBubble,
                    ),
                  );
                },
              ),
            ),
          ),
          if (_messages.isEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'No messages yet. Start the conversation.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: _quickReplies
                  .map(
                    (q) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(q),
                        onPressed: () => _send(q),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Material(
            elevation: 8,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Type a message…',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        onSubmitted: _send,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: widget.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _send(_inputController.text),
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
