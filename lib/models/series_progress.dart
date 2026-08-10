class SeriesProgressState {
  SeriesProgressState._();

  static const String notStarted = 'not_started';

  static const String inProgress = 'in_progress';

  static const String upToDate = 'up_to_date';

  static const String completed = 'completed';

  static const String stopped = 'stopped';
}

class SeriesProgress {
  int watchedEpisodes;
  int releasedEpisodes;
  int remainingEpisodes;
  double progress;
  String state;

  SeriesProgress({
    required this.watchedEpisodes,
    required this.releasedEpisodes,
    required this.remainingEpisodes,
    required this.progress,
    required this.state,
  });

  int get percentage {
    return (progress * 100).round();
  }
}
