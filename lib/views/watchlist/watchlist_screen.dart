import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/user_media_item.dart';
import '../../presenters/user_media_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'فهرست تماشا',
          ),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
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
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: buildBody(),
        ),
      ),
    );
  }

  Widget buildBody() {
    if (presenter.isGuest()) {
      return buildGuestView();
    }

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: FilledButton.icon(
          onPressed: loadWatchlist,
          icon: const Icon(
            Icons.refresh_rounded,
          ),
          label: const Text(
            'تلاش دوباره',
          ),
        ),
      );
    }

    return TabBarView(
      children: [
        buildList(watching),
        buildList(watched),
        buildList(planned),
        buildList(favorites),
      ],
    );
  }

  Widget buildGuestView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bookmark_outline_rounded,
              size: 72,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 18),
            const Text(
              'فهرست تماشا مخصوص کاربران عضو است.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.login,
                );
              },
              child: const Text(
                'ورود به حساب',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildList(
    List<UserMediaItem> items,
  ) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'هنوز اثری در این بخش وجود ندارد.',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadWatchlist,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (
          context,
          index,
        ) {
          return const SizedBox(
            height: 10,
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

  Widget buildItem(
    UserMediaItem item,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
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
        child: SizedBox(
          height: 125,
          child: Row(
            children: [
              SizedBox(
                width: 85,
                height: double.infinity,
                child: item.posterUrl.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.movie_rounded,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: item.posterUrl,
                        fit: BoxFit.cover,
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        item.mediaTypeTitle,
                        style: const TextStyle(
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            item.releaseYear,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          if (item.isFavorite)
                            const Icon(
                              Icons.favorite_rounded,
                              color: AppColors.error,
                              size: 19,
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
}
