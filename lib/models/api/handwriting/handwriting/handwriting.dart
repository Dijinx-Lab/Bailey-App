import 'dart:convert';

import 'package:bailey/models/api/upload/upload/upload.dart';

class Handwriting {
  final String? id;
  final Upload? upload;

  Handwriting({
    this.id,
    this.upload,
  });

  factory Handwriting.fromRawJson(String str) =>
      Handwriting.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Handwriting.fromJson(Map<String, dynamic> json) => Handwriting(
        id: json["_id"],
        upload: json["upload"] == null ? null : Upload.fromJson(json["upload"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "upload": upload?.toJson(),
      };
}
