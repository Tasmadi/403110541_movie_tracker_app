import 'dart:io';

import 'package:flutter/material.dart';

import '../models/review.dart';
import '../presenters/review_presenter.dart';
import '../routes/app_routes.dart';
import '../services/service_locator.dart';
import '../utils/app_colors.dart';

class ReviewPanel extends StatefulWidget {
  final int mediaId;
  final String mediaType;

  const ReviewPanel({
    super.key,
    required this.mediaId,
    required this.mediaType,
  });

  @override
  State<ReviewPanel> createState() {
    return _ReviewPanelState();
  }
}

class _ReviewPanelState extends State<ReviewPanel> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController reviewController = TextEditingController();

  late final ReviewPresenter presenter;

  List<Review> reviews = [];

  Review? ownReview;

  final Set<int> revealedSpoilers = {};

  bool isSpoiler = false;

  bool isLoading = true;

  bool isSaving = false;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.reviewPresenter;

    loadReviews();
  }

  @override
  void dispose() {
    reviewController.dispose();

    super.dispose();
  }

  Future<void> loadReviews() async {
    try {
      List<Review> result = await presenter.loadReviews(
        mediaId: widget.mediaId,
        mediaType: widget.mediaType,
      );

      if (!mounted) {
        return;
      }

      Review? currentUserReview;

      for (Review review in result) {
        if (review.isOwnReview) {
          currentUserReview = review;
          break;
        }
      }

      setState(() {
        reviews = result;
        ownReview = currentUserReview;

        if (currentUserReview != null) {
          reviewController.text = currentUserReview.text;

          isSpoiler = currentUserReview.isSpoiler;
        }

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

  Future<void> saveReview() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (presenter.isGuest()) {
      showLoginMessage();
      return;
    }

    FocusScope.of(context).unfocus();

    bool wasEditing = ownReview != null;

    setState(() {
      isSaving = true;
    });

    try {
      List<Review> result = await presenter.saveReview(
        mediaId: widget.mediaId,
        mediaType: widget.mediaType,
        text: reviewController.text,
        isSpoiler: isSpoiler,
      );

      if (!mounted) {
        return;
      }

      Review? currentUserReview;

      for (Review review in result) {
        if (review.isOwnReview) {
          currentUserReview = review;
          break;
        }
      }

      setState(() {
        reviews = result;
        ownReview = currentUserReview;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasEditing ? 'نظر شما ویرایش شد.' : 'نظر شما ثبت شد.',
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
          'برای ثبت نظر وارد حساب کاربری شوید.',
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
          24,
        ),
        child: _ReviewLoadingCard(),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildHeader(),
          const SizedBox(
            height: 13,
          ),
          if (presenter.isGuest()) buildGuestMessage() else buildReviewForm(),
          const SizedBox(
            height: 17,
          ),
          if (errorMessage != null)
            buildErrorMessage()
          else if (reviews.isEmpty)
            buildEmptyReviews()
          else
            ...reviews.map(
              buildReviewCard,
            ),
        ],
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
            color: AppColors.primary.withOpacity(
              0.11,
            ),
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
          child: const Icon(
            Icons.forum_rounded,
            color: AppColors.primaryLight,
            size: 21,
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
                'نظرات کاربران',
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
                'تجربه کاربران TV Time درباره این اثر',
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
            horizontal: 10,
            vertical: 6,
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
            '${reviews.length} نظر',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildGuestMessage() {
    return Container(
      padding: const EdgeInsets.all(
        15,
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
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(
                0.10,
              ),
              borderRadius: BorderRadius.circular(
                13,
              ),
            ),
            child: const Icon(
              Icons.login_rounded,
              color: AppColors.primaryLight,
              size: 21,
            ),
          ),
          const SizedBox(
            width: 11,
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نظر خودت را بنویس',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  'برای ثبت نظر وارد حساب کاربری شوید.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
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

  Widget buildReviewForm() {
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
          color: ownReview != null
              ? AppColors.primary.withOpacity(
                  0.30,
                )
              : AppColors.border,
        ),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
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
                    ownReview == null
                        ? Icons.rate_review_outlined
                        : Icons.edit_rounded,
                    color: AppColors.primaryLight,
                    size: 20,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    ownReview == null ? 'نظر شما' : 'ویرایش نظر شما',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (ownReview != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(
                        0.10,
                      ),
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                    ),
                    child: const Text(
                      'ثبت شده',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            TextFormField(
              controller: reviewController,
              maxLines: 5,
              maxLength: 1000,
              decoration: const InputDecoration(
                hintText: 'نظر خود را درباره این اثر بنویسید...',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(
                    bottom: 75,
                  ),
                  child: Icon(
                    Icons.notes_rounded,
                  ),
                ),
              ),
              validator: (
                String? value,
              ) {
                if (value == null || value.trim().isEmpty) {
                  return 'متن نظر را وارد کنید.';
                }

                return null;
              },
            ),
            const SizedBox(
              height: 4,
            ),
            buildSpoilerControl(),
            const SizedBox(
              height: 14,
            ),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: isSaving ? null : saveReview,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        ownReview == null
                            ? Icons.send_rounded
                            : Icons.edit_rounded,
                      ),
                label: Text(
                  isSaving
                      ? 'در حال ذخیره...'
                      : ownReview == null
                          ? 'ثبت نظر'
                          : 'ذخیره ویرایش',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSpoilerControl() {
    return InkWell(
      borderRadius: BorderRadius.circular(
        15,
      ),
      onTap: isSaving
          ? null
          : () {
              setState(() {
                isSpoiler = !isSpoiler;
              });
            },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: isSpoiler
              ? AppColors.warning.withOpacity(
                  0.09,
                )
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(
            15,
          ),
          border: Border.all(
            color: isSpoiler
                ? AppColors.warning.withOpacity(
                    0.30,
                  )
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isSpoiler
                    ? AppColors.warning.withOpacity(
                        0.13,
                      )
                    : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(
                  10,
                ),
              ),
              child: Icon(
                isSpoiler
                    ? Icons.warning_amber_rounded
                    : Icons.visibility_outlined,
                color: isSpoiler ? AppColors.warning : AppColors.textMuted,
                size: 18,
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
                    'این نظر شامل اسپویل است',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    'محتوای نظر برای دیگران مخفی می‌ماند.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isSpoiler,
              onChanged: isSaving
                  ? null
                  : (
                      bool value,
                    ) {
                      setState(() {
                        isSpoiler = value;
                      });
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(
        14,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(
          0.08,
        ),
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: AppColors.error.withOpacity(
            0.20,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 21,
          ),
          const SizedBox(
            width: 9,
          ),
          Expanded(
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
          IconButton(
            tooltip: 'تلاش دوباره',
            onPressed: loadReviews,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.error,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyReviews() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 30,
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
      child: const Column(
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            color: AppColors.textMuted,
            size: 38,
          ),
          SizedBox(
            height: 11,
          ),
          Text(
            'هنوز نظری ثبت نشده',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Text(
            'اولین نظر درباره این اثر را ثبت کن.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReviewCard(
    Review review,
  ) {
    bool spoilerHidden = review.isSpoiler &&
        !review.isOwnReview &&
        !revealedSpoilers.contains(
          review.id,
        );

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(
        15,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color: review.isOwnReview
              ? AppColors.primary.withOpacity(
                  0.28,
                )
              : review.isSpoiler
                  ? AppColors.warning.withOpacity(
                      0.22,
                    )
                  : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildReviewAuthor(
            review,
          ),
          const SizedBox(
            height: 14,
          ),
          if (spoilerHidden)
            buildHiddenSpoiler(
              review,
            )
          else
            buildReviewText(
              review,
            ),
        ],
      ),
    );
  }

  Widget buildReviewAuthor(
    Review review,
  ) {
    return Row(
      children: [
        buildAvatar(
          review,
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '@${review.username}',
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (review.isOwnReview) ...[
                    const SizedBox(
                      width: 7,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(
                          0.11,
                        ),
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                      ),
                      child: const Text(
                        'نظر شما',
                        style: TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    color: AppColors.textMuted,
                    size: 11,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    review.displayDate,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (review.isSpoiler)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(
                0.10,
              ),
              borderRadius: BorderRadius.circular(
                9,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 13,
                ),
                SizedBox(
                  width: 3,
                ),
                Text(
                  'اسپویل',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget buildReviewText(
    Review review,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        13,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(
          14,
        ),
      ),
      child: Text(
        review.text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          height: 1.7,
        ),
      ),
    );
  }

  Widget buildHiddenSpoiler(
    Review review,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        17,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(
          15,
        ),
        border: Border.all(
          color: AppColors.warning.withOpacity(
            0.18,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(
                0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.visibility_off_rounded,
              size: 25,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'این نظر شامل اسپویل است',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          const Text(
            'اگر هنوز این اثر را ندیده‌ای، بهتر است متن را باز نکنی.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
              height: 1.5,
            ),
          ),
          const SizedBox(
            height: 13,
          ),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                revealedSpoilers.add(
                  review.id,
                );
              });
            },
            icon: const Icon(
              Icons.visibility_rounded,
              size: 18,
            ),
            label: const Text(
              'نمایش اسپویل',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAvatar(
    Review review,
  ) {
    String? path = review.profileImagePath;

    bool hasImage = path != null &&
        path.isNotEmpty &&
        File(
          path,
        ).existsSync();

    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(
        2,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: review.isOwnReview ? AppColors.primary : AppColors.border,
          width: 2,
        ),
      ),
      child: CircleAvatar(
        backgroundColor: AppColors.surfaceLight,
        backgroundImage: hasImage
            ? FileImage(
                File(
                  path,
                ),
              )
            : null,
        child: hasImage
            ? null
            : const Icon(
                Icons.person_rounded,
                color: AppColors.textSecondary,
                size: 23,
              ),
      ),
    );
  }
}

class _ReviewLoadingCard extends StatelessWidget {
  const _ReviewLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
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
