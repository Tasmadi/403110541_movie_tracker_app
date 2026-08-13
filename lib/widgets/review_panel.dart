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
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'نظرات کاربران',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${reviews.length} نظر',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (presenter.isGuest()) buildGuestMessage() else buildReviewForm(),
          const SizedBox(height: 18),
          if (errorMessage != null)
            Text(
              errorMessage!,
              style: const TextStyle(
                color: AppColors.error,
              ),
            )
          else if (reviews.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 22,
                ),
                child: Text(
                  'هنوز نظری ثبت نشده است.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ...reviews.map(
              buildReviewCard,
            ),
        ],
      ),
    );
  }

  Widget buildGuestMessage() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(
              Icons.login_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'برای ثبت نظر وارد حساب کاربری شوید.',
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
      ),
    );
  }

  Widget buildReviewForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ownReview == null ? 'نظر شما' : 'ویرایش نظر شما',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: reviewController,
                maxLines: 4,
                maxLength: 1000,
                decoration: const InputDecoration(
                  hintText: 'نظر خود را درباره این اثر بنویسید...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'متن نظر را وارد کنید.';
                  }

                  return null;
                },
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: isSpoiler,
                title: const Text(
                  'این نظر شامل اسپویل است',
                ),
                subtitle: const Text(
                  'محتوای نظر تا انتخاب کاربر مخفی می‌ماند.',
                ),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: isSaving
                    ? null
                    : (value) {
                        setState(() {
                          isSpoiler = value ?? false;
                        });
                      },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isSaving ? null : saveReview,
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          ownReview == null
                              ? Icons.send_rounded
                              : Icons.edit_rounded,
                        ),
                  label: Text(
                    ownReview == null ? 'ثبت نظر' : 'ویرایش نظر',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildReviewCard(
    Review review,
  ) {
    bool spoilerHidden = review.isSpoiler &&
        !review.isOwnReview &&
        !revealedSpoilers.contains(review.id);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                buildAvatar(review),
                const SizedBox(width: 10),
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
                                fontWeight: FontWeight.bold,
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
                                vertical: 2,
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
                                'نظر شما',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        review.displayDate,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (review.isSpoiler)
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 21,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (spoilerHidden)
              buildHiddenSpoiler(
                review,
              )
            else
              Text(
                review.text,
                style: const TextStyle(
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildHiddenSpoiler(
    Review review,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.visibility_off_rounded,
            size: 34,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 8),
          const Text(
            'این نظر شامل اسپویل است',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'برای نمایش متن، دکمه زیر را انتخاب کنید.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
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

    bool hasImage = path != null && path.isNotEmpty && File(path).existsSync();

    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.surfaceLight,
      backgroundImage: hasImage
          ? FileImage(
              File(path),
            )
          : null,
      child: hasImage
          ? null
          : const Icon(
              Icons.person_rounded,
              color: AppColors.textSecondary,
            ),
    );
  }
}
