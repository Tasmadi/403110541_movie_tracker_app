import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/episode.dart';
import '../../models/season_arguments.dart';
import '../../models/season_detail.dart';
import '../../presenters/series_detail_presenter.dart';
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

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.seriesDetailPresenter;

    loadSeason();
  }

  Future<void> loadSeason() async {
    try {
      SeasonDetail result = await presenter.loadSeasonDetail(
        widget.arguments.seriesId,
        widget.arguments.seasonNumber,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        season = result;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
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

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: season!.episodes.length,
      separatorBuilder: (
        context,
        index,
      ) {
        return const SizedBox(height: 12);
      },
      itemBuilder: (
        context,
        index,
      ) {
        return buildEpisodeCard(
          season!.episodes[index],
        );
      },
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
