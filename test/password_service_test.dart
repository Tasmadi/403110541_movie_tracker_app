import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tracker_app/services/password_service.dart';

void main() {
  test(
    'Password hash can be verified',
    () async {
      PasswordService service = PasswordService();

      PasswordHashResult result = await service.hashPassword(
        'StrongPassword123',
      );

      expect(
        result.hash,
        isNotEmpty,
      );

      expect(
        result.salt,
        isNotEmpty,
      );

      expect(
        result.hash,
        isNot(
          'StrongPassword123',
        ),
      );

      bool valid = await service.verifyPassword(
        password: 'StrongPassword123',
        storedHash: result.hash,
        storedSalt: result.salt,
      );

      expect(
        valid,
        true,
      );
    },
  );

  test(
    'Wrong password is rejected',
    () async {
      PasswordService service = PasswordService();

      PasswordHashResult result = await service.hashPassword(
        'CorrectPassword123',
      );

      bool valid = await service.verifyPassword(
        password: 'WrongPassword',
        storedHash: result.hash,
        storedSalt: result.salt,
      );

      expect(
        valid,
        false,
      );
    },
  );
}
