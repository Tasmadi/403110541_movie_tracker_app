import 'package:flutter/material.dart';

import '../../presenters/password_reset_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';

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

      ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

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
      appBar: AppBar(
        title: const Text(
          'رمز عبور جدید',
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
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const Icon(
                      Icons.lock_reset_rounded,
                      size: 78,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'رمز عبور جدید را تعیین کنید',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 28,
                    ),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: 'رمز عبور جدید',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 8) {
                          return 'رمز عبور باید حداقل ۸ کاراکتر باشد.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: confirmController,
                      obscureText: obscureConfirm,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: 'تکرار رمز عبور جدید',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscureConfirm = !obscureConfirm;
                            });
                          },
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != passwordController.text) {
                          return 'رمزهای عبور یکسان نیستند.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: isLoading ? null : resetPassword,
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.check_circle_outline_rounded,
                              ),
                        label: const Text(
                          'تغییر رمز عبور',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
