import 'package:flutter/material.dart';

import '../../models/user_statistics.dart';
import '../../presenters/user_statistics_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';

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
      appBar: AppBar(
        title: const Text(
          'آمار فعالیت',
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    if (presenter.isGuest()) {
      return buildGuest();
    }

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null || statistics == null) {
      return buildError();
    }

    return RefreshIndicator(
      onRefresh: loadStatistics,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          buildHeader(),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.25,
            children: [
              buildStatCard(
                icon: Icons.movie_rounded,
                title: 'فیلم‌های دیده‌شده',
                value: '${statistics!.watchedMovies}',
              ),
              buildStatCard(
                icon: Icons.tv_rounded,
                title: 'سریال‌های دیده‌شده',
                value: '${statistics!.watchedSeries}',
              ),
              buildStatCard(
                icon: Icons.play_circle_rounded,
                title: 'قسمت‌های دیده‌شده',
                value: '${statistics!.watchedEpisodes}',
              ),
              buildStatCard(
                icon: Icons.schedule_rounded,
                title: 'زمان تقریبی تماشا',
                value: statistics!.watchTimeText,
              ),
              buildStatCard(
                icon: Icons.category_rounded,
                title: 'ژانر موردعلاقه',
                value: statistics!.favoriteGenre,
              ),
              buildStatCard(
                icon: Icons.star_rounded,
                title: 'میانگین امتیازها',
                value: statistics!.averageRatingText,
              ),
            ],
          ),
          const SizedBox(height: 16),
          buildExtraInfo(),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(
                  16,
                ),
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'فعالیت شما',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'خلاصه‌ای از فیلم‌ها و سریال‌هایی که دنبال کرده‌اید.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 30,
            ),
            const SizedBox(height: 9),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildExtraInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildInfoRow(
              icon: Icons.bookmark_rounded,
              title: 'سریال‌های دنبال‌شده',
              value: '${statistics!.followedSeries}',
            ),
            const Divider(),
            buildInfoRow(
              icon: Icons.favorite_rounded,
              title: 'علاقه‌مندی‌ها',
              value: '${statistics!.favorites}',
            ),
            const Divider(),
            buildInfoRow(
              icon: Icons.rate_review_rounded,
              title: 'تعداد امتیازهای ثبت‌شده',
              value: '${statistics!.ratingCount}',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildGuest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.insights_outlined,
              size: 72,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 18),
            const Text(
              'آمار فعالیت مخصوص کاربران عضو است.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.login,
                );
              },
              child: const Text(
                'ورود به حساب',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildError() {
    return Center(
      child: FilledButton.icon(
        onPressed: loadStatistics,
        icon: const Icon(
          Icons.refresh_rounded,
        ),
        label: const Text(
          'تلاش دوباره',
        ),
      ),
    );
  }
}
