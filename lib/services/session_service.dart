import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionService {
  static const String userIdKey = 'current_user_id';

  static const String expiresAtKey = 'session_expires_at';

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> createSession({
    required int userId,
    int durationDays = 30,
  }) async {
    DateTime expirationDate = DateTime.now().add(
      Duration(
        days: durationDays,
      ),
    );

    await storage.write(
      key: userIdKey,
      value: userId.toString(),
    );

    await storage.write(
      key: expiresAtKey,
      value: expirationDate.toIso8601String(),
    );
  }

  Future<int?> getCurrentUserId() async {
    String? userIdValue = await storage.read(
      key: userIdKey,
    );

    String? expirationValue = await storage.read(
      key: expiresAtKey,
    );

    if (userIdValue == null || expirationValue == null) {
      return null;
    }

    int? userId = int.tryParse(userIdValue);

    DateTime? expirationDate = DateTime.tryParse(
      expirationValue,
    );

    if (userId == null || expirationDate == null) {
      await clearSession();

      return null;
    }

    if (DateTime.now().isAfter(
      expirationDate,
    )) {
      await clearSession();

      return null;
    }

    return userId;
  }

  Future<bool> hasActiveSession() async {
    int? userId = await getCurrentUserId();

    return userId != null;
  }

  Future<void> clearSession() async {
    await storage.delete(
      key: userIdKey,
    );

    await storage.delete(
      key: expiresAtKey,
    );
  }
}
