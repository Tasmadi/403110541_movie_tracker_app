import 'dart:math';

import 'package:sqflite/sqflite.dart';

import 'database_service.dart';
import 'email_service.dart';
import 'password_service.dart';
import 'session_service.dart';

class PasswordResetService {
  final DatabaseService databaseService;
  final EmailService emailService;
  final PasswordService passwordService;
  final SessionService sessionService;

  final Map<String, _PasswordResetRequest> _requests = {};

  PasswordResetService({
    required this.databaseService,
    required this.emailService,
    required this.passwordService,
    required this.sessionService,
  });

  Future<void> requestCode(
    String email,
  ) async {
    String normalizedEmail = email.trim().toLowerCase();

    if (!_isValidEmail(
      normalizedEmail,
    )) {
      throw Exception(
        'ایمیل واردشده معتبر نیست.',
      );
    }

    DateTime now = DateTime.now();

    _PasswordResetRequest? oldRequest = _requests[normalizedEmail];

    if (oldRequest != null) {
      Duration difference = now.difference(
        oldRequest.lastSentAt,
      );

      if (difference.inSeconds < 60) {
        int remaining = 60 - difference.inSeconds;

        throw Exception(
          'برای ارسال مجدد کد $remaining ثانیه صبر کنید.',
        );
      }
    }

    Database db = await databaseService.getDatabase();

    List<Map<String, dynamic>> users = await db.query(
      'users',
      columns: [
        'id',
        'username',
        'email',
      ],
      where: 'email = ?',
      whereArgs: [
        normalizedEmail,
      ],
      limit: 1,
    );

    if (users.isEmpty) {
      throw Exception(
        'کاربری با این ایمیل پیدا نشد.',
      );
    }

    Map<String, dynamic> user = users.first;

    String code = _generateCode();

    await emailService.sendPasswordResetCode(
      email: normalizedEmail,
      username: user['username'] ?? 'User',
      code: code,
    );

    _requests[normalizedEmail] = _PasswordResetRequest(
      code: code,
      createdAt: now,
      expiresAt: now.add(
        const Duration(
          minutes: 10,
        ),
      ),
      lastSentAt: now,
      attempts: 0,
      verified: false,
    );
  }

  Future<void> verifyCode({
    required String email,
    required String code,
  }) async {
    String normalizedEmail = email.trim().toLowerCase();

    String normalizedCode = code.trim();

    if (normalizedCode.length != 6) {
      throw Exception(
        'کد بازیابی باید ۶ رقمی باشد.',
      );
    }

    _PasswordResetRequest? request = _requests[normalizedEmail];

    if (request == null) {
      throw Exception(
        'درخواست بازیابی پیدا نشد. کد جدید دریافت کنید.',
      );
    }

    if (DateTime.now().isAfter(
      request.expiresAt,
    )) {
      _requests.remove(
        normalizedEmail,
      );

      throw Exception(
        'کد بازیابی منقضی شده است. کد جدید دریافت کنید.',
      );
    }

    if (request.attempts >= 5) {
      throw Exception(
        'تعداد تلاش‌های ناموفق بیش از حد مجاز است. کد جدید دریافت کنید.',
      );
    }

    if (request.code != normalizedCode) {
      request.attempts++;

      int remaining = 5 - request.attempts;

      if (remaining <= 0) {
        throw Exception(
          'تعداد تلاش‌های ناموفق بیش از حد مجاز است. کد جدید دریافت کنید.',
        );
      }

      throw Exception(
        'کد واردشده صحیح نیست. $remaining تلاش باقی مانده است.',
      );
    }

    request.verified = true;
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    String normalizedEmail = email.trim().toLowerCase();

    _PasswordResetRequest? request = _requests[normalizedEmail];

    if (request == null) {
      throw Exception(
        'درخواست بازیابی معتبر نیست.',
      );
    }

    if (DateTime.now().isAfter(
      request.expiresAt,
    )) {
      _requests.remove(
        normalizedEmail,
      );

      throw Exception(
        'زمان بازیابی رمز عبور به پایان رسیده است.',
      );
    }

    if (!request.verified) {
      throw Exception(
        'ابتدا کد ارسال‌شده به ایمیل را تأیید کنید.',
      );
    }

    if (newPassword.length < 8) {
      throw Exception(
        'رمز عبور باید حداقل ۸ کاراکتر باشد.',
      );
    }

    Database db = await databaseService.getDatabase();

    List<Map<String, dynamic>> users = await db.query(
      'users',
      columns: [
        'id',
      ],
      where: 'email = ?',
      whereArgs: [
        normalizedEmail,
      ],
      limit: 1,
    );

    if (users.isEmpty) {
      throw Exception(
        'حساب کاربری پیدا نشد.',
      );
    }

    int userId = users.first['id'] as int;

    final passwordResult = await passwordService.hashPassword(
      newPassword,
    );

    await db.update(
      'users',
      {
        'password_hash': passwordResult.hash,
        'password_salt': passwordResult.salt,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [
        userId,
      ],
    );

    _requests.remove(
      normalizedEmail,
    );

    await sessionService.clearSession();
  }

  bool _isValidEmail(
    String email,
  ) {
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(
      email,
    );
  }

  String _generateCode() {
    Random random = Random.secure();

    int value = 100000 +
        random.nextInt(
          900000,
        );

    return value.toString();
  }
}

class _PasswordResetRequest {
  String code;

  DateTime createdAt;
  DateTime expiresAt;
  DateTime lastSentAt;

  int attempts;

  bool verified;

  _PasswordResetRequest({
    required this.code,
    required this.createdAt,
    required this.expiresAt,
    required this.lastSentAt,
    required this.attempts,
    required this.verified,
  });
}
