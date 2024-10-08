import 'dart:convert';

class UserDetail {
  final String? name;
  final String? email;
  final String? token;
  final String? googleId;
  final String? appleId;
  final DateTime? lastSigninOn;
  bool? fingerprintsAdded;
  bool? photosAdded;
  bool? handwritingsAdded;
  bool? notificationsEnabled;

  UserDetail({
    this.name,
    this.email,
    this.token,
    this.googleId,
    this.appleId,
    this.lastSigninOn,
    this.fingerprintsAdded,
    this.photosAdded,
    this.handwritingsAdded,
    this.notificationsEnabled,
  });

  factory UserDetail.fromRawJson(String str) =>
      UserDetail.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserDetail.fromJson(Map<String, dynamic> json) => UserDetail(
        name: json["name"],
        email: json["email"],
        token: json["token"],
        googleId: json["google_id"],
        appleId: json["apple_id"],
        lastSigninOn: json["last_signin_on"] == null
            ? null
            : DateTime.parse(json["last_signin_on"]),
        fingerprintsAdded: json["fingerprints_added"],
        photosAdded: json["photos_added"],
        handwritingsAdded: json["handwritings_added"],
        notificationsEnabled: json["notifications_enabled"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "token": token,
        "google_id": googleId,
        "apple_id": appleId,
        "last_signin_on": lastSigninOn?.toIso8601String(),
        "fingerprints_added": fingerprintsAdded,
        "photos_added": photosAdded,
        "handwritings_added": handwritingsAdded,
        "notifications_enabled": notificationsEnabled,
      };
}
