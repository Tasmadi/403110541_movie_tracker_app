import 'package:flutter/material.dart';

import '../../presenters/auth_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/cinema_background.dart';

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

    if (!usernamePattern.hasMatch(
      username,
    )) {
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

    if (!emailPattern.hasMatch(
      email,
    )) {
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
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    22,
                    8,
                    22,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildTopBar(),
                      const SizedBox(
                        height: 10,
                      ),
                      const Center(
                        child: AppLogo(
                          size: 72,
                          showTagline: false,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'ایجاد حساب کاربری',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      const Text(
                        'برای شروع سفر سینمایی خود اطلاعات زیر را وارد کنید',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      buildRegisterCard(),
                      const SizedBox(
                        height: 16,
                      ),
                      buildLoginLink(),
                    ],
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
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(
            0.76,
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
        ),
      ),
    );
  }

  Widget buildRegisterCard() {
    return Container(
      padding: const EdgeInsets.all(
        18,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(
          0.93,
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
              0.24,
            ),
            blurRadius: 28,
            offset: const Offset(
              0,
              14,
            ),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: fullNameController,
              validator: validateFullName,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'نام و نام خانوادگی',
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                ),
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            TextFormField(
              controller: usernameController,
              validator: validateUsername,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'نام کاربری',
                hintText: 'username',
                prefixIcon: Icon(
                  Icons.alternate_email_rounded,
                ),
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            TextFormField(
              controller: emailController,
              validator: validateEmail,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'ایمیل',
                hintText: 'example@email.com',
                prefixIcon: Icon(
                  Icons.email_outlined,
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
              textInputAction: TextInputAction.next,
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
            TextFormField(
              controller: confirmPasswordController,
              validator: validateConfirmPassword,
              obscureText: obscureConfirmPassword,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'تکرار رمز عبور',
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscureConfirmPassword = !obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            TextFormField(
              controller: bioController,
              maxLines: 3,
              maxLength: 150,
              decoration: const InputDecoration(
                labelText: 'بیوگرافی کوتاه',
                hintText: 'چند کلمه درباره خودت... (اختیاری)',
                alignLabelWithHint: true,
                prefixIcon: Icon(
                  Icons.edit_note_rounded,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: isLoading ? null : register,
                icon: isLoading
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.person_add_alt_1_rounded,
                      ),
                label: Text(
                  isLoading ? 'در حال ساخت حساب...' : 'ثبت‌نام',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'قبلاً حساب ساخته‌اید؟',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
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
            'ورود',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
