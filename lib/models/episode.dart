import '../utils/api_config.dart';

class Episode {
  int id;
  int episodeNumber;
  int seasonNumber;
  String name;
  String overview;
  String airDate;
  int runtime;
  double voteAverage;
  String? stillPath;

  Episode({
    required this.id,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.name,
    required this.overview,
    required this.airDate,
    required this.runtime,
    required this.voteAverage,
    required this.stillPath,
  });

  factory Episode.fromJson(
    Map<String, dynamic> json,
  ) {
    return Episode(
      id: json['id'] ?? 0,
      episodeNumber: json['episode_number'] ?? 0,
      seasonNumber: json['season_number'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      airDate: json['air_date'] ?? '',
      runtime: json['runtime'] ?? 0,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      stillPath: json['still_path'],
    );
  }

  String get stillUrl {
    if (stillPath == null || stillPath!.isEmpty) {
      return '';
    }

    return '${ApiConfig.imageBaseUrl}$stillPath';
  }

  String get runtimeText {
    if (runtime <= 0) {
      return 'نامشخص';
    }

    return '$runtime دقیقه';
  }
}
