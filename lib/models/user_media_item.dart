import '../utils/api_config.dart';

class WatchStatus {
  WatchStatus._();

  static const String none = 'none';
  static const String planned = 'planned';
  static const String watching = 'watching';
  static const String watched = 'watched';
  static const String paused = 'paused';
  static const String dropped = 'dropped';

  static const List<String> values = [
    none,
    planned,
    watching,
    watched,
    paused,
    dropped,
  ];

  static String getTitle(
    String status,
  ) {
    switch (status) {
      case planned:
        return 'بعداً می‌بینم';

      case watching:
        return 'در حال تماشا';

      case watched:
        return 'تماشا شده';

      case paused:
        return 'متوقف موقت';

      case dropped:
        return 'رها شده';

      default:
        return 'بدون وضعیت';
    }
  }
}

class UserMediaItem {
  int? id;
  int userId;
  int mediaId;
  String mediaType;
  String title;
  String? posterPath;
  String releaseYear;
  String watchStatus;
  bool isFavorite;
  String updatedAt;

  UserMediaItem({
    this.id,
    required this.userId,
    required this.mediaId,
    required this.mediaType,
    required this.title,
    required this.posterPath,
    required this.releaseYear,
    required this.watchStatus,
    required this.isFavorite,
    required this.updatedAt,
  });

  factory UserMediaItem.fromMap(
    Map<String, dynamic> map,
  ) {
    return UserMediaItem(
      id: map['id'],
      userId: map['user_id'] ?? 0,
      mediaId: map['media_id'] ?? 0,
      mediaType: map['media_type'] ?? '',
      title: map['title'] ?? '',
      posterPath: map['poster_path'],
      releaseYear: map['release_year'] ?? '',
      watchStatus: map['watch_status'] ?? WatchStatus.none,
      isFavorite: (map['is_favorite'] ?? 0) == 1,
      updatedAt: map['updated_at'] ?? '',
    );
  }

  bool get isMovie {
    return mediaType == 'movie';
  }

  bool get isSeries {
    return mediaType == 'tv';
  }

  String get mediaTypeTitle {
    return isMovie ? 'فیلم' : 'سریال';
  }

  String get statusTitle {
    return WatchStatus.getTitle(
      watchStatus,
    );
  }

  String get posterUrl {
    if (posterPath == null || posterPath!.isEmpty) {
      return '';
    }

    return '${ApiConfig.imageBaseUrl}$posterPath';
  }
}
