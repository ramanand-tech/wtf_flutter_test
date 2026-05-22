import '../models/user.dart';
import '../utils/app_logger.dart';
import '../utils/seed_data.dart';
import 'local_store.dart';

abstract class AuthService {
  Future<User?> getCurrentUser();
  Future<void> completeOnboarding({required User member, required String trainerId});
  Future<void> loginTrainer(User trainer);
  Future<void> logout();
  bool get isOnboardingDone;
}

class LocalAuthService implements AuthService {
  LocalAuthService(this._store);

  final LocalStore _store;

  @override
  bool get isOnboardingDone => _store.onboardingDone;

  @override
  Future<User?> getCurrentUser() async {
    final json = _store.currentUserJson;
    if (json == null) return null;
    return User.fromJson(json);
  }

  @override
  Future<void> completeOnboarding({
    required User member,
    required String trainerId,
  }) async {
    final user = member.copyWith(assignedTrainerId: trainerId);
    await _store.setCurrentUser(user.toJson());
    await _store.setOnboardingDone(true);
    AppLogger.instance.log(LogTag.auth, 'Onboarding complete for ${user.name}');
  }

  @override
  Future<void> loginTrainer(User trainer) async {
    await _store.setCurrentUser(trainer.toJson());
    await _store.setOnboardingDone(true);
    AppLogger.instance.log(LogTag.auth, 'Trainer login: ${trainer.name}');
  }

  @override
  Future<void> logout() async {
    await _store.setCurrentUser(null);
    AppLogger.instance.log(LogTag.auth, 'Logged out');
  }
}

/// Guru app uses DK; trainer uses Aarav seed.
User getDefaultUserForApp({required bool isGuruApp}) {
  return isGuruApp ? SeedData.dk : SeedData.aarav;
}
