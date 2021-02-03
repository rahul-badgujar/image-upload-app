// STRING CONSTANTS

/// Name of the app
const String appName = "Image Upload App";

/// upload directory for images
const String UPLOAD_DIRECTORY = "photos";

/// Enum denoting Image Upload Destination
enum UploadDestination {
  /// Upload Image to FTP Server
  FTPServer,
  // Upload Image to Firebase Storage
  FirebaseStorage,
}

// num constants
double MAX_IMAGE_DIM = 1024;
