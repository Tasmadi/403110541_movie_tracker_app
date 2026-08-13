import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/cast_member.dart';
import '../../models/custom_list_media_arguments.dart';
import '../../models/movie_detail.dart';
import '../../presenters/movie_detail_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';
import '../../widgets/media_action_panel.dart';
import '../../widgets/rating_panel.dart';
import '../../widgets/review_panel.dart';

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

    if (errorMessage != null || movie == null) {
      return buildError();
    }

    MovieDetail currentMovie = movie!;

    return RefreshIndicator(
      onRefresh: () {
        return loadMovie(
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
            currentMovie,
          ),
          const SizedBox(
            height: 16,
          ),
          MediaActionPanel(
            mediaId: currentMovie.id,
            mediaType: 'movie',
            title: currentMovie.title,
            posterPath: currentMovie.posterPath,
            releaseYear: currentMovie.releaseYear,
          ),
          buildCustomListButton(
            currentMovie,
          ),
          RatingPanel(
            mediaId: currentMovie.id,
            mediaType: 'movie',
          ),
          buildOverview(
            currentMovie,
          ),
          buildInformation(
            currentMovie,
          ),
          buildCast(
            currentMovie,
          ),
          ReviewPanel(
            mediaId: currentMovie.id,
            mediaType: 'movie',
          ),
        ],
      ),
    );
  }

  Widget buildHero(
    MovieDetail movie,
  ) {
    double statusBar = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 390,
      child: Stack(
        fit: StackFit.expand,
        children: [
          buildBackdrop(
            movie,
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
              movie,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBackdrop(
    MovieDetail movie,
  ) {
    if (movie.backdropUrl.isEmpty) {
      return const ColoredBox(
        color: AppColors.surfaceLight,
        child: Center(
          child: Icon(
            Icons.movie_creation_outlined,
            size: 72,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: movie.backdropUrl,
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
    MovieDetail movie,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        buildPoster(
          movie,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildMovieBadge(),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  movie.title,
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
                if (movie.originalTitle != movie.title) ...[
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    movie.originalTitle,
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
                      text: movie.releaseYear.isEmpty
                          ? 'نامشخص'
                          : movie.releaseYear,
                    ),
                    buildMetaBadge(
                      icon: Icons.schedule_rounded,
                      text: movie.runtimeText,
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
                      rating: movie.voteAverage.toStringAsFixed(
                        1,
                      ),
                      icon: Icons.star_rounded,
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    buildRatingBadge(
                      label: 'IMDb',
                      rating: movie.imdbRatingText,
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
    MovieDetail movie,
  ) {
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
      child: movie.posterUrl.isEmpty
          ? const Center(
              child: Icon(
                Icons.movie_rounded,
                size: 44,
                color: AppColors.textMuted,
              ),
            )
          : CachedNetworkImage(
              imageUrl: movie.posterUrl,
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

  Widget buildMovieBadge() {
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
        'فیلم',
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

  Widget buildCustomListButton(
    MovieDetail movie,
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
                mediaId: movie.id,
                mediaType: 'movie',
                title: movie.title,
                posterPath: movie.posterPath,
                releaseYear: movie.releaseYear,
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
    MovieDetail movie,
  ) {
    return buildSection(
      icon: Icons.menu_book_rounded,
      title: 'خلاصه داستان',
      child: Text(
        movie.overview.isEmpty
            ? 'خلاصه‌ای برای این فیلم موجود نیست.'
            : movie.overview,
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
    MovieDetail movie,
  ) {
    return buildSection(
      icon: Icons.info_outline_rounded,
      title: 'اطلاعات فیلم',
      child: Column(
        children: [
          buildInformationRow(
            icon: Icons.movie_creation_outlined,
            title: 'کارگردان',
            value: movie.director.isEmpty ? 'نامشخص' : movie.director,
          ),
          buildDivider(),
          buildInformationRow(
            icon: Icons.category_outlined,
            title: 'ژانر',
            value: movie.genres.isEmpty
                ? 'نامشخص'
                : movie.genres.join(
                    ', ',
                  ),
          ),
          buildDivider(),
          buildInformationRow(
            icon: Icons.public_rounded,
            title: 'کشور سازنده',
            value: movie.countries.isEmpty
                ? 'نامشخص'
                : movie.countries.join(
                    ', ',
                  ),
          ),
          buildDivider(),
          buildInformationRow(
            icon: Icons.how_to_vote_outlined,
            title: 'رأی‌های TMDB',
            value: movie.voteCount.toString(),
          ),
          buildDivider(),
          buildInformationRow(
            icon: Icons.local_movies_outlined,
            title: 'امتیاز IMDb',
            value: movie.imdbRatingText,
          ),
          buildDivider(),
          buildInformationRow(
            icon: Icons.people_outline_rounded,
            title: 'رأی‌های IMDb',
            value: movie.imdbVotesText,
          ),
          buildDivider(),
          buildInformationRow(
            icon: Icons.tag_rounded,
            title: 'IMDb ID',
            value: movie.imdbId ?? 'نامشخص',
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
          itemCount: movie.cast.length,
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
              'در حال دریافت اطلاعات فیلم...',
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
                'اطلاعات فیلم دریافت نشد',
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
