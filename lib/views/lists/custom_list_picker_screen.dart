import 'package:flutter/material.dart';

import '../../models/custom_list.dart';
import '../../models/custom_list_media_arguments.dart';
import '../../presenters/custom_list_presenter.dart';
import '../../services/service_locator.dart';

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

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.customListPresenter;

    loadData();
  }

  Future<void> loadData() async {
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
  }

  Future<void> toggle(
    CustomList list,
  ) async {
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
      appBar: AppBar(
        title: const Text(
          'افزودن به فهرست',
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: createList,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'فهرست جدید',
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : lists.isEmpty
                ? const Center(
                    child: Text(
                      'ابتدا یک فهرست بسازید.',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(
                      16,
                    ),
                    itemCount: lists.length,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      CustomList list = lists[index];

                      bool selected = selectedLists.contains(
                        list.id,
                      );

                      return Card(
                        child: CheckboxListTile(
                          value: selected,
                          title: Text(
                            list.name,
                          ),
                          subtitle: Text(
                            '${list.itemCount} اثر',
                          ),
                          onChanged: (_) {
                            toggle(list);
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
