class ImdbInfo {
  final double? rating;
  final String votes;

  const ImdbInfo({
    required this.rating,
    required this.votes,
  });

  factory ImdbInfo.fromJson(
    Map<String, dynamic> json,
  ) {
    String rawRating = json['imdbRating']?.toString().trim() ?? '';

    double? rating;

    if (rawRating.isNotEmpty && rawRating != 'N/A') {
      rating = double.tryParse(
        rawRating,
      );
    }

    String votes = json['imdbVotes']?.toString().trim() ?? '';

    if (votes == 'N/A') {
      votes = '';
    }

    return ImdbInfo(
      rating: rating,
      votes: votes,
    );
  }

  bool get hasRating {
    return rating != null;
  }
}
