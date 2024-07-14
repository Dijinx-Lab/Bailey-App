import 'dart:convert';

class GenericResponse {
  final bool? success;
  final String? message;

  GenericResponse({
    this.success,
    this.message,
  });

  factory GenericResponse.fromRawJson(String str) =>
      GenericResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GenericResponse.fromJson(Map<String, dynamic> json) =>
      GenericResponse(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
      };
}
