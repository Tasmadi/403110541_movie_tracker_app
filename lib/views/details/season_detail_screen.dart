import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/episode.dart';
import '../../models/season_arguments.dart';
import '../../models/season_detail.dart';
import '../../presenters/series_detail_presenter.dart';
import '../../presenters/episode_progress_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';

class SeasonDetailScreen extends StatefulWidget {
  final SeasonArguments arguments;

  const SeasonDetailScreen({
    super.key,
    required this.arguments,
  });

  @override
  State<SeasonDetailScreen> createState() {
    return _SeasonDetailScreenState();
  }
}

class _SeasonDetailScreenState extends State<SeasonDetailScreen> {
  late final SeriesDetailPresenter presenter;

  SeasonDetail? season;

  bool isLoading = true;

  String? errorMessage;

  late final EpisodeProgressPresenter progressPresenter;

  Set<int> watchedEpisodeNumbers = {};

  Set<int> savingEpisodeNumbers = {};

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.seriesDetailPresenter;

    progressPresenter = ServiceLocator.episodeProgressPresenter;

    loadSeason();
  }

  Future<void> loadSeason() async {
    try {
      SeasonDetail result = await presenter.loadSeasonDetail(
        widget.arguments.seriesId,
        widget.arguments.seasonNumber,
      );

      Set<int> watched = {};

      if (!progressPresenter.isGuest()) {
        watched = await progressPresenter.getWatchedEpisodeNumbers(
          seriesId: widget.arguments.seriesId,
          seasonNumber: widget.arguments.seasonNumber,
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        season = result;
        watchedEpisodeNumbers = watched;
        isLoading = false;
        errorMessage = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        errorMessage = error.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  Future<void> toggleEpisode(
    Episode episode,
  ) async {
    if (progressPresenter.isGuest()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'برای ثبت قسمت‌های مشاهده‌شده وارد حساب شوید.',
          ),
          action: SnackBarAction(
            label: 'ورود',
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.login,
              );
            },
          ),
        ),
      );

      return;
    }

    if (!episode.isReleased) {
      return;
    }

    setState(() {
      savingEpisodeNumbers.add(
        episode.episodeNumber,
      );
    });

    try {
      bool isWatched = await progressPresenter.toggleEpisode(
        seriesId: widget.arguments.seriesId,
        episode: episode,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (isWatched) {
          watchedEpisodeNumbers.add(
            episode.episodeNumber,
          );
        } else {
          watchedEpisodeNumbers.remove(
            episode.episodeNumber,
          );
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          savingEpisodeNumbers.remove(
            episode.episodeNumber,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.arguments.seriesName} - فصل ${widget.arguments.seasonNumber}',
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
        ),
      );
    }

    int releasedCount = season!.episodes.where((episode) {
      return episode.isReleased;
    }).length;

    int watchedCount = watchedEpisodeNumbers.length;

    int remainingCount = releasedCount - watchedCount;

    if (remainingCount < 0) {
      remainingCount = 0;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            4,
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(
                    Icons.playlist_add_check_circle_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$watchedCount از $releasedCount قسمت منتشرشده دیده شده',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '$remainingCount باقی‌مانده',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: season!.episodes.length,
            separatorBuilder: (
              context,
              index,
            ) {
              return const SizedBox(
                height: 12,
              );
            },
            itemBuilder: (
              context,
              index,
            ) {
              return buildEpisodeCard(
                season!.episodes[index],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildEpisodeCard(
    Episode episode,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (episode.stillUrl.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: episode.stillUrl,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'قسمت ${episode.episodeNumber}: ${episode.name}',
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      episode.airDate,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      episode.runtimeText,
                    ),
                  ],
                ),
                if (episode.overview.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    episode.overview,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: savingEpisodeNumbers.contains(
                      episode.episodeNumber,
                    )
                        ? null
                        : episode.isReleased
                            ? () {
                                toggleEpisode(
                                  episode,
                                );
                              }
                            : null,
                    icon: savingEpisodeNumbers.contains(
                      episode.episodeNumber,
                    )
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            watchedEpisodeNumbers.contains(
                              episode.episodeNumber,
                            )
                                ? Icons.check_circle_rounded
                                : episode.isReleased
                                    ? Icons.radio_button_unchecked_rounded
                                    : Icons.schedule_rounded,
                          ),
                    label: Text(
                      !episode.isReleased
                          ? 'هنوز منتشر نشده'
                          : watchedEpisodeNumbers.contains(
                              episode.episodeNumber,
                            )
                              ? 'مشاهده شده'
                              : 'علامت‌گذاری به عنوان مشاهده‌شده',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
