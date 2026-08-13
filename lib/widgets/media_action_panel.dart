import 'package:flutter/material.dart';

import '../models/user_media_item.dart';
import '../presenters/user_media_presenter.dart';
import '../routes/app_routes.dart';
import '../services/service_locator.dart';
import '../utils/app_colors.dart';

class MediaActionPanel extends StatefulWidget {
  final int mediaId;
  final String mediaType;
  final String title;
  final String? posterPath;
  final String releaseYear;
  final VoidCallback? onChanged;

  const MediaActionPanel({
    super.key,
    required this.mediaId,
    required this.mediaType,
    required this.title,
    required this.posterPath,
    required this.releaseYear,
    this.onChanged,
  });

  @override
  State<MediaActionPanel> createState() {
    return _MediaActionPanelState();
  }
}

class _MediaActionPanelState extends State<MediaActionPanel> {
  late final UserMediaPresenter presenter;

  String watchStatus = WatchStatus.none;

  bool isFavorite = false;

  bool isLoading = true;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.userMediaPresenter;

    loadItem();
  }

  Future<void> loadItem() async {
    if (presenter.isGuest()) {
      setState(() {
        isLoading = false;
      });

      return;
    }

    try {
      UserMediaItem? item = await presenter.getItem(
        mediaId: widget.mediaId,
        mediaType: widget.mediaType,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        watchStatus = item?.watchStatus ?? WatchStatus.none;

        isFavorite = item?.isFavorite ?? false;

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

  void showLoginMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'برای ذخیره وضعیت وارد حساب کاربری شوید.',
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

  Future<void> changeStatus(
    String value,
  ) async {
    if (presenter.isGuest()) {
      showLoginMessage();

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      UserMediaItem? item = await presenter.setStatus(
        mediaId: widget.mediaId,
        mediaType: widget.mediaType,
        title: widget.title,
        posterPath: widget.posterPath,
        releaseYear: widget.releaseYear,
        watchStatus: value,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        watchStatus = item?.watchStatus ?? WatchStatus.none;

        isFavorite = item?.isFavorite ?? false;
      });

      widget.onChanged?.call();
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

  Future<void> toggleFavorite() async {
    if (presenter.isGuest()) {
      showLoginMessage();

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      UserMediaItem? item = await presenter.toggleFavorite(
        mediaId: widget.mediaId,
        mediaType: widget.mediaType,
        title: widget.title,
        posterPath: widget.posterPath,
        releaseYear: widget.releaseYear,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        watchStatus = item?.watchStatus ?? WatchStatus.none;

        isFavorite = item?.isFavorite ?? false;
      });
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          22,
        ),
        child: ContainerLoadingPlaceholder(),
      );
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
              height: 17,
            ),
            buildStatusControl(),
            const SizedBox(
              height: 13,
            ),
            buildFavoriteButton(),
            if (presenter.isGuest()) ...[
              const SizedBox(
                height: 12,
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
            color: AppColors.primary.withOpacity(
              0.11,
            ),
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
          child: const Icon(
            Icons.bookmark_added_rounded,
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
                'وضعیت شخصی',
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
                'این اثر را در کتابخانه شخصی خود مدیریت کن',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        buildStatusIndicator(),
      ],
    );
  }

  Widget buildStatusIndicator() {
    bool hasStatus = watchStatus != WatchStatus.none;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: hasStatus
            ? AppColors.primary.withOpacity(
                0.12,
              )
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(
          10,
        ),
        border: Border.all(
          color: hasStatus
              ? AppColors.primary.withOpacity(
                  0.22,
                )
              : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasStatus
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 13,
            color: hasStatus ? AppColors.primaryLight : AppColors.textMuted,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            hasStatus ? 'ثبت شده' : 'ثبت نشده',
            style: TextStyle(
              color: hasStatus ? AppColors.primaryLight : AppColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusControl() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        13,
        6,
        13,
        6,
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
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(
                0.10,
              ),
              borderRadius: BorderRadius.circular(
                11,
              ),
            ),
            child: const Icon(
              Icons.visibility_outlined,
              color: AppColors.primaryLight,
              size: 19,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          const Text(
            'وضعیت تماشا',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: watchStatus,
                isExpanded: true,
                dropdownColor: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(
                  16,
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                ),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                items: WatchStatus.values.map(
                  (
                    String status,
                  ) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(
                        WatchStatus.getTitle(
                          status,
                        ),
                      ),
                    );
                  },
                ).toList(),
                onChanged: isSaving
                    ? null
                    : (
                        String? value,
                      ) {
                        if (value != null) {
                          changeStatus(
                            value,
                          );
                        }
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFavoriteButton() {
    if (isFavorite) {
      return SizedBox(
        height: 50,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error.withOpacity(
              0.15,
            ),
            foregroundColor: AppColors.error,
          ),
          onPressed: isSaving ? null : toggleFavorite,
          icon: const Icon(
            Icons.favorite_rounded,
            size: 20,
          ),
          label: const Text(
            'در علاقه‌مندی‌های شما',
          ),
        ),
      );
    }

    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: isSaving ? null : toggleFavorite,
        icon: const Icon(
          Icons.favorite_border_rounded,
          size: 20,
        ),
        label: const Text(
          'افزودن به علاقه‌مندی‌ها',
        ),
      ),
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
            Icons.info_outline_rounded,
            color: AppColors.primaryLight,
            size: 18,
          ),
          const SizedBox(
            width: 8,
          ),
          const Expanded(
            child: Text(
              'برای ذخیره وضعیت و علاقه‌مندی وارد حساب شوید.',
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

class ContainerLoadingPlaceholder extends StatelessWidget {
  const ContainerLoadingPlaceholder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
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
