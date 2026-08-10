import '../models/episode.dart';
import '../models/season_detail.dart';
import '../models/series_detail.dart';
import '../models/series_progress.dart';
import '../models/user_media_item.dart';
import '../repositories/episode_progress_repository.dart';
import '../repositories/media_repository.dart';
import '../repositories/user_media_repository.dart';

class EpisodeProgressPresenter {
  EpisodeProgressRepository episodeRepository;

  MediaRepository mediaRepository;

  UserMediaRepository userMediaRepository;

  EpisodeProgressPresenter({
    required this.episodeRepository,
    required this.mediaRepository,
    required this.userMediaRepository,
  });

  bool isGuest() {
    return episodeRepository.isGuest();
  }

  Future<Set<int>> getWatchedEpisodeNumbers({
    required int seriesId,
    required int seasonNumber,
  }) {
    return episodeRepository.getWatchedEpisodeNumbers(
      seriesId: seriesId,
      seasonNumber: seasonNumber,
    );
  }

  Future<bool> toggleEpisode({
    required int seriesId,
    required Episode episode,
  }) {
    return episodeRepository.toggleEpisode(
      seriesId: seriesId,
      episode: episode,
    );
  }

  Future<SeriesProgress> loadSeriesProgress(
    SeriesDetail series,
  ) async {
    int watchedEpisodes = await episodeRepository.getWatchedEpisodeCount(
      series.id,
    );

    List<SeasonDetail> seasons = await Future.wait(
      series.seasons.map((season) {
        return mediaRepository.getSeasonDetail(
          series.id,
          season.seasonNumber,
        );
      }),
    );

    int releasedEpisodes = 0;

    for (SeasonDetail season in seasons) {
      releasedEpisodes += season.episodes.where((episode) {
        return episode.isReleased;
      }).length;
    }

    int effectiveWatched = watchedEpisodes;

    if (effectiveWatched > releasedEpisodes) {
      effectiveWatched = releasedEpisodes;
    }

    int remainingEpisodes = releasedEpisodes - effectiveWatched;

    double progress =
        releasedEpisodes == 0 ? 0 : effectiveWatched / releasedEpisodes;

    UserMediaItem? mediaItem = await userMediaRepository.getItem(
      mediaId: series.id,
      mediaType: 'tv',
    );

    String state;

    bool isStopped = mediaItem?.watchStatus == WatchStatus.dropped ||
        mediaItem?.watchStatus == WatchStatus.paused;

    if (isStopped) {
      state = SeriesProgressState.stopped;
    } else if (effectiveWatched == 0) {
      state = SeriesProgressState.notStarted;
    } else if (remainingEpisodes > 0) {
      state = SeriesProgressState.inProgress;
    } else {
      String normalizedStatus = series.status.trim().toLowerCase();

      bool seriesFinished = normalizedStatus == 'ended' ||
          normalizedStatus == 'canceled' ||
          normalizedStatus == 'cancelled';

      state = seriesFinished
          ? SeriesProgressState.completed
          : SeriesProgressState.upToDate;
    }

    return SeriesProgress(
      watchedEpisodes: effectiveWatched,
      releasedEpisodes: releasedEpisodes,
      remainingEpisodes: remainingEpisodes,
      progress: progress,
      state: state,
    );
  }
}
