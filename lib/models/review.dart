class Review {
  int id;
  int userId;
  int mediaId;
  String mediaType;
  String text;
  bool isSpoiler;
  String createdAt;
  String updatedAt;
  String username;
  String? profileImagePath;
  bool isOwnReview;

  Review({
    required this.id,
    required this.userId,
    required this.mediaId,
    required this.mediaType,
    required this.text,
    required this.isSpoiler,
    required this.createdAt,
    required this.updatedAt,
    required this.username,
    required this.profileImagePath,
    required this.isOwnReview,
  });

  factory Review.fromMap(
    Map<String, dynamic> map, {
    required int? currentUserId,
  }) {
    int userId = map['user_id'] ?? 0;

    return Review(
      id: map['id'] ?? 0,
      userId: userId,
      mediaId: map['media_id'] ?? 0,
      mediaType: map['media_type'] ?? '',
      text: map['review_text'] ?? '',
      isSpoiler: (map['is_spoiler'] ?? 0) == 1,
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
      username: map['username'] ?? '',
      profileImagePath: map['profile_image_path'],
      isOwnReview: currentUserId != null && currentUserId == userId,
    );
  }

  String get displayDate {
    DateTime? date = DateTime.tryParse(createdAt);

    if (date == null) {
      return '';
    }

    String month = date.month.toString().padLeft(
          2,
          '0',
        );

    String day = date.day.toString().padLeft(
          2,
          '0',
        );

    return '${date.year}/$month/$day';
  }
}
