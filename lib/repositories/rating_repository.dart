import 'package:sqflite/sqflite.dart';

import '../models/rating_stats.dart';
import '../services/database_service.dart';
import '../services/session_service.dart';

class RatingRepository {
  DatabaseService databaseService;
  SessionService sessionService;

  RatingRepository({
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
        'برای ثبت امتیاز وارد حساب کاربری شوید.',
      );
    }

    return userId;
  }

  Future<void> setRating({
    required int mediaId,
    required String mediaType,
    required int rating,
  }) async {
    if (rating < 1 || rating > 5) {
      throw Exception(
        'امتیاز باید بین ۱ تا ۵ باشد.',
      );
    }

    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    List<Map<String, dynamic>> rows = await db.query(
      'ratings',
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
        'ratings',
        {
          'user_id': userId,
          'media_id': mediaId,
          'media_type': mediaType,
          'rating': rating,
          'created_at': now,
          'updated_at': now,
        },
      );

      return;
    }

    await db.update(
      'ratings',
      {
        'rating': rating,
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

  Future<int?> getUserRating({
    required int mediaId,
    required String mediaType,
  }) async {
    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    List<Map<String, dynamic>> rows = await db.query(
      'ratings',
      columns: [
        'rating',
      ],
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

    return rows.first['rating'] as int;
  }

  Future<RatingStats> getStats({
    required int mediaId,
    required String mediaType,
  }) async {
    Database db = await databaseService.getDatabase();

    List<Map<String, dynamic>> rows = await db.query(
      'ratings',
      columns: [
        'rating',
      ],
      where: 'media_id = ? AND media_type = ?',
      whereArgs: [
        mediaId,
        mediaType,
      ],
    );

    Map<int, int> counts = {
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
    };

    int totalScore = 0;

    for (Map<String, dynamic> row in rows) {
      int rating = row['rating'] as int;

      counts[rating] = (counts[rating] ?? 0) + 1;

      totalScore += rating;
    }

    int totalRatings = rows.length;

    Map<int, double> percentages = {};

    for (int stars = 1; stars <= 5; stars++) {
      int count = counts[stars] ?? 0;

      percentages[stars] = totalRatings == 0 ? 0 : (count / totalRatings) * 100;
    }

    double average = totalRatings == 0 ? 0 : totalScore / totalRatings;

    int? userRating;

    if (!isGuest()) {
      userRating = await getUserRating(
        mediaId: mediaId,
        mediaType: mediaType,
      );
    }

    return RatingStats(
      totalRatings: totalRatings,
      averageRating: average,
      counts: counts,
      percentages: percentages,
      userRating: userRating,
    );
  }
}
