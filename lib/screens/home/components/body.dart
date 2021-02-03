import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_upload_app/constants.dart';
import 'package:image_upload_app/services/firebase_storage_services.dart';
import 'package:image_upload_app/services/local_file_manager.dart';
import 'package:image_upload_app/services/sftp_services.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:image_upload_app/utilities.dart' as utils;
import 'package:flutter_svg/flutter_svg.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  /// Local Path of Image selected to upload
  PickedFile imageFilePicked;

  @override
  void initState() {
    super.initState();
    imageFilePicked = null;
  }

  @override
  Widget build(BuildContext context) {
    /// MediaQueryData for [context]
    final mediaqueryData = MediaQuery.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                constraints: BoxConstraints(
                  minWidth: mediaqueryData.size.shortestSide * 0.75,
                  minHeight: mediaqueryData.size.longestSide * 0.24,
                  maxWidth: mediaqueryData.size.shortestSide * 0.85,
                  maxHeight: mediaqueryData.size.longestSide * 0.32,
                ),
                margin: const EdgeInsets.all(8),
                child: imageFilePicked == null // image is not selected
                    // show Button to select image
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Select Image Button
                          IconButton(
                            icon: const Icon(Icons.add_a_photo),
                            onPressed: _selectImageButtonCallback,
                            iconSize: 50,
                            color: Colors.black54,
                          ),
                          Text(
                            "Select image to upload",
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ],
                      )
                    // show Image selected
                    : FutureBuilder<Uint8List>(
                        future: imageFilePicked.readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Icon(
                              Icons.error,
                              size: 50,
                              color: Colors.black54,
                            );
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          return Column(
                            children: [
                              Expanded(
                                child: Image.memory(
                                  snapshot.data,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Divider(),
                              Text(
                                "Image size: " +
                                    // lengthSync gives length of file in bytes, converting it into kB
                                    ((snapshot.data.buffer.lengthInBytes /
                                                (1024))
                                            .toString() +
                                        " kB"),
                              ),
                            ],
                          );
                        },
                      ),
              ),
              if (imageFilePicked != null) // if image is selected
                // show Upload and Cancel Button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Upload Button
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        iconSize: 50,
                        onPressed: _uploadImageButtonCallback,
                      ),
                      // Cancel Button
                      IconButton(
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                        iconSize: 50,
                        onPressed: _removeImageCallback,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Upload Image Button callback
  ///
  /// * Prompts user to select Upload Target and Uploads image to target specified
  Future<void> _uploadImageButtonCallback() async {
    try {
      // Get upload destination from user
      final UploadDestination uploadDestination =
          await _showUploadDestinationPicker(context);
      // Flag to maintain Uplad Status
      bool uploadResult = false;
      // if FTP Server is selected as Upload Destination
      if (uploadDestination == UploadDestination.FTPServer) {
        uploadResult = await _uploadImageToSFTP();
      }
      // if Firebase Server is selected as Upload Destination
      else if (uploadDestination == UploadDestination.FirebaseStorage) {
        uploadResult = await _uploadImageToFirebase();
      }
      // If upload is successfull
      if (uploadResult) {
        utils.showSnackbar(context, const Text("Image uploaded successfully"));
      }
    }
    // Handle Possible types of Exceptions
    on FirebaseException catch (e) {
      // can be caused by Firebase Storage Operation
      debugPrint(e.toString());
      utils.showSnackbar(context, Text(e.message));
    } on PlatformException catch (e) {
      // can be caused by SSH Client
      debugPrint(e.toString());
      utils.showSnackbar(context, Text(e.message));
    } on Exception catch (e) {
      // Handle General Exceptions (mainly User Defined)
      debugPrint(e.toString());
      utils.showSnackbar(context, Text(e.toString()));
    } catch (e) {
      // Handle any exception not caught above
      debugPrint(e.toString());
      utils.showSnackbar(
          context, const Text("Unknown error occured while upload image"));
    }
    return Future<void>.value();
  }

  /// Function to Upload Image to Firebase
  Future<bool> _uploadImageToFirebase() async {
    // To store Download URL of Image
    String downloadUrl;

    final imageUploadFuture = FirebaseStorageServices()
        .uploadFileToPath(
          File(imageFilePicked.path),
          UPLOAD_DIRECTORY,
          // extracting Filename
          imageFilePicked.path.split("/").last,
        )
        .then((value) => downloadUrl = value);

    // showing Progress Dialog untill Future complete
    await showDialog(
      context: context,
      builder: (context) {
        return FutureProgressDialog(
          imageUploadFuture,
          message: const Text("Uploading image, please wait..."),
        );
      },
    );

    // downloadUrl will be null if image not uploaded
    return downloadUrl != null;
  }

  /// Function to upload image to SFTP Server
  Future<bool> _uploadImageToSFTP() async {
    // Flag for Upload Status
    bool result = false;
    final imageUploadFuture = SFTPService()
        .uploadFileToSFTPServer(
          UPLOAD_DIRECTORY,
          imageFilePicked.path,
        )
        .then((value) => result = value);
    // show Progress Dialog untill Future completes
    await showDialog(
      context: context,
      builder: (context) {
        return FutureProgressDialog(
          imageUploadFuture,
          message: const Text("Uploading image, please wait..."),
        );
      },
    );
    return result;
  }

  /// Callback Function for Select Image Button
  Future<void> _selectImageButtonCallback() async {
    try {
      // Prompt user to chose image source
      final imageSource = await _showImageSourcePicker(context);
      // Prompt user to select image from given source
      final imgPath = await LocalFileManager().choseImageFromLocalFiles(
        imageSource,
        maxHeight: MAX_IMAGE_DIM,
        maxWidth: MAX_IMAGE_DIM,
      );
      setState(() {
        imageFilePicked = imgPath;
      });
    }
    // Handle Exceptions
    on Exception catch (e) {
      debugPrint(e.toString());
      utils.showSnackbar(context, Text(e.toString()));
    } catch (e) {
      debugPrint("Unknown error occured: $e");
      utils.showSnackbar(context, const Text("Unknown error occured"));
    }
    return Future<void>.value();
  }

  /// Callback Function to remove selected image
  void _removeImageCallback() {
    setState(() {
      imageFilePicked = null;
    });
  }

  /// Function to prompt user to select Upload Destination within [context]
  Future<UploadDestination> _showUploadDestinationPicker(
      BuildContext context) async {
    final UploadDestination uploadDestination = await showModalBottomSheet(
      context: context,
      builder: (BuildContext _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              children: <Widget>[
                Center(
                  child: Text(
                    "Chose upload destination",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                ListTile(
                    leading: SvgPicture.asset("assets/icons/ftp-icon.svg"),
                    title: const Text('FTP Server'),
                    onTap: () {
                      Navigator.of(context).pop(UploadDestination.FTPServer);
                    }),
                ListTile(
                  leading: SvgPicture.asset("assets/icons/firebase-icon.svg"),
                  title: const Text('Firebase Storage'),
                  onTap: () {
                    Navigator.of(context)
                        .pop(UploadDestination.FirebaseStorage);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    // if no upload destination is selected
    if (uploadDestination == null) {
      throw Exception("Upload Destination not selected");
    }
    return uploadDestination;
  }

  /// Function to prompt user to chose Image Source within [context]
  Future<ImageSource> _showImageSourcePicker(BuildContext context) async {
    final ImageSource imageSource = await showModalBottomSheet(
      context: context,
      builder: (BuildContext _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              children: <Widget>[
                Center(
                  child: Text(
                    "Chose file location",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () {
                      Navigator.of(context).pop(ImageSource.gallery);
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    // if no image source is selected
    if (imageSource == null) {
      throw Exception("Image source not selected");
    }
    return imageSource;
  }
}
