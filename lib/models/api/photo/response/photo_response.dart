import 'dart:convert';

import 'package:bailey/models/api/photo/photo/photo.dart';

class PhotoResponse {
  final bool? success;
  final Data? data;
  final String? message;

  PhotoResponse({
    this.success,
    this.data,
    this.message,
  });

  factory PhotoResponse.fromRawJson(String str) =>
      PhotoResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PhotoResponse.fromJson(Map<String, dynamic> json) => PhotoResponse(
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
  final Photo? photo;

  Data({
    this.photo,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        photo: json["photo"] == null ? null : Photo.fromJson(json["photo"]),
      );

  Map<String, dynamic> toJson() => {
        "photo": photo?.toJson(),
      };
}
