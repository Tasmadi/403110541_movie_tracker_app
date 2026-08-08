import '../presenters/splash_presenter.dart';

class ServiceLocator {
  ServiceLocator._();

  static final SplashPresenter splashPresenter = SplashPresenter();

  static Future<void> initialize() async {
    // سرویس‌های دیتابیس، API و Session
    // در مراحل بعدی در این قسمت مقداردهی می‌شوند.
  }
}
