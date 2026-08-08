import '../utils/api_config.dart';
import 'cast_member.dart';
import 'season.dart';

class SeriesDetail {
  int id;
  String name;
  String originalName;
  String overview;
  String? posterPath;
  String? backdropPath;
  String firstAirDate;
  String lastAirDate;
  String status;
  int numberOfSeasons;
  int numberOfEpisodes;
  double voteAverage;
  int voteCount;
  List<String> genres;
  List<String> creators;
  List<Season> seasons;
  List<CastMember> cast;

  SeriesDetail({
    required this.id,
    required this.name,
    required this.originalName,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.firstAirDate,
    required this.lastAirDate,
    required this.status,
    required this.numberOfSeasons,
    required this.numberOfEpisodes,
    required this.voteAverage,
    required this.voteCount,
    required this.genres,
    required this.creators,
    required this.seasons,
    required this.cast,
  });

  factory SeriesDetail.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic> creditsJson,
  ) {
    List<dynamic> genreData = json['genres'] ?? [];

    List<String> genres = genreData.map((item) {
      Map<String, dynamic> genre = item as Map<String, dynamic>;

      return genre['name']?.toString() ?? '';
    }).where((name) {
      return name.isNotEmpty;
    }).toList();

    List<dynamic> creatorData = json['created_by'] ?? [];

    List<String> creators = creatorData.map((item) {
      Map<String, dynamic> creator = item as Map<String, dynamic>;

      return creator['name']?.toString() ?? '';
    }).where((name) {
      return name.isNotEmpty;
    }).toList();

    List<dynamic> seasonData = json['seasons'] ?? [];

    List<Season> seasons = seasonData.map((item) {
      return Season.fromJson(
        item as Map<String, dynamic>,
      );
    }).where((season) {
      return season.seasonNumber > 0;
    }).toList();

    List<dynamic> castData = creditsJson['cast'] ?? [];

    List<CastMember> cast = castData.take(10).map((item) {
      Map<String, dynamic> data = item as Map<String, dynamic>;

      String character = '';

      List<dynamic> roles = data['roles'] ?? [];

      if (roles.isNotEmpty) {
        Map<String, dynamic> firstRole = roles.first as Map<String, dynamic>;

        character = firstRole['character']?.toString() ?? '';
      }

      return CastMember(
        id: data['id'] ?? 0,
        name: data['name'] ?? '',
        character: character,
        profilePath: data['profile_path'],
      );
    }).toList();

    return SeriesDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      originalName: json['original_name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      firstAirDate: json['first_air_date'] ?? '',
      lastAirDate: json['last_air_date'] ?? '',
      status: json['status'] ?? '',
      numberOfSeasons: json['number_of_seasons'] ?? 0,
      numberOfEpisodes: json['number_of_episodes'] ?? 0,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: json['vote_count'] ?? 0,
      genres: genres,
      creators: creators,
      seasons: seasons,
      cast: cast,
    );
  }

  String get backdropUrl {
    if (backdropPath == null || backdropPath!.isEmpty) {
      return '';
    }

    return '${ApiConfig.imageBaseUrl}$backdropPath';
  }

  String get firstAirYear {
    if (firstAirDate.length < 4) {
      return '';
    }

    return firstAirDate.substring(0, 4);
  }

  String get lastAirYear {
    if (lastAirDate.length < 4) {
      return '';
    }

    return lastAirDate.substring(0, 4);
  }
}
