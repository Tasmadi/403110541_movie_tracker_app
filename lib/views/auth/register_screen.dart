import 'package:flutter/material.dart';

import '../../presenters/auth_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() {
    return _RegisterScreenState();
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();

  final TextEditingController usernameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  final TextEditingController bioController = TextEditingController();

  late final AuthPresenter presenter;

  bool obscurePassword = true;

  bool obscureConfirmPassword = true;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.authPresenter;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    bioController.dispose();

    super.dispose();
  }

  String? validateFullName(
    String? value,
  ) {
    if (value == null || value.trim().length < 3) {
      return 'نام و نام خانوادگی را وارد کنید.';
    }

    return null;
  }

  String? validateUsername(
    String? value,
  ) {
    String username = value?.trim() ?? '';

    if (username.length < 3) {
      return 'نام کاربری باید حداقل ۳ کاراکتر باشد.';
    }

    RegExp usernamePattern = RegExp(
      r'^[a-zA-Z0-9_]+$',
    );

    if (!usernamePattern.hasMatch(username)) {
      return 'نام کاربری فقط می‌تواند شامل حروف انگلیسی، عدد و _ باشد.';
    }

    return null;
  }

  String? validateEmail(
    String? value,
  ) {
    String email = value?.trim() ?? '';

    RegExp emailPattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailPattern.hasMatch(email)) {
      return 'ایمیل معتبر وارد کنید.';
    }

    return null;
  }

  String? validatePassword(
    String? value,
  ) {
    if (value == null || value.length < 8) {
      return 'رمز عبور باید حداقل ۸ کاراکتر باشد.';
    }

    return null;
  }

  String? validateConfirmPassword(
    String? value,
  ) {
    if (value != passwordController.text) {
      return 'تکرار رمز عبور مطابقت ندارد.';
    }

    return null;
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    try {
      await presenter.register(
        fullName: fullNameController.text,
        username: usernameController.text,
        email: emailController.text,
        password: passwordController.text,
        bio: bioController.text,
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
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
      appBar: AppBar(
        title: const Text(
          'ثبت‌نام',
        ),
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(
              24,
            ),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 70,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'ایجاد حساب کاربری',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: fullNameController,
                    validator: validateFullName,
                    decoration: const InputDecoration(
                      labelText: 'نام و نام خانوادگی',
                      prefixIcon: Icon(
                        Icons.person_outline,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: usernameController,
                    validator: validateUsername,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'نام کاربری',
                      prefixIcon: Icon(
                        Icons.alternate_email,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: emailController,
                    validator: validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'ایمیل',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: passwordController,
                    validator: validatePassword,
                    obscureText: obscurePassword,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: 'رمز عبور',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                      ),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: confirmPasswordController,
                    validator: validateConfirmPassword,
                    obscureText: obscureConfirmPassword,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: 'تکرار رمز عبور',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                      ),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: bioController,
                    maxLines: 3,
                    maxLength: 150,
                    decoration: const InputDecoration(
                      labelText: 'بیوگرافی کوتاه (اختیاری)',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(
                        Icons.info_outline,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: isLoading ? null : register,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'ثبت‌نام',
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            );
                          },
                    child: const Text(
                      'قبلاً ثبت‌نام کرده‌اید؟ ورود',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
