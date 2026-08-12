import 'package:flutter/material.dart';

import '../../models/custom_list.dart';
import '../../models/custom_list_detail_arguments.dart';
import '../../presenters/custom_list_presenter.dart';
import '../../routes/app_routes.dart';
import '../../services/service_locator.dart';
import '../../utils/app_colors.dart';

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

    List<CustomList> result = await presenter.getLists();

    if (!mounted) {
      return;
    }

    setState(() {
      lists = result;
      isLoading = false;
    });
  }

  Future<void> createList() async {
    String? name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        String enteredName = '';

        return AlertDialog(
          title: const Text(
            'فهرست جدید',
          ),
          content: TextFormField(
            autofocus: true,
            maxLength: 60,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              labelText: 'نام فهرست',
              hintText: 'مثلاً My Fav Movies',
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
            FilledButton(
              onPressed: () {
                String normalizedName = enteredName.trim();

                if (normalizedName.isEmpty) {
                  return;
                }

                Navigator.of(dialogContext).pop(
                  normalizedName,
                );
              },
              child: const Text(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'فهرست‌های شخصی',
        ),
      ),
      floatingActionButton: presenter.isGuest()
          ? null
          : FloatingActionButton(
              onPressed: createList,
              child: const Icon(
                Icons.add_rounded,
              ),
            ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    if (presenter.isGuest()) {
      return const Center(
        child: Text(
          'برای ایجاد فهرست شخصی وارد حساب شوید.',
        ),
      );
    }

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (lists.isEmpty) {
      return const Center(
        child: Text(
          'هنوز فهرستی ایجاد نکرده‌اید.',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: lists.length,
      separatorBuilder: (
        context,
        index,
      ) {
        return const SizedBox(
          height: 10,
        );
      },
      itemBuilder: (
        context,
        index,
      ) {
        CustomList list = lists[index];

        return Card(
          child: ListTile(
            onTap: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.customListDetail,
                arguments: CustomListDetailArguments(
                  listId: list.id,
                  listName: list.name,
                ),
              );

              await loadLists();
            },
            leading: const CircleAvatar(
              child: Icon(
                Icons.list_alt_rounded,
              ),
            ),
            title: Text(
              list.name,
            ),
            subtitle: Text(
              '${list.itemCount} اثر',
            ),
            trailing: IconButton(
              onPressed: () {
                deleteList(list);
              },
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
              ),
            ),
          ),
        );
      },
    );
  }
}
