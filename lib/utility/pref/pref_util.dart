import 'package:bailey/keys/pref/pref_keys.dart';
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
}
