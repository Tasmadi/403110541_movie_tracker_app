import '../utils/api_config.dart';

class CustomListItem {
  int id;
  int listId;
  int mediaId;
  String mediaType;
  String title;
  String? posterPath;
  String releaseYear;
  String addedAt;

  CustomListItem({
    required this.id,
    required this.listId,
    required this.mediaId,
    required this.mediaType,
    required this.title,
    required this.posterPath,
    required this.releaseYear,
    required this.addedAt,
  });

  factory CustomListItem.fromMap(
    Map<String, dynamic> map,
  ) {
    return CustomListItem(
      id: map['id'] ?? 0,
      listId: map['list_id'] ?? 0,
      mediaId: map['media_id'] ?? 0,
      mediaType: map['media_type'] ?? '',
      title: map['title'] ?? '',
      posterPath: map['poster_path'],
      releaseYear: map['release_year'] ?? '',
      addedAt: map['added_at'] ?? '',
    );
  }

  bool get isMovie {
    return mediaType == 'movie';
  }

  String get mediaTypeTitle {
    return isMovie ? 'فیلم' : 'سریال';
  }

  String get posterUrl {
    if (posterPath == null || posterPath!.isEmpty) {
      return '';
    }

    return '${ApiConfig.imageBaseUrl}$posterPath';
  }
}
