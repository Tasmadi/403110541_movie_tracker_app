class ApiConfig {
  ApiConfig._();

  static const String tmdbToken = String.fromEnvironment(
    'TMDB_TOKEN',
  );

  static const String baseHost = 'api.themoviedb.org';

  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  static const String emailJsServiceId = String.fromEnvironment(
    'EMAILJS_SERVICE_ID',
  );

  static const String emailJsTemplateId = String.fromEnvironment(
    'EMAILJS_TEMPLATE_ID',
  );

  static const String emailJsPublicKey = String.fromEnvironment(
    'EMAILJS_PUBLIC_KEY',
  );

  static const String omdbApiKey = String.fromEnvironment(
    'OMDB_API_KEY',
  );
}
