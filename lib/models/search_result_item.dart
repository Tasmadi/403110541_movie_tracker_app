import '../utils/api_config.dart';

class SearchResultItem {
  int id;
  String title;
  String originalTitle;
  String overview;
  String? posterPath;
  String releaseDate;
  double voteAverage;
  int voteCount;
  String mediaType;

  SearchResultItem({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.mediaType,
  });

  factory SearchResultItem.fromJson(
    Map<String, dynamic> json,
  ) {
    String mediaType = json['media_type'] ?? '';

    bool isMovie = mediaType == 'movie';

    return SearchResultItem(
      id: json['id'] ?? 0,
      title: isMovie ? json['title'] ?? '' : json['name'] ?? '',
      originalTitle:
          isMovie ? json['original_title'] ?? '' : json['original_name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      releaseDate:
          isMovie ? json['release_date'] ?? '' : json['first_air_date'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: json['vote_count'] ?? 0,
      mediaType: mediaType,
    );
  }

  bool get isMovie {
    return mediaType == 'movie';
  }

  bool get isSeries {
    return mediaType == 'tv';
  }

  String get mediaTypeTitle {
    if (isMovie) {
      return 'فیلم';
    }

    if (isSeries) {
      return 'سریال';
    }

    return '';
  }

  String get releaseYear {
    if (releaseDate.length < 4) {
      return '';
    }

    return releaseDate.substring(0, 4);
  }

  String get posterUrl {
    if (posterPath == null || posterPath!.isEmpty) {
      return '';
    }

    return '${ApiConfig.imageBaseUrl}$posterPath';
  }
}
