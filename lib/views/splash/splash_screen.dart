import 'package:flutter/material.dart';

import '../../presenters/splash_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/cinema_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final SplashPresenter presenter;

  late final AnimationController animationController;

  late final Animation<double> logoOpacityAnimation;

  late final Animation<double> logoScaleAnimation;

  late final Animation<double> progressAnimation;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.splashPresenter;

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1900,
      ),
    );

    logoOpacityAnimation = CurvedAnimation(
      parent: animationController,
      curve: const Interval(
        0,
        0.55,
        curve: Curves.easeOut,
      ),
    );

    logoScaleAnimation = Tween<double>(
      begin: 0.72,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0,
          0.62,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    progressAnimation = CurvedAnimation(
      parent: animationController,
      curve: const Interval(
        0.38,
        1,
        curve: Curves.easeInOut,
      ),
    );

    animationController.forward();

    prepareApplication();
  }

  @override
  void dispose() {
    animationController.dispose();

    super.dispose();
  }

  Future<void> prepareApplication() async {
    Stopwatch stopwatch = Stopwatch()..start();

    bool hasSession = await presenter.prepareApplication();

    int elapsedMilliseconds = stopwatch.elapsedMilliseconds;

    const int minimumSplashDuration = 2300;

    if (elapsedMilliseconds < minimumSplashDuration) {
      await Future.delayed(
        Duration(
          milliseconds: minimumSplashDuration - elapsedMilliseconds,
        ),
      );
    }

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
    double screenWidth = MediaQuery.of(context).size.width;

    double logoSize = screenWidth < 360 ? 105 : 125;

    return Scaffold(
      body: CinemaBackground(
        child: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(
                      flex: 3,
                    ),
                    AnimatedBuilder(
                      animation: animationController,
                      builder: (
                        context,
                        child,
                      ) {
                        return Opacity(
                          opacity: logoOpacityAnimation.value,
                          child: Transform.scale(
                            scale: logoScaleAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: AppLogo(
                        size: logoSize,
                      ),
                    ),
                    const SizedBox(
                      height: 44,
                    ),
                    SizedBox(
                      width: 220,
                      height: 7,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            20,
                          ),
                          child: AnimatedBuilder(
                            animation: progressAnimation,
                            builder: (
                              context,
                              child,
                            ) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                widthFactor: progressAnimation.value,
                                child: child,
                              );
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryLight,
                                    AppColors.secondary,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    FadeTransition(
                      opacity: progressAnimation,
                      child: const Text(
                        'در حال بارگذاری...',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Spacer(
                      flex: 4,
                    ),
                    FadeTransition(
                      opacity: logoOpacityAnimation,
                      child: const Padding(
                        padding: EdgeInsets.only(
                          bottom: 20,
                        ),
                        child: Text(
                          'فیلم‌ها و سریال‌های شما، همیشه همراهتان',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
