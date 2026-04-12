import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ngo_connect/services/firebase_service.dart';

/// Allowed MIME types for document uploads.
const _allowedMimeTypes = {'application/pdf', 'text/csv'};

/// Allowed file extensions for document uploads.
const _allowedExtensions = {'.pdf', '.csv'};

/// Maximum allowed file size in bytes (10 MB).
const int kMaxFileSizeBytes = 10 * 1024 * 1024;

/// Result of a file validation check.
class FileValidationResult {
  final bool isValid;
  final String? error;

  const FileValidationResult.ok() : isValid = true, error = null;
  const FileValidationResult.rejected(this.error) : isValid = false;
}

/// Validates a file's type by checking its extension and/or MIME type.
/// Returns a [FileValidationResult] without making any network calls.
FileValidationResult validateFileType(String filename, {String? mimeType}) {
  final lower = filename.toLowerCase();
  final hasValidExtension =
      _allowedExtensions.any((ext) => lower.endsWith(ext));
  final hasValidMime =
      mimeType != null && _allowedMimeTypes.contains(mimeType.toLowerCase());

  if (!hasValidExtension && !hasValidMime) {
    return const FileValidationResult.rejected(
      'Only PDF and CSV files are accepted.',
    );
  }
  return const FileValidationResult.ok();
}

/// Validates a file's size against the 10 MB limit.
/// Returns a [FileValidationResult] without making any network calls.
FileValidationResult validateFileSize(int sizeBytes) {
  if (sizeBytes > kMaxFileSizeBytes) {
    return const FileValidationResult.rejected(
      'File exceeds the 10 MB size limit.',
    );
  }
  return const FileValidationResult.ok();
}

class StorageService {
  static final _storage = FirebaseStorage.instance;

  /// Uploads [bytes] to Firebase Storage at [path] with the given [contentType].
  /// Returns the public download URL.
  static Future<String> uploadFile(
      String path, Uint8List bytes, String contentType) async {
    final ref = _storage.ref(path);
    final metadata = SettableMetadata(contentType: contentType);
    await ref.putData(bytes, metadata);
    return ref.getDownloadURL();
  }

  /// Deletes the file at [path] from Firebase Storage.
  static Future<void> deleteFile(String path) async {
    await _storage.ref(path).delete();
  }

  /// Full upload pipeline:
  /// 1. Validates file type (extension + optional MIME).
  /// 2. Validates file size (≤ 10 MB).
  /// 3. Uploads to `documents/{ngoId}/{filename}`.
  /// 4. Writes metadata to the `ngo_documents` Firestore collection.
  ///
  /// Returns the Firestore document id of the saved metadata on success.
  /// Throws a [StorageUploadException] if validation fails.
  static Future<String> uploadDocument({
    required String ngoId,
    required String filename,
    required Uint8List bytes,
    String? mimeType,
  }) async {
    // 1. Type validation — client-side, no network call.
    final typeResult = validateFileType(filename, mimeType: mimeType);
    if (!typeResult.isValid) {
      throw StorageUploadException(typeResult.error!);
    }

    // 2. Size validation — client-side, no network call.
    final sizeResult = validateFileSize(bytes.length);
    if (!sizeResult.isValid) {
      throw StorageUploadException(sizeResult.error!);
    }

    // 3. Determine content type.
    final lower = filename.toLowerCase();
    final contentType = lower.endsWith('.pdf') ? 'application/pdf' : 'text/csv';

    // 4. Upload to Firebase Storage.
    final storagePath = 'documents/$ngoId/$filename';
    final downloadUrl =
        await uploadFile(storagePath, bytes, contentType);

    // 5. Write metadata to Firestore.
    final docId = await FirebaseService.saveDocumentMetadata({
      'ngoId': ngoId,
      'filename': filename,
      'contentType': contentType,
      'downloadUrl': downloadUrl,
      'storagePath': storagePath,
      'sizeBytes': bytes.length,
    });

    return docId;
  }
}

/// Thrown when a file fails client-side validation before upload.
class StorageUploadException implements Exception {
  final String message;
  const StorageUploadException(this.message);

  @override
  String toString() => 'StorageUploadException: $message';
}
