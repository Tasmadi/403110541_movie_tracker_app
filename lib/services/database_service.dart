import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  Database? database;

  Future<Database> getDatabase() async {
    if (database != null) {
      return database!;
    }

    String databasePath = await getDatabasesPath();

    String path = join(
      databasePath,
      'movie_tracker.db',
    );

    database = await openDatabase(
      path,
      version: 3,
      onCreate: (
        Database db,
        int version,
      ) async {
        await createTables(db);
      },
      onUpgrade: (
        Database db,
        int oldVersion,
        int newVersion,
      ) async {
        if (oldVersion < 2) {
          await createUserMediaTable(db);
        }

        if (oldVersion < 3) {
          await createWatchedEpisodesTable(
            db,
          );
        }
      },
    );

    return database!;
  }

  Future<void> createTables(
    Database db,
  ) async {
    await db.execute(
      '''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        password_salt TEXT NOT NULL,
        profile_image_path TEXT,
        bio TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
      ''',
    );

    await createUserMediaTable(db);

    await createWatchedEpisodesTable(
      db,
    );
  }

  Future<void> createUserMediaTable(
    Database db,
  ) async {
    await db.execute(
      '''
      CREATE TABLE user_media (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        media_id INTEGER NOT NULL,
        media_type TEXT NOT NULL,
        title TEXT NOT NULL,
        poster_path TEXT,
        release_year TEXT NOT NULL DEFAULT '',
        watch_status TEXT NOT NULL DEFAULT 'none',
        is_favorite INTEGER NOT NULL DEFAULT 0,
        updated_at TEXT NOT NULL,
        UNIQUE(user_id, media_id, media_type)
      )
      ''',
    );
  }

  Future<void> createWatchedEpisodesTable(
    Database db,
  ) async {
    await db.execute(
      '''
      CREATE TABLE watched_episodes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        series_id INTEGER NOT NULL,
        season_number INTEGER NOT NULL,
        episode_number INTEGER NOT NULL,
        episode_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        air_date TEXT NOT NULL DEFAULT '',
        runtime INTEGER NOT NULL DEFAULT 0,
        watched_at TEXT NOT NULL,
        UNIQUE(
          user_id,
          series_id,
          season_number,
          episode_number
        )
      )
      ''',
    );
  }

  Future<void> close() async {
    if (database == null) {
      return;
    }

    await database!.close();

    database = null;
  }
}
