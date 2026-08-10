import '../presenters/auth_presenter.dart';
import '../presenters/home_presenter.dart';
import '../presenters/movie_detail_presenter.dart';
import '../presenters/search_presenter.dart';
import '../presenters/series_detail_presenter.dart';
import '../presenters/splash_presenter.dart';
import '../repositories/auth_repository.dart';
import '../repositories/media_repository.dart';
import 'api_service.dart';
import 'profile_image_service.dart';
import 'database_service.dart';
import 'password_service.dart';
import 'session_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static final ApiService apiService = ApiService();

  static final DatabaseService databaseService = DatabaseService();

  static final PasswordService passwordService = PasswordService();

  static final SessionService sessionService = SessionService();

  static final ProfileImageService profileImageService = ProfileImageService();

  static final AuthRepository authRepository = AuthRepository(
    databaseService: databaseService,
    passwordService: passwordService,
    sessionService: sessionService,
  );

  static final MediaRepository mediaRepository = MediaRepository(
    apiService: apiService,
  );

  static final SplashPresenter splashPresenter = SplashPresenter(
    authRepository: authRepository,
  );

  static final HomePresenter homePresenter = HomePresenter(
    mediaRepository: mediaRepository,
  );

  static final SearchPresenter searchPresenter = SearchPresenter(
    mediaRepository: mediaRepository,
  );

  static final MovieDetailPresenter movieDetailPresenter = MovieDetailPresenter(
    mediaRepository: mediaRepository,
  );

  static final SeriesDetailPresenter seriesDetailPresenter =
      SeriesDetailPresenter(
    mediaRepository: mediaRepository,
  );

  static final AuthPresenter authPresenter = AuthPresenter(
    authRepository: authRepository,
  );

  static Future<void> initialize() async {
    await databaseService.getDatabase();
  }
}
