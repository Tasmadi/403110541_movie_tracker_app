import '../utils/api_config.dart';
import 'imdb_info.dart';
import 'cast_member.dart';

class MovieDetail {
  int id;
  String title;
  String originalTitle;
  String overview;
  String? posterPath;
  String? backdropPath;
  String releaseDate;
  int runtime;
  double voteAverage;
  int voteCount;
  String? imdbId;
  double? imdbRating;
  String imdbVotes;
  String director;
  List<String> genres;
  List<String> countries;
  List<CastMember> cast;

  MovieDetail({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.runtime,
    required this.voteAverage,
    required this.voteCount,
    required this.imdbId,
    this.imdbRating,
    this.imdbVotes = '',
    required this.director,
    required this.genres,
    required this.countries,
    required this.cast,
  });

  factory MovieDetail.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic> creditsJson, {
    ImdbInfo? imdbInfo,
  }) {
    List<dynamic> genreData = json['genres'] ?? [];

    List<String> genres = genreData.map((item) {
      Map<String, dynamic> genre = item as Map<String, dynamic>;

      return genre['name']?.toString() ?? '';
    }).where((name) {
      return name.isNotEmpty;
    }).toList();

    List<dynamic> countryData = json['production_countries'] ?? [];

    List<String> countries = countryData.map((item) {
      Map<String, dynamic> country = item as Map<String, dynamic>;

      return country['name']?.toString() ?? '';
    }).where((name) {
      return name.isNotEmpty;
    }).toList();

    String director = '';

    List<dynamic> crewData = creditsJson['crew'] ?? [];

    for (dynamic item in crewData) {
      Map<String, dynamic> crewMember = item as Map<String, dynamic>;

      if (crewMember['job'] == 'Director') {
        director = crewMember['name']?.toString() ?? '';

        break;
      }
    }

    List<dynamic> castData = creditsJson['cast'] ?? [];

    List<CastMember> cast = castData.take(10).map((item) {
      return CastMember.fromJson(
        item as Map<String, dynamic>,
      );
    }).toList();

    return MovieDetail(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      originalTitle: json['original_title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'] ?? '',
      runtime: json['runtime'] ?? 0,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: json['vote_count'] ?? 0,
      imdbId: json['imdb_id'],
      imdbRating: imdbInfo?.rating,
      imdbVotes: imdbInfo?.votes ?? '',
      director: director,
      genres: genres,
      countries: countries,
      cast: cast,
    );
  }

  String get posterUrl {
    if (posterPath == null || posterPath!.isEmpty) {
      return '';
    }

    return '${ApiConfig.imageBaseUrl}$posterPath';
  }

  String get backdropUrl {
    if (backdropPath == null || backdropPath!.isEmpty) {
      return '';
    }

    return '${ApiConfig.imageBaseUrl}$backdropPath';
  }

  String get releaseYear {
    if (releaseDate.length < 4) {
      return '';
    }

    return releaseDate.substring(0, 4);
  }

  String get runtimeText {
    if (runtime <= 0) {
      return 'نامشخص';
    }

    int hours = runtime ~/ 60;
    int minutes = runtime % 60;

    if (hours == 0) {
      return '$minutes دقیقه';
    }

    return '$hours ساعت و $minutes دقیقه';
  }

  String get imdbRatingText {
    if (imdbRating == null) {
      return 'ناموجود';
    }

    return imdbRating!.toStringAsFixed(1);
  }

  String get imdbVotesText {
    if (imdbVotes.isEmpty) {
      return 'ناموجود';
    }

    return imdbVotes;
  }
}
