import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/search_page_result.dart';
import '../../models/search_result_item.dart';
import '../../models/search_type.dart';
import '../../presenters/search_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/main_bottom_navigation.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
  });

  @override
  State<SearchScreen> createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchPresenter presenter;

  final TextEditingController searchController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  Timer? debounceTimer;

  List<SearchResultItem> results = [];

  SearchType selectedSearchType = SearchType.title;

  bool isLoading = false;

  bool isLoadingMore = false;

  bool hasSearched = false;

  bool hasMore = false;

  int currentPage = 1;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.searchPresenter;

    scrollController.addListener(
      onScroll,
    );
  }

  @override
  void dispose() {
    debounceTimer?.cancel();

    scrollController.removeListener(
      onScroll,
    );

    scrollController.dispose();
    searchController.dispose();

    super.dispose();
  }

  void onScroll() {
    if (!scrollController.hasClients) {
      return;
    }

    double currentPosition = scrollController.position.pixels;

    double maxPosition = scrollController.position.maxScrollExtent;

    if (currentPosition >= maxPosition - 300) {
      loadMore();
    }
  }

  void onSearchChanged(
    String value,
  ) {
    debounceTimer?.cancel();

    String query = value.trim();

    setState(() {});

    if (query.isEmpty) {
      setState(() {
        results = [];
        isLoading = false;
        isLoadingMore = false;
        hasSearched = false;
        hasMore = false;
        currentPage = 1;
        errorMessage = null;
      });

      return;
    }

    debounceTimer = Timer(
      const Duration(
        milliseconds: 500,
      ),
      () {
        search(
          query,
        );
      },
    );
  }

  void changeSearchType(
    SearchType type,
  ) {
    if (selectedSearchType == type) {
      return;
    }

    debounceTimer?.cancel();

    FocusScope.of(context).unfocus();

    setState(() {
      selectedSearchType = type;
      results = [];
      hasSearched = false;
      hasMore = false;
      currentPage = 1;
      errorMessage = null;
    });

    String query = searchController.text.trim();

    if (query.isNotEmpty) {
      search(
        query,
      );
    }
  }

  Future<void> search(
    String query,
  ) async {
    SearchType requestType = selectedSearchType;

    setState(() {
      isLoading = true;
      isLoadingMore = false;
      hasSearched = true;
      hasMore = false;
      currentPage = 1;
      errorMessage = null;
    });

    try {
      SearchPageResult pageResult = await presenter.searchPage(
        query: query,
        searchType: requestType,
        page: 1,
      );

      if (!mounted) {
        return;
      }

      if (searchController.text.trim() != query) {
        return;
      }

      if (selectedSearchType != requestType) {
        return;
      }

      setState(() {
        results = pageResult.items;

        currentPage = pageResult.page;

        hasMore = pageResult.hasMore;

        isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      if (searchController.text.trim() != query) {
        return;
      }

      if (selectedSearchType != requestType) {
        return;
      }

      setState(() {
        results = [];

        isLoading = false;

        hasMore = false;

        errorMessage = error.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  Future<void> loadMore() async {
    if (isLoading || isLoadingMore || !hasMore) {
      return;
    }

    String query = searchController.text.trim();

    if (query.isEmpty) {
      return;
    }

    SearchType requestType = selectedSearchType;

    int nextPage = currentPage + 1;

    setState(() {
      isLoadingMore = true;
    });

    try {
      SearchPageResult pageResult = await presenter.searchPage(
        query: query,
        searchType: requestType,
        page: nextPage,
      );

      if (!mounted) {
        return;
      }

      if (searchController.text.trim() != query) {
        return;
      }

      if (selectedSearchType != requestType) {
        return;
      }

      Map<String, SearchResultItem> uniqueItems = {};

      for (SearchResultItem item in results) {
        String key = '${item.mediaType}_${item.id}';

        uniqueItems[key] = item;
      }

      for (SearchResultItem item in pageResult.items) {
        String key = '${item.mediaType}_${item.id}';

        uniqueItems[key] = item;
      }

      setState(() {
        results = uniqueItems.values.toList();

        currentPage = pageResult.page;

        hasMore = pageResult.hasMore;

        isLoadingMore = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoadingMore = false;
      });

      String message = error.toString().replaceFirst(
            'Exception: ',
            '',
          );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
        ),
      );
    }
  }

  void submitSearch() {
    debounceTimer?.cancel();

    String query = searchController.text.trim();

    if (query.isEmpty) {
      return;
    }

    search(
      query,
    );
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
        return;

      case 2:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.watchlist,
        );
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

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              buildHeader(),
              buildSearchPanel(),
              Expanded(
                child: buildBody(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MainBottomNavigation(
        currentIndex: 1,
        onSelected: onNavigationSelected,
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        4,
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
                  'جست‌وجو',
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
                  'فیلم، سریال و عوامل موردنظرت را پیدا کن',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
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
              tooltip: 'بازگشت',
              onPressed: () {
                Navigator.maybePop(
                  context,
                );
              },
              icon: const Icon(
                Icons.arrow_forward_rounded,
                size: 21,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        8,
      ),
      padding: const EdgeInsets.all(
        14,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          22,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(
              0.06,
            ),
            blurRadius: 24,
            offset: const Offset(
              0,
              10,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSearchField(),
          const SizedBox(
            height: 14,
          ),
          const Text(
            'جست‌وجو بر اساس',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          buildSearchTypes(),
        ],
      ),
    );
  }

  Widget buildSearchTypes() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SearchType.values.map(
          (
            SearchType type,
          ) {
            bool selected = selectedSearchType == type;

            return Padding(
              padding: const EdgeInsets.only(
                left: 8,
              ),
              child: ChoiceChip(
                label: Text(
                  type.title,
                ),
                selected: selected,
                showCheckmark: false,
                avatar: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: Colors.white,
                      )
                    : null,
                onSelected: (_) {
                  changeSearchType(
                    type,
                  );
                },
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget buildSearchField() {
    return TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      onSubmitted: (_) {
        submitSearch();
      },
      keyboardType: selectedSearchType == SearchType.year
          ? TextInputType.number
          : TextInputType.text,
      textInputAction: TextInputAction.search,
      textDirection: TextDirection.ltr,
      decoration: InputDecoration(
        hintText: selectedSearchType.hint,
        prefixIcon: const Icon(
          Icons.search_rounded,
        ),
        suffixIcon: searchController.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'پاک کردن',
                onPressed: () {
                  debounceTimer?.cancel();

                  searchController.clear();

                  onSearchChanged(
                    '',
                  );
                },
                icon: const Icon(
                  Icons.close_rounded,
                ),
              ),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return buildLoading();
    }

    if (errorMessage != null) {
      return buildError();
    }

    if (!hasSearched) {
      return buildInitialState();
    }

    if (results.isEmpty) {
      return buildEmptyState();
    }

    return buildResults();
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
            'در حال جست‌وجو...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInitialState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          28,
          24,
          28,
          120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(
                  0.08,
                ),
                border: Border.all(
                  color: AppColors.primary.withOpacity(
                    0.18,
                  ),
                ),
              ),
              child: const Icon(
                Icons.manage_search_rounded,
                size: 55,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(
              height: 22,
            ),
            const Text(
              'دنبال چی می‌گردی؟',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              'می‌توانی بین فیلم‌ها، سریال‌ها، بازیگران، کارگردان‌ها، ژانرها و سال انتشار جست‌وجو کنی.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.7,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(
                  14,
                ),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Text(
                'حالت فعلی: ${selectedSearchType.title}',
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
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
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 46,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'نتیجه‌ای پیدا نشد',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 7,
            ),
            const Text(
              'عبارت دیگری را امتحان کن یا نوع جست‌وجو را تغییر بده.',
              textAlign: TextAlign.center,
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
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(
                  0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 43,
                color: AppColors.error,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'جست‌وجو انجام نشد',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.6,
              ),
            ),
            const SizedBox(
              height: 22,
            ),
            FilledButton.icon(
              onPressed: () {
                String query = searchController.text.trim();

                if (query.isNotEmpty) {
                  search(
                    query,
                  );
                }
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

  Widget buildResults() {
    return Column(
      children: [
        buildResultsHeader(),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              120,
            ),
            itemCount: results.length + (isLoadingMore ? 1 : 0),
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
              if (index >= results.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 22,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 27,
                          height: 27,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          'در حال دریافت نتایج بیشتر...',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return buildResultCard(
                results[index],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildResultsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        7,
        18,
        5,
      ),
      child: Row(
        children: [
          const Text(
            'نتایج',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(
                0.12,
              ),
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            child: Text(
              '${results.length}',
              style: const TextStyle(
                color: AppColors.primaryLight,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          if (hasMore)
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.swipe_up_alt_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                SizedBox(
                  width: 4,
                ),
                Text(
                  'برای نتایج بیشتر اسکرول کن',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildResultCard(
    SearchResultItem item,
  ) {
    return Material(
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
          height: 146,
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
                width: 96,
                height: double.infinity,
                child: buildPoster(
                  item,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    13,
                    12,
                    13,
                    11,
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
                          buildTypeBadge(
                            item,
                          ),
                          if (item.releaseYear.isNotEmpty) ...[
                            const SizedBox(
                              width: 8,
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
                          const Spacer(),
                          buildRating(
                            item,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 9,
                      ),
                      Expanded(
                        child: Text(
                          item.overview.isEmpty
                              ? 'خلاصه‌ای برای این اثر موجود نیست.'
                              : item.overview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
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
    SearchResultItem item,
  ) {
    if (item.posterUrl.isEmpty) {
      return const ColoredBox(
        color: AppColors.surfaceLight,
        child: Center(
          child: Icon(
            Icons.movie_rounded,
            size: 42,
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
              Icons.broken_image_rounded,
              size: 38,
              color: AppColors.textMuted,
            ),
          ),
        );
      },
    );
  }

  Widget buildRating(
    SearchResultItem item,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(
          0.10,
        ),
        borderRadius: BorderRadius.circular(
          9,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: AppColors.rating,
            size: 14,
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
          0.13,
        ),
        borderRadius: BorderRadius.circular(
          9,
        ),
        border: Border.all(
          color: AppColors.primary.withOpacity(
            0.20,
          ),
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
