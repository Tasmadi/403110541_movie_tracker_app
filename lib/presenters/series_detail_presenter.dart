import '../models/season_detail.dart';
import '../models/series_detail.dart';
import '../repositories/media_repository.dart';

class SeriesDetailPresenter {
  MediaRepository mediaRepository;

  SeriesDetailPresenter({
    required this.mediaRepository,
  });

  Future<SeriesDetail> loadSeriesDetail(
    int seriesId, {
    bool forceRefresh = false,
  }) async {
    return mediaRepository.getSeriesDetail(
      seriesId,
      forceRefresh: forceRefresh,
    );
  }

  Future<SeasonDetail> loadSeasonDetail(
    int seriesId,
    int seasonNumber, {
    bool forceRefresh = false,
  }) async {
    return mediaRepository.getSeasonDetail(
      seriesId,
      seasonNumber,
      forceRefresh: forceRefresh,
    );
  }
}
