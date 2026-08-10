import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../presenters/auth_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/profile_image_service.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();

  final TextEditingController usernameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController bioController = TextEditingController();

  late final AuthPresenter presenter;

  late final ProfileImageService imageService;

  User? user;

  String? profileImagePath;

  bool isLoading = true;

  bool isSaving = false;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.authPresenter;

    imageService = ServiceLocator.profileImageService;

    loadProfile();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    bioController.dispose();

    super.dispose();
  }

  Future<void> loadProfile() async {
    if (presenter.isGuest()) {
      setState(() {
        isLoading = false;
      });

      return;
    }

    try {
      User? currentUser = await presenter.getCurrentUser();

      if (!mounted) {
        return;
      }

      if (currentUser == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'اطلاعات کاربر پیدا نشد.';
        });

        return;
      }

      user = currentUser;

      fullNameController.text = currentUser.fullName;

      usernameController.text = currentUser.username;

      emailController.text = currentUser.email;

      bioController.text = currentUser.bio;

      profileImagePath = currentUser.profileImagePath;

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        errorMessage = error.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  Future<void> chooseImage() async {
    String? path = await imageService.pickProfileImage(
      oldImagePath: profileImagePath,
    );

    if (path == null || !mounted) {
      return;
    }

    setState(() {
      profileImagePath = path;
    });
  }

  Future<void> removeImage() async {
    await imageService.removeProfileImage(
      profileImagePath,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      profileImagePath = null;
    });
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

    RegExp pattern = RegExp(
      r'^[a-zA-Z0-9_]+$',
    );

    if (!pattern.hasMatch(username)) {
      return 'نام کاربری فقط شامل حروف انگلیسی، عدد و _ باشد.';
    }

    return null;
  }

  String? validateEmail(
    String? value,
  ) {
    String email = value?.trim() ?? '';

    RegExp pattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!pattern.hasMatch(email)) {
      return 'ایمیل معتبر وارد کنید.';
    }

    return null;
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (user?.id == null) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isSaving = true;
    });

    try {
      User updatedUser = await presenter.updateProfile(
        userId: user!.id!,
        fullName: fullNameController.text,
        username: usernameController.text,
        email: emailController.text,
        bio: bioController.text,
        profileImagePath: profileImagePath,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        user = updatedUser;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'اطلاعات پروفایل ذخیره شد.',
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
          isSaving = false;
        });
      }
    }
  }

  Future<void> logout() async {
    await presenter.logout();

    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.authWelcome,
      (route) {
        return false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'پروفایل',
        ),
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: buildBody(),
        ),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (presenter.isGuest()) {
      return buildGuestProfile();
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            errorMessage!,
          ),
        ),
      );
    }

    return buildMemberProfile();
  }

  Widget buildGuestProfile() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 48,
              child: Icon(
                Icons.person_outline_rounded,
                size: 52,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'حالت مهمان',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'برای ذخیره اطلاعات شخصی، وارد حساب خود شوید یا ثبت‌نام کنید.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) {
                      return false;
                    },
                  );
                },
                child: const Text(
                  'ورود',
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.register,
                    (route) {
                      return false;
                    },
                  );
                },
                child: const Text(
                  'ایجاد حساب کاربری',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMemberProfile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildProfileImage(),
            const SizedBox(height: 26),
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
              controller: bioController,
              maxLines: 3,
              maxLength: 150,
              decoration: const InputDecoration(
                labelText: 'بیوگرافی کوتاه',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: isSaving ? null : saveProfile,
              icon: const Icon(
                Icons.save_rounded,
              ),
              label: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'ذخیره تغییرات',
                      ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: showChangePasswordDialog,
              icon: const Icon(
                Icons.lock_reset_rounded,
              ),
              label: const Text(
                'تغییر رمز عبور',
              ),
            ),
            const SizedBox(height: 26),
            const Divider(),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: logout,
              icon: const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
              ),
              label: const Text(
                'خروج از حساب',
                style: TextStyle(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileImage() {
    bool hasImage = profileImagePath != null &&
        profileImagePath!.isNotEmpty &&
        File(
          profileImagePath!,
        ).existsSync();

    return Column(
      children: [
        CircleAvatar(
          radius: 58,
          backgroundColor: const Color(0xFFE8E8EE),
          backgroundImage: hasImage
              ? FileImage(
                  File(
                    profileImagePath!,
                  ),
                )
              : null,
          child: hasImage
              ? null
              : const Icon(
                  Icons.person_rounded,
                  size: 58,
                  color: AppColors.textSecondary,
                ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            TextButton.icon(
              onPressed: chooseImage,
              icon: const Icon(
                Icons.photo_library_outlined,
              ),
              label: Text(
                hasImage ? 'تغییر عکس' : 'انتخاب عکس',
              ),
            ),
            if (hasImage)
              TextButton.icon(
                onPressed: removeImage,
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                label: const Text(
                  'حذف',
                  style: TextStyle(
                    color: AppColors.error,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> showChangePasswordDialog() async {
    TextEditingController currentPasswordController = TextEditingController();

    TextEditingController newPasswordController = TextEditingController();

    TextEditingController confirmPasswordController = TextEditingController();

    GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

    bool submitting = false;

    ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'تغییر رمز عبور',
              ),
              content: Form(
                key: passwordFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: currentPasswordController,
                      obscureText: true,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        labelText: 'رمز عبور فعلی',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'رمز فعلی را وارد کنید.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: true,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        labelText: 'رمز عبور جدید',
                      ),
                      validator: (value) {
                        if (value == null || value.length < 8) {
                          return 'حداقل ۸ کاراکتر وارد کنید.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        labelText: 'تکرار رمز جدید',
                      ),
                      validator: (value) {
                        if (value != newPasswordController.text) {
                          return 'رمزها یکسان نیستند.';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                  child: const Text(
                    'انصراف',
                  ),
                ),
                FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          if (!passwordFormKey.currentState!.validate()) {
                            return;
                          }

                          NavigatorState dialogNavigator = Navigator.of(
                            dialogContext,
                          );

                          setDialogState(() {
                            submitting = true;
                          });

                          try {
                            await presenter.changePassword(
                              userId: user!.id!,
                              currentPassword: currentPasswordController.text,
                              newPassword: newPasswordController.text,
                            );

                            if (!mounted) {
                              return;
                            }

                            dialogNavigator.pop();

                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'رمز عبور تغییر کرد.',
                                ),
                              ),
                            );
                          } catch (error) {
                            if (!mounted) {
                              return;
                            }

                            setDialogState(() {
                              submitting = false;
                            });

                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  error.toString().replaceFirst(
                                        'Exception: ',
                                        '',
                                      ),
                                ),
                              ),
                            );
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'تغییر رمز',
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }
}
