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
import 'views/auth/auth_welcome_screen.dart';
import 'views/profile/profile_screen.dart';
import 'models/custom_list_detail_arguments.dart';
import 'models/custom_list_media_arguments.dart';
import 'views/lists/custom_list_detail_screen.dart';
import 'views/profile/user_statistics_screen.dart';
import 'views/lists/custom_list_picker_screen.dart';
import 'views/auth/forgot_password_screen.dart';
import 'views/auth/reset_password_screen.dart';
import 'views/auth/verify_reset_code_screen.dart';
import 'views/lists/custom_lists_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/watchlist/watchlist_screen.dart';
import 'views/auth/register_screen.dart';

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
        AppRoutes.authWelcome: (context) {
          return const AuthWelcomeScreen();
        },
        AppRoutes.login: (context) {
          return const LoginScreen();
        },
        AppRoutes.register: (context) {
          return const RegisterScreen();
        },
        AppRoutes.profile: (context) {
          return const ProfileScreen();
        },
        AppRoutes.watchlist: (context) {
          return const WatchlistScreen();
        },
        AppRoutes.customLists: (context) {
          return const CustomListsScreen();
        },
        AppRoutes.statistics: (context) {
          return const UserStatisticsScreen();
        },
        AppRoutes.forgotPassword: (context) {
          return const ForgotPasswordScreen();
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

        if (settings.name == AppRoutes.customListPicker) {
          Object? arguments = settings.arguments;

          if (arguments is CustomListMediaArguments) {
            return MaterialPageRoute(
              builder: (context) {
                return CustomListPickerScreen(
                  media: arguments,
                );
              },
            );
          }
        }

        if (settings.name == AppRoutes.customListDetail) {
          Object? arguments = settings.arguments;

          if (arguments is CustomListDetailArguments) {
            return MaterialPageRoute(
              builder: (context) {
                return CustomListDetailScreen(
                  arguments: arguments,
                );
              },
            );
          }
        }

        if (settings.name == AppRoutes.verifyResetCode) {
          Object? arguments = settings.arguments;

          if (arguments is String) {
            return MaterialPageRoute(
              builder: (context) {
                return VerifyResetCodeScreen(
                  email: arguments,
                );
              },
            );
          }
        }

        if (settings.name == AppRoutes.resetPassword) {
          Object? arguments = settings.arguments;

          if (arguments is String) {
            return MaterialPageRoute(
              builder: (context) {
                return ResetPasswordScreen(
                  email: arguments,
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
