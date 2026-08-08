import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/cast_member.dart';
import '../../models/movie_detail.dart';
import '../../presenters/movie_detail_presenter.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({
    super.key,
    required this.movieId,
  });

  @override
  State<MovieDetailScreen> createState() {
    return _MovieDetailScreenState();
  }
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late final MovieDetailPresenter presenter;

  MovieDetail? movie;

  bool isLoading = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.movieDetailPresenter;

    loadMovie();
  }

  Future<void> loadMovie({
    bool forceRefresh = false,
  }) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      MovieDetail result = await presenter.loadMovieDetail(
        widget.movieId,
        forceRefresh: forceRefresh,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        movie = result;
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
          'جزئیات فیلم',
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  loadMovie(
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
            ],
          ),
        ),
      );
    }

    MovieDetail currentMovie = movie!;

    return RefreshIndicator(
      onRefresh: () {
        return loadMovie(
          forceRefresh: true,
        );
      },
      child: ListView(
        padding: const EdgeInsets.only(
          bottom: 30,
        ),
        children: [
          buildPoster(currentMovie),
          buildMainInformation(
            currentMovie,
          ),
          buildOverview(currentMovie),
          buildInformation(currentMovie),
          buildCast(currentMovie),
        ],
      ),
    );
  }

  Widget buildPoster(
    MovieDetail movie,
  ) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: movie.backdropUrl.isEmpty
          ? Container(
              color: const Color(
                0xFFE6E6EC,
              ),
              child: const Center(
                child: Icon(
                  Icons.movie_rounded,
                  size: 72,
                ),
              ),
            )
          : CachedNetworkImage(
              imageUrl: movie.backdropUrl,
              fit: BoxFit.cover,
              placeholder: (
                context,
                url,
              ) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              errorWidget: (
                context,
                url,
                error,
              ) {
                return const Center(
                  child: Icon(
                    Icons.broken_image_rounded,
                    size: 64,
                  ),
                );
              },
            ),
    );
  }

  Widget buildMainInformation(
    MovieDetail movie,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie.title,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (movie.originalTitle != movie.title) ...[
            const SizedBox(height: 6),
            Text(
              movie.originalTitle,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              buildChip(
                Icons.calendar_month_rounded,
                movie.releaseYear.isEmpty ? 'سال نامشخص' : movie.releaseYear,
              ),
              buildChip(
                Icons.schedule_rounded,
                movie.runtimeText,
              ),
              buildChip(
                Icons.star_rounded,
                'TMDB ${movie.voteAverage.toStringAsFixed(1)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildOverview(
    MovieDetail movie,
  ) {
    return buildSection(
      title: 'خلاصه داستان',
      child: Text(
        movie.overview.isEmpty
            ? 'خلاصه‌ای برای این فیلم موجود نیست.'
            : movie.overview,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: AppColors.textSecondary,
          height: 1.6,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget buildInformation(
    MovieDetail movie,
  ) {
    return buildSection(
      title: 'اطلاعات فیلم',
      child: Column(
        children: [
          buildInformationRow(
            'کارگردان',
            movie.director.isEmpty ? 'نامشخص' : movie.director,
          ),
          buildInformationRow(
            'ژانر',
            movie.genres.isEmpty ? 'نامشخص' : movie.genres.join(', '),
          ),
          buildInformationRow(
            'کشور سازنده',
            movie.countries.isEmpty ? 'نامشخص' : movie.countries.join(', '),
          ),
          buildInformationRow(
            'تعداد رأی TMDB',
            movie.voteCount.toString(),
          ),
          buildInformationRow(
            'IMDb ID',
            movie.imdbId ?? 'نامشخص',
          ),
        ],
      ),
    );
  }

  Widget buildCast(
    MovieDetail movie,
  ) {
    if (movie.cast.isEmpty) {
      return const SizedBox.shrink();
    }

    return buildSection(
      title: 'بازیگران',
      child: SizedBox(
        height: 165,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: movie.cast.length,
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
            return buildCastItem(
              movie.cast[index],
            );
          },
        ),
      ),
    );
  }

  Widget buildCastItem(
    CastMember member,
  ) {
    return SizedBox(
      width: 95,
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: const Color(0xFFE6E6EC),
            backgroundImage: member.profileUrl.isEmpty
                ? null
                : CachedNetworkImageProvider(
                    member.profileUrl,
                  ),
            child: member.profileUrl.isEmpty
                ? const Icon(
                    Icons.person_rounded,
                    size: 40,
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            member.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            member.character,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSection({
    required String title,
    required Widget child,
  }) {
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
              color: AppColors.textPrimary,
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

  Widget buildInformationRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
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
        color: AppColors.primary.withOpacity(
          0.10,
        ),
        borderRadius: BorderRadius.circular(
          12,
        ),
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
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
