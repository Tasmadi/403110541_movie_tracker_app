import '../utils/api_config.dart';

class Movie {
  int id;
  String title;
  String originalTitle;
  String overview;
  String? posterPath;
  String? backdropPath;
  String releaseDate;
  double voteAverage;
  int voteCount;
  List<int> genreIds;

  Movie({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genreIds,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    List<dynamic> genres = json['genre_ids'] ?? [];

    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      originalTitle: json['original_title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: json['vote_count'] ?? 0,
      genreIds: genres.map((genre) {
        return genre as int;
      }).toList(),
    );
  }

  String get posterUrl {
    if (posterPath == null || posterPath!.isEmpty) {
      return '';
    }

    return '${ApiConfig.imageBaseUrl}$posterPath';
  }

  String get releaseYear {
    if (releaseDate.length < 4) {
      return '';
    }

    return releaseDate.substring(0, 4);
  }
}
