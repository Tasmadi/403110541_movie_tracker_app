import '../services/password_reset_service.dart';

class PasswordResetPresenter {
  final PasswordResetService service;

  PasswordResetPresenter({
    required this.service,
  });

  Future<void> requestCode(
    String email,
  ) {
    return service.requestCode(
      email,
    );
  }

  Future<void> verifyCode({
    required String email,
    required String code,
  }) {
    return service.verifyCode(
      email: email,
      code: code,
    );
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) {
    return service.resetPassword(
      email: email,
      newPassword: newPassword,
    );
  }
}
