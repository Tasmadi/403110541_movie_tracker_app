import 'package:flutter/material.dart';

import '../../models/custom_list.dart';
import '../../models/custom_list_detail_arguments.dart';
import '../../presenters/custom_list_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/main_bottom_navigation.dart';

class CustomListsScreen extends StatefulWidget {
  const CustomListsScreen({
    super.key,
  });

  @override
  State<CustomListsScreen> createState() {
    return _CustomListsScreenState();
  }
}

class _CustomListsScreenState extends State<CustomListsScreen> {
  late final CustomListPresenter presenter;

  List<CustomList> lists = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.customListPresenter;

    loadLists();
  }

  Future<void> loadLists() async {
    if (presenter.isGuest()) {
      setState(() {
        isLoading = false;
      });

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      List<CustomList> result = await presenter.getLists();

      if (!mounted) {
        return;
      }

      setState(() {
        lists = result;
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

  Future<void> createList() async {
    String? name = await showDialog<String>(
      context: context,
      builder: (
        dialogContext,
      ) {
        String enteredName = '';

        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.playlist_add_rounded,
                color: AppColors.primaryLight,
              ),
              SizedBox(
                width: 8,
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
              hintText: 'مثلاً My Favorite Movies',
              prefixIcon: Icon(
                Icons.edit_outlined,
              ),
            ),
            onChanged: (value) {
              enteredName = value;
            },
            onFieldSubmitted: (
              value,
            ) {
              String normalizedName = value.trim();

              if (normalizedName.isEmpty) {
                return;
              }

              Navigator.of(
                dialogContext,
              ).pop(
                normalizedName,
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
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

                Navigator.of(
                  dialogContext,
                ).pop(
                  normalizedName,
                );
              },
              icon: const Icon(
                Icons.add_rounded,
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
      await presenter.createList(
        name.trim(),
      );

      if (!mounted) {
        return;
      }

      await loadLists();
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

  Future<void> deleteList(
    CustomList list,
  ) async {
    await presenter.deleteList(
      list.id,
    );

    await loadLists();
  }

  void onNavigationSelected(
    int index,
  ) {
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) {
            return false;
          },
        );
        return;

      case 1:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.search,
        );
        return;

      case 2:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.watchlist,
        );
        return;

      case 3:
        return;

      case 4:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.profile,
        );
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
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
      bottomNavigationBar: MainBottomNavigation(
        currentIndex: 3,
        onSelected: onNavigationSelected,
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        12,
      ),
      child: Row(
        children: [
          const AppLogo(
            size: 42,
            showTitle: false,
            showTagline: false,
          ),
          const SizedBox(
            width: 10,
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لیست‌های من',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  'مجموعه‌های شخصی فیلم و سریال',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (!presenter.isGuest())
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  14,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(
                      0.22,
                    ),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: IconButton(
                tooltip: 'فهرست جدید',
                onPressed: createList,
                icon: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildBody() {
    if (presenter.isGuest()) {
      return buildGuestView();
    }

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
              height: 14,
            ),
            Text(
              'در حال دریافت لیست‌ها...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    if (lists.isEmpty) {
      return buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: loadLists,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          5,
          16,
          120,
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
          return buildListCard(
            lists[index],
            index,
          );
        },
      ),
    );
  }

  Widget buildGuestView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          28,
          20,
          28,
          120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(
                  0.10,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(
                    0.22,
                  ),
                ),
              ),
              child: const Icon(
                Icons.playlist_play_rounded,
                color: AppColors.primaryLight,
                size: 52,
              ),
            ),
            const SizedBox(
              height: 22,
            ),
            const Text(
              'لیست‌های شخصی خودت',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 9,
            ),
            const Text(
              'با ورود به حساب می‌توانی مجموعه‌های دلخواه بسازی و فیلم‌ها و سریال‌ها را داخل آن‌ها دسته‌بندی کنی.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.7,
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.login,
                  );
                },
                icon: const Icon(
                  Icons.login_rounded,
                ),
                label: const Text(
                  'ورود به حساب',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          28,
          20,
          28,
          120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: const Icon(
                Icons.playlist_add_rounded,
                color: AppColors.primaryLight,
                size: 46,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'هنوز لیستی نساخته‌ای',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              'لیست‌های شخصی برای دسته‌بندی فیلم‌ها و سریال‌های موردعلاقه‌ات بساز.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.6,
              ),
            ),
            const SizedBox(
              height: 22,
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

  Widget buildListCard(
    CustomList list,
    int index,
  ) {
    IconData icon;

    switch (index % 4) {
      case 0:
        icon = Icons.movie_filter_rounded;
        break;

      case 1:
        icon = Icons.favorite_rounded;
        break;

      case 2:
        icon = Icons.auto_awesome_rounded;
        break;

      default:
        icon = Icons.tv_rounded;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(
          20,
        ),
        onTap: () async {
          await Navigator.pushNamed(
            context,
            AppRoutes.customListDetail,
            arguments: CustomListDetailArguments(
              listId: list.id,
              listName: list.name,
            ),
          );

          if (!mounted) {
            return;
          }

          await loadLists();
        },
        child: Container(
          padding: const EdgeInsets.all(
            14,
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(
                        0.85,
                      ),
                      AppColors.primaryLight.withOpacity(
                        0.55,
                      ),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(
                width: 13,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.video_collection_outlined,
                          color: AppColors.textMuted,
                          size: 14,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          '${list.itemCount} اثر',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'حذف فهرست',
                onPressed: () {
                  deleteList(
                    list,
                  );
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 21,
                ),
              ),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 12,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
