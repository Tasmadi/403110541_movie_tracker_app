import 'package:flutter/material.dart';

import '../../presenters/auth_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/cinema_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  late final AuthPresenter presenter;

  bool obscurePassword = true;

  bool isLoading = false;

  int sessionDurationDays = 30;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.authPresenter;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  String? validateEmail(
    String? value,
  ) {
    String email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'ایمیل را وارد کنید.';
    }

    RegExp emailPattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailPattern.hasMatch(email)) {
      return 'فرمت ایمیل صحیح نیست.';
    }

    return null;
  }

  String? validatePassword(
    String? value,
  ) {
    if (value == null || value.isEmpty) {
      return 'رمز عبور را وارد کنید.';
    }

    return null;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    try {
      await presenter.login(
        email: emailController.text,
        password: passwordController.text,
        sessionDurationDays: sessionDurationDays,
      );

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

      String message = error.toString().replaceFirst(
            'Exception: ',
            '',
          );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            message,
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
  Widget build(
    BuildContext context,
  ) {
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
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    22,
                    8,
                    22,
                    28,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 36,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildTopBar(),
                        const SizedBox(
                          height: 12,
                        ),
                        const Center(
                          child: AppLogo(
                            size: 82,
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        const Text(
                          'خوش آمدید!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        const Text(
                          'وارد حساب کاربری خود شوید',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(
                          height: 28,
                        ),
                        buildLoginCard(),
                        const SizedBox(
                          height: 18,
                        ),
                        buildRegisterSection(),
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

  Widget buildTopBar() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(
              0.75,
            ),
            borderRadius: BorderRadius.circular(
              14,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: IconButton(
            onPressed: isLoading
                ? null
                : () {
                    Navigator.maybePop(
                      context,
                    );
                  },
            icon: const Icon(
              Icons.arrow_forward_rounded,
            ),
            tooltip: 'بازگشت',
          ),
        ),
      ],
    );
  }

  Widget buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(
        18,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(
          0.92,
        ),
        borderRadius: BorderRadius.circular(
          24,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.22,
            ),
            blurRadius: 28,
            offset: const Offset(
              0,
              14,
            ),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(
              0.06,
            ),
            blurRadius: 35,
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'اطلاعات ورود',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextFormField(
              controller: emailController,
              validator: validateEmail,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.next,
              autofillHints: const [
                AutofillHints.email,
              ],
              decoration: const InputDecoration(
                labelText: 'ایمیل',
                hintText: 'example@email.com',
                prefixIcon: Icon(
                  Icons.alternate_email_rounded,
                ),
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            TextFormField(
              controller: passwordController,
              validator: validatePassword,
              obscureText: obscurePassword,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.done,
              autofillHints: const [
                AutofillHints.password,
              ],
              onFieldSubmitted: (_) {
                if (!isLoading) {
                  login();
                }
              },
              decoration: InputDecoration(
                labelText: 'رمز عبور',
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            DropdownButtonFormField<int>(
              value: sessionDurationDays,
              decoration: const InputDecoration(
                labelText: 'مدت نگهداری ورود',
                prefixIcon: Icon(
                  Icons.schedule_rounded,
                ),
              ),
              dropdownColor: AppColors.surfaceElevated,
              items: const [
                DropdownMenuItem(
                  value: 7,
                  child: Text(
                    '۷ روز',
                  ),
                ),
                DropdownMenuItem(
                  value: 14,
                  child: Text(
                    '۱۴ روز',
                  ),
                ),
                DropdownMenuItem(
                  value: 30,
                  child: Text(
                    '۳۰ روز',
                  ),
                ),
              ],
              onChanged: isLoading
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }

                      setState(
                        () {
                          sessionDurationDays = value;
                        },
                      );
                    },
            ),
            const SizedBox(
              height: 4,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.forgotPassword,
                        );
                      },
                child: const Text(
                  'رمز عبور را فراموش کرده‌اید؟',
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: isLoading ? null : login,
                child: isLoading
                    ? const SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.login_rounded,
                            size: 20,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            'ورود',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRegisterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(
          0.58,
        ),
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'حساب کاربری ندارید؟',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          TextButton(
            onPressed: isLoading
                ? null
                : () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.register,
                    );
                  },
            child: const Text(
              'ثبت‌نام',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
