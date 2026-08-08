import '../utils/api_config.dart';

class CastMember {
  int id;
  String name;
  String character;
  String? profilePath;

  CastMember({
    required this.id,
    required this.name,
    required this.character,
    required this.profilePath,
  });

  factory CastMember.fromJson(
    Map<String, dynamic> json,
  ) {
    return CastMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      character: json['character'] ?? '',
      profilePath: json['profile_path'],
    );
  }

  String get profileUrl {
    if (profilePath == null || profilePath!.isEmpty) {
      return '';
    }

    return '${ApiConfig.imageBaseUrl}$profilePath';
  }
}
