import 'search_result_item.dart';

class HomeData {
  List<SearchResultItem> popularMovies;
  List<SearchResultItem> popularSeries;
  List<SearchResultItem> newReleases;
  List<SearchResultItem> topRated;
  List<SearchResultItem> recommendations;

  HomeData({
    required this.popularMovies,
    required this.popularSeries,
    required this.newReleases,
    required this.topRated,
    required this.recommendations,
  });
}
