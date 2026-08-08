import '../models/search_result_item.dart';
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
}
