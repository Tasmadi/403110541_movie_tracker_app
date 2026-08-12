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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isLoading)
              const LinearProgressIndicator()
            else
              Row(
                children: [
                  buildValue(
                    'فیلم',
                    summary?.watchedMovies ?? 0,
                  ),
                  buildDivider(),
                  buildValue(
                    'سریال',
                    summary?.followedSeries ?? 0,
                  ),
                  buildDivider(),
                  buildValue(
                    'علاقه‌مندی',
                    summary?.favorites ?? 0,
                  ),
                ],
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
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
                  Icons.insights_rounded,
                ),
                label: const Text(
                  'مشاهده آمار فعالیت',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildValue(
    String title,
    int value,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDivider() {
    return Container(
      width: 1,
      height: 38,
      color: const Color(0xFFE0E0E6),
    );
  }
}
