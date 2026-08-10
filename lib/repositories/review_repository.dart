import 'package:sqflite/sqflite.dart';

import '../models/review.dart';
import '../services/database_service.dart';
import '../services/session_service.dart';

class ReviewRepository {
  DatabaseService databaseService;
  SessionService sessionService;

  ReviewRepository({
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
        'برای ثبت نظر وارد حساب کاربری شوید.',
      );
    }

    return userId;
  }

  Future<List<Review>> getReviews({
    required int mediaId,
    required String mediaType,
  }) async {
    Database db = await databaseService.getDatabase();

    int? currentUserId;

    if (!isGuest()) {
      currentUserId = await sessionService.getCurrentUserId();
    }

    List<Map<String, dynamic>> rows = await db.rawQuery(
      '''
      SELECT
        reviews.*,
        users.username,
        users.profile_image_path
      FROM reviews
      INNER JOIN users
        ON users.id = reviews.user_id
      WHERE reviews.media_id = ?
        AND reviews.media_type = ?
      ORDER BY reviews.updated_at DESC
      ''',
      [
        mediaId,
        mediaType,
      ],
    );

    return rows.map((row) {
      return Review.fromMap(
        row,
        currentUserId: currentUserId,
      );
    }).toList();
  }

  Future<void> saveReview({
    required int mediaId,
    required String mediaType,
    required String text,
    required bool isSpoiler,
  }) async {
    String normalizedText = text.trim();

    if (normalizedText.isEmpty) {
      throw Exception(
        'متن نظر نمی‌تواند خالی باشد.',
      );
    }

    if (normalizedText.length > 1000) {
      throw Exception(
        'متن نظر بیش از حد طولانی است.',
      );
    }

    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    List<Map<String, dynamic>> rows = await db.query(
      'reviews',
      where: 'user_id = ? AND media_id = ? AND media_type = ?',
      whereArgs: [
        userId,
        mediaId,
        mediaType,
      ],
      limit: 1,
    );

    String now = DateTime.now().toIso8601String();

    if (rows.isEmpty) {
      await db.insert(
        'reviews',
        {
          'user_id': userId,
          'media_id': mediaId,
          'media_type': mediaType,
          'review_text': normalizedText,
          'is_spoiler': isSpoiler ? 1 : 0,
          'created_at': now,
          'updated_at': now,
        },
      );

      return;
    }

    await db.update(
      'reviews',
      {
        'review_text': normalizedText,
        'is_spoiler': isSpoiler ? 1 : 0,
        'updated_at': now,
      },
      where: 'user_id = ? AND media_id = ? AND media_type = ?',
      whereArgs: [
        userId,
        mediaId,
        mediaType,
      ],
    );
  }
}
