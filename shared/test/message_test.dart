import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/enums.dart';
import 'package:shared/models/message.dart';

void main() {
  test('Message serialization round-trip', () {
    final original = Message(
      id: 'msg_1',
      chatId: 'chat_dk_aarav',
      senderId: 'member_dk',
      receiverId: 'trainer_aarav',
      text: 'Hi Coach 👋',
      createdAt: DateTime(2026, 5, 23, 18, 0),
      status: MessageStatus.sent,
    );

    final restored = Message.fromJson(original.toJson());
    expect(restored.id, original.id);
    expect(restored.text, original.text);
    expect(restored.status, MessageStatus.sent);
    expect(restored.createdAt, original.createdAt);
  });
}
