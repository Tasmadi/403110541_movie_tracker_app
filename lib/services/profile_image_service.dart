import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ProfileImageService {
  final ImagePicker imagePicker = ImagePicker();

  Future<String?> pickProfileImage() async {
    XFile? pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (pickedImage == null) {
      return null;
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    Directory profileDirectory = Directory(
      join(
        documentsDirectory.path,
        'profile_images',
      ),
    );

    if (!await profileDirectory.exists()) {
      await profileDirectory.create(
        recursive: true,
      );
    }

    String imageExtension = extension(pickedImage.path);

    if (imageExtension.isEmpty) {
      imageExtension = '.jpg';
    }

    String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}'
        '$imageExtension';

    String destinationPath = join(
      profileDirectory.path,
      fileName,
    );

    File copiedImage = await File(
      pickedImage.path,
    ).copy(
      destinationPath,
    );

    return copiedImage.path;
  }

  Future<void> removeProfileImage(
    String? imagePath,
  ) async {
    if (imagePath == null || imagePath.isEmpty) {
      return;
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String profileDirectoryPath = join(
      documentsDirectory.path,
      'profile_images',
    );

    if (!isWithin(
      profileDirectoryPath,
      imagePath,
    )) {
      return;
    }

    File file = File(
      imagePath,
    );

    if (await file.exists()) {
      await file.delete();
    }
  }
}
