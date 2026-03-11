import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Saves exported files to public device storage so they appear in File Manager.
///
/// Target folder (Android):
///   Internal Storage/Documents/Certificate_Inspection/
class FileStorageService {
  static const String _certificateFolderName = 'Certificate_Inspection';
  static const MethodChannel _channel =
      MethodChannel('com.cenro.cenroapp/file_storage');

  static String sanitizeFileName(String fileName) {
    // Avoid invalid filename characters on Android/Linux filesystems
    return fileName
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static Future<void> _ensureStoragePermission() async {
    if (!Platform.isAndroid) return;

    // For Android 9 and below, we still need the legacy storage permission
    // to write to public directories. On Android 10+, we save via MediaStore.
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      // On Android 10+ this may be denied/not applicable; saving can still work via MediaStore.
      // We only hard-fail if the platform call fails.
      return;
    }
  }

  static Future<String> _saveBytesToCertificateFolder({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) async {
    final safeName = sanitizeFileName(filename);

    await _ensureStoragePermission();

    final uri = await _channel.invokeMethod<String>(
      'saveToDocuments',
      <String, dynamic>{
        'folderName': _certificateFolderName,
        'filename': safeName,
        'mimeType': mimeType,
        'bytes': bytes,
      },
    );

    if (uri == null || uri.isEmpty) {
      throw Exception('Failed to save file to Documents.');
    }
    return uri;
  }

  static Future<String> savePdfFile({
    required Uint8List bytes,
    required String filename,
  }) =>
      _saveBytesToCertificateFolder(
        bytes: bytes,
        filename: filename,
        mimeType: 'application/pdf',
      );

  static Future<String> saveExcelFile({
    required Uint8List bytes,
    required String filename,
  }) =>
      _saveBytesToCertificateFolder(
        bytes: bytes,
        filename: filename,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );

  static Future<String> saveWordFile({
    required Uint8List bytes,
    required String filename,
  }) =>
      _saveBytesToCertificateFolder(
        bytes: bytes,
        filename: filename,
        mimeType:
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      );

  /// Human-readable folder path for dialogs.
  static String get publicFolderDisplayPath =>
      'Documents/$_certificateFolderName';

  /// Attempts to open the Certificate_Inspection folder in a file manager.
  static Future<void> openCertificateFolder() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>('openCertificateFolder');
  }
}
