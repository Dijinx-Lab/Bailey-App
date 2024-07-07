import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PickerUtil {
  static final ImagePicker _picker = ImagePicker();

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
        if (context!.mounted) {
          ToastUtils.showCustomSnackbar(
              context: context,
              contentText:
                  "You can only choose a maximum of $maxCount items at a time",
              type: "info");
        }
      }
    }
    return imagePaths;
  }

  static Future<String?> pickImage() async {
    String imagePath = '';
    if (Platform.isAndroid) {
      await Permission.storage.request();
    } else {
      await Permission.photos.request();
    }
    XFile? xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );
    if (xfile != null) {
      if (await File(xfile.path).exists()) {
        imagePath = xfile.path;
      }
    }
    return imagePath;
  }

  static Future<String?> captureImage() async {
    String imagePath = '';

    await Permission.camera.request();

    XFile? xfile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 40,
    );
    if (xfile != null) {
      if (await File(xfile.path).exists()) {
        imagePath = xfile.path;
      }
    }
    return imagePath;
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
