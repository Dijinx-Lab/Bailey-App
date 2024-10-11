import 'dart:convert';

import 'package:bailey/models/api/base/base_response.dart';
import 'package:bailey/models/api/upload/response/upload_response.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as parser;
import 'package:bailey/keys/api/api_keys.dart';

class UploadService {
  Future<BaseResponse> upload({
    required String folder,
    required String filePath,
    required String fileName,
  }) async {
    try {
      var url = ApiKeys.upload;
      // print(url);
      // print(filePath);
      var request = http.MultipartRequest("POST", Uri.parse(url));
      request.headers["authorization"] =
          "Bearer ${PrefUtil().currentUser!.token!}";
      request.fields["folder"] = folder;
      request.fields["file_name"] = fileName;

      http.MultipartFile uploadFile = await http.MultipartFile.fromPath(
          'file', filePath,
          contentType: getContentType(filePath));
      request.files.add(uploadFile);

      var value = await request.send();

      if (value.statusCode == 200) {
        final response = await http.Response.fromStream(value);
        var responseBody = json.decode(response.body);

        UploadResponse parsedResponse = UploadResponse.fromJson(responseBody);
        return BaseResponse(value.statusCode, parsedResponse, null);
      } else {
        final response = await http.Response.fromStream(value);

        return BaseResponse(value.statusCode, null, response.body);
      }
    } catch (e) {
      return BaseResponse(null, null, e.toString());
    }
  }

  parser.MediaType getContentType(String filePath) {
    String extension = filePath.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return parser.MediaType('image', 'jpeg');
      case 'png':
        return parser.MediaType('image', 'png');
      case 'gif':
        return parser.MediaType('image', 'gif');
      case 'bmp':
        return parser.MediaType('image', 'bmp');
      case 'mp4':
        return parser.MediaType('video', 'mp4');
      case 'mov':
        return parser.MediaType('video', 'quicktime');
      case 'avi':
        return parser.MediaType('video', 'x-msvideo');

      default:
        return parser.MediaType(
            'application', 'octet-stream'); // Default media type
    }
  }

  static Map<String, String> getUploadFilePath(
      {required UploadType uploadType, bool? isLeftHand, String? fingerType}) {
    switch (uploadType) {
      case UploadType.fingerprint:
        return {
          "filename": "${isLeftHand == true ? "left" : "right"}-$fingerType",
          "folder":
              "sessions/${PrefUtil().currentUser?.companyName}-${PrefUtil().currentUser?.id}/${PrefUtil().currentSession?.firstName}-${PrefUtil().currentSession?.lastName}-${PrefUtil().currentSession?.dateOfBirth!.toIso8601String()}-${PrefUtil().currentSession?.id}/fingerprints"
        };
      case UploadType.photo:
        return {
          "filename": DateTime.now()
              .toIso8601String()
              .replaceAll(":", "")
              .replaceAll(".", ""),
          "folder":
              "sessions/${PrefUtil().currentUser?.companyName}-${PrefUtil().currentUser?.id}/${PrefUtil().currentSession?.firstName}-${PrefUtil().currentSession?.lastName}-${PrefUtil().currentSession?.dateOfBirth!.toIso8601String()}-${PrefUtil().currentSession?.id}/photos"
        };
      case UploadType.handwriting:
        return {
          "filename": DateTime.now()
              .toIso8601String()
              .replaceAll(":", "")
              .replaceAll(".", ""),
          "folder":
              "sessions/${PrefUtil().currentUser?.companyName}-${PrefUtil().currentUser?.id}/${PrefUtil().currentSession?.firstName}-${PrefUtil().currentSession?.lastName}-${PrefUtil().currentSession?.dateOfBirth!.toIso8601String()}-${PrefUtil().currentSession?.id}/handwritings"
        };
    }
  }
}

enum UploadType { fingerprint, photo, handwriting }
