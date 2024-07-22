import 'dart:convert';

import 'package:bailey/models/api/upload/upload/upload.dart';

class Fingerprint {
  final String? id;
   bool? isSkipped;
  final String? hand;
  final String? finger;
  final Upload? upload;
  String? changeKey;

  Fingerprint({
    this.id,
    this.isSkipped,
    this.hand,
    this.finger,
    this.upload,
    this.changeKey,
  });

  Fingerprint.copy(Fingerprint original)
      : id = original.id,
        isSkipped = original.isSkipped,
        hand = original.hand,
        finger = original.finger,
        upload = original.upload != null ? Upload.copy(original.upload!) : null,
        changeKey = original.changeKey;

  factory Fingerprint.fromRawJson(String str) =>
      Fingerprint.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Fingerprint.fromJson(Map<String, dynamic> json) => Fingerprint(
        id: json["_id"],
        isSkipped: json["is_skipped"],
        hand: json["hand"],
        finger: json["finger"],
        upload: json["upload"] == null
            ? null
            : Upload.fromJson(
                json["upload"],
              ),
        changeKey: json["change_key"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "is_skipped": isSkipped,
        "hand": hand,
        "finger": finger,
        "upload": upload?.toJson(),
        "change_key": changeKey
      };
}
