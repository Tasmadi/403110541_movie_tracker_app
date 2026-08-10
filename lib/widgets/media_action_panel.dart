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

  const MediaActionPanel({
    super.key,
    required this.mediaId,
    required this.mediaType,
    required this.title,
    required this.posterPath,
    required this.releaseYear,
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
        22,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'وضعیت شخصی',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: watchStatus,
                decoration: const InputDecoration(
                  labelText: 'وضعیت تماشا',
                  border: OutlineInputBorder(),
                ),
                items: WatchStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(
                      WatchStatus.getTitle(
                        status,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value != null) {
                          changeStatus(
                            value,
                          );
                        }
                      },
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: isSaving ? null : toggleFavorite,
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? AppColors.error : null,
                ),
                label: Text(
                  isFavorite
                      ? 'حذف از علاقه‌مندی‌ها'
                      : 'افزودن به علاقه‌مندی‌ها',
                ),
              ),
              if (isSaving) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
