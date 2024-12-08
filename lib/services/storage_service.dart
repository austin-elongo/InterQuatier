import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

typedef ProgressCallback = void Function(double progress);

class StorageService {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadEventImage(
    String eventId,
    File imageFile, {
    ProgressCallback? onProgress,
  }) async {
    final ext = path.extension(imageFile.path);
    final ref = _storage.ref().child('events/$eventId$ext');
    
    final uploadTask = ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/$ext'),
    );

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      onProgress?.call(progress);
    });

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<List<String>> uploadEventImages(
    String eventId,
    List<File> imageFiles, {
    ProgressCallback? onProgress,
  }) async {
    final urls = <String>[];
    final totalBytes = await _calculateTotalBytes(imageFiles);
    var uploadedBytes = 0;
    
    for (var i = 0; i < imageFiles.length; i++) {
      final file = imageFiles[i];
      final ext = path.extension(file.path);
      final ref = _storage.ref().child('events/$eventId/image_$i$ext');
      
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/$ext'),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final currentUploadedBytes = uploadedBytes + snapshot.bytesTransferred;
        final progress = currentUploadedBytes / totalBytes;
        onProgress?.call(progress);
      });

      final snapshot = await uploadTask;
      uploadedBytes += await file.length();
      final url = await snapshot.ref.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }

  Future<int> _calculateTotalBytes(List<File> files) async {
    var total = 0;
    for (final file in files) {
      total += await file.length();
    }
    return total;
  }

  Future<void> deleteEventImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      try {
        final ref = _storage.refFromURL(url);
        await ref.delete();
      } catch (e) {
        // Handle or ignore error if image doesn't exist
      }
    }
  }
} 