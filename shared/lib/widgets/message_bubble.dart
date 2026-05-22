import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/message.dart';
import '../utils/seed_data.dart';
import '../utils/theme.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.memberColor,
    required this.trainerColor,
  });

  final Message message;
  final bool isMine;
  final Color memberColor;
  final Color trainerColor;

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message.text,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final senderIsMember = message.senderId == SeedData.dkId;
    final bubbleColor = senderIsMember ? memberColor : trainerColor;
    final textColor = Colors.white;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(message.text, style: TextStyle(color: textColor, fontSize: 15)),
            if (isMine) ...[
              const SizedBox(height: 4),
              _StatusTicks(status: message.status, color: textColor.withValues(alpha: 0.85)),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusTicks extends StatelessWidget {
  const _StatusTicks({required this.status, required this.color});

  final MessageStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final icon = status == MessageStatus.read ? Icons.done_all : Icons.done;
    return Icon(icon, size: 14, color: color);
  }
}
