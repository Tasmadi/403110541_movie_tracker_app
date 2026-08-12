import '../models/custom_list.dart';
import '../models/custom_list_item.dart';
import '../models/custom_list_media_arguments.dart';
import '../repositories/custom_list_repository.dart';

class CustomListPresenter {
  CustomListRepository repository;

  CustomListPresenter({
    required this.repository,
  });

  bool isGuest() {
    return repository.isGuest();
  }

  Future<List<CustomList>> getLists() {
    return repository.getLists();
  }

  Future<CustomList> createList(
    String name,
  ) {
    return repository.createList(name);
  }

  Future<void> deleteList(
    int listId,
  ) {
    return repository.deleteList(listId);
  }

  Future<Set<int>> getListsContainingMedia({
    required int mediaId,
    required String mediaType,
  }) {
    return repository.getListsContainingMedia(
      mediaId: mediaId,
      mediaType: mediaType,
    );
  }

  Future<void> toggleMedia({
    required int listId,
    required CustomListMediaArguments media,
  }) {
    return repository.toggleMedia(
      listId: listId,
      media: media,
    );
  }

  Future<List<CustomListItem>> getItems(
    int listId,
  ) {
    return repository.getItems(listId);
  }

  Future<void> removeItem({
    required int listId,
    required int mediaId,
    required String mediaType,
  }) {
    return repository.removeItem(
      listId: listId,
      mediaId: mediaId,
      mediaType: mediaType,
    );
  }
}
