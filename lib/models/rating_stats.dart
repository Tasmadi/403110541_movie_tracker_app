class RatingStats {
  int totalRatings;
  double averageRating;

  Map<int, int> counts;

  Map<int, double> percentages;

  int? userRating;

  RatingStats({
    required this.totalRatings,
    required this.averageRating,
    required this.counts,
    required this.percentages,
    required this.userRating,
  });

  int getCount(
    int stars,
  ) {
    return counts[stars] ?? 0;
  }

  double getPercentage(
    int stars,
  ) {
    return percentages[stars] ?? 0;
  }

  int getRoundedPercentage(
    int stars,
  ) {
    return getPercentage(
      stars,
    ).round();
  }
}
