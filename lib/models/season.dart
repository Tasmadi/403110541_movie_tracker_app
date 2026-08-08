import '../utils/api_config.dart';

class Season {
  int id;
  int seasonNumber;
  int episodeCount;
  String name;
  String overview;
  String airDate;
  String? posterPath;

  Season({
    required this.id,
    required this.seasonNumber,
    required this.episodeCount,
    required this.name,
    required this.overview,
    required this.airDate,
    required this.posterPath,
  });

  factory Season.fromJson(
    Map<String, dynamic> json,
  ) {
    return Season(
      id: json['id'] ?? 0,
      seasonNumber: json['season_number'] ?? 0,
      episodeCount: json['episode_count'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      airDate: json['air_date'] ?? '',
      posterPath: json['poster_path'],
    );
  }

  String get posterUrl {
    if (posterPath == null || posterPath!.isEmpty) {
      return '';
    }

    return '${ApiConfig.imageBaseUrl}$posterPath';
  }

  String get airYear {
    if (airDate.length < 4) {
      return '';
    }

    return airDate.substring(0, 4);
  }
}
