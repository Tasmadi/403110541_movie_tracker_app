import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../presenters/password_reset_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';

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
      appBar: AppBar(
        title: const Text(
          'تأیید کد',
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                24,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    size: 78,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'کد ارسال‌شده را وارد کنید',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    widget.email,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 28,
                  ),
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
                      fontSize: 28,
                      letterSpacing: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'کد بازیابی',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    onSubmitted: (_) {
                      if (!isLoading) {
                        verifyCode();
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isLoading ? null : verifyCode,
                      icon: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.check_rounded,
                            ),
                      label: const Text(
                        'تأیید کد',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    onPressed: isResending ? null : resendCode,
                    child: Text(
                      isResending ? 'در حال ارسال...' : 'ارسال مجدد کد',
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  const Text(
                    'کد بازیابی ۱۰ دقیقه اعتبار دارد.',
                    style: TextStyle(
                      fontSize: 12,
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
