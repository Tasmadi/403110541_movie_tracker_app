import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../presenters/password_reset_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';
import '../../widgets/cinema_background.dart';

class VerifyResetCodeScreen extends StatefulWidget {
  final String email;

  const VerifyResetCodeScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyResetCodeScreen> createState() {
    return _VerifyResetCodeScreenState();
  }
}

class _VerifyResetCodeScreenState extends State<VerifyResetCodeScreen> {
  final TextEditingController codeController = TextEditingController();

  late final PasswordResetPresenter presenter;

  bool isLoading = false;
  bool isResending = false;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.passwordResetPresenter;
  }

  @override
  void dispose() {
    codeController.dispose();

    super.dispose();
  }

  Future<void> verifyCode() async {
    String code = codeController.text.trim();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'کد ۶ رقمی را کامل وارد کنید.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await presenter.verifyCode(
        email: widget.email,
        code: code,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.resetPassword,
        arguments: widget.email,
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

  Future<void> resendCode() async {
    setState(() {
      isResending = true;
    });

    try {
      await presenter.requestCode(
        widget.email,
      );

      if (!mounted) {
        return;
      }

      codeController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'کد جدید ارسال شد.',
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
          isResending = false;
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
                    'تأیید کد بازیابی',
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
                    'کد ۶ رقمی ارسال‌شده به ایمیل زیر را وارد کنید',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  buildEmailBadge(),
                  const SizedBox(
                    height: 28,
                  ),
                  buildVerificationCard(),
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
          Icons.verified_user_outlined,
          size: 42,
          color: AppColors.primaryLight,
        ),
      ),
    );
  }

  Widget buildEmailBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(
            20,
          ),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Text(
          widget.email,
          textDirection: TextDirection.ltr,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget buildVerificationCard() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: codeController,
            autofocus: true,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            maxLength: 6,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              letterSpacing: 10,
              fontWeight: FontWeight.w800,
            ),
            decoration: const InputDecoration(
              hintText: '••••••',
              counterText: '',
            ),
            onSubmitted: (_) {
              if (!isLoading) {
                verifyCode();
              }
            },
          ),
          const SizedBox(
            height: 14,
          ),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: isLoading ? null : verifyCode,
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
                      Icons.check_rounded,
                    ),
              label: Text(
                isLoading ? 'در حال بررسی...' : 'تأیید کد',
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          TextButton.icon(
            onPressed: isResending ? null : resendCode,
            icon: isResending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                  ),
            label: Text(
              isResending ? 'در حال ارسال...' : 'ارسال مجدد کد',
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          const Text(
            'این کد تا ۱۰ دقیقه معتبر است.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
