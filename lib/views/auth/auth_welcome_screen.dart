import 'package:flutter/material.dart';

import '../../presenters/auth_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/cinema_background.dart';

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

    try {
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
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CinemaBackground(
        child: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: LayoutBuilder(
              builder: (
                context,
                constraints,
              ) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    30,
                    24,
                    28,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 58,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        const AppLogo(
                          size: 125,
                        ),
                        const SizedBox(
                          height: 38,
                        ),
                        const Text(
                          'دنیای فیلم و سریال خودت',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'آثاری که می‌بینی را دنبال کن، امتیاز بده و همه‌چیز را در یک جا نگه دار.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.8,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        buildFeatures(),
                        const SizedBox(
                          height: 42,
                        ),
                        buildActions(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFeatures() {
    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(
          0.82,
        ),
        borderRadius: BorderRadius.circular(
          22,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _FeatureItem(
              icon: Icons.play_circle_outline_rounded,
              title: 'ردیابی',
            ),
          ),
          _FeatureDivider(),
          Expanded(
            child: _FeatureItem(
              icon: Icons.star_outline_rounded,
              title: 'امتیاز',
            ),
          ),
          _FeatureDivider(),
          Expanded(
            child: _FeatureItem(
              icon: Icons.bookmark_border_rounded,
              title: 'لیست‌ها',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 54,
          child: FilledButton.icon(
            onPressed: isLoading
                ? null
                : () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.login,
                    );
                  },
            icon: const Icon(
              Icons.login_rounded,
            ),
            label: const Text(
              'ورود به حساب',
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        SizedBox(
          height: 54,
          child: OutlinedButton.icon(
            onPressed: isLoading
                ? null
                : () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.register,
                    );
                  },
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
            ),
            label: const Text(
              'ایجاد حساب کاربری',
            ),
          ),
        ),
        const SizedBox(
          height: 14,
        ),
        TextButton.icon(
          onPressed: isLoading ? null : continueAsGuest,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.visibility_outlined,
                ),
          label: Text(
            isLoading ? 'در حال ورود...' : 'ادامه به عنوان مهمان',
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        const Text(
          'در حالت مهمان می‌توانید فیلم‌ها و سریال‌ها را جست‌وجو و مشاهده کنید.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _FeatureItem({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(
              0.12,
            ),
            borderRadius: BorderRadius.circular(
              13,
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryLight,
            size: 22,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FeatureDivider extends StatelessWidget {
  const _FeatureDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 50,
      color: AppColors.divider,
    );
  }
}
