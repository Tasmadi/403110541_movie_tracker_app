import '../repositories/auth_repository.dart';

class SplashPresenter {
  AuthRepository authRepository;

  SplashPresenter({
    required this.authRepository,
  });

  Future<bool> prepareApplication() async {
    await Future.delayed(
      const Duration(
        milliseconds: 900,
      ),
    );

    return authRepository.getCurrentUser().then((user) {
      return user != null;
    });
  }
}
