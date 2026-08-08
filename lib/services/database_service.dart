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
      version: 1,
      onCreate: (
        Database db,
        int version,
      ) async {
        await createTables(db);
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
  }

  Future<void> close() async {
    if (database == null) {
      return;
    }

    await database!.close();
    database = null;
  }
}
