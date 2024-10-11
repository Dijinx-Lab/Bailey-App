import 'dart:convert';

import 'package:bailey/models/api/session/session/session.dart';

class SessionResponse {
  final bool? success;
  final Data? data;
  final String? message;

  SessionResponse({
    this.success,
    this.data,
    this.message,
  });

  factory SessionResponse.fromRawJson(String str) =>
      SessionResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SessionResponse.fromJson(Map<String, dynamic> json) =>
      SessionResponse(
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
  final Session? session;

  Data({
    this.session,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        session:
            json["session"] == null ? null : Session.fromJson(json["session"]),
      );

  Map<String, dynamic> toJson() => {
        "session": session?.toJson(),
      };
}
