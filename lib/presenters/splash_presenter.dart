class SplashPresenter {
  Future<void> prepareApplication() async {
    await Future<void>.delayed(
      const Duration(milliseconds: 1200),
    );
  }
}
