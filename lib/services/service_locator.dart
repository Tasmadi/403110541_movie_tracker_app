import '../presenters/home_presenter.dart';
import '../presenters/search_presenter.dart';
import '../presenters/splash_presenter.dart';
import '../repositories/media_repository.dart';
import 'api_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static final ApiService apiService = ApiService();

  static final MediaRepository mediaRepository = MediaRepository(
    apiService: apiService,
  );

  static final SplashPresenter splashPresenter = SplashPresenter();

  static final HomePresenter homePresenter = HomePresenter(
    mediaRepository: mediaRepository,
  );

  static final SearchPresenter searchPresenter = SearchPresenter(
    mediaRepository: mediaRepository,
  );

  static Future<void> initialize() async {
    // سرویس‌های دیتابیس و Session
    // در مراحل بعد اضافه خواهند شد.
  }
}
