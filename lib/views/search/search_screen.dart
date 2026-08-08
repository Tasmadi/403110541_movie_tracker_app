import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/search_result_item.dart';
import '../../presenters/search_presenter.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchPresenter presenter;

  final TextEditingController searchController = TextEditingController();

  Timer? debounceTimer;

  List<SearchResultItem> results = [];

  bool isLoading = false;

  bool hasSearched = false;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.searchPresenter;
  }

  @override
  void dispose() {
    debounceTimer?.cancel();
    searchController.dispose();

    super.dispose();
  }

  void onSearchChanged(String value) {
    debounceTimer?.cancel();

    String query = value.trim();

    if (query.isEmpty) {
      setState(() {
        results = [];
        isLoading = false;
        hasSearched = false;
        errorMessage = null;
      });

      return;
    }

    debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () {
        search(query);
      },
    );
  }

  Future<void> search(String query) async {
    setState(() {
      isLoading = true;
      hasSearched = true;
      errorMessage = null;
    });

    try {
      List<SearchResultItem> searchResults = await presenter.search(query);

      if (!mounted) {
        return;
      }

      if (searchController.text.trim() != query) {
        return;
      }

      setState(() {
        results = searchResults;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      if (searchController.text.trim() != query) {
        return;
      }

      setState(() {
        results = [];
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
          'جست‌وجو',
        ),
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              buildSearchField(),
              Expanded(
                child: buildBody(),
              ),
            ],
          ),
        ),
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
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'نام فیلم یا سریال را وارد کنید',
          prefixIcon: const Icon(
            Icons.search_rounded,
          ),
          suffixIcon: searchController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    searchController.clear();
                    onSearchChanged('');
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
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
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  String query = searchController.text.trim();

                  if (query.isNotEmpty) {
                    search(query);
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.manage_search_rounded,
                size: 80,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 18),
              Text(
                'فیلم یا سریال موردنظر خود را جست‌وجو کنید',
                textAlign: TextAlign.center,
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

    if (results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 72,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16),
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
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
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
      child: SizedBox(
        height: 150,
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: double.infinity,
              child: buildPoster(item),
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
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        buildTypeBadge(item),
                        if (item.releaseYear.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            item.releaseYear,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
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
                          item.voteAverage.toStringAsFixed(1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
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
