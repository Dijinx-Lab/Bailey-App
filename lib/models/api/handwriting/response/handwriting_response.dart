import 'dart:convert';

import 'package:bailey/models/api/handwriting/handwriting/handwriting.dart';

class HandwritingResponse {
  final bool? success;
  final Data? data;
  final String? message;

  HandwritingResponse({
    this.success,
    this.data,
    this.message,
  });

  factory HandwritingResponse.fromRawJson(String str) =>
      HandwritingResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory HandwritingResponse.fromJson(Map<String, dynamic> json) =>
      HandwritingResponse(
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
  final Handwriting? handwriting;

  Data({
    this.handwriting,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        handwriting: json["handwriting"] == null
            ? null
            : Handwriting.fromJson(json["handwriting"]),
      );

  Map<String, dynamic> toJson() => {
        "handwriting": handwriting?.toJson(),
      };
}
