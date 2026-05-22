import '../models/enums.dart';
import '../models/user.dart';

/// Pre-seeded users for assessment (DK + Aarav).
class SeedData {
  static const String dkId = 'member_dk';
  static const String aaravId = 'trainer_aarav';
  static const String defaultChatId = 'chat_dk_aarav';

  static const User dk = User(
    id: dkId,
    role: UserRole.member,
    name: 'DK',
    email: 'dk@wtf.local',
    avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=DK',
    assignedTrainerId: aaravId,
  );

  static const User aarav = User(
    id: aaravId,
    role: UserRole.trainer,
    name: 'Aarav (Lead Trainer)',
    email: 'aarav@wtf.local',
    avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Aarav',
  );

  static const List<User> trainers = [aarav];

  static User? findUser(String id) {
    if (id == dkId) return dk;
    if (id == aaravId) return aarav;
    return null;
  }
}
