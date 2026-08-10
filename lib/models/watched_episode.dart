class WatchedEpisode {
  int? id;
  int userId;
  int seriesId;
  int seasonNumber;
  int episodeNumber;
  int episodeId;
  String title;
  String airDate;
  int runtime;
  String watchedAt;

  WatchedEpisode({
    this.id,
    required this.userId,
    required this.seriesId,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.episodeId,
    required this.title,
    required this.airDate,
    required this.runtime,
    required this.watchedAt,
  });

  factory WatchedEpisode.fromMap(
    Map<String, dynamic> map,
  ) {
    return WatchedEpisode(
      id: map['id'],
      userId: map['user_id'] ?? 0,
      seriesId: map['series_id'] ?? 0,
      seasonNumber: map['season_number'] ?? 0,
      episodeNumber: map['episode_number'] ?? 0,
      episodeId: map['episode_id'] ?? 0,
      title: map['title'] ?? '',
      airDate: map['air_date'] ?? '',
      runtime: map['runtime'] ?? 0,
      watchedAt: map['watched_at'] ?? '',
    );
  }
}
