import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'utils/app_strings.dart';
import 'utils/app_theme.dart';
import 'views/home/home_screen.dart';
import 'views/search/search_screen.dart';
import 'views/splash/splash_screen.dart';

class MovieTrackerApp extends StatelessWidget {
  const MovieTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) {
          return const SplashScreen();
        },
        AppRoutes.home: (context) {
          return const HomeScreen();
        },
        AppRoutes.search: (context) {
          return const SearchScreen();
        },
      },
    );
  }
}
