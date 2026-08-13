import 'package:flutter/material.dart';

import '../../presenters/password_reset_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';
import '../../widgets/cinema_background.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() {
    return _ResetPasswordScreenState();
  }
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmController = TextEditingController();

  late final PasswordResetPresenter presenter;

  bool obscurePassword = true;
  bool obscureConfirm = true;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.passwordResetPresenter;
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();

    super.dispose();
  }

  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    try {
      await presenter.resetPassword(
        email: widget.email,
        newPassword: passwordController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessengerState messenger = ScaffoldMessenger.of(
        context,
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );

      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'رمز عبور با موفقیت تغییر کرد. با رمز جدید وارد شوید.',
          ),
        ),
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
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                22,
                8,
                22,
                30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildBackButton(),
                  const SizedBox(
                    height: 42,
                  ),
                  buildIcon(),
                  const SizedBox(
                    height: 22,
                  ),
                  const Text(
                    'رمز عبور جدید',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(
                    height: 9,
                  ),
                  const Text(
                    'یک رمز عبور جدید و امن برای حساب خود تعیین کنید.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(
                    height: 28,
                  ),
                  buildForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBackButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
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
        ),
      ),
    );
  }

  Widget buildIcon() {
    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(
            0.13,
          ),
          border: Border.all(
            color: AppColors.primary.withOpacity(
              0.35,
            ),
          ),
        ),
        child: const Icon(
          Icons.lock_reset_rounded,
          color: AppColors.primaryLight,
          size: 42,
        ),
      ),
    );
  }

  Widget buildForm() {
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
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'رمز عبور جدید',
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
              validator: (value) {
                if (value == null || value.length < 8) {
                  return 'رمز عبور باید حداقل ۸ کاراکتر باشد.';
                }

                return null;
              },
            ),
            const SizedBox(
              height: 14,
            ),
            TextFormField(
              controller: confirmController,
              obscureText: obscureConfirm,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (!isLoading) {
                  resetPassword();
                }
              },
              decoration: InputDecoration(
                labelText: 'تکرار رمز عبور جدید',
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscureConfirm = !obscureConfirm;
                    });
                  },
                  icon: Icon(
                    obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value != passwordController.text) {
                  return 'رمزهای عبور یکسان نیستند.';
                }

                return null;
              },
            ),
            const SizedBox(
              height: 12,
            ),
            const Text(
              'رمز عبور باید حداقل ۸ کاراکتر داشته باشد.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
            const SizedBox(
              height: 22,
            ),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: isLoading ? null : resetPassword,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.check_circle_outline_rounded,
                      ),
                label: Text(
                  isLoading ? 'در حال تغییر...' : 'تغییر رمز عبور',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
