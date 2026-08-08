import 'package:flutter/material.dart';

import '../../presenters/auth_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';

class AuthWelcomeScreen extends StatefulWidget {
  const AuthWelcomeScreen({
    super.key,
  });

  @override
  State<AuthWelcomeScreen> createState() {
    return _AuthWelcomeScreenState();
  }
}

class _AuthWelcomeScreenState extends State<AuthWelcomeScreen> {
  late final AuthPresenter presenter;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.authPresenter;
  }

  Future<void> continueAsGuest() async {
    setState(() {
      isLoading = true;
    });

    await presenter.continueAsGuest();

    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) {
        return false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(
                      28,
                    ),
                  ),
                  child: const Icon(
                    Icons.movie_filter_rounded,
                    size: 54,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'فیلم‌ها و سریال‌های موردعلاقه خود را دنبال کنید',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.login,
                            );
                          },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      child: Text(
                        'ورود',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.register,
                            );
                          },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      child: Text(
                        'ایجاد حساب کاربری',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: isLoading ? null : continueAsGuest,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'ادامه به عنوان مهمان',
                        ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
