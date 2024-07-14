import 'dart:convert';

import 'package:bailey/models/api/handwriting/handwriting/handwriting.dart';

class HandwritingListResponse {
  final bool? success;
  final Data? data;
  final String? message;

  HandwritingListResponse({
    this.success,
    this.data,
    this.message,
  });

  factory HandwritingListResponse.fromRawJson(String str) =>
      HandwritingListResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory HandwritingListResponse.fromJson(Map<String, dynamic> json) =>
      HandwritingListResponse(
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
  final List<Handwriting>? handwritings;

  Data({
    this.handwritings,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        handwritings: json["handwritings"] == null
            ? []
            : List<Handwriting>.from(
                json["handwritings"]!.map((x) => Handwriting.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "handwritings": handwritings == null
            ? []
            : List<dynamic>.from(handwritings!.map((x) => x.toJson())),
      };
}
