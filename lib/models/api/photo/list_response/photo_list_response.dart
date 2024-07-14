import 'dart:convert';

import 'package:bailey/models/api/photo/photo/photo.dart';

class PhotoListResponse {
  final bool? success;
  final Data? data;
  final String? message;

  PhotoListResponse({
    this.success,
    this.data,
    this.message,
  });

  factory PhotoListResponse.fromRawJson(String str) =>
      PhotoListResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PhotoListResponse.fromJson(Map<String, dynamic> json) =>
      PhotoListResponse(
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
  final List<Photo>? photos;

  Data({
    this.photos,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        photos: json["photos"] == null
            ? []
            : List<Photo>.from(json["photos"]!.map((x) => Photo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "photos": photos == null
            ? []
            : List<dynamic>.from(photos!.map((x) => x.toJson())),
      };
}
