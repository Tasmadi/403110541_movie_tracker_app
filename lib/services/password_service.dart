import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/helpers.dart';

class PasswordHashResult {
  String hash;
  String salt;

  PasswordHashResult({
    required this.hash,
    required this.salt,
  });
}

class PasswordService {
  final Argon2id algorithm = Argon2id(
    memory: 10000,
    parallelism: 1,
    iterations: 2,
    hashLength: 32,
  );

  Future<PasswordHashResult> hashPassword(
    String password,
  ) async {
    List<int> salt = randomBytes(16);

    SecretKey secretKey = await algorithm.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );

    List<int> hashBytes = await secretKey.extractBytes();

    return PasswordHashResult(
      hash: base64Encode(hashBytes),
      salt: base64Encode(salt),
    );
  }

  Future<bool> verifyPassword({
    required String password,
    required String storedHash,
    required String storedSalt,
  }) async {
    List<int> salt = base64Decode(storedSalt);

    List<int> expectedHash = base64Decode(storedHash);

    SecretKey secretKey = await algorithm.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );

    List<int> actualHash = await secretKey.extractBytes();

    return constantTimeBytesEquality.equals(
      actualHash,
      expectedHash,
    );
  }
}
