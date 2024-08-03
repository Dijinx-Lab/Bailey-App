import 'dart:convert';

import 'package:bailey/keys/pref/pref_keys.dart';
import 'package:bailey/models/api/user/user/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefUtil {
  static SharedPreferences? _sharedPreferences;

  factory PrefUtil() => PrefUtil._internal();

  PrefUtil._internal();

  Future<void> init() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
  }

  //APP DATA

  bool get isOnboarded => _sharedPreferences!.getBool(onboarded) ?? false;

  set isOnboarded(bool value) {
    _sharedPreferences!.setBool(onboarded, value);
  }

  bool get isLoggedIn => _sharedPreferences!.getBool(loggedIn) ?? false;

  set isLoggedIn(bool value) {
    _sharedPreferences!.setBool(loggedIn, value);
  }

  bool get rememberMe => _sharedPreferences!.getBool(keepLoggedIn) ?? false;

  set rememberMe(bool value) {
    _sharedPreferences!.setBool(keepLoggedIn, value);
  }

  //USER

  UserDetail? get currentUser {
    try {
      String? teamJson = _sharedPreferences!.getString(userDetails);
      if (teamJson == null || teamJson == '') return null;

      return UserDetail.fromJson(json.decode(teamJson));
    } catch (e) {
      return null;
    }
  }

  set currentUser(UserDetail? value) {
    try {
      if (value == null) {
        _sharedPreferences!.setString(userDetails, '');
      } else {
        final String teamJson = json.encode(value.toJson());
        print(teamJson);
        _sharedPreferences!.setString(userDetails, teamJson);
      }
    } catch (e) {
      print(e);
      _sharedPreferences!.setString(userDetails, '');
    }
  }

  bool get showFingerprintTips =>
      _sharedPreferences!.getBool(showProcessingTips) ?? true;

  set showFingerprintTips(bool value) {
    _sharedPreferences!.setBool(showProcessingTips, value);
  }
}
