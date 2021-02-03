import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Provides Local File Managing Utilities
class LocalFileManager {
  // making the class singleton
  factory LocalFileManager() => _instance;
  LocalFileManager._privateConstructor();
  static final LocalFileManager _instance =
      LocalFileManager._privateConstructor();

  /// Chose Image from Local Files
  ///
  /// Parameters:
  /// * [imageSource]: Source of Image (Camera/Gallery), must not be null
  /// * [maxHeight]: maximum height of image (if found greater, image will be compressed)
  /// * [maxWidth]: maximum width of image (if found greater, image will be compressed)
  ///
  /// Returns:
  /// * Path to image picked
  Future<PickedFile> choseImageFromLocalFiles(
    ImageSource imageSource, {
    double maxHeight,
    double maxWidth,
  }) async {
    assert(imageSource != null, "imageSource cannot be null");

    // check for storage permissions
    await checkStoragePermissions();

    final imagePicker = ImagePicker();
    // pick image
    final PickedFile imagePicked = await imagePicker.getImage(
      source: imageSource,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
    );

    return imagePicked;
  }

  /// Check Storage Permissions
  Future<void> checkStoragePermissions() async {
    // Request permissions if not permissions not granted
    final PermissionStatus photoPermissionStatus =
        await Permission.photos.request();

    // Check permissions status
    if (!photoPermissionStatus.isGranted) {
      throw Exception(
          "Permission required to read storage, please give permission");
    }
  }
}
