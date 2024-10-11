import 'dart:convert';

class UserDetail {
  final String? id;
  final String? contactName;
  final String? email;
  final String? companyName;
  final String? companyLocation;
  final String? fcmToken;
  final String? token;
  final String? googleId;
  final String? appleId;
  final DateTime? lastSigninOn;
  final DateTime? emailVerifiedOn;
  final String? emailVerificationCode;
  final String? passwordVerificationCode;
  final bool? notificationsEnabled;
  final String? loginMethod;

  UserDetail({
    this.id,
    this.contactName,
    this.email,
    this.companyName,
    this.companyLocation,
    this.fcmToken,
    this.token,
    this.googleId,
    this.appleId,
    this.lastSigninOn,
    this.emailVerifiedOn,
    this.emailVerificationCode,
    this.passwordVerificationCode,
    this.notificationsEnabled,
    this.loginMethod,
  });

  factory UserDetail.fromRawJson(String str) =>
      UserDetail.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserDetail.fromJson(Map<String, dynamic> json) => UserDetail(
        id: json["_id"],
        contactName: json["contact_name"],
        email: json["email"],
        companyName: json["company_name"],
        companyLocation: json["company_location"],
        fcmToken: json["fcm_token"],
        token: json["token"],
        googleId: json["google_id"],
        appleId: json["apple_id"],
        lastSigninOn: json["last_signin_on"] == null
            ? null
            : DateTime.parse(json["last_signin_on"]),
        emailVerifiedOn: json["email_verified_on"] == null
            ? null
            : DateTime.parse(json["email_verified_on"]),
        emailVerificationCode: json["email_verification_code"],
        passwordVerificationCode: json["password_verification_code"],
        notificationsEnabled: json["notifications_enabled"],
        loginMethod: json["login_method"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "contact_name": contactName,
        "email": email,
        "company_name": companyName,
        "company_location": companyLocation,
        "fcm_token": fcmToken,
        "token": token,
        "google_id": googleId,
        "apple_id": appleId,
        "last_signin_on": lastSigninOn?.toIso8601String(),
        "email_verified_on": emailVerifiedOn?.toIso8601String(),
        "email_verification_code": emailVerificationCode,
        "password_verification_code": passwordVerificationCode,
        "notifications_enabled": notificationsEnabled,
        "login_method": loginMethod,
      };
}
