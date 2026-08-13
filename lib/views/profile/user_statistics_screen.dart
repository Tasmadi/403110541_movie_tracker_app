import 'package:flutter/material.dart';

import '../../models/user_statistics.dart';
import '../../presenters/user_statistics_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_logo.dart';

class UserStatisticsScreen extends StatefulWidget {
  const UserStatisticsScreen({
    super.key,
  });

  @override
  State<UserStatisticsScreen> createState() {
    return _UserStatisticsScreenState();
  }
}

class _UserStatisticsScreenState extends State<UserStatisticsScreen> {
  late final UserStatisticsPresenter presenter;

  UserStatistics? statistics;

  bool isLoading = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.userStatisticsPresenter;

    loadStatistics();
  }

  Future<void> loadStatistics() async {
    if (presenter.isGuest()) {
      setState(() {
        isLoading = false;
      });

      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      UserStatistics result = await presenter.loadStatistics();

      if (!mounted) {
        return;
      }

      setState(() {
        statistics = result;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              buildTopBar(),
              Expanded(
                child: buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTopBar() {
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
                  'آمار فعالیت',
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
                  'مروری بر دنیای فیلم و سریال شما',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(
                14,
              ),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: IconButton(
              tooltip: 'بازگشت',
              onPressed: () {
                Navigator.maybePop(
                  context,
                );
              },
              icon: const Icon(
                Icons.arrow_forward_rounded,
                size: 21,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    if (presenter.isGuest()) {
      return buildGuest();
    }

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
              'در حال محاسبه آمار...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null || statistics == null) {
      return buildError();
    }

    return RefreshIndicator(
      onRefresh: loadStatistics,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          30,
        ),
        children: [
          buildHeroCard(),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'آمار تماشا',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 11,
            crossAxisSpacing: 11,
            childAspectRatio: 1.18,
            children: [
              buildStatCard(
                icon: Icons.movie_rounded,
                title: 'فیلم دیده‌شده',
                value: '${statistics!.watchedMovies}',
                color: AppColors.primaryLight,
              ),
              buildStatCard(
                icon: Icons.tv_rounded,
                title: 'سریال دیده‌شده',
                value: '${statistics!.watchedSeries}',
                color: AppColors.primary,
              ),
              buildStatCard(
                icon: Icons.play_circle_rounded,
                title: 'قسمت دیده‌شده',
                value: '${statistics!.watchedEpisodes}',
                color: AppColors.success,
              ),
              buildStatCard(
                icon: Icons.schedule_rounded,
                title: 'زمان تماشا',
                value: statistics!.watchTimeText,
                color: AppColors.secondary,
              ),
              buildStatCard(
                icon: Icons.category_rounded,
                title: 'ژانر محبوب',
                value: statistics!.favoriteGenre,
                color: AppColors.primaryLight,
              ),
              buildStatCard(
                icon: Icons.star_rounded,
                title: 'میانگین امتیاز',
                value: statistics!.averageRatingText,
                color: AppColors.rating,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'فعالیت بیشتر',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          buildExtraInfo(),
        ],
      ),
    );
  }

  Widget buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(
        18,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary.withOpacity(
              0.23,
            ),
            AppColors.surface,
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(
          24,
        ),
        border: Border.all(
          color: AppColors.primary.withOpacity(
            0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryLight,
                  AppColors.primary,
                ],
              ),
              borderRadius: BorderRadius.circular(
                19,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(
                    0.25,
                  ),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(
            width: 14,
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'فعالیت شما در TV Time',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                Text(
                  'همه زمان‌هایی که با فیلم‌ها و سریال‌ها گذرانده‌ای اینجا جمع شده است.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(
        14,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(
                0.12,
              ),
              borderRadius: BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(
            height: 9,
          ),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExtraInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
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
        children: [
          buildInfoRow(
            icon: Icons.bookmark_rounded,
            title: 'سریال‌های دنبال‌شده',
            value: '${statistics!.followedSeries}',
          ),
          const Divider(
            color: AppColors.divider,
          ),
          buildInfoRow(
            icon: Icons.favorite_rounded,
            title: 'علاقه‌مندی‌ها',
            value: '${statistics!.favorites}',
          ),
          const Divider(
            color: AppColors.divider,
          ),
          buildInfoRow(
            icon: Icons.star_rate_rounded,
            title: 'امتیازهای ثبت‌شده',
            value: '${statistics!.ratingCount}',
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(
                0.10,
              ),
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryLight,
              size: 19,
            ),
          ),
          const SizedBox(
            width: 11,
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGuest() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(
          28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(
                  0.10,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(
                    0.22,
                  ),
                ),
              ),
              child: const Icon(
                Icons.insights_outlined,
                size: 50,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(
              height: 22,
            ),
            const Text(
              'آمار فعالیت شما',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 9,
            ),
            const Text(
              'برای مشاهده آمار تماشا و فعالیت خود وارد حساب کاربری شوید.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.7,
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.login,
                  );
                },
                icon: const Icon(
                  Icons.login_rounded,
                ),
                label: const Text(
                  'ورود به حساب',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(
                  0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: AppColors.error,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            const Text(
              'دریافت آمار انجام نشد',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(
                height: 8,
              ),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(
              height: 20,
            ),
            FilledButton.icon(
              onPressed: loadStatistics,
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
}
