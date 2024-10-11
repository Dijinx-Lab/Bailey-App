import 'dart:convert';

class Session {
  final String? id;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  bool? fingerprintsAdded;
  bool? photosAdded;
  bool? handwritingsAdded;

  Session({
    this.id,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.fingerprintsAdded,
    this.photosAdded,
    this.handwritingsAdded,
  });

  factory Session.fromRawJson(String str) => Session.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json["_id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        dateOfBirth: json["date_of_birth"] == null
            ? null
            : DateTime.parse(json["date_of_birth"]),
        fingerprintsAdded: json["fingerprints_added"],
        photosAdded: json["photos_added"],
        handwritingsAdded: json["handwritings_added"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "first_name": firstName,
        "last_name": lastName,
        "date_of_birth": dateOfBirth?.toIso8601String(),
        "fingerprints_added": fingerprintsAdded,
        "photos_added": photosAdded,
        "handwritings_added": handwritingsAdded,
      };
}
