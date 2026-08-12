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

  @override
  void initState() {
    super.initState();

    presenter = ServiceLocator.customListPresenter;

    loadItems();
  }

  Future<void> loadItems() async {
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
  }

  Future<void> removeItem(
    CustomListItem item,
  ) async {
    await presenter.removeItem(
      listId: widget.arguments.listId,
      mediaId: item.mediaId,
      mediaType: item.mediaType,
    );

    await loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.arguments.listName,
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : items.isEmpty
                ? const Center(
                    child: Text(
                      'این فهرست خالی است.',
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(
                      16,
                    ),
                    itemCount: items.length,
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
                      return buildItem(
                        items[index],
                      );
                    },
                  ),
      ),
    );
  }

  Widget buildItem(
    CustomListItem item,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            item.isMovie ? AppRoutes.movieDetail : AppRoutes.seriesDetail,
            arguments: item.mediaId,
          );
        },
        child: SizedBox(
          height: 125,
          child: Row(
            children: [
              SizedBox(
                width: 85,
                height: double.infinity,
                child: item.posterUrl.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.movie_rounded,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: item.posterUrl,
                        fit: BoxFit.cover,
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      Text(
                        item.mediaTypeTitle,
                        style: const TextStyle(
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            item.releaseYear,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              removeItem(
                                item,
                              );
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
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
}
