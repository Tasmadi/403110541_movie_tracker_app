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
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          22,
        ),
        child: _RatingLoadingCard(),
      );
    }

    if (errorMessage != null || stats == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        22,
      ),
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildHeader(),
            const SizedBox(
              height: 18,
            ),
            buildSummary(),
            const SizedBox(
              height: 20,
            ),
            const Divider(
              color: AppColors.divider,
              height: 1,
            ),
            const SizedBox(
              height: 18,
            ),
            buildUserRating(),
            const SizedBox(
              height: 20,
            ),
            const Divider(
              color: AppColors.divider,
              height: 1,
            ),
            const SizedBox(
              height: 17,
            ),
            buildDistribution(),
            if (presenter.isGuest()) ...[
              const SizedBox(
                height: 15,
              ),
              buildGuestHint(),
            ],
            if (isSaving) ...[
              const SizedBox(
                height: 14,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  20,
                ),
                child: const LinearProgressIndicator(
                  minHeight: 3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(
              0.10,
            ),
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
          child: const Icon(
            Icons.star_rounded,
            color: AppColors.rating,
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
                'امتیاز کاربران',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(
                height: 2,
              ),
              Text(
                'نظر کاربران TV Time درباره این اثر',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(
              10,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Text(
            '${stats!.totalRatings} رأی',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSummary() {
    return Row(
      children: [
        Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.secondary.withOpacity(
                  0.18,
                ),
                AppColors.surfaceLight,
              ],
            ),
            borderRadius: BorderRadius.circular(
              20,
            ),
            border: Border.all(
              color: AppColors.secondary.withOpacity(
                0.20,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stats!.averageRating.toStringAsFixed(
                  1,
                ),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: AppColors.rating,
                    size: 17,
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  Text(
                    'از ۵',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 14,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stats!.totalRatings == 0
                    ? 'هنوز امتیازی ثبت نشده'
                    : getAverageTitle(),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              Text(
                stats!.totalRatings == 0
                    ? 'اولین نفری باش که به این اثر امتیاز می‌دهد.'
                    : 'بر اساس ${stats!.totalRatings} امتیاز ثبت‌شده',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String getAverageTitle() {
    double rating = stats!.averageRating;

    if (rating >= 4.5) {
      return 'عالی';
    }

    if (rating >= 4) {
      return 'خیلی خوب';
    }

    if (rating >= 3) {
      return 'خوب';
    }

    if (rating >= 2) {
      return 'متوسط';
    }

    return 'ضعیف';
  }

  Widget buildUserRating() {
    int? currentRating = stats!.userRating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'امتیاز شما',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (currentRating != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(
                    0.10,
                  ),
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.rating,
                      size: 14,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      '$currentRating / 5',
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(
          height: 11,
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(
              16,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              5,
              (
                int index,
              ) {
                int rating = index + 1;

                bool selected =
                    currentRating != null && rating <= currentRating;

                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                    onTap: isSaving
                        ? null
                        : () {
                            rate(
                              rating,
                            );
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            selected
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: AppColors.rating,
                            size: 30,
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            '$rating',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(
          height: 9,
        ),
        Text(
          currentRating == null
              ? 'برای ثبت امتیاز یکی از ستاره‌ها را انتخاب کن.'
              : 'برای ویرایش، امتیاز جدید را انتخاب کن.',
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget buildDistribution() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'توزیع امتیازها',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        ...List.generate(
          5,
          (
            int index,
          ) {
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
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: AppColors.rating,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 8,
                        color: AppColors.rating,
                        backgroundColor: AppColors.surfaceLight,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 9,
                  ),
                  SizedBox(
                    width: 38,
                    child: Text(
                      '${stats!.getRoundedPercentage(stars)}٪',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildGuestHint() {
    return Container(
      padding: const EdgeInsets.all(
        11,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(
          0.07,
        ),
        borderRadius: BorderRadius.circular(
          13,
        ),
        border: Border.all(
          color: AppColors.primary.withOpacity(
            0.15,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.login_rounded,
            color: AppColors.primaryLight,
            size: 18,
          ),
          const SizedBox(
            width: 8,
          ),
          const Expanded(
            child: Text(
              'برای ثبت امتیاز وارد حساب کاربری شوید.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.login,
              );
            },
            child: const Text(
              'ورود',
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingLoadingCard extends StatelessWidget {
  const _RatingLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          22,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
