import 'package:flutter/material.dart';

import '../../models/custom_list.dart';
import '../../models/custom_list_media_arguments.dart';
import '../../presenters/custom_list_presenter.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';

class CustomListPickerScreen extends StatefulWidget {
  final CustomListMediaArguments media;

  const CustomListPickerScreen({
    super.key,
    required this.media,
  });

  @override
  State<CustomListPickerScreen> createState() {
    return _CustomListPickerScreenState();
  }
}

class _CustomListPickerScreenState extends State<CustomListPickerScreen> {
  late final CustomListPresenter presenter;

  List<CustomList> lists = [];

  Set<int> selectedLists = {};

  bool isLoading = true;

  Set<int> savingLists = {};

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.customListPresenter;

    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<CustomList> result = await presenter.getLists();

      Set<int> selected = await presenter.getListsContainingMedia(
        mediaId: widget.media.mediaId,
        mediaType: widget.media.mediaType,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        lists = result;
        selectedLists = selected;
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

  Future<void> toggle(
    CustomList list,
  ) async {
    if (savingLists.contains(list.id)) {
      return;
    }

    setState(() {
      savingLists.add(list.id);
    });

    try {
      await presenter.toggleMedia(
        listId: list.id,
        media: widget.media,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (selectedLists.contains(list.id)) {
          selectedLists.remove(list.id);
        } else {
          selectedLists.add(list.id);
        }
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
          savingLists.remove(list.id);
        });
      }
    }
  }

  Future<void> createList() async {
    String? name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        String enteredName = '';

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
                Icons.playlist_add_rounded,
                color: AppColors.primaryLight,
              ),
              SizedBox(
                width: 9,
              ),
              Text(
                'فهرست جدید',
              ),
            ],
          ),
          content: TextFormField(
            autofocus: true,
            maxLength: 60,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              labelText: 'نام فهرست',
              hintText: 'مثلاً My Fav Movies',
              prefixIcon: Icon(
                Icons.edit_rounded,
              ),
            ),
            onChanged: (value) {
              enteredName = value;
            },
            onFieldSubmitted: (value) {
              String normalizedName = value.trim();

              if (normalizedName.isEmpty) {
                return;
              }

              Navigator.of(dialogContext).pop(
                normalizedName,
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'انصراف',
              ),
            ),
            FilledButton.icon(
              onPressed: () {
                String normalizedName = enteredName.trim();

                if (normalizedName.isEmpty) {
                  return;
                }

                Navigator.of(dialogContext).pop(
                  normalizedName,
                );
              },
              icon: const Icon(
                Icons.add_rounded,
                size: 18,
              ),
              label: const Text(
                'ایجاد',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || name == null || name.trim().isEmpty) {
      return;
    }

    try {
      CustomList newList = await presenter.createList(
        name.trim(),
      );

      await presenter.toggleMedia(
        listId: newList.id,
        media: widget.media,
      );

      if (!mounted) {
        return;
      }

      await loadData();
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
              buildMediaSummary(),
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
        10,
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'افزودن به لیست',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  'لیست‌های شخصی خود را انتخاب کن',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 43,
            child: FilledButton.icon(
              onPressed: createList,
              icon: const Icon(
                Icons.add_rounded,
                size: 18,
              ),
              label: const Text(
                'جدید',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMediaSummary() {
    String typeTitle = widget.media.mediaType == 'movie' ? 'فیلم' : 'سریال';

    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        18,
      ),
      padding: const EdgeInsets.all(
        14,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary.withOpacity(
              0.17,
            ),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color: AppColors.primary.withOpacity(
            0.20,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(
                0.13,
              ),
              borderRadius: BorderRadius.circular(
                14,
              ),
            ),
            child: Icon(
              widget.media.mediaType == 'movie'
                  ? Icons.movie_rounded
                  : Icons.tv_rounded,
              color: AppColors.primaryLight,
              size: 24,
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
                  widget.media.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Text(
                      typeTitle,
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (widget.media.releaseYear.isNotEmpty) ...[
                      const SizedBox(
                        width: 7,
                      ),
                      const Text(
                        '•',
                        style: TextStyle(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      Text(
                        widget.media.releaseYear,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
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
            ),
            child: Text(
              '${selectedLists.length} انتخاب',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
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
              'در حال دریافت لیست‌ها...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    if (lists.isEmpty) {
      return buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: loadData,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          28,
        ),
        itemCount: lists.length,
        separatorBuilder: (
          context,
          index,
        ) {
          return const SizedBox(
            height: 11,
          );
        },
        itemBuilder: (
          context,
          index,
        ) {
          CustomList list = lists[index];

          return buildListItem(
            list,
          );
        },
      ),
    );
  }

  Widget buildListItem(
    CustomList list,
  ) {
    bool selected = selectedLists.contains(
      list.id,
    );

    bool saving = savingLists.contains(
      list.id,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: saving
            ? null
            : () {
                toggle(
                  list,
                );
              },
        borderRadius: BorderRadius.circular(
          19,
        ),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 180,
          ),
          padding: const EdgeInsets.all(
            14,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(
                    0.10,
                  )
                : AppColors.surface,
            borderRadius: BorderRadius.circular(
              19,
            ),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withOpacity(
                      0.45,
                    )
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withOpacity(
                          0.17,
                        )
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  selected
                      ? Icons.playlist_add_check_rounded
                      : Icons.playlist_play_rounded,
                  color:
                      selected ? AppColors.primaryLight : AppColors.textMuted,
                  size: 24,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      '${list.itemCount} اثر',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              if (saving)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              else
                AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 180,
                  ),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color:
                        selected ? AppColors.primary : AppColors.surfaceLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Icon(
                    selected ? Icons.check_rounded : Icons.add_rounded,
                    color: selected ? Colors.white : AppColors.textMuted,
                    size: 17,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          28,
          20,
          28,
          40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(
                  0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.playlist_add_rounded,
                color: AppColors.primaryLight,
                size: 43,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            const Text(
              'هنوز لیستی نداری',
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
              'یک لیست شخصی بساز و این اثر را به آن اضافه کن.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.6,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            FilledButton.icon(
              onPressed: createList,
              icon: const Icon(
                Icons.add_rounded,
              ),
              label: const Text(
                'ساخت اولین لیست',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
