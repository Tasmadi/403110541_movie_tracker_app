import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/cast_member.dart';
import '../../models/season.dart';
import '../../models/season_arguments.dart';
import '../../models/series_detail.dart';
import '../../presenters/series_detail_presenter.dart';
import '../../widgets/media_action_panel.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';

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

  SeriesDetail? series;

  bool isLoading = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.seriesDetailPresenter;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'جزئیات سریال',
        ),
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: buildBody(),
        ),
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
        child: FilledButton.icon(
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
      );
    }

    SeriesDetail item = series!;

    return RefreshIndicator(
      onRefresh: () {
        return loadSeries(
          forceRefresh: true,
        );
      },
      child: ListView(
        padding: const EdgeInsets.only(
          bottom: 30,
        ),
        children: [
          buildBackdrop(item),
          buildMainInfo(item),
          MediaActionPanel(
            mediaId: item.id,
            mediaType: 'tv',
            title: item.name,
            posterPath: item.posterPath,
            releaseYear: item.firstAirYear,
          ),
          buildOverview(item),
          buildInformation(item),
          buildSeasons(item),
          buildCast(item),
        ],
      ),
    );
  }

  Widget buildBackdrop(
    SeriesDetail item,
  ) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: item.backdropUrl.isEmpty
          ? const Center(
              child: Icon(
                Icons.tv_rounded,
                size: 70,
              ),
            )
          : CachedNetworkImage(
              imageUrl: item.backdropUrl,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget buildMainInfo(
    SeriesDetail item,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              buildChip(
                Icons.calendar_month_rounded,
                item.firstAirYear,
              ),
              buildChip(
                Icons.star_rounded,
                'TMDB ${item.voteAverage.toStringAsFixed(1)}',
              ),
              buildChip(
                Icons.tv_rounded,
                '${item.numberOfSeasons} فصل',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildOverview(
    SeriesDetail item,
  ) {
    return buildSection(
      'خلاصه داستان',
      Text(
        item.overview.isEmpty ? 'خلاصه‌ای موجود نیست.' : item.overview,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: AppColors.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }

  Widget buildInformation(
    SeriesDetail item,
  ) {
    return buildSection(
      'اطلاعات سریال',
      Column(
        children: [
          buildInfoRow(
            'وضعیت پخش',
            item.status,
          ),
          buildInfoRow(
            'شروع پخش',
            item.firstAirYear,
          ),
          buildInfoRow(
            'پایان پخش',
            item.lastAirYear.isEmpty ? 'نامشخص' : item.lastAirYear,
          ),
          buildInfoRow(
            'تعداد فصل',
            item.numberOfSeasons.toString(),
          ),
          buildInfoRow(
            'تعداد قسمت',
            item.numberOfEpisodes.toString(),
          ),
          buildInfoRow(
            'ژانر',
            item.genres.join(', '),
          ),
          buildInfoRow(
            'سازنده',
            item.creators.isEmpty ? 'نامشخص' : item.creators.join(', '),
          ),
        ],
      ),
    );
  }

  Widget buildSeasons(
    SeriesDetail item,
  ) {
    return buildSection(
      'فصل‌ها',
      Column(
        children: item.seasons.map((season) {
          return buildSeasonCard(
            item,
            season,
          );
        }).toList(),
      ),
    );
  }

  Widget buildSeasonCard(
    SeriesDetail series,
    Season season,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.seasonDetail,
            arguments: SeasonArguments(
              seriesId: series.id,
              seasonNumber: season.seasonNumber,
              seriesName: series.name,
            ),
          );
        },
        leading: const CircleAvatar(
          child: Icon(
            Icons.video_library_rounded,
          ),
        ),
        title: Text(
          season.name,
          textDirection: TextDirection.ltr,
        ),
        subtitle: Text(
          '${season.episodeCount} قسمت'
          '${season.airYear.isEmpty ? '' : ' • ${season.airYear}'}',
        ),
        trailing: const Icon(
          Icons.chevron_left_rounded,
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
      'بازیگران',
      SizedBox(
        height: 155,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: item.cast.length,
          separatorBuilder: (
            context,
            index,
          ) {
            return const SizedBox(width: 12);
          },
          itemBuilder: (
            context,
            index,
          ) {
            CastMember member = item.cast[index];

            return SizedBox(
              width: 90,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundImage: member.profileUrl.isEmpty
                        ? null
                        : CachedNetworkImageProvider(
                            member.profileUrl,
                          ),
                    child: member.profileUrl.isEmpty
                        ? const Icon(
                            Icons.person_rounded,
                          )
                        : null,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    member.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    member.character,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildSection(
    String title,
    Widget child,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget buildInfoRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChip(
    IconData icon,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: AppColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
