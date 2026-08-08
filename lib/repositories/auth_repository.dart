import 'package:sqflite/sqflite.dart';

import '../models/user.dart';
import '../services/database_service.dart';
import '../services/password_service.dart';
import '../services/session_service.dart';

class AuthRepository {
  DatabaseService databaseService;
  PasswordService passwordService;
  SessionService sessionService;

  AuthRepository({
    required this.databaseService,
    required this.passwordService,
    required this.sessionService,
  });

  Future<User> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
    String bio = '',
  }) async {
    Database db = await databaseService.getDatabase();

    String normalizedUsername = username.trim().toLowerCase();

    String normalizedEmail = email.trim().toLowerCase();

    List<Map<String, dynamic>> existingUsers = await db.query(
      'users',
      where: 'username = ? OR email = ?',
      whereArgs: [
        normalizedUsername,
        normalizedEmail,
      ],
      limit: 1,
    );

    if (existingUsers.isNotEmpty) {
      Map<String, dynamic> existing = existingUsers.first;

      if (existing['email'] == normalizedEmail) {
        throw Exception(
          'این ایمیل قبلاً ثبت شده است.',
        );
      }

      throw Exception(
        'این نام کاربری قبلاً ثبت شده است.',
      );
    }

    PasswordHashResult passwordResult = await passwordService.hashPassword(
      password,
    );

    String now = DateTime.now().toIso8601String();

    int userId = await db.insert(
      'users',
      {
        'full_name': fullName.trim(),
        'username': normalizedUsername,
        'email': normalizedEmail,
        'password_hash': passwordResult.hash,
        'password_salt': passwordResult.salt,
        'profile_image_path': null,
        'bio': bio.trim(),
        'created_at': now,
        'updated_at': now,
      },
    );

    await sessionService.createSession(
      userId: userId,
    );

    return User(
      id: userId,
      fullName: fullName.trim(),
      username: normalizedUsername,
      email: normalizedEmail,
      profileImagePath: null,
      bio: bio.trim(),
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<User> login({
    required String email,
    required String password,
    int sessionDurationDays = 30,
  }) async {
    Database db = await databaseService.getDatabase();

    String normalizedEmail = email.trim().toLowerCase();

    List<Map<String, dynamic>> rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [
        normalizedEmail,
      ],
      limit: 1,
    );

    if (rows.isEmpty) {
      throw Exception(
        'ایمیل یا رمز عبور صحیح نیست.',
      );
    }

    Map<String, dynamic> row = rows.first;

    bool passwordIsValid = await passwordService.verifyPassword(
      password: password,
      storedHash: row['password_hash'],
      storedSalt: row['password_salt'],
    );

    if (!passwordIsValid) {
      throw Exception(
        'ایمیل یا رمز عبور صحیح نیست.',
      );
    }

    int userId = row['id'];

    await sessionService.createSession(
      userId: userId,
      durationDays: sessionDurationDays,
    );

    return User.fromMap(row);
  }

  Future<User?> getCurrentUser() async {
    int? userId = await sessionService.getCurrentUserId();

    if (userId == null) {
      return null;
    }

    Database db = await databaseService.getDatabase();

    List<Map<String, dynamic>> rows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [
        userId,
      ],
      limit: 1,
    );

    if (rows.isEmpty) {
      await sessionService.clearSession();

      return null;
    }

    return User.fromMap(
      rows.first,
    );
  }

  Future<void> continueAsGuest() async {
    await sessionService.startGuestSession();
  }

  bool isGuest() {
    return sessionService.isGuest;
  }

  Future<void> logout() async {
    await sessionService.clearSession();
  }
}
