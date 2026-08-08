import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'utils/app_strings.dart';
import 'utils/app_theme.dart';
import 'views/home/home_screen.dart';
import 'views/search/search_screen.dart';
import 'views/splash/splash_screen.dart';
import 'views/details/movie_detail_screen.dart';
import 'models/season_arguments.dart';
import 'views/details/season_detail_screen.dart';
import 'views/details/series_detail_screen.dart';

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
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.movieDetail) {
          Object? arguments = settings.arguments;

          if (arguments is int) {
            return MaterialPageRoute(
              builder: (context) {
                return MovieDetailScreen(
                  movieId: arguments,
                );
              },
            );
          }
        }

        if (settings.name == AppRoutes.seriesDetail) {
          Object? arguments = settings.arguments;

          if (arguments is int) {
            return MaterialPageRoute(
              builder: (context) {
                return SeriesDetailScreen(
                  seriesId: arguments,
                );
              },
            );
          }
        }

        if (settings.name == AppRoutes.seasonDetail) {
          Object? arguments = settings.arguments;

          if (arguments is SeasonArguments) {
            return MaterialPageRoute(
              builder: (context) {
                return SeasonDetailScreen(
                  arguments: arguments,
                );
              },
            );
          }
        }

        return null;
      },
    );
  }
}
