import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

class ImageService {
  static Future<File?> pickAndProcessImage({
    required File imageFile,
    bool crop = true,
    bool compress = true,
  }) async {
    File? processedImage = imageFile;

    // Crop image
    if (crop) {
      processedImage = await cropImage(processedImage);
      if (processedImage == null) return null;
    }

    // Compress image
    if (compress) {
      processedImage = await compressImage(processedImage);
    }

    return processedImage;
  }

  static Future<File?> cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio16x9,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
          aspectRatioPickerButtonHidden: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    if (croppedFile == null) return null;
    return File(croppedFile.path);
  }

  static Future<File> compressImage(File file) async {
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath = path.join(dir.path, '${DateTime.now().toIso8601String()}.jpg');

    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 70,
      format: CompressFormat.jpeg,
    );

    if (result == null) {
      throw Exception('Failed to compress image');
    }

    return File(result.path);
  }
} 