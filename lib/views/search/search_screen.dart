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

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'جست‌وجو',
        ),
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              buildSearchControls(),
              Expanded(
                child: buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSearchControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSearchTypes(),
        buildSearchField(),
      ],
    );
  }

  Widget buildSearchTypes() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'جست‌وجو بر اساس',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          SingleChildScrollView(
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
          ),
        ],
      ),
    );
  }

  Widget buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        8,
      ),
      child: TextField(
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              18,
            ),
          ),
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
          padding: const EdgeInsets.all(
            24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 20,
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

    if (!hasSearched) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(
            24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.manage_search_rounded,
                size: 80,
                color: AppColors.textSecondary,
              ),
              const SizedBox(
                height: 18,
              ),
              const Text(
                'فیلم یا سریال موردنظر خود را جست‌وجو کنید',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'نوع جست‌وجو: ${selectedSearchType.title}',
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

    if (results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(
            24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 72,
                color: AppColors.textSecondary,
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                'نتیجه‌ای پیدا نشد',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        24,
      ),
      itemCount: results.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (
        context,
        index,
      ) {
        return const SizedBox(
          height: 12,
        );
      },
      itemBuilder: (
        context,
        index,
      ) {
        if (index >= results.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 20,
            ),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return buildResultCard(
          results[index],
        );
      },
    );
  }

  Widget buildResultCard(
    SearchResultItem item,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
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
        },
        child: SizedBox(
          height: 150,
          child: Row(
            children: [
              SizedBox(
                width: 100,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
                            Text(
                              item.releaseYear,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.secondary,
                            size: 18,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            item.voteAverage.toStringAsFixed(
                              1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Expanded(
                        child: Text(
                          item.overview.isEmpty
                              ? 'خلاصه‌ای موجود نیست.'
                              : item.overview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
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
        color: Color(0xFFE8E8EE),
        child: Center(
          child: Icon(
            Icons.movie_rounded,
            size: 42,
            color: AppColors.textSecondary,
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
            size: 42,
          ),
        );
      },
    );
  }

  Widget buildTypeBadge(
    SearchResultItem item,
  ) {
    return Container(
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
        item.mediaTypeTitle,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
