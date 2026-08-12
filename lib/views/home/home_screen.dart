import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

import '../../models/movie.dart';
import '../../presenters/home_presenter.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomePresenter presenter;

  List<Movie> movies = [];

  bool isLoading = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.homePresenter;

    loadMovies();
  }

  Future<void> loadMovies({
    bool forceRefresh = false,
  }) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      List<Movie> result = await presenter.loadPopularMovies(
        forceRefresh: forceRefresh,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        movies = result;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage = error.toString().replaceFirst(
              'Exception: ',
              '',
            );

        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.appName,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.search,
              );
            },
            tooltip: 'جست‌وجو',
            icon: const Icon(
              Icons.search_rounded,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.watchlist,
              );
            },
            tooltip: 'فهرست تماشا',
            icon: const Icon(
              Icons.bookmarks_outlined,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.customLists,
              );
            },
            tooltip: 'فهرست‌های شخصی',
            icon: const Icon(
              Icons.playlist_play_rounded,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.profile,
              );
            },
            tooltip: 'پروفایل',
            icon: const Icon(
              Icons.account_circle_outlined,
            ),
          ),
        ],
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
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  loadMovies(
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

    return RefreshIndicator(
      onRefresh: () {
        return loadMovies(
          forceRefresh: true,
        );
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'فیلم‌های محبوب',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'محبوب‌ترین فیلم‌های IMDb',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: movies.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              crossAxisSpacing: 14,
              mainAxisSpacing: 18,
            ),
            itemBuilder: (context, index) {
              Movie movie = movies[index];

              return buildMovieCard(movie);
            },
          ),
        ],
      ),
    );
  }

  Widget buildMovieCard(Movie movie) {
    return InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.movieDetail,
            arguments: movie.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: movie.posterUrl.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.movie_rounded,
                          size: 48,
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
                              size: 48,
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.secondary,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          movie.voteAverage.toStringAsFixed(1),
                        ),
                        const Spacer(),
                        Text(
                          movie.releaseYear,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
