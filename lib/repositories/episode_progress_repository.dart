import 'package:sqflite/sqflite.dart';

import '../models/episode.dart';
import '../models/watched_episode.dart';
import '../services/database_service.dart';
import '../services/session_service.dart';

class EpisodeProgressRepository {
  DatabaseService databaseService;
  SessionService sessionService;

  EpisodeProgressRepository({
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
        'برای ثبت قسمت مشاهده‌شده وارد حساب کاربری شوید.',
      );
    }

    return userId;
  }

  Future<Set<int>> getWatchedEpisodeNumbers({
    required int seriesId,
    required int seasonNumber,
  }) async {
    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    List<Map<String, dynamic>> rows = await db.query(
      'watched_episodes',
      columns: [
        'episode_number',
      ],
      where: 'user_id = ? AND series_id = ? AND season_number = ?',
      whereArgs: [
        userId,
        seriesId,
        seasonNumber,
      ],
    );

    return rows.map((row) {
      return row['episode_number'] as int;
    }).toSet();
  }

  Future<bool> toggleEpisode({
    required int seriesId,
    required Episode episode,
  }) async {
    if (!episode.isReleased) {
      throw Exception(
        'این قسمت هنوز منتشر نشده است.',
      );
    }

    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    List<Map<String, dynamic>> rows = await db.query(
      'watched_episodes',
      where:
          'user_id = ? AND series_id = ? AND season_number = ? AND episode_number = ?',
      whereArgs: [
        userId,
        seriesId,
        episode.seasonNumber,
        episode.episodeNumber,
      ],
      limit: 1,
    );

    if (rows.isNotEmpty) {
      await db.delete(
        'watched_episodes',
        where:
            'user_id = ? AND series_id = ? AND season_number = ? AND episode_number = ?',
        whereArgs: [
          userId,
          seriesId,
          episode.seasonNumber,
          episode.episodeNumber,
        ],
      );

      return false;
    }

    await db.insert(
      'watched_episodes',
      {
        'user_id': userId,
        'series_id': seriesId,
        'season_number': episode.seasonNumber,
        'episode_number': episode.episodeNumber,
        'episode_id': episode.id,
        'title': episode.name,
        'air_date': episode.airDate,
        'runtime': episode.runtime,
        'watched_at': DateTime.now().toIso8601String(),
      },
    );

    return true;
  }

  Future<int> getWatchedEpisodeCount(
    int seriesId,
  ) async {
    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM watched_episodes
      WHERE user_id = ?
      AND series_id = ?
      ''',
      [
        userId,
        seriesId,
      ],
    );

    return Sqflite.firstIntValue(
          result,
        ) ??
        0;
  }

  Future<List<WatchedEpisode>> getWatchedEpisodes(
    int seriesId,
  ) async {
    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    List<Map<String, dynamic>> rows = await db.query(
      'watched_episodes',
      where: 'user_id = ? AND series_id = ?',
      whereArgs: [
        userId,
        seriesId,
      ],
      orderBy: 'season_number ASC, episode_number ASC',
    );

    return rows.map((row) {
      return WatchedEpisode.fromMap(
        row,
      );
    }).toList();
  }
}
