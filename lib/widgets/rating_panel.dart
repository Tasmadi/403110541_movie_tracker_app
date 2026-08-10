import 'package:flutter/material.dart';

import '../models/rating_stats.dart';
import '../presenters/rating_presenter.dart';
import '../routes/app_routes.dart';
import '../services/service_locator.dart';
import '../utils/app_colors.dart';

class RatingPanel extends StatefulWidget {
  final int mediaId;
  final String mediaType;

  const RatingPanel({
    super.key,
    required this.mediaId,
    required this.mediaType,
  });

  @override
  State<RatingPanel> createState() {
    return _RatingPanelState();
  }
}

class _RatingPanelState extends State<RatingPanel> {
  late final RatingPresenter presenter;

  RatingStats? stats;

  bool isLoading = true;

  bool isSaving = false;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.ratingPresenter;

    loadStats();
  }

  Future<void> loadStats() async {
    try {
      RatingStats result = await presenter.loadStats(
        mediaId: widget.mediaId,
        mediaType: widget.mediaType,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        stats = result;
        isLoading = false;
        errorMessage = null;
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

  Future<void> rate(
    int rating,
  ) async {
    if (presenter.isGuest()) {
      showLoginMessage();

      return;
    }

    int? previousRating = stats?.userRating;

    setState(() {
      isSaving = true;
    });

    try {
      RatingStats result = await presenter.setRating(
        mediaId: widget.mediaId,
        mediaType: widget.mediaType,
        rating: rating,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        stats = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            previousRating == null
                ? 'امتیاز شما ثبت شد.'
                : 'امتیاز شما ویرایش شد.',
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

  void showLoginMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'برای ثبت امتیاز وارد حساب کاربری شوید.',
        ),
        action: SnackBarAction(
          label: 'ورود',
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.login,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        22,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'امتیاز کاربران',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              buildSummary(),
              const SizedBox(height: 18),
              buildUserRating(),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              buildDistribution(),
              if (isSaving) ...[
                const SizedBox(height: 14),
                const LinearProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSummary() {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stats!.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(
                Icons.star_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stats!.totalRatings == 0
                    ? 'هنوز امتیازی ثبت نشده'
                    : 'میانگین امتیاز کاربران',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${stats!.totalRatings} امتیاز ثبت شده',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildUserRating() {
    int? currentRating = stats!.userRating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentRating == null
              ? 'امتیاز شما'
              : 'امتیاز شما: $currentRating از ۵',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(
            5,
            (index) {
              int rating = index + 1;

              bool selected = currentRating != null && rating <= currentRating;

              return IconButton(
                onPressed: isSaving
                    ? null
                    : () {
                        rate(rating);
                      },
                tooltip: '$rating ستاره',
                icon: Icon(
                  selected ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AppColors.secondary,
                  size: 32,
                ),
              );
            },
          ),
        ),
        if (currentRating != null)
          const Text(
            'برای ویرایش، تعداد ستاره جدید را انتخاب کنید.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget buildDistribution() {
    return Column(
      children: List.generate(
        5,
        (index) {
          int stars = 5 - index;

          double percentage = stats!.getPercentage(
            stars,
          );

          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  child: Row(
                    children: [
                      Text(
                        '$stars',
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 42,
                  child: Text(
                    '${stats!.getRoundedPercentage(stars)}٪',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
