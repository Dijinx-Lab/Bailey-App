import 'dart:convert';

class LinkResponse {
  final bool? success;
  final Data? data;
  final String? message;

  LinkResponse({
    this.success,
    this.data,
    this.message,
  });

  factory LinkResponse.fromRawJson(String str) =>
      LinkResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LinkResponse.fromJson(Map<String, dynamic> json) => LinkResponse(
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
  final String? link;

  Data({
    this.link,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        link: json["link"],
      );

  Map<String, dynamic> toJson() => {
        "link": link,
      };
}
