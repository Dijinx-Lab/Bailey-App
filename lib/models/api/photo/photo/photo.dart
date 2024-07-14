import 'dart:convert';

import 'package:bailey/models/api/upload/upload/upload.dart';

class Photo {
  final String? id;
  final Upload? upload;

  Photo({
    this.id,
    this.upload,
  });

  factory Photo.fromRawJson(String str) => Photo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
        id: json["_id"],
        upload: json["upload"] == null ? null : Upload.fromJson(json["upload"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "upload": upload?.toJson(),
      };
}
