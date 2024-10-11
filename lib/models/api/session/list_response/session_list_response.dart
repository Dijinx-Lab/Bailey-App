import 'dart:convert';

import 'package:bailey/models/api/session/session/session.dart';

class SessionListResponse {
  final bool? success;
  final Data? data;
  final String? message;

  SessionListResponse({
    this.success,
    this.data,
    this.message,
  });

  factory SessionListResponse.fromRawJson(String str) =>
      SessionListResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SessionListResponse.fromJson(Map<String, dynamic> json) =>
      SessionListResponse(
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
  final List<Session>? sessions;

  Data({
    this.sessions,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        sessions: json["sessions"] == null
            ? []
            : List<Session>.from(
                json["sessions"]!.map((x) => Session.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "sessions": sessions == null
            ? []
            : List<dynamic>.from(sessions!.map((x) => x.toJson())),
      };
}
