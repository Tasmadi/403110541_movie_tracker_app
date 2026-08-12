import 'search_result_item.dart';

class SearchPageResult {
  final List<SearchResultItem> items;

  final int page;

  final int totalPages;

  SearchPageResult({
    required this.items,
    required this.page,
    required this.totalPages,
  });

  bool get hasMore {
    return page < totalPages;
  }
}
