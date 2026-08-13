import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/cast_member.dart';
import '../../models/custom_list_media_arguments.dart';
import '../../models/season.dart';
import '../../models/season_arguments.dart';
import '../../models/series_detail.dart';
import '../../models/series_progress.dart';
import '../../presenters/episode_progress_presenter.dart';
import '../../presenters/series_detail_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/api_config.dart';
import '../../utils/app_colors.dart';
import '../../widgets/media_action_panel.dart';
import '../../widgets/rating_panel.dart';
import '../../widgets/review_panel.dart';

class SeriesDetailScreen extends StatefulWidget {
  final int seriesId;

  const SeriesDetailScreen({
    super.key,
    required this.seriesId,
  });

  @override
  State<SeriesDetailScreen> createState() {
    return _SeriesDetailScreenState();
  }
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen> {
  late final SeriesDetailPresenter presenter;

  late final EpisodeProgressPresenter progressPresenter;

  SeriesDetail? series;

  SeriesProgress? progress;

  bool isLoading = true;

  bool isProgressLoading = false;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.seriesDetailPresenter;

    progressPresenter = ServiceLocator.episodeProgressPresenter;

    loadSeries();
  }

  Future<void> loadSeries({
    bool forceRefresh = false,
  }) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      SeriesDetail result = await presenter.loadSeriesDetail(
        widget.seriesId,
        forceRefresh: forceRefresh,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        series = result;
        isLoading = false;
      });

      await loadProgress(
        result,
      );
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

  Future<void> loadProgress(
    SeriesDetail item,
  ) async {
    if (progressPresenter.isGuest()) {
      return;
    }

    setState(() {
      isProgressLoading = true;
    });

    try {
      SeriesProgress result = await progressPresenter.loadSeriesProgress(
        item,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        progress = result;
        isProgressLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        isProgressLoading = false;
      });
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

    if (errorMessage != null || series == null) {
      return buildError();
    }

    SeriesDetail item = series!;

    return RefreshIndicator(
      onRefresh: () {
        return loadSeries(
          forceRefresh: true,
        );
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          bottom: 34,
        ),
        children: [
          buildHero(
            item,
          ),
          buildProgressSection(),
          const SizedBox(
            height: 4,
          ),
          MediaActionPanel(
            mediaId: item.id,
            mediaType: 'tv',
            title: item.name,
            posterPath: item.posterPath,
            releaseYear: item.firstAirYear,
            onChanged: () {
              loadProgress(
                item,
              );
            },
          ),
          buildCustomListButton(
            item,
          ),
          RatingPanel(
            mediaId: item.id,
            mediaType: 'tv',
          ),
          buildOverview(
            item,
          ),
          buildInformation(
            item,
          ),
          buildSeasons(
            item,
          ),
          buildCast(
            item,
          ),
          ReviewPanel(
            mediaId: item.id,
            mediaType: 'tv',
          ),
        ],
      ),
    );
  }

  Widget buildHero(
    SeriesDetail item,
  ) {
    double statusBar = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 400,
      child: Stack(
        fit: StackFit.expand,
        children: [
          buildBackdrop(
            item,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x55000000),
                  Color(0x22000000),
                  Color(0xCC0D0D12),
                  AppColors.background,
                ],
                stops: [
                  0,
                  0.30,
                  0.72,
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
            left: 16,
            right: 16,
            bottom: 8,
            child: buildHeroInformation(
              item,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBackdrop(
    SeriesDetail item,
  ) {
    if (item.backdropUrl.isEmpty) {
      return const ColoredBox(
        color: AppColors.surfaceLight,
        child: Center(
          child: Icon(
            Icons.tv_rounded,
            size: 72,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: item.backdropUrl,
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
              size: 60,
              color: AppColors.textMuted,
            ),
          ),
        );
      },
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

  Widget buildHeroInformation(
    SeriesDetail item,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        buildPoster(
          item,
        ),
        const SizedBox(
          width: 14,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 4,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSeriesBadge(),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 23,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (item.originalName != item.name) ...[
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    item.originalName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
                const SizedBox(
                  height: 11,
                ),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    buildMetaBadge(
                      icon: Icons.calendar_month_rounded,
                      text: item.firstAirYear.isEmpty
                          ? 'نامشخص'
                          : item.firstAirYear,
                    ),
                    buildMetaBadge(
                      icon: Icons.tv_rounded,
                      text: '${item.numberOfSeasons} فصل',
                    ),
                    buildMetaBadge(
                      icon: Icons.play_circle_outline_rounded,
                      text: '${item.numberOfEpisodes} قسمت',
                    ),
                  ],
                ),
                const SizedBox(
                  height: 9,
                ),
                Row(
                  children: [
                    buildRatingBadge(
                      label: 'TMDB',
                      rating: item.voteAverage.toStringAsFixed(
                        1,
                      ),
                      icon: Icons.star_rounded,
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    buildRatingBadge(
                      label: 'IMDb',
                      rating: item.imdbRatingText,
                      icon: Icons.local_movies_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPoster(
    SeriesDetail item,
  ) {
    String posterUrl = getPosterUrl(
      item,
    );

    return Container(
      width: 112,
      height: 168,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(
            0.12,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.38,
            ),
            blurRadius: 24,
            offset: const Offset(
              0,
              10,
            ),
          ),
        ],
      ),
      child: posterUrl.isEmpty
          ? const Center(
              child: Icon(
                Icons.tv_rounded,
                size: 44,
                color: AppColors.textMuted,
              ),
            )
          : CachedNetworkImage(
              imageUrl: posterUrl,
              fit: BoxFit.cover,
              placeholder: (
                context,
                url,
              ) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                );
              },
              errorWidget: (
                context,
                url,
                error,
              ) {
                return const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textMuted,
                  ),
                );
              },
            ),
    );
  }

  String getPosterUrl(
    SeriesDetail item,
  ) {
    if (item.posterPath == null || item.posterPath!.isEmpty) {
      return '';
    }

    return '${ApiConfig.imageBaseUrl}${item.posterPath}';
  }

  Widget buildSeriesBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(
          0.85,
        ),
        borderRadius: BorderRadius.circular(
          9,
        ),
      ),
      child: const Text(
        'سریال',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget buildMetaBadge({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(
          0xAA17171F,
        ),
        borderRadius: BorderRadius.circular(
          9,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(
            0.08,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.textSecondary,
            size: 13,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRatingBadge({
    required String label,
    required String rating,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(
          0.10,
        ),
        borderRadius: BorderRadius.circular(
          9,
        ),
        border: Border.all(
          color: AppColors.secondary.withOpacity(
            0.22,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.rating,
            size: 14,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            '$label $rating',
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProgressSection() {
    if (progressPresenter.isGuest()) {
      return const SizedBox.shrink();
    }

    if (isProgressLoading) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          18,
        ),
        child: LinearProgressIndicator(),
      );
    }

    if (progress == null) {
      return const SizedBox.shrink();
    }

    Color progressColor = getProgressColor();

    String stateTitle = getProgressStateTitle();

    return Container(
      margin: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        20,
      ),
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          21,
        ),
        border: Border.all(
          color: progressColor.withOpacity(
            0.35,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(
                    0.13,
                  ),
                  borderRadius: BorderRadius.circular(
                    13,
                  ),
                  border: progress!.state == SeriesProgressState.notStarted
                      ? Border.all(
                          color: AppColors.border,
                        )
                      : null,
                ),
                child: Icon(
                  getProgressIcon(),
                  color: progress!.state == SeriesProgressState.notStarted
                      ? AppColors.textSecondary
                      : progressColor,
                  size: 22,
                ),
              ),
              const SizedBox(
                width: 11,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'پیشرفت تماشا',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      stateTitle,
                      style: TextStyle(
                        color: progress!.state == SeriesProgressState.notStarted
                            ? AppColors.textSecondary
                            : progressColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${progress!.percentage}٪',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: progress!.state == SeriesProgressState.notStarted
                      ? AppColors.textPrimary
                      : progressColor,
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
              value: progress!.progress,
              minHeight: 9,
              color: progressColor,
              backgroundColor: AppColors.surfaceLight,
            ),
          ),
          const SizedBox(
            height: 11,
          ),
          Row(
            children: [
              Expanded(
                child: buildProgressValue(
                  '${progress!.watchedEpisodes}',
                  'دیده‌شده',
                ),
              ),
              buildProgressDivider(),
              Expanded(
                child: buildProgressValue(
                  '${progress!.releasedEpisodes}',
                  'منتشرشده',
                ),
              ),
              buildProgressDivider(),
              Expanded(
                child: buildProgressValue(
                  '${progress!.remainingEpisodes}',
                  'باقی‌مانده',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color getProgressColor() {
    switch (progress!.state) {
      case SeriesProgressState.completed:
        return AppColors.primary;

      case SeriesProgressState.upToDate:
        return AppColors.success;

      case SeriesProgressState.stopped:
        return AppColors.error;

      case SeriesProgressState.inProgress:
        return AppColors.warning;

      default:
        return const Color(
          0xFF050509,
        );
    }
  }

  String getProgressStateTitle() {
    switch (progress!.state) {
      case SeriesProgressState.completed:
        return 'تماشا کامل شده';

      case SeriesProgressState.upToDate:
        return 'تا آخرین قسمت به‌روز هستی';

      case SeriesProgressState.stopped:
        return 'تماشا متوقف شده';

      case SeriesProgressState.inProgress:
        return 'در حال تماشا';

      default:
        return 'هنوز شروع نشده';
    }
  }

  IconData getProgressIcon() {
    switch (progress!.state) {
      case SeriesProgressState.completed:
        return Icons.workspace_premium_rounded;

      case SeriesProgressState.upToDate:
        return Icons.check_circle_rounded;

      case SeriesProgressState.stopped:
        return Icons.pause_circle_filled_rounded;

      case SeriesProgressState.inProgress:
        return Icons.play_circle_fill_rounded;

      default:
        return Icons.radio_button_unchecked_rounded;
    }
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
      height: 35,
      color: AppColors.divider,
    );
  }

  Widget buildCustomListButton(
    SeriesDetail item,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        22,
      ),
      child: SizedBox(
        height: 50,
        child: OutlinedButton.icon(
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.customListPicker,
              arguments: CustomListMediaArguments(
                mediaId: item.id,
                mediaType: 'tv',
                title: item.name,
                posterPath: item.posterPath,
                releaseYear: item.firstAirYear,
              ),
            );
          },
          icon: const Icon(
            Icons.playlist_add_rounded,
          ),
          label: const Text(
            'افزودن به لیست شخصی',
          ),
        ),
      ),
    );
  }

  Widget buildOverview(
    SeriesDetail item,
  ) {
    return buildSection(
      icon: Icons.menu_book_rounded,
      title: 'خلاصه داستان',
      child: Text(
        item.overview.isEmpty
            ? 'خلاصه‌ای برای این سریال موجود نیست.'
            : item.overview,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          height: 1.75,
        ),
      ),
    );
  }

  Widget buildInformation(
    SeriesDetail item,
  ) {
    return buildSection(
      icon: Icons.info_outline_rounded,
      title: 'اطلاعات سریال',
      child: Column(
        children: [
          buildInformationRow(
            icon: Icons.live_tv_rounded,
            title: 'وضعیت پخش',
            value: item.status.isEmpty ? 'نامشخص' : item.status,
          ),
          buildDivider(),
          buildInformationRow(
            icon: Icons.calendar_month_outlined,
            title: 'شروع پخش',
            value: item.firstAirYear.isEmpty ? 'نامشخص' : item.firstAirYear,
          ),
          buildDivider(),
          buildInformationRow(
            icon: Icons.event_available_rounded,
            title: 'پایان پخش',
            value: item.lastAirYear.isEmpty ? 'نامشخص' : item.lastAirYear,
          ),
          buildDivider(),
          buildInformationRow(
            icon: Icons.video_library_outlined,
            title: 'تعداد فصل',
            value: item.numberOfSeasons.toString(),
          ),
          buildDivider(),
          buildInformationRow(
            icon: Icons.play_circle_outline,
            title: 'تعداد قسمت',
            value: item.numberOfEpisodes.toString(),
          ),
          buildDivider(),
          buildInformationRow(
            icon: Icons.category_outlined,
            title: 'ژانر',
            value: item.genres.isEmpty
                ? 'نامشخص'
                : item.genres.join(
                    ', ',
                  ),
          ),
          buildDivider(),
          buildInformationRow(
            icon: Icons.edit_note_rounded,
            title: 'سازنده',
            value: item.creators.isEmpty
                ? 'نامشخص'
                : item.creators.join(
                    ', ',
                  ),
          ),
          buildDivider(),
          buildInformationRow(
            icon: Icons.local_movies_outlined,
            title: 'امتیاز IMDb',
            value: item.imdbRatingText,
          ),
          buildDivider(),
          buildInformationRow(
            icon: Icons.people_outline_rounded,
            title: 'رأی‌های IMDb',
            value: item.imdbVotesText,
          ),
          buildDivider(),
          buildInformationRow(
            icon: Icons.tag_rounded,
            title: 'IMDb ID',
            value: item.imdbId ?? 'ناموجود',
          ),
        ],
      ),
    );
  }

  Widget buildSeasons(
    SeriesDetail item,
  ) {
    if (item.seasons.isEmpty) {
      return const SizedBox.shrink();
    }

    return buildSection(
      icon: Icons.video_collection_rounded,
      title: 'فصل‌ها',
      child: Column(
        children: item.seasons.map(
          (
            Season season,
          ) {
            return buildSeasonCard(
              item,
              season,
            );
          },
        ).toList(),
      ),
    );
  }

  Widget buildSeasonCard(
    SeriesDetail item,
    Season season,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            16,
          ),
          onTap: () async {
            await Navigator.pushNamed(
              context,
              AppRoutes.seasonDetail,
              arguments: SeasonArguments(
                seriesId: item.id,
                seasonNumber: season.seasonNumber,
                seriesName: item.name,
              ),
            );

            if (!mounted) {
              return;
            }

            await loadProgress(
              item,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(
              12,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(
                16,
              ),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(
                      0.13,
                    ),
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: const Icon(
                    Icons.video_library_rounded,
                    color: AppColors.primaryLight,
                    size: 23,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        season.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Text(
                            '${season.episodeCount} قسمت',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                          if (season.airYear.isNotEmpty) ...[
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                color: AppColors.textMuted,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              season.airYear,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textMuted,
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCast(
    SeriesDetail item,
  ) {
    if (item.cast.isEmpty) {
      return const SizedBox.shrink();
    }

    return buildSection(
      icon: Icons.groups_rounded,
      title: 'بازیگران',
      removeInnerPadding: true,
      child: SizedBox(
        height: 168,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: item.cast.length,
          separatorBuilder: (
            context,
            index,
          ) {
            return const SizedBox(
              width: 11,
            );
          },
          itemBuilder: (
            context,
            index,
          ) {
            return buildCastItem(
              item.cast[index],
            );
          },
        ),
      ),
    );
  }

  Widget buildCastItem(
    CastMember member,
  ) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(
        9,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(
          17,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: AppColors.surfaceElevated,
            backgroundImage: member.profileUrl.isEmpty
                ? null
                : CachedNetworkImageProvider(
                    member.profileUrl,
                  ),
            child: member.profileUrl.isEmpty
                ? const Icon(
                    Icons.person_rounded,
                    size: 37,
                    color: AppColors.textMuted,
                  )
                : null,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            member.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            member.character,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
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

  Widget buildSection({
    required IconData icon,
    required String title,
    required Widget child,
    bool removeInnerPadding = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        22,
      ),
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                15,
                14,
                15,
                12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(
                        0.11,
                      ),
                      borderRadius: BorderRadius.circular(
                        11,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 19,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(
                    width: 9,
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (removeInnerPadding)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 15,
                ),
                child: child,
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  15,
                  0,
                  15,
                  16,
                ),
                child: child,
              ),
          ],
        ),
      ),
    );
  }

  Widget buildInformationRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(
                0.08,
              ),
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.textMuted,
              size: 17,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          SizedBox(
            width: 86,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 7,
              ),
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 7,
              ),
              child: Text(
                value,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDivider() {
    return const Divider(
      color: AppColors.divider,
      height: 1,
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
              'در حال دریافت اطلاعات سریال...',
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
                'اطلاعات سریال دریافت نشد',
                textAlign: TextAlign.center,
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
                  loadSeries(
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
