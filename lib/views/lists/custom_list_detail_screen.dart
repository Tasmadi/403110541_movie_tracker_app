import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/custom_list_detail_arguments.dart';
import '../../models/custom_list_item.dart';
import '../../presenters/custom_list_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';

class CustomListDetailScreen extends StatefulWidget {
  final CustomListDetailArguments arguments;

  const CustomListDetailScreen({
    super.key,
    required this.arguments,
  });

  @override
  State<CustomListDetailScreen> createState() {
    return _CustomListDetailScreenState();
  }
}

class _CustomListDetailScreenState extends State<CustomListDetailScreen> {
  late final CustomListPresenter presenter;

  List<CustomListItem> items = [];

  bool isLoading = true;

  Set<String> removingItems = {};

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.customListPresenter;

    loadItems();
  }

  Future<void> loadItems() async {
    try {
      List<CustomListItem> result = await presenter.getItems(
        widget.arguments.listId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        items = result;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

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
    }
  }

  String getItemKey(
    CustomListItem item,
  ) {
    return '${item.mediaType}_${item.mediaId}';
  }

  Future<void> removeItem(
    CustomListItem item,
  ) async {
    String key = getItemKey(
      item,
    );

    if (removingItems.contains(key)) {
      return;
    }

    setState(() {
      removingItems.add(key);
    });

    try {
      await presenter.removeItem(
        listId: widget.arguments.listId,
        mediaId: item.mediaId,
        mediaType: item.mediaType,
      );

      await loadItems();
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
          removingItems.remove(key);
        });
      }
    }
  }

  Future<void> confirmRemove(
    CustomListItem item,
  ) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (
        BuildContext dialogContext,
      ) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              22,
            ),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
              ),
              SizedBox(
                width: 9,
              ),
              Text(
                'حذف از لیست',
              ),
            ],
          ),
          content: Text(
            '«${item.title}» از این لیست حذف شود؟',
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(
                  false,
                );
              },
              child: const Text(
                'انصراف',
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(
                  true,
                );
              },
              child: const Text(
                'حذف',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await removeItem(
        item,
      );
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
              buildHeader(),
              Expanded(
                child: buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        14,
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
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
          const SizedBox(
            width: 11,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.arguments.listName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  '${items.length} اثر در این لیست',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(
                0.11,
              ),
              borderRadius: BorderRadius.circular(
                14,
              ),
            ),
            child: const Icon(
              Icons.playlist_play_rounded,
              color: AppColors.primaryLight,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
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
              height: 13,
            ),
            Text(
              'در حال دریافت لیست...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: loadItems,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          2,
          16,
          30,
        ),
        itemCount: items.length,
        separatorBuilder: (
          context,
          index,
        ) {
          return const SizedBox(
            height: 12,
          );
        },
        itemBuilder: (
          context,
          index,
        ) {
          return buildItem(
            items[index],
          );
        },
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(
          28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(
                  0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.playlist_remove_rounded,
                size: 45,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(
              height: 19,
            ),
            const Text(
              'این لیست هنوز خالی است',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 7,
            ),
            const Text(
              'از صفحه فیلم یا سریال می‌توانی آثار موردعلاقه‌ات را به این لیست اضافه کنی.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.65,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(
    CustomListItem item,
  ) {
    String key = getItemKey(
      item,
    );

    bool removing = removingItems.contains(
      key,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(
          20,
        ),
        onTap: removing
            ? null
            : () {
                Navigator.pushNamed(
                  context,
                  item.isMovie ? AppRoutes.movieDetail : AppRoutes.seriesDetail,
                  arguments: item.mediaId,
                );
              },
        child: Container(
          height: 132,
          clipBehavior: Clip.antiAlias,
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
              buildPoster(
                item,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    13,
                    13,
                    12,
                    13,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.ltr,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          buildTypeBadge(
                            item,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 9,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: AppColors.textMuted,
                            size: 14,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            item.releaseYear.isEmpty
                                ? 'سال نامشخص'
                                : item.releaseYear,
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.open_in_new_rounded,
                            color: AppColors.primaryLight,
                            size: 15,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Text(
                            'مشاهده جزئیات',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          if (removing)
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          else
                            IconButton(
                              tooltip: 'حذف از لیست',
                              onPressed: () {
                                confirmRemove(
                                  item,
                                );
                              },
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.error,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPoster(
    CustomListItem item,
  ) {
    return SizedBox(
      width: 88,
      height: double.infinity,
      child: item.posterUrl.isEmpty
          ? ColoredBox(
              color: AppColors.surfaceLight,
              child: Center(
                child: Icon(
                  item.isMovie ? Icons.movie_rounded : Icons.tv_rounded,
                  color: AppColors.textMuted,
                  size: 35,
                ),
              ),
            )
          : CachedNetworkImage(
              imageUrl: item.posterUrl,
              fit: BoxFit.cover,
              placeholder: (
                context,
                url,
              ) {
                return const ColoredBox(
                  color: AppColors.surfaceLight,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorWidget: (
                context,
                url,
                error,
              ) {
                return ColoredBox(
                  color: AppColors.surfaceLight,
                  child: Center(
                    child: Icon(
                      item.isMovie ? Icons.movie_rounded : Icons.tv_rounded,
                      color: AppColors.textMuted,
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget buildTypeBadge(
    CustomListItem item,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(
          0.11,
        ),
        borderRadius: BorderRadius.circular(
          8,
        ),
      ),
      child: Text(
        item.mediaTypeTitle,
        style: const TextStyle(
          color: AppColors.primaryLight,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
