import 'package:flutter/foundation.dart';
import 'package:ssh/ssh.dart';

class SFTPService {
  // making class singleton
  SFTPService._privateConstructor();
  static final _instance = SFTPService._privateConstructor();
  factory SFTPService() {
    return _instance;
  }

  // server details
  /// Host of SSH Server
  static const String HOST = "william-blount.dreamhost.com";

  /// Port Number of SSH Server
  static const int PORT = 22;

  /// Username for SSH Server
  static const String USERNAME = "flutter_ftp";

  /// Password for SSH Server
  static const String PASSWORD = "67IbyHP3PVF0";

  // status codes
  /// Status Code denoting SSH Session connected successfully
  static const String SESSION_CONNECT_SUCCESS = "session_connected";

  /// Status Code denoting SFTP Session connected successfully
  static const String SFTP_CONNECT_SUCCESS = "sftp_connected";

  /// Status Code denoting file uploaded successfully to SFTP Server
  static const String UPLOAD_SUCCESS = "upload_success";

  /// SSH Client instance
  SSHClient _client;

  /// Client connection status
  bool connected = false;
  // SSH Client Instance
  SSHClient get client {
    // if client not configured, initialize it
    return _client ??= SSHClient(
      host: HOST,
      port: 22,
      username: USERNAME,
      passwordOrKey: PASSWORD,
    );
  }

  /// Ensures SSH and SFTP connections
  Future<void> _ensureConnection() async {
    if (!connected) {
      final sshConnectStatus = await client.connect();
      if (sshConnectStatus == SESSION_CONNECT_SUCCESS) {
        final sftpConnectStatus = await _client.connectSFTP();
        if (sftpConnectStatus == SFTP_CONNECT_SUCCESS) {
          connected = true;
        }
      }
    }
  }

  /// Uploads file at [filePath] to SFTP Server at [uploadPath]
  ///
  /// Parameters:
  /// * [uploadPath]: Upload Destination on SFTP Server
  /// * [filePath]: Local path to file to be uploaded
  ///
  /// Returns:
  /// * True if file uploaded successfully, else False
  Future<bool> uploadFileToSFTPServer(
      String uploadPath, String filepath) async {
    await _ensureConnection();
    final result = await client.sftpUpload(
      path: filepath,
      toPath: "$uploadPath/.",
      callback: (progress) {
        debugPrint(progress.toString());
      },
    );
    return result == UPLOAD_SUCCESS;
  }

  /// Terminate SSH and SFTP Connections
  Future<void> close() async {
    await client.disconnectSFTP();
    await client.disconnect();
  }
}
