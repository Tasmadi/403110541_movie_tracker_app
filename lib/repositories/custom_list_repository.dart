import 'package:sqflite/sqflite.dart';

import '../models/custom_list.dart';
import '../models/custom_list_item.dart';
import '../models/custom_list_media_arguments.dart';
import '../services/database_service.dart';
import '../services/session_service.dart';

class CustomListRepository {
  DatabaseService databaseService;
  SessionService sessionService;

  CustomListRepository({
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
        'برای استفاده از فهرست‌های شخصی وارد حساب شوید.',
      );
    }

    return userId;
  }

  Future<List<CustomList>> getLists() async {
    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    List<Map<String, dynamic>> rows = await db.rawQuery(
      '''
      SELECT
        custom_lists.*,
        COUNT(custom_list_items.id) AS item_count
      FROM custom_lists
      LEFT JOIN custom_list_items
        ON custom_list_items.list_id = custom_lists.id
      WHERE custom_lists.user_id = ?
      GROUP BY custom_lists.id
      ORDER BY custom_lists.updated_at DESC
      ''',
      [
        userId,
      ],
    );

    return rows.map((row) {
      return CustomList.fromMap(row);
    }).toList();
  }

  Future<CustomList> createList(
    String name,
  ) async {
    String normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw Exception(
        'نام فهرست نمی‌تواند خالی باشد.',
      );
    }

    if (normalizedName.length > 60) {
      throw Exception(
        'نام فهرست بیش از حد طولانی است.',
      );
    }

    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    List<Map<String, dynamic>> existing = await db.query(
      'custom_lists',
      where: 'user_id = ? AND name = ?',
      whereArgs: [
        userId,
        normalizedName,
      ],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      throw Exception(
        'فهرستی با این نام وجود دارد.',
      );
    }

    String now = DateTime.now().toIso8601String();

    int id = await db.insert(
      'custom_lists',
      {
        'user_id': userId,
        'name': normalizedName,
        'created_at': now,
        'updated_at': now,
      },
    );

    return CustomList(
      id: id,
      userId: userId,
      name: normalizedName,
      itemCount: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> deleteList(
    int listId,
  ) async {
    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    await db.transaction(
      (transaction) async {
        int deleted = await transaction.delete(
          'custom_lists',
          where: 'id = ? AND user_id = ?',
          whereArgs: [
            listId,
            userId,
          ],
        );

        if (deleted == 0) {
          throw Exception(
            'فهرست پیدا نشد.',
          );
        }

        await transaction.delete(
          'custom_list_items',
          where: 'list_id = ?',
          whereArgs: [
            listId,
          ],
        );
      },
    );
  }

  Future<bool> containsMedia({
    required int listId,
    required int mediaId,
    required String mediaType,
  }) async {
    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    await ensureOwnership(
      db,
      userId,
      listId,
    );

    List<Map<String, dynamic>> rows = await db.query(
      'custom_list_items',
      where: 'list_id = ? AND media_id = ? AND media_type = ?',
      whereArgs: [
        listId,
        mediaId,
        mediaType,
      ],
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  Future<void> toggleMedia({
    required int listId,
    required CustomListMediaArguments media,
  }) async {
    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    await ensureOwnership(
      db,
      userId,
      listId,
    );

    List<Map<String, dynamic>> rows = await db.query(
      'custom_list_items',
      where: 'list_id = ? AND media_id = ? AND media_type = ?',
      whereArgs: [
        listId,
        media.mediaId,
        media.mediaType,
      ],
      limit: 1,
    );

    if (rows.isNotEmpty) {
      await db.delete(
        'custom_list_items',
        where: 'list_id = ? AND media_id = ? AND media_type = ?',
        whereArgs: [
          listId,
          media.mediaId,
          media.mediaType,
        ],
      );
    } else {
      await db.insert(
        'custom_list_items',
        {
          'list_id': listId,
          'media_id': media.mediaId,
          'media_type': media.mediaType,
          'title': media.title,
          'poster_path': media.posterPath,
          'release_year': media.releaseYear,
          'added_at': DateTime.now().toIso8601String(),
        },
      );
    }

    await db.update(
      'custom_lists',
      {
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [
        listId,
        userId,
      ],
    );
  }

  Future<Set<int>> getListsContainingMedia({
    required int mediaId,
    required String mediaType,
  }) async {
    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    List<Map<String, dynamic>> rows = await db.rawQuery(
      '''
      SELECT custom_list_items.list_id
      FROM custom_list_items
      INNER JOIN custom_lists
        ON custom_lists.id =
           custom_list_items.list_id
      WHERE custom_lists.user_id = ?
        AND custom_list_items.media_id = ?
        AND custom_list_items.media_type = ?
      ''',
      [
        userId,
        mediaId,
        mediaType,
      ],
    );

    return rows.map((row) {
      return row['list_id'] as int;
    }).toSet();
  }

  Future<List<CustomListItem>> getItems(
    int listId,
  ) async {
    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    await ensureOwnership(
      db,
      userId,
      listId,
    );

    List<Map<String, dynamic>> rows = await db.query(
      'custom_list_items',
      where: 'list_id = ?',
      whereArgs: [
        listId,
      ],
      orderBy: 'added_at DESC',
    );

    return rows.map((row) {
      return CustomListItem.fromMap(row);
    }).toList();
  }

  Future<void> removeItem({
    required int listId,
    required int mediaId,
    required String mediaType,
  }) async {
    int userId = await getUserId();

    Database db = await databaseService.getDatabase();

    await ensureOwnership(
      db,
      userId,
      listId,
    );

    await db.delete(
      'custom_list_items',
      where: 'list_id = ? AND media_id = ? AND media_type = ?',
      whereArgs: [
        listId,
        mediaId,
        mediaType,
      ],
    );
  }

  Future<void> ensureOwnership(
    Database db,
    int userId,
    int listId,
  ) async {
    List<Map<String, dynamic>> rows = await db.query(
      'custom_lists',
      columns: [
        'id',
      ],
      where: 'id = ? AND user_id = ?',
      whereArgs: [
        listId,
        userId,
      ],
      limit: 1,
    );

    if (rows.isEmpty) {
      throw Exception(
        'فهرست پیدا نشد.',
      );
    }
  }
}
