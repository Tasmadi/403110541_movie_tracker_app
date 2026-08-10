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
import '../presenters/episode_progress_presenter.dart';
import '../presenters/rating_presenter.dart';
import '../repositories/rating_repository.dart';
import '../repositories/episode_progress_repository.dart';
import 'password_service.dart';
import 'session_service.dart';
import '../presenters/user_media_presenter.dart';
import '../repositories/user_media_repository.dart';

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

  static final UserMediaRepository userMediaRepository = UserMediaRepository(
    databaseService: databaseService,
    sessionService: sessionService,
  );

  static final UserMediaPresenter userMediaPresenter = UserMediaPresenter(
    repository: userMediaRepository,
  );

  static final MediaRepository mediaRepository = MediaRepository(
    apiService: apiService,
  );

  static final SplashPresenter splashPresenter = SplashPresenter(
    authRepository: authRepository,
  );

  static final RatingRepository ratingRepository = RatingRepository(
    databaseService: databaseService,
    sessionService: sessionService,
  );

  static final RatingPresenter ratingPresenter = RatingPresenter(
    repository: ratingRepository,
  );

  static final HomePresenter homePresenter = HomePresenter(
    mediaRepository: mediaRepository,
  );

  static final SearchPresenter searchPresenter = SearchPresenter(
    mediaRepository: mediaRepository,
  );

  static final EpisodeProgressRepository episodeProgressRepository =
      EpisodeProgressRepository(
    databaseService: databaseService,
    sessionService: sessionService,
  );

  static final EpisodeProgressPresenter episodeProgressPresenter =
      EpisodeProgressPresenter(
    episodeRepository: episodeProgressRepository,
    mediaRepository: mediaRepository,
    userMediaRepository: userMediaRepository,
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
