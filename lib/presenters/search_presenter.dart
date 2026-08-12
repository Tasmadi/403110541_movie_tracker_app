import '../models/search_page_result.dart';
import '../models/search_result_item.dart';
import '../models/search_type.dart';
import '../repositories/media_repository.dart';

class SearchPresenter {
  MediaRepository mediaRepository;

  SearchPresenter({
    required this.mediaRepository,
  });

  Future<List<SearchResultItem>> search(
    String query,
  ) async {
    return mediaRepository.searchMedia(
      query,
    );
  }

  Future<SearchPageResult> searchPage({
    required String query,
    required SearchType searchType,
    int page = 1,
  }) async {
    return mediaRepository.searchMediaPage(
      query: query,
      searchType: searchType,
      page: page,
    );
  }
}
