import 'dart:convert';

import 'package:bailey/models/api/fingerprint/fingerprint/fingerprint.dart';

class FingerprintListResponse {
  final bool? success;
  final Data? data;
  final String? message;

  FingerprintListResponse({
    this.success,
    this.data,
    this.message,
  });

  factory FingerprintListResponse.fromRawJson(String str) =>
      FingerprintListResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FingerprintListResponse.fromJson(Map<String, dynamic> json) =>
      FingerprintListResponse(
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
  final List<Fingerprint>? leftHand;
  final List<Fingerprint>? rightHand;

  Data({
    this.leftHand,
    this.rightHand,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        leftHand: json["left_hand"] == null
            ? []
            : List<Fingerprint>.from(
                json["left_hand"]!.map((x) => Fingerprint.fromJson(x))),
        rightHand: json["right_hand"] == null
            ? []
            : List<Fingerprint>.from(
                json["right_hand"]!.map((x) => Fingerprint.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "left_hand": leftHand == null
            ? []
            : List<dynamic>.from(leftHand!.map((x) => x.toJson())),
        "right_hand": rightHand == null
            ? []
            : List<dynamic>.from(leftHand!.map((x) => x.toJson())),
      };
}
