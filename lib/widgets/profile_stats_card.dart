import 'package:flutter/material.dart';

import '../models/user_statistics.dart';
import '../presenters/user_statistics_presenter.dart';
import '../routes/app_routes.dart';
import '../services/service_locator.dart';
import '../utils/app_colors.dart';

class ProfileStatsCard extends StatefulWidget {
  const ProfileStatsCard({
    super.key,
  });

  @override
  State<ProfileStatsCard> createState() {
    return _ProfileStatsCardState();
  }
}

class _ProfileStatsCardState extends State<ProfileStatsCard> {
  late final UserStatisticsPresenter presenter;

  UserStatisticsSummary? summary;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.userStatisticsPresenter;

    loadSummary();
  }

  Future<void> loadSummary() async {
    if (presenter.isGuest()) {
      return;
    }

    try {
      UserStatisticsSummary result = await presenter.loadSummary();

      if (!mounted) {
        return;
      }

      setState(() {
        summary = result;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (presenter.isGuest()) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(
        16,
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
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(
                    0.13,
                  ),
                  borderRadius: BorderRadius.circular(
                    13,
                  ),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: AppColors.primaryLight,
                  size: 22,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'فعالیت من',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      'خلاصه‌ای از فعالیت شما در TV Time',
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
          const SizedBox(
            height: 18,
          ),
          if (isLoading)
            const SizedBox(
              height: 62,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            )
          else
            Row(
              children: [
                buildValue(
                  icon: Icons.movie_rounded,
                  title: 'فیلم',
                  value: summary?.watchedMovies ?? 0,
                ),
                buildDivider(),
                buildValue(
                  icon: Icons.tv_rounded,
                  title: 'سریال',
                  value: summary?.followedSeries ?? 0,
                ),
                buildDivider(),
                buildValue(
                  icon: Icons.favorite_rounded,
                  title: 'علاقه‌مندی',
                  value: summary?.favorites ?? 0,
                ),
              ],
            ),
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () async {
                await Navigator.pushNamed(
                  context,
                  AppRoutes.statistics,
                );

                if (!mounted) {
                  return;
                }

                await loadSummary();
              },
              icon: const Icon(
                Icons.bar_chart_rounded,
                size: 19,
              ),
              label: const Text(
                'مشاهده آمار کامل',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildValue({
    required IconData icon,
    required String title,
    required int value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primaryLight,
            size: 20,
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            '$value',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(
            height: 2,
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

  Widget buildDivider() {
    return Container(
      width: 1,
      height: 54,
      margin: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      color: AppColors.divider,
    );
  }
}
