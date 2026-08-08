import '../models/user.dart';
import '../repositories/auth_repository.dart';

class AuthPresenter {
  AuthRepository authRepository;

  AuthPresenter({
    required this.authRepository,
  });

  Future<User> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
    String bio = '',
  }) async {
    return authRepository.register(
      fullName: fullName,
      username: username,
      email: email,
      password: password,
      bio: bio,
    );
  }

  Future<User> login({
    required String email,
    required String password,
    int sessionDurationDays = 30,
  }) async {
    return authRepository.login(
      email: email,
      password: password,
      sessionDurationDays: sessionDurationDays,
    );
  }

  Future<User?> getCurrentUser() async {
    return authRepository.getCurrentUser();
  }

  Future<void> continueAsGuest() async {
    await authRepository.continueAsGuest();
  }

  bool isGuest() {
    return authRepository.isGuest();
  }

  Future<void> logout() async {
    await authRepository.logout();
  }
}
