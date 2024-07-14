import 'dart:convert';

import 'package:bailey/models/api/fingerprint/fingerprint/fingerprint.dart';

class FingerprintResponse {
  final bool? success;
  final Data? data;
  final String? message;

  FingerprintResponse({
    this.success,
    this.data,
    this.message,
  });

  factory FingerprintResponse.fromRawJson(String str) =>
      FingerprintResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FingerprintResponse.fromJson(Map<String, dynamic> json) =>
      FingerprintResponse(
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
  final Fingerprint? fingerprint;

  Data({
    this.fingerprint,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        fingerprint: json["fingerprint"] == null
            ? null
            : Fingerprint.fromJson(json["fingerprint"]),
      );

  Map<String, dynamic> toJson() => {
        "fingerprint": fingerprint?.toJson(),
      };
}

