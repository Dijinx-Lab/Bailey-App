import 'dart:convert';

class FingerprintProcessingResponse {
  final bool? success;
  final Data? data;
  final String? message;

  FingerprintProcessingResponse({
    this.success,
    this.data,
    this.message,
  });

  factory FingerprintProcessingResponse.fromRawJson(String str) =>
      FingerprintProcessingResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FingerprintProcessingResponse.fromJson(Map<String, dynamic> json) =>
      FingerprintProcessingResponse(
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
  final String? processedImage;

  Data({
    this.processedImage,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        processedImage: json["processed_image"],
      );

  Map<String, dynamic> toJson() => {
        "processed_image": processedImage,
      };
}
