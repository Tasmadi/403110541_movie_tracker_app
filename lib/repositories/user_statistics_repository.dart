import 'package:sqflite/sqflite.dart';

import '../models/user_media_item.dart';
import '../models/user_statistics.dart';
import '../services/database_service.dart';
import '../services/session_service.dart';

class UserStatisticsRepository {
  DatabaseService databaseService;
  SessionService sessionService;

  UserStatisticsRepository({
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
        'برای مشاهده آمار وارد حساب کاربری شوید.',
      );
    }

    return userId;
  }

  Future<int> countQuery(
    Database db,
    String sql,
    List<Object?> arguments,
  ) async {
    List<Map<String, dynamic>> result = await db.rawQuery(
      sql,
      arguments,
    );

    return Sqflite.firstIntValue(
          result,
        ) ??
        0;
  }

  Future<UserStatisticsSummary> loadSummary() async {
    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    int watchedMovies = await countQuery(
      db,
      '''
      SELECT COUNT(*)
      FROM user_media
      WHERE user_id = ?
        AND media_type = 'movie'
        AND watch_status = 'watched'
      ''',
      [
        userId,
      ],
    );

    int followedSeries = await countQuery(
      db,
      '''
      SELECT COUNT(*)
      FROM user_media
      WHERE user_id = ?
        AND media_type = 'tv'
        AND watch_status != 'none'
      ''',
      [
        userId,
      ],
    );

    int favorites = await countQuery(
      db,
      '''
      SELECT COUNT(*)
      FROM user_media
      WHERE user_id = ?
        AND is_favorite = 1
      ''',
      [
        userId,
      ],
    );

    return UserStatisticsSummary(
      watchedMovies: watchedMovies,
      followedSeries: followedSeries,
      favorites: favorites,
    );
  }

  Future<UserStatisticsLocalData> loadLocalData() async {
    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    int watchedMovies = await countQuery(
      db,
      '''
      SELECT COUNT(*)
      FROM user_media
      WHERE user_id = ?
        AND media_type = 'movie'
        AND watch_status = 'watched'
      ''',
      [
        userId,
      ],
    );

    int watchedSeries = await countQuery(
      db,
      '''
      SELECT COUNT(*)
      FROM user_media
      WHERE user_id = ?
        AND media_type = 'tv'
        AND watch_status = 'watched'
      ''',
      [
        userId,
      ],
    );

    int followedSeries = await countQuery(
      db,
      '''
      SELECT COUNT(*)
      FROM user_media
      WHERE user_id = ?
        AND media_type = 'tv'
        AND watch_status != 'none'
      ''',
      [
        userId,
      ],
    );

    int watchedEpisodes = await countQuery(
      db,
      '''
      SELECT COUNT(*)
      FROM watched_episodes
      WHERE user_id = ?
      ''',
      [
        userId,
      ],
    );

    int favorites = await countQuery(
      db,
      '''
      SELECT COUNT(*)
      FROM user_media
      WHERE user_id = ?
        AND is_favorite = 1
      ''',
      [
        userId,
      ],
    );

    List<Map<String, dynamic>> runtimeRows = await db.rawQuery(
      '''
      SELECT COALESCE(
        SUM(runtime),
        0
      ) AS total_runtime
      FROM watched_episodes
      WHERE user_id = ?
      ''',
      [
        userId,
      ],
    );

    int episodeWatchMinutes =
        (runtimeRows.first['total_runtime'] as num?)?.toInt() ?? 0;

    List<Map<String, dynamic>> ratingRows = await db.rawQuery(
      '''
      SELECT
        COUNT(*) AS rating_count,
        AVG(rating) AS average_rating
      FROM ratings
      WHERE user_id = ?
      ''',
      [
        userId,
      ],
    );

    int ratingCount = (ratingRows.first['rating_count'] as num?)?.toInt() ?? 0;

    double averageRating =
        (ratingRows.first['average_rating'] as num?)?.toDouble() ?? 0;

    List<Map<String, dynamic>> movieRows = await db.query(
      'user_media',
      columns: [
        'media_id',
      ],
      where:
          "user_id = ? AND media_type = 'movie' AND watch_status = 'watched'",
      whereArgs: [
        userId,
      ],
    );

    List<int> watchedMovieIds = movieRows.map((row) {
      return row['media_id'] as int;
    }).toList();

    List<Map<String, dynamic>> candidateRows = await db.query(
      'user_media',
      where: "user_id = ? AND (watch_status != 'none' OR is_favorite = 1)",
      whereArgs: [
        userId,
      ],
      orderBy: 'updated_at DESC',
      limit: 20,
    );

    List<UserMediaItem> genreCandidates = candidateRows.map((row) {
      return UserMediaItem.fromMap(
        row,
      );
    }).toList();

    return UserStatisticsLocalData(
      watchedMovies: watchedMovies,
      watchedSeries: watchedSeries,
      followedSeries: followedSeries,
      watchedEpisodes: watchedEpisodes,
      favorites: favorites,
      episodeWatchMinutes: episodeWatchMinutes,
      ratingCount: ratingCount,
      averageRating: averageRating,
      watchedMovieIds: watchedMovieIds,
      genreCandidates: genreCandidates,
    );
  }
}
