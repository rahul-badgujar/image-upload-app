import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Provides Firebase Storage Utilities
class FirebaseStorageServices {
  // making the class singleton
  FirebaseStorageServices._privateConstructor();
  static final FirebaseStorageServices _instance =
      FirebaseStorageServices._privateConstructor();
  factory FirebaseStorageServices() => _instance;

  /// Upload files to Firebase Storage
  ///
  /// Parameters:
  /// * [file]: File Object to be uploaded, must not be null
  /// * [path]: Destination path of File Upload, must not be null
  /// * [filename]: Name of the file, must not be null
  ///
  /// Returns:
  /// * Download URL of uploaded File
  Future<String> uploadFileToPath(
      File file, String path, String filename) async {
    assert(file != null, "file cannot be null");
    assert(path != null, "path cannot be null");
    assert(filename != null, "filename cannot be null");

    // get reference for Default Storage Bucket
    final Reference firestorageRef = FirebaseStorage.instance.ref();
    // Upload file to given path
    final snapshot =
        await firestorageRef.child(path).child(filename).putFile(file);

    // get download url for file
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
