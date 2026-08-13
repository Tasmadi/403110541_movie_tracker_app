import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/episode.dart';
import '../../models/season_arguments.dart';
import '../../models/season_detail.dart';
import '../../presenters/episode_progress_presenter.dart';
import '../../presenters/series_detail_presenter.dart';
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

  late final EpisodeProgressPresenter progressPresenter;

  SeasonDetail? season;

  bool isLoading = true;

  String? errorMessage;

  Set<int> watchedEpisodeNumbers = {};

  Set<int> savingEpisodeNumbers = {};

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.seriesDetailPresenter;

    progressPresenter = ServiceLocator.episodeProgressPresenter;

    loadSeason();
  }

  Future<void> loadSeason({
    bool forceRefresh = false,
  }) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      SeasonDetail result = await presenter.loadSeasonDetail(
        widget.arguments.seriesId,
        widget.arguments.seasonNumber,
        forceRefresh: forceRefresh,
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
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return buildLoading();
    }

    if (errorMessage != null || season == null) {
      return buildError();
    }

    return RefreshIndicator(
      onRefresh: () {
        return loadSeason(
          forceRefresh: true,
        );
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          bottom: 30,
        ),
        children: [
          buildHero(),
          buildProgressCard(),
          buildEpisodeHeader(),
          ...season!.episodes.map(
            (
              Episode episode,
            ) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  13,
                ),
                child: buildEpisodeCard(
                  episode,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildHero() {
    String imageUrl = '';

    for (Episode episode in season!.episodes) {
      if (episode.stillUrl.isNotEmpty) {
        imageUrl = episode.stillUrl;
        break;
      }
    }

    double statusBar = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isEmpty)
            const ColoredBox(
              color: AppColors.surfaceLight,
              child: Center(
                child: Icon(
                  Icons.tv_rounded,
                  size: 70,
                  color: AppColors.textMuted,
                ),
              ),
            )
          else
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (
                context,
                url,
              ) {
                return const ColoredBox(
                  color: AppColors.surfaceLight,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorWidget: (
                context,
                url,
                error,
              ) {
                return const ColoredBox(
                  color: AppColors.surfaceLight,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.textMuted,
                      size: 52,
                    ),
                  ),
                );
              },
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66000000),
                  Color(0x33000000),
                  Color(0xDD0D0D12),
                  AppColors.background,
                ],
                stops: [
                  0,
                  0.35,
                  0.78,
                  1,
                ],
              ),
            ),
          ),
          Positioned(
            top: statusBar + 10,
            right: 16,
            child: buildBackButton(),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(
                      0.90,
                    ),
                    borderRadius: BorderRadius.circular(
                      9,
                    ),
                  ),
                  child: Text(
                    'فصل ${widget.arguments.seasonNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  widget.arguments.seriesName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  season!.name,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBackButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(
          0xCC111119,
        ),
        borderRadius: BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(
            0.10,
          ),
        ),
      ),
      child: IconButton(
        tooltip: 'بازگشت',
        onPressed: () {
          Navigator.maybePop(
            context,
          );
        },
        icon: const Icon(
          Icons.arrow_forward_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget buildProgressCard() {
    int releasedCount = season!.episodes.where(
      (
        Episode episode,
      ) {
        return episode.isReleased;
      },
    ).length;

    int watchedCount = watchedEpisodeNumbers.length;

    if (watchedCount > releasedCount) {
      watchedCount = releasedCount;
    }

    int remainingCount = releasedCount - watchedCount;

    if (remainingCount < 0) {
      remainingCount = 0;
    }

    double percentage = releasedCount == 0 ? 0 : watchedCount / releasedCount;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        20,
      ),
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          22,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(
                    0.12,
                  ),
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                ),
                child: const Icon(
                  Icons.playlist_add_check_circle_rounded,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(
                width: 11,
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'پیشرفت این فصل',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      'قسمت‌های منتشرشده',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(percentage * 100).round()}٪',
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(
              20,
            ),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 9,
              color: AppColors.success,
              backgroundColor: AppColors.surfaceLight,
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          Row(
            children: [
              Expanded(
                child: buildProgressValue(
                  '$watchedCount',
                  'دیده‌شده',
                ),
              ),
              buildProgressDivider(),
              Expanded(
                child: buildProgressValue(
                  '$releasedCount',
                  'منتشرشده',
                ),
              ),
              buildProgressDivider(),
              Expanded(
                child: buildProgressValue(
                  '$remainingCount',
                  'باقی‌مانده',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildProgressValue(
    String value,
    String title,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget buildProgressDivider() {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.divider,
    );
  }

  Widget buildEpisodeHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        13,
      ),
      child: Row(
        children: [
          const Text(
            'قسمت‌ها',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(
                0.12,
              ),
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            child: Text(
              '${season!.episodes.length}',
              style: const TextStyle(
                color: AppColors.primaryLight,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEpisodeCard(
    Episode episode,
  ) {
    bool watched = watchedEpisodeNumbers.contains(
      episode.episodeNumber,
    );

    bool saving = savingEpisodeNumbers.contains(
      episode.episodeNumber,
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          21,
        ),
        border: Border.all(
          color: watched
              ? AppColors.success.withOpacity(
                  0.35,
                )
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildEpisodeImage(
            episode,
            watched,
          ),
          Padding(
            padding: const EdgeInsets.all(
              15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: watched
                            ? AppColors.success.withOpacity(
                                0.12,
                              )
                            : AppColors.primary.withOpacity(
                                0.10,
                              ),
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: Text(
                        '${episode.episodeNumber}',
                        style: TextStyle(
                          color: watched
                              ? AppColors.success
                              : AppColors.primaryLight,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 11,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            episode.name.isEmpty
                                ? 'قسمت ${episode.episodeNumber}'
                                : episode.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(
                            height: 7,
                          ),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              buildEpisodeMeta(
                                Icons.calendar_today_outlined,
                                episode.airDate.isEmpty
                                    ? 'تاریخ نامشخص'
                                    : episode.airDate,
                              ),
                              buildEpisodeMeta(
                                Icons.schedule_rounded,
                                episode.runtimeText,
                              ),
                              if (episode.voteAverage > 0)
                                buildEpisodeMeta(
                                  Icons.star_rounded,
                                  episode.voteAverage.toStringAsFixed(
                                    1,
                                  ),
                                  accent: true,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (episode.overview.isNotEmpty) ...[
                  const SizedBox(
                    height: 13,
                  ),
                  Text(
                    episode.overview,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.65,
                    ),
                  ),
                ],
                const SizedBox(
                  height: 15,
                ),
                buildEpisodeActionButton(
                  episode: episode,
                  watched: watched,
                  saving: saving,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEpisodeImage(
    Episode episode,
    bool watched,
  ) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (episode.stillUrl.isEmpty)
            const ColoredBox(
              color: AppColors.surfaceLight,
              child: Center(
                child: Icon(
                  Icons.movie_filter_outlined,
                  color: AppColors.textMuted,
                  size: 48,
                ),
              ),
            )
          else
            CachedNetworkImage(
              imageUrl: episode.stillUrl,
              fit: BoxFit.cover,
              placeholder: (
                context,
                url,
              ) {
                return const ColoredBox(
                  color: AppColors.surfaceLight,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorWidget: (
                context,
                url,
                error,
              ) {
                return const ColoredBox(
                  color: AppColors.surfaceLight,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.textMuted,
                    ),
                  ),
                );
              },
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(
                      0.55,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: buildEpisodeStateBadge(
              episode,
              watched,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEpisodeStateBadge(
    Episode episode,
    bool watched,
  ) {
    Color color;
    IconData icon;
    String text;

    if (!episode.isReleased) {
      color = AppColors.textSecondary;
      icon = Icons.schedule_rounded;
      text = 'منتشر نشده';
    } else if (watched) {
      color = AppColors.success;
      icon = Icons.check_rounded;
      text = 'دیده شده';
    } else {
      color = AppColors.primaryLight;
      icon = Icons.play_arrow_rounded;
      text = 'آماده تماشا';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(
          0xDD101016,
        ),
        borderRadius: BorderRadius.circular(
          10,
        ),
        border: Border.all(
          color: color.withOpacity(
            0.40,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEpisodeMeta(
    IconData icon,
    String text, {
    bool accent = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: accent
            ? AppColors.secondary.withOpacity(
                0.10,
              )
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(
          9,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: accent ? AppColors.rating : AppColors.textMuted,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            text,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEpisodeActionButton({
    required Episode episode,
    required bool watched,
    required bool saving,
  }) {
    if (!episode.isReleased) {
      return SizedBox(
        width: double.infinity,
        height: 47,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(
            Icons.schedule_rounded,
          ),
          label: const Text(
            'هنوز منتشر نشده',
          ),
        ),
      );
    }

    if (watched) {
      return SizedBox(
        width: double.infinity,
        height: 47,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.success,
          ),
          onPressed: saving
              ? null
              : () {
                  toggleEpisode(
                    episode,
                  );
                },
          icon: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.check_circle_rounded,
                ),
          label: const Text(
            'مشاهده شده',
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 47,
      child: FilledButton.icon(
        onPressed: saving
            ? null
            : () {
                toggleEpisode(
                  episode,
                );
              },
        icon: saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(
                Icons.radio_button_unchecked_rounded,
              ),
        label: const Text(
          'علامت‌گذاری به عنوان مشاهده‌شده',
        ),
      ),
    );
  }

  Widget buildLoading() {
    return const SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ),
            ),
            SizedBox(
              height: 14,
            ),
            Text(
              'در حال دریافت قسمت‌ها...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildError() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(
            28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error.withOpacity(
                    0.10,
                  ),
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 44,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              const Text(
                'اطلاعات فصل دریافت نشد',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(
                  height: 8,
                ),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(
                height: 20,
              ),
              FilledButton.icon(
                onPressed: () {
                  loadSeason(
                    forceRefresh: true,
                  );
                },
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'تلاش دوباره',
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              TextButton(
                onPressed: () {
                  Navigator.maybePop(
                    context,
                  );
                },
                child: const Text(
                  'بازگشت',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
