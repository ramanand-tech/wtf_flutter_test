import '../models/enums.dart';
import '../models/message.dart';
import '../models/user.dart';
import 'seed_data.dart';

class ChatSummary {
  const ChatSummary({
    required this.chatId,
    required this.peerId,
    required this.peerName,
    this.peerAvatarUrl,
    this.lastPreview,
    this.lastAt,
    this.unreadCount = 0,
  });

  final String chatId;
  final String peerId;
  final String peerName;
  final String? peerAvatarUrl;
  final String? lastPreview;
  final DateTime? lastAt;
  final int unreadCount;
}

List<ChatSummary> buildChatSummaries({
  required List<Message> messages,
  required String currentUserId,
  required UserRole currentRole,
}) {
  final peer = currentRole == UserRole.member ? SeedData.aarav : SeedData.dk;
  final chatId = SeedData.defaultChatId;
  final chatMessages = messages.where((m) => m.chatId == chatId).toList();
  if (chatMessages.isEmpty) {
    return [
      ChatSummary(
        chatId: chatId,
        peerId: peer.id,
        peerName: peer.name,
        peerAvatarUrl: peer.avatarUrl,
      ),
    ];
  }

  chatMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  final last = chatMessages.first;
  final unread = chatMessages
      .where((m) => m.receiverId == currentUserId && m.status != MessageStatus.read)
      .length;

  return [
    ChatSummary(
      chatId: chatId,
      peerId: peer.id,
      peerName: peer.name,
      peerAvatarUrl: peer.avatarUrl,
      lastPreview: last.isSystem ? last.text : last.text,
      lastAt: last.createdAt,
      unreadCount: unread,
    ),
  ];
}

User peerForRole(UserRole role) => role == UserRole.member ? SeedData.aarav : SeedData.dk;
