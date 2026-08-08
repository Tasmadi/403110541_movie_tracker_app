import 'episode.dart';

class SeasonDetail {
  int id;
  int seasonNumber;
  String name;
  String overview;
  String airDate;
  List<Episode> episodes;

  SeasonDetail({
    required this.id,
    required this.seasonNumber,
    required this.name,
    required this.overview,
    required this.airDate,
    required this.episodes,
  });

  factory SeasonDetail.fromJson(
    Map<String, dynamic> json,
  ) {
    List<dynamic> episodeData = json['episodes'] ?? [];

    List<Episode> episodes = episodeData.map((item) {
      return Episode.fromJson(
        item as Map<String, dynamic>,
      );
    }).toList();

    return SeasonDetail(
      id: json['id'] ?? 0,
      seasonNumber: json['season_number'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      airDate: json['air_date'] ?? '',
      episodes: episodes,
    );
  }
}
