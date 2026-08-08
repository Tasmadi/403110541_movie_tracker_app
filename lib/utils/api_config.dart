class ApiConfig {
  ApiConfig._();

  static const String tmdbToken = String.fromEnvironment(
    'TMDB_TOKEN',
  );

  static const String baseHost = 'api.themoviedb.org';

  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
}
