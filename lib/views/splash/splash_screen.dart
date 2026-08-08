import 'package:flutter/material.dart';

import '../../presenters/splash_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  late final SplashPresenter presenter;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.splashPresenter;

    prepareApplication();
  }

  Future<void> prepareApplication() async {
    bool hasSession = await presenter.prepareApplication();

    if (!mounted) {
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      hasSession ? AppRoutes.home : AppRoutes.authWelcome,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.movie_filter_rounded,
                    size: 82,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 24),
                  Text(
                    AppStrings.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
