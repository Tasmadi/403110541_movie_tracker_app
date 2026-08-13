import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/user_media_item.dart';
import '../../presenters/user_media_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/main_bottom_navigation.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({
    super.key,
  });

  @override
  State<WatchlistScreen> createState() {
    return _WatchlistScreenState();
  }
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  late final UserMediaPresenter presenter;

  List<UserMediaItem> watching = [];
  List<UserMediaItem> watched = [];
  List<UserMediaItem> planned = [];
  List<UserMediaItem> favorites = [];

  bool isLoading = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.userMediaPresenter;

    loadWatchlist();
  }

  Future<void> loadWatchlist() async {
    if (presenter.isGuest()) {
      setState(() {
        isLoading = false;
      });

      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      List<List<UserMediaItem>> results = await Future.wait([
        presenter.getWatching(),
        presenter.getWatched(),
        presenter.getPlanned(),
        presenter.getFavorites(),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        watching = results[0];
        watched = results[1];
        planned = results[2];
        favorites = results[3];

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

  void onNavigationSelected(
    int index,
  ) {
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) {
            return false;
          },
        );
        return;

      case 1:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.search,
        );
        return;

      case 2:
        return;

      case 3:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.customLists,
        );
        return;

      case 4:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.profile,
        );
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                buildHeader(),
                if (!presenter.isGuest()) buildTabBar(),
                Expanded(
                  child: buildBody(),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: MainBottomNavigation(
          currentIndex: 2,
          onSelected: onNavigationSelected,
        ),
      ),
    );
  }

  Widget buildHeader() {
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
            size: 42,
            showTitle: false,
            showTagline: false,
          ),
          const SizedBox(
            width: 10,
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'فهرست تماشا',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  'فیلم‌ها و سریال‌هایی که دنبال می‌کنی',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (!presenter.isGuest())
            Container(
              width: 42,
              height: 42,
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
                tooltip: 'به‌روزرسانی',
                onPressed: isLoading ? null : loadWatchlist,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 21,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        5,
        16,
        10,
      ),
      padding: const EdgeInsets.all(
        5,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: TabBar(
        isScrollable: true,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textMuted,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(
            13,
          ),
        ),
        tabs: const [
          Tab(
            text: 'در حال تماشا',
          ),
          Tab(
            text: 'تماشا شده',
          ),
          Tab(
            text: 'بعداً می‌بینم',
          ),
          Tab(
            text: 'علاقه‌مندی‌ها',
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    if (presenter.isGuest()) {
      return buildGuestView();
    }

    if (isLoading) {
      return buildLoading();
    }

    if (errorMessage != null) {
      return buildError();
    }

    return TabBarView(
      children: [
        buildList(
          watching,
          emptyText: 'فعلاً چیزی در حال تماشا نیست.',
          icon: Icons.play_circle_outline_rounded,
        ),
        buildList(
          watched,
          emptyText: 'هنوز اثری را تماشا شده علامت نزده‌اید.',
          icon: Icons.check_circle_outline_rounded,
        ),
        buildList(
          planned,
          emptyText: 'لیست «بعداً می‌بینم» خالی است.',
          icon: Icons.schedule_rounded,
        ),
        buildList(
          favorites,
          emptyText: 'هنوز اثری به علاقه‌مندی‌ها اضافه نشده.',
          icon: Icons.favorite_border_rounded,
        ),
      ],
    );
  }

  Widget buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
            'در حال دریافت فهرست...',
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          28,
          20,
          28,
          120,
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
                Icons.cloud_off_rounded,
                size: 42,
                color: AppColors.error,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            const Text(
              'دریافت فهرست انجام نشد',
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
              onPressed: loadWatchlist,
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

  Widget buildGuestView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          28,
          20,
          28,
          120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(
                  0.10,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(
                    0.22,
                  ),
                ),
              ),
              child: const Icon(
                Icons.bookmarks_outlined,
                size: 50,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(
              height: 22,
            ),
            const Text(
              'فهرست تماشای شخصی',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 9,
            ),
            const Text(
              'برای ذخیره وضعیت تماشا، علاقه‌مندی‌ها و برنامه‌های آینده وارد حساب کاربری خود شوید.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.7,
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.login,
                  );
                },
                icon: const Icon(
                  Icons.login_rounded,
                ),
                label: const Text(
                  'ورود به حساب',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildList(
    List<UserMediaItem> items, {
    required String emptyText,
    required IconData icon,
  }) {
    if (items.isEmpty) {
      return buildEmptyList(
        emptyText,
        icon,
      );
    }

    return RefreshIndicator(
      onRefresh: loadWatchlist,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          120,
        ),
        itemCount: items.length,
        separatorBuilder: (
          context,
          index,
        ) {
          return const SizedBox(
            height: 11,
          );
        },
        itemBuilder: (
          context,
          index,
        ) {
          return buildItem(
            items[index],
          );
        },
      ),
    );
  }

  Widget buildEmptyList(
    String message,
    IconData icon,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          28,
          20,
          28,
          120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Icon(
                icon,
                size: 42,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(
    UserMediaItem item,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(
          19,
        ),
        onTap: () async {
          await Navigator.pushNamed(
            context,
            item.isMovie ? AppRoutes.movieDetail : AppRoutes.seriesDetail,
            arguments: item.mediaId,
          );

          if (!mounted) {
            return;
          }

          await loadWatchlist();
        },
        child: Container(
          height: 128,
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
          child: Row(
            children: [
              SizedBox(
                width: 88,
                height: double.infinity,
                child: buildPoster(
                  item,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(
                    12,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          buildMediaTypeBadge(
                            item,
                          ),
                          if (item.releaseYear.isNotEmpty) ...[
                            const SizedBox(
                              width: 9,
                            ),
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              item.releaseYear,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          if (item.isFavorite)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(
                                  0.10,
                                ),
                                borderRadius: BorderRadius.circular(
                                  9,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.favorite_rounded,
                                    color: AppColors.error,
                                    size: 13,
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    'علاقه‌مندی',
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 12,
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
    );
  }

  Widget buildPoster(
    UserMediaItem item,
  ) {
    if (item.posterUrl.isEmpty) {
      return const ColoredBox(
        color: AppColors.surfaceLight,
        child: Center(
          child: Icon(
            Icons.movie_rounded,
            size: 38,
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
              color: AppColors.textMuted,
            ),
          ),
        );
      },
    );
  }

  Widget buildMediaTypeBadge(
    UserMediaItem item,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(
          0.13,
        ),
        borderRadius: BorderRadius.circular(
          9,
        ),
      ),
      child: Text(
        item.mediaTypeTitle,
        style: const TextStyle(
          color: AppColors.primaryLight,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
