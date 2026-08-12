import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/home_data.dart';
import '../../models/search_result_item.dart';
import '../../presenters/home_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomePresenter presenter;

  HomeData? homeData;

  bool isLoading = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.homePresenter;

    loadHome();
  }

  Future<void> loadHome({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      setState(() {
        isLoading = true;
      });
    }

    setState(() {
      errorMessage = null;
    });

    try {
      HomeData result = await presenter.loadHome(
        forceRefresh: forceRefresh,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        homeData = result;
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
          'ردیاب فیلم و سریال',
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.search,
              );
            },
            tooltip: 'جستجو',
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
              Icons.person_outline_rounded,
            ),
          ),
        ],
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

    if (errorMessage != null || homeData == null) {
      return buildError();
    }

    return RefreshIndicator(
      onRefresh: () {
        return loadHome(
          forceRefresh: true,
        );
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          bottom: 28,
        ),
        children: [
          buildHeader(),
          buildSection(
            title: 'محبوب‌ترین فیلم‌ها',
            icon: Icons.local_fire_department_rounded,
            items: homeData!.popularMovies,
          ),
          buildSection(
            title: 'محبوب‌ترین سریال‌ها',
            icon: Icons.tv_rounded,
            items: homeData!.popularSeries,
          ),
          buildSection(
            title: 'تازه‌ها',
            icon: Icons.auto_awesome_rounded,
            items: homeData!.newReleases,
          ),
          buildSection(
            title: 'بالاترین امتیاز',
            icon: Icons.star_rounded,
            items: homeData!.topRated,
          ),
          buildSection(
            title: 'پیشنهاد برای شما',
            icon: Icons.recommend_rounded,
            items: homeData!.recommendations,
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.movie_filter_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'چی ببینیم؟',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'فیلم‌ها و سریال‌های محبوب را پیدا و دنبال کن.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSection({
    required String title,
    required IconData icon,
    required List<SearchResultItem> items,
  }) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 285,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (
                context,
                index,
              ) {
                return const SizedBox(
                  width: 12,
                );
              },
              itemBuilder: (
                context,
                index,
              ) {
                return buildMediaCard(
                  items[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMediaCard(
    SearchResultItem item,
  ) {
    return SizedBox(
      width: 145,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              item.isMovie ? AppRoutes.movieDetail : AppRoutes.seriesDetail,
              arguments: item.id,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: 198,
                child: item.posterUrl.isEmpty
                    ? Container(
                        color: const Color(
                          0xFFE8E8EE,
                        ),
                        child: const Icon(
                          Icons.movie_rounded,
                          size: 45,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: item.posterUrl,
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
                          return const Icon(
                            Icons.broken_image_outlined,
                          );
                        },
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(
                    9,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            item.voteAverage.toStringAsFixed(
                              1,
                            ),
                            style: const TextStyle(
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            item.releaseYear,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 60,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'دریافت اطلاعات صفحه اصلی با خطا مواجه شد.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                loadHome(
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
}
