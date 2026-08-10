import 'package:sqflite/sqflite.dart';

import '../models/user_media_item.dart';
import '../services/database_service.dart';
import '../services/session_service.dart';

class UserMediaRepository {
  DatabaseService databaseService;
  SessionService sessionService;

  UserMediaRepository({
    required this.databaseService,
    required this.sessionService,
  });

  bool isGuest() {
    return sessionService.isGuest;
  }

  Future<int> getUserId() async {
    int? userId = await sessionService.getCurrentUserId();

    if (userId == null) {
      throw Exception(
        'برای استفاده از این قابلیت وارد حساب کاربری شوید.',
      );
    }

    return userId;
  }

  Future<UserMediaItem?> getItem({
    required int mediaId,
    required String mediaType,
  }) async {
    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    List<Map<String, dynamic>> rows = await db.query(
      'user_media',
      where: 'user_id = ? AND media_id = ? AND media_type = ?',
      whereArgs: [
        userId,
        mediaId,
        mediaType,
      ],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return UserMediaItem.fromMap(
      rows.first,
    );
  }

  Future<UserMediaItem?> setStatus({
    required int mediaId,
    required String mediaType,
    required String title,
    required String? posterPath,
    required String releaseYear,
    required String watchStatus,
  }) async {
    if (!WatchStatus.values.contains(watchStatus)) {
      throw Exception(
        'وضعیت تماشا معتبر نیست.',
      );
    }

    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    UserMediaItem? current = await getItem(
      mediaId: mediaId,
      mediaType: mediaType,
    );

    if (watchStatus == WatchStatus.none &&
        current != null &&
        !current.isFavorite) {
      await db.delete(
        'user_media',
        where: 'user_id = ? AND media_id = ? AND media_type = ?',
        whereArgs: [
          userId,
          mediaId,
          mediaType,
        ],
      );

      return null;
    }

    await saveItem(
      userId: userId,
      mediaId: mediaId,
      mediaType: mediaType,
      title: title,
      posterPath: posterPath,
      releaseYear: releaseYear,
      watchStatus: watchStatus,
      isFavorite: current?.isFavorite ?? false,
    );

    return getItem(
      mediaId: mediaId,
      mediaType: mediaType,
    );
  }

  Future<UserMediaItem?> toggleFavorite({
    required int mediaId,
    required String mediaType,
    required String title,
    required String? posterPath,
    required String releaseYear,
  }) async {
    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    UserMediaItem? current = await getItem(
      mediaId: mediaId,
      mediaType: mediaType,
    );

    bool newFavoriteValue = !(current?.isFavorite ?? false);

    if (!newFavoriteValue &&
        (current == null || current.watchStatus == WatchStatus.none)) {
      await db.delete(
        'user_media',
        where: 'user_id = ? AND media_id = ? AND media_type = ?',
        whereArgs: [
          userId,
          mediaId,
          mediaType,
        ],
      );

      return null;
    }

    await saveItem(
      userId: userId,
      mediaId: mediaId,
      mediaType: mediaType,
      title: title,
      posterPath: posterPath,
      releaseYear: releaseYear,
      watchStatus: current?.watchStatus ?? WatchStatus.none,
      isFavorite: newFavoriteValue,
    );

    return getItem(
      mediaId: mediaId,
      mediaType: mediaType,
    );
  }

  Future<void> saveItem({
    required int userId,
    required int mediaId,
    required String mediaType,
    required String title,
    required String? posterPath,
    required String releaseYear,
    required String watchStatus,
    required bool isFavorite,
  }) async {
    Database db = await databaseService.getDatabase();

    List<Map<String, dynamic>> rows = await db.query(
      'user_media',
      where: 'user_id = ? AND media_id = ? AND media_type = ?',
      whereArgs: [
        userId,
        mediaId,
        mediaType,
      ],
      limit: 1,
    );

    Map<String, dynamic> values = {
      'user_id': userId,
      'media_id': mediaId,
      'media_type': mediaType,
      'title': title,
      'poster_path': posterPath,
      'release_year': releaseYear,
      'watch_status': watchStatus,
      'is_favorite': isFavorite ? 1 : 0,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (rows.isEmpty) {
      await db.insert(
        'user_media',
        values,
      );

      return;
    }

    await db.update(
      'user_media',
      values,
      where: 'user_id = ? AND media_id = ? AND media_type = ?',
      whereArgs: [
        userId,
        mediaId,
        mediaType,
      ],
    );
  }

  Future<List<UserMediaItem>> getByStatus(
    String watchStatus,
  ) async {
    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    List<Map<String, dynamic>> rows = await db.query(
      'user_media',
      where: 'user_id = ? AND watch_status = ?',
      whereArgs: [
        userId,
        watchStatus,
      ],
      orderBy: 'updated_at DESC',
    );

    return rows.map((row) {
      return UserMediaItem.fromMap(row);
    }).toList();
  }

  Future<List<UserMediaItem>> getFavorites() async {
    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    List<Map<String, dynamic>> rows = await db.query(
      'user_media',
      where: 'user_id = ? AND is_favorite = 1',
      whereArgs: [
        userId,
      ],
      orderBy: 'updated_at DESC',
    );

    return rows.map((row) {
      return UserMediaItem.fromMap(row);
    }).toList();
  }
}
