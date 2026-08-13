import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/home_data.dart';
import '../../models/search_result_item.dart';
import '../../presenters/home_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/main_bottom_navigation.dart';

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
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: buildBody(),
        ),
      ),
      bottomNavigationBar: MainBottomNavigation(
        currentIndex: 0,
        onSelected: onNavigationSelected,
      ),
    );
  }

  void onNavigationSelected(
    int index,
  ) {
    switch (index) {
      case 0:
        return;

      case 1:
        Navigator.pushNamed(
          context,
          AppRoutes.search,
        );
        return;

      case 2:
        Navigator.pushNamed(
          context,
          AppRoutes.watchlist,
        );
        return;

      case 3:
        Navigator.pushNamed(
          context,
          AppRoutes.customLists,
        );
        return;

      case 4:
        Navigator.pushNamed(
          context,
          AppRoutes.profile,
        );
        return;
    }
  }

  Widget buildBody() {
    if (isLoading) {
      return buildLoading();
    }

    if (errorMessage != null || homeData == null) {
      return buildError();
    }

    HomeData data = homeData!;

    return RefreshIndicator(
      onRefresh: () {
        return loadHome(
          forceRefresh: true,
        );
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          bottom: 120,
        ),
        children: [
          buildTopHeader(),
          buildHero(data),
          buildSection(
            title: 'محبوب‌ترین فیلم‌ها',
            subtitle: 'فیلم‌هایی که این روزها همه درباره‌شان صحبت می‌کنند',
            icon: Icons.local_fire_department_rounded,
            items: data.popularMovies,
          ),
          buildSection(
            title: 'محبوب‌ترین سریال‌ها',
            subtitle: 'سریال‌های پرطرفدار برای تماشای بعدی',
            icon: Icons.tv_rounded,
            items: data.popularSeries,
          ),
          buildSection(
            title: 'تازه‌ها',
            subtitle: 'جدیدترین فیلم‌ها و سریال‌ها',
            icon: Icons.auto_awesome_rounded,
            items: data.newReleases,
          ),
          buildSection(
            title: 'بالاترین امتیاز',
            subtitle: 'آثاری که بیشترین رضایت مخاطبان را گرفته‌اند',
            icon: Icons.star_rounded,
            items: data.topRated,
          ),
          buildSection(
            title: 'پیشنهاد برای شما',
            subtitle: 'انتخاب‌هایی بر اساس فعالیت شما',
            icon: Icons.recommend_rounded,
            items: data.recommendations,
          ),
        ],
      ),
    );
  }

  Widget buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        10,
      ),
      child: Row(
        children: [
          const AppLogo(
            size: 43,
            showTitle: false,
            showTagline: false,
          ),
          const SizedBox(
            width: 10,
          ),
          const Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  Text(
                    'TV',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Time',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          buildHeaderButton(
            icon: Icons.search_rounded,
            tooltip: 'جست‌وجو',
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.search,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildHeaderButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(
          icon,
          color: AppColors.textPrimary,
          size: 22,
        ),
      ),
    );
  }

  Widget buildHero(
    HomeData data,
  ) {
    SearchResultItem? heroItem;

    if (data.popularMovies.isNotEmpty) {
      heroItem = data.popularMovies.first;
    } else if (data.popularSeries.isNotEmpty) {
      heroItem = data.popularSeries.first;
    }

    if (heroItem == null) {
      return const SizedBox.shrink();
    }

    SearchResultItem currentItem = heroItem;

    return Container(
      height: 205,
      margin: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        10,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          26,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(
              0.09,
            ),
            blurRadius: 30,
            offset: const Offset(
              0,
              12,
            ),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 150,
            child: buildHeroPoster(
              currentItem,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    AppColors.surface.withOpacity(
                      0.72,
                    ),
                    AppColors.surface,
                    AppColors.surface,
                  ],
                  stops: const [
                    0,
                    0.34,
                    0.64,
                    1,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              115,
              18,
              18,
              18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    buildFeaturedBadge(),
                    const SizedBox(
                      width: 8,
                    ),
                    buildTypeBadge(
                      currentItem,
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    currentItem.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.rating,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      currentItem.voteAverage.toStringAsFixed(
                        1,
                      ),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (currentItem.releaseYear.isNotEmpty) ...[
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.textMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        currentItem.releaseYear,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(
                  height: 13,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 40,
                    child: FilledButton.icon(
                      onPressed: () {
                        openMedia(
                          currentItem,
                        );
                      },
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                        size: 20,
                      ),
                      label: const Text(
                        'مشاهده',
                      ),
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

  Widget buildHeroPoster(
    SearchResultItem item,
  ) {
    if (item.posterUrl.isEmpty) {
      return const ColoredBox(
        color: AppColors.surfaceLight,
        child: Center(
          child: Icon(
            Icons.movie_creation_outlined,
            color: AppColors.textMuted,
            size: 52,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: item.posterUrl,
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
              size: 40,
            ),
          ),
        );
      },
    );
  }

  Widget buildFeaturedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(
          0.14,
        ),
        borderRadius: BorderRadius.circular(
          10,
        ),
        border: Border.all(
          color: AppColors.secondary.withOpacity(
            0.35,
          ),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: AppColors.secondary,
            size: 14,
          ),
          SizedBox(
            width: 4,
          ),
          Text(
            'ترند',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<SearchResultItem> items,
  }) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(
                      0.12,
                    ),
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryLight,
                    size: 20,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 13,
          ),
          SizedBox(
            height: 275,
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
      width: 148,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            19,
          ),
          onTap: () {
            openMedia(
              item,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(
                19,
              ),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 198,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      buildPoster(
                        item,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: buildRatingBadge(
                          item,
                        ),
                      ),
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: buildTypeBadge(
                          item,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      9,
                      9,
                      9,
                      8,
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
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Expanded(
                              child: Text(
                                item.releaseYear.isEmpty
                                    ? '—'
                                    : item.releaseYear,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 11,
                              color: AppColors.textMuted,
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
      ),
    );
  }

  Widget buildPoster(
    SearchResultItem item,
  ) {
    if (item.posterUrl.isEmpty) {
      return const ColoredBox(
        color: AppColors.surfaceLight,
        child: Center(
          child: Icon(
            Icons.movie_rounded,
            size: 44,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: item.posterUrl,
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
              size: 40,
              color: AppColors.textMuted,
            ),
          ),
        );
      },
    );
  }

  Widget buildRatingBadge(
    SearchResultItem item,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(
          0xDD101016,
        ),
        borderRadius: BorderRadius.circular(
          10,
        ),
        border: Border.all(
          color: AppColors.rating.withOpacity(
            0.30,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: AppColors.rating,
            size: 13,
          ),
          const SizedBox(
            width: 3,
          ),
          Text(
            item.voteAverage.toStringAsFixed(
              1,
            ),
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

  Widget buildTypeBadge(
    SearchResultItem item,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(
          0.86,
        ),
        borderRadius: BorderRadius.circular(
          9,
        ),
      ),
      child: Text(
        item.mediaTypeTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void openMedia(
    SearchResultItem item,
  ) {
    if (item.isMovie) {
      Navigator.pushNamed(
        context,
        AppRoutes.movieDetail,
        arguments: item.id,
      );

      return;
    }

    if (item.isSeries) {
      Navigator.pushNamed(
        context,
        AppRoutes.seriesDetail,
        arguments: item.id,
      );
    }
  }

  Widget buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLogo(
            size: 70,
            showTagline: false,
          ),
          SizedBox(
            height: 28,
          ),
          SizedBox(
            width: 38,
            height: 38,
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),
          SizedBox(
            height: 14,
          ),
          Text(
            'در حال آماده‌سازی پیشنهادها...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildError() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(
          28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(
                  0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 42,
                color: AppColors.error,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'ارتباط برقرار نشد',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              'دریافت اطلاعات صفحه اصلی با خطا مواجه شد.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.6,
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
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
            const SizedBox(
              height: 22,
            ),
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
