import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../widgets/profile_stats_card.dart';
import '../../presenters/auth_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/profile_image_service.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/main_bottom_navigation.dart';
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

  String? savedProfileImagePath;

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

      savedProfileImagePath = currentUser.profileImagePath;

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
    String? path = await imageService.pickProfileImage();

    if (path == null || !mounted) {
      return;
    }

    String? previousPath = profileImagePath;

    if (previousPath != null &&
        previousPath.isNotEmpty &&
        previousPath != savedProfileImagePath) {
      await imageService.removeProfileImage(
        previousPath,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      profileImagePath = path;
    });
  }

  Future<void> removeImage() async {
    String? currentPath = profileImagePath;

    if (currentPath != null &&
        currentPath.isNotEmpty &&
        currentPath != savedProfileImagePath) {
      await imageService.removeProfileImage(
        currentPath,
      );
    }

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
      String? previousSavedImagePath = savedProfileImagePath;
      User updatedUser = await presenter.updateProfile(
        userId: user!.id!,
        fullName: fullNameController.text,
        username: usernameController.text,
        email: emailController.text,
        bio: bioController.text,
        profileImagePath: profileImagePath,
      );

      if (previousSavedImagePath != null &&
          previousSavedImagePath.isNotEmpty &&
          previousSavedImagePath != updatedUser.profileImagePath) {
        await imageService.removeProfileImage(
          previousSavedImagePath,
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        user = updatedUser;

        profileImagePath = updatedUser.profileImagePath;

        savedProfileImagePath = updatedUser.profileImagePath;
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

  void onNavigationSelected(
    int index,
  ) {
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) {
            return false;
          },
        );
        return;

      case 1:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.search,
        );
        return;

      case 2:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.watchlist,
        );
        return;

      case 3:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.customLists,
        );
        return;

      case 4:
        return;
    }
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        8,
      ),
      child: Row(
        children: [
          const AppLogo(
            size: 42,
            showTitle: false,
            showTagline: false,
          ),
          const SizedBox(
            width: 10,
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'پروفایل من',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  'حساب و فعالیت‌های شما',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              buildHeader(),
              Expanded(
                child: buildBody(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MainBottomNavigation(
        currentIndex: 4,
        onSelected: onNavigationSelected,
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 38,
              height: 38,
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ),
            ),
            SizedBox(
              height: 14,
            ),
            Text(
              'در حال دریافت پروفایل...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    if (presenter.isGuest()) {
      return buildGuestProfile();
    }

    if (errorMessage != null) {
      return buildErrorView();
    }

    return buildMemberProfile();
  }

  Widget buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          28,
          20,
          28,
          120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 54,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            FilledButton.icon(
              onPressed: loadProfile,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'تلاش دوباره',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGuestProfile() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          28,
          20,
          28,
          120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(
                  0.10,
                ),
                border: Border.all(
                  color: AppColors.primary.withOpacity(
                    0.25,
                  ),
                ),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 56,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(
              height: 22,
            ),
            const Text(
              'حالت مهمان',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 9,
            ),
            const Text(
              'با ساخت حساب می‌توانی فعالیت‌ها، آمار، لیست‌ها و اطلاعات شخصی خودت را ذخیره کنی.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.7,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) {
                      return false;
                    },
                  );
                },
                icon: const Icon(
                  Icons.login_rounded,
                ),
                label: const Text(
                  'ورود',
                ),
              ),
            ),
            const SizedBox(
              height: 11,
            ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.register,
                    (route) {
                      return false;
                    },
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
          ],
        ),
      ),
    );
  }

  Widget buildMemberProfile() {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(
        18,
        8,
        18,
        120,
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildProfileHero(),
            const SizedBox(
              height: 16,
            ),
            const ProfileStatsCard(),
            const SizedBox(
              height: 16,
            ),
            buildAccountCard(),
            const SizedBox(
              height: 16,
            ),
            buildSecurityCard(),
            const SizedBox(
              height: 18,
            ),
            buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget buildProfileHero() {
    bool hasImage = profileImagePath != null &&
        profileImagePath!.isNotEmpty &&
        File(
          profileImagePath!,
        ).existsSync();

    return Container(
      padding: const EdgeInsets.all(
        20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary.withOpacity(
              0.22,
            ),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(
          25,
        ),
        border: Border.all(
          color: AppColors.primary.withOpacity(
            0.22,
          ),
        ),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 122,
                height: 122,
                padding: const EdgeInsets.all(
                  4,
                ),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryLight,
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: AppColors.surfaceLight,
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
              ),
              Positioned(
                left: -4,
                bottom: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surface,
                      width: 3,
                    ),
                  ),
                  child: IconButton(
                    onPressed: chooseImage,
                    constraints: const BoxConstraints(
                      minWidth: 38,
                      minHeight: 38,
                    ),
                    padding: const EdgeInsets.all(
                      7,
                    ),
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            user?.fullName ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            '@${user?.username ?? ''}',
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              color: AppColors.primaryLight,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (user != null && user!.bio.trim().isNotEmpty) ...[
            const SizedBox(
              height: 9,
            ),
            Text(
              user!.bio,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.6,
              ),
            ),
          ],
          const SizedBox(
            height: 12,
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: chooseImage,
                icon: const Icon(
                  Icons.photo_library_outlined,
                  size: 18,
                ),
                label: Text(
                  hasImage ? 'تغییر عکس' : 'انتخاب عکس',
                ),
              ),
              if (hasImage)
                TextButton.icon(
                  onPressed: removeImage,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                  label: const Text(
                    'حذف عکس',
                    style: TextStyle(
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildAccountCard() {
    return Container(
      padding: const EdgeInsets.all(
        17,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          22,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(
                Icons.manage_accounts_rounded,
                color: AppColors.primaryLight,
                size: 22,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                'اطلاعات حساب',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 17,
          ),
          TextFormField(
            controller: fullNameController,
            validator: validateFullName,
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
            decoration: const InputDecoration(
              labelText: 'نام کاربری',
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
            decoration: const InputDecoration(
              labelText: 'ایمیل',
              prefixIcon: Icon(
                Icons.email_outlined,
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
            height: 52,
            child: FilledButton.icon(
              onPressed: isSaving ? null : saveProfile,
              icon: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.save_rounded,
                    ),
              label: Text(
                isSaving ? 'در حال ذخیره...' : 'ذخیره تغییرات',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSecurityCard() {
    return Container(
      padding: const EdgeInsets.all(
        17,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          22,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(
                Icons.security_rounded,
                color: AppColors.primaryLight,
                size: 22,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                'امنیت حساب',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'در صورت نیاز می‌توانید رمز عبور حساب خود را تغییر دهید.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.6,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: showChangePasswordDialog,
              icon: const Icon(
                Icons.lock_reset_rounded,
              ),
              label: const Text(
                'تغییر رمز عبور',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLogoutButton() {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: logout,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(
            color: AppColors.error,
          ),
        ),
        icon: const Icon(
          Icons.logout_rounded,
        ),
        label: const Text(
          'خروج از حساب',
        ),
      ),
    );
  }

  Future<void> showChangePasswordDialog() async {
    if (user?.id == null) {
      return;
    }

    bool? passwordChanged = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ChangePasswordDialog(
          userId: user!.id!,
          presenter: presenter,
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (passwordChanged == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'رمز عبور با موفقیت تغییر کرد.',
          ),
        ),
      );
    }
  }
}

class ChangePasswordDialog extends StatefulWidget {
  final int userId;
  final AuthPresenter presenter;

  const ChangePasswordDialog({
    super.key,
    required this.userId,
    required this.presenter,
  });

  @override
  State<ChangePasswordDialog> createState() {
    return _ChangePasswordDialogState();
  }
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController currentPasswordController =
      TextEditingController();

  final TextEditingController newPasswordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  String? errorMessage;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await widget.presenter.changePassword(
        userId: widget.userId,
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'تغییر رمز عبور',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: obscureCurrentPassword,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: 'رمز عبور فعلی',
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscureCurrentPassword = !obscureCurrentPassword;
                      });
                    },
                    icon: Icon(
                      obscureCurrentPassword
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'رمز عبور فعلی را وارد کنید.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: newPasswordController,
                obscureText: obscureNewPassword,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: 'رمز عبور جدید',
                  prefixIcon: const Icon(
                    Icons.lock_reset_rounded,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscureNewPassword = !obscureNewPassword;
                      });
                    },
                    icon: Icon(
                      obscureNewPassword
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'رمز جدید باید حداقل ۸ کاراکتر باشد.';
                  }

                  if (value == currentPasswordController.text) {
                    return 'رمز جدید باید با رمز فعلی متفاوت باشد.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: 'تکرار رمز عبور جدید',
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
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'رمزهای جدید یکسان نیستند.';
                  }

                  return null;
                },
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
          child: const Text(
            'انصراف',
          ),
        ),
        FilledButton(
          onPressed: isLoading ? null : changePassword,
          child: isLoading
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
  }
}
