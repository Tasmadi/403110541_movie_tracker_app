class CustomList {
  int id;
  int userId;
  String name;
  int itemCount;
  String createdAt;
  String updatedAt;

  CustomList({
    required this.id,
    required this.userId,
    required this.name,
    required this.itemCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomList.fromMap(
    Map<String, dynamic> map,
  ) {
    return CustomList(
      id: map['id'] ?? 0,
      userId: map['user_id'] ?? 0,
      name: map['name'] ?? '',
      itemCount: map['item_count'] ?? 0,
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }
}
