import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PickerUtil {
  static final ImagePicker _picker = ImagePicker();
  static final ImageCropper _cropper = ImageCropper();

  static Future<String> converToBase64(String imagePath) async {
    try {
      File imageFile = File(imagePath);
      if (imageFile.existsSync()) {
        List<int> imageBytes = await imageFile.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        return "data:image/png;base64,$base64Image";
      } else {
        return "";
      }
    } catch (e) {
      print('Error converting image to base64: $e');
      return "";
    }
  }

  static Future<String> converBytesToBase64(Uint8List imageBytes) async {
    try {
      if (imageBytes.isNotEmpty) {
        String base64Image = base64Encode(imageBytes);
        return "data:image/png;base64,$base64Image";
      } else {
        return "";
      }
    } catch (e) {
      print('Error converting image to base64: $e');
      return "";
    }
  }

  static Future<List<String>?> pickMultipleImages(
      {int? maxCount, BuildContext? context}) async {
    if (maxCount != null && context == null) {
      throw "Context is required when maxCount is present";
    }
    List<String> imagePaths = [];
    if (Platform.isAndroid) {
      await Permission.storage.request();
    } else {
      await Permission.photos.request();
    }
    List<XFile>? xfile = await _picker.pickMultiImage(
      imageQuality: 40,
    );
    if (xfile.isNotEmpty) {
      for (var file in xfile) {
        if (await File(file.path).exists()) {
          imagePaths.add(file.path);
        }
      }
    }
    if (maxCount != null) {
      if (maxCount < imagePaths.length) {
        imagePaths = imagePaths.take(maxCount).toList();
        if (!context!.mounted) {
          return null;
        }
        ToastUtils.showCustomSnackbar(
            context: context,
            contentText:
                "You can only choose a maximum of $maxCount items at a time",
            type: "info");
      }
    }
    return imagePaths;
  }

  static Future<String?> pickImage(
      {bool addCropper = true, bool compress = true}) async {
    String imagePath = '';
    if (Platform.isAndroid) {
      await Permission.storage.request();
    } else {
      await Permission.photos.request();
    }
    dynamic xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: compress ? 40 : 80,
    );
    if (xfile != null && addCropper) {
      xfile = await crop(filePath: xfile.path);
    }

    if (xfile != null) {
      if (await File(xfile.path).exists()) {
        imagePath = xfile.path;
      }
    }
    return imagePath;
  }

  static Future<String?> captureImage(
      {bool addCropper = true, bool compress = true}) async {
    String imagePath = '';

    await Permission.camera.request();

    dynamic xfile = await _picker.pickImage(
      preferredCameraDevice: CameraDevice.rear,
      source: ImageSource.camera,
      imageQuality: compress ? 40 : 80,
    );
    if (xfile != null && addCropper) {
      xfile = await crop(filePath: xfile.path);
    }
    if (xfile != null) {
      if (await File(xfile.path).exists()) {
        imagePath = xfile.path;
      }
    }
    return imagePath;
  }

  static Future<CroppedFile?> crop({required String filePath}) async {
    CroppedFile? cfile = await _cropper.cropImage(
        sourcePath: filePath,
        cropStyle: CropStyle.rectangle,
        compressQuality: 100,
        compressFormat: ImageCompressFormat.png,
        uiSettings: [IOSUiSettings(), AndroidUiSettings()]);
    return cfile;
  }

  static Future<bool> isFileSmallerThan(
      String filePath, int maxSizeInMB) async {
    try {
      File file = File(filePath);
      int fileSizeInBytes = await file.length();
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      return fileSizeInMB < maxSizeInMB;
    } catch (e) {
      print("Error checking file size: $e");
      return false;
    }
  }
}
