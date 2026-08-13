import 'package:flutter/material.dart';

import '../../presenters/password_reset_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';
import '../../widgets/cinema_background.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
  });

  @override
  State<ForgotPasswordScreen> createState() {
    return _ForgotPasswordScreenState();
  }
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();

  late final PasswordResetPresenter presenter;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.passwordResetPresenter;
  }

  @override
  void dispose() {
    emailController.dispose();

    super.dispose();
  }

  Future<void> requestCode() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    try {
      String email = emailController.text.trim().toLowerCase();

      await presenter.requestCode(
        email,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'کد بازیابی به ایمیل شما ارسال شد.',
          ),
        ),
      );

      Navigator.pushNamed(
        context,
        AppRoutes.verifyResetCode,
        arguments: email,
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
                    height: 46,
                  ),
                  buildIcon(),
                  const SizedBox(
                    height: 22,
                  ),
                  const Text(
                    'بازیابی رمز عبور',
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
                    'ایمیل حساب کاربری خود را وارد کنید تا کد بازیابی برایتان ارسال شود.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
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
          color: AppColors.primary.withOpacity(
            0.13,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withOpacity(
              0.35,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(
                0.16,
              ),
              blurRadius: 28,
            ),
          ],
        ),
        child: const Icon(
          Icons.mark_email_read_outlined,
          color: AppColors.primaryLight,
          size: 40,
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
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'ایمیل',
                hintText: 'example@email.com',
                prefixIcon: Icon(
                  Icons.email_outlined,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'ایمیل را وارد کنید.';
                }

                if (!value.contains('@')) {
                  return 'ایمیل معتبر نیست.';
                }

                return null;
              },
              onFieldSubmitted: (_) {
                if (!isLoading) {
                  requestCode();
                }
              },
            ),
            const SizedBox(
              height: 10,
            ),
            const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.textMuted,
                  size: 17,
                ),
                SizedBox(
                  width: 7,
                ),
                Expanded(
                  child: Text(
                    'یک کد امنیتی ۶ رقمی برای شما ارسال می‌شود.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 22,
            ),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: isLoading ? null : requestCode,
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
                        Icons.send_rounded,
                      ),
                label: Text(
                  isLoading ? 'در حال ارسال...' : 'ارسال کد بازیابی',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
