import 'dart:convert';

import 'package:bailey/models/api/upload/upload/upload.dart';

class Fingerprint {
  final String? id;
  final bool? isSkipped;
  final String? hand;
  final String? finger;
  final Upload? upload;

  Fingerprint({
    this.id,
    this.isSkipped,
    this.hand,
    this.finger,
    this.upload,
  });

  factory Fingerprint.fromRawJson(String str) =>
      Fingerprint.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Fingerprint.fromJson(Map<String, dynamic> json) => Fingerprint(
        id: json["_id"],
        isSkipped: json["is_skipped"],
        hand: json["hand"],
        finger: json["finger"],
        upload: json["upload"] == null ? null : Upload.fromJson(json["upload"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "is_skipped": isSkipped,
        "hand": hand,
        "finger": finger,
        "upload": upload?.toJson(),
      };
}
