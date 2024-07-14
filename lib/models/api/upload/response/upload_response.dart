import 'dart:convert';

import 'package:bailey/models/api/upload/upload/upload.dart';

class UploadResponse {
  final bool? success;
  final Data? data;
  final String? message;

  UploadResponse({
    this.success,
    this.data,
    this.message,
  });

  factory UploadResponse.fromRawJson(String str) =>
      UploadResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UploadResponse.fromJson(Map<String, dynamic> json) => UploadResponse(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
      };
}

class Data {
  final Upload? upload;

  Data({
    this.upload,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        upload: json["upload"] == null ? null : Upload.fromJson(json["upload"]),
      );

  Map<String, dynamic> toJson() => {
        "upload": upload?.toJson(),
      };
}
