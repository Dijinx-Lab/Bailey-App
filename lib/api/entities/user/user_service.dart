import 'dart:collection';
import 'dart:convert';

import 'package:bailey/models/api/base/base_response.dart';
import 'package:bailey/models/api/generic/generic_response.dart';
import 'package:bailey/models/api/user/response/user_response.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:http/http.dart' as http;
import 'package:bailey/keys/api/api_keys.dart';

class UserService {
  Future<BaseResponse> signIn({
    required String email,
    required String password,
    required String fcmToken,
  }) async {
    try {
      var url = ApiKeys.signIn;

      var params = HashMap();
      params["email"] = email;
      params["password"] = password;
      params["fcm_token"] = fcmToken;
      params.removeWhere((key, value) => value == null || value == '');
      var response = await http.post(
        Uri.parse(url),
        body: json.encode(params),
        headers: {
          "content-type": "application/json",
        },
      );
      var responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        UserResponse userResponse = UserResponse.fromJson(responseBody);
        return BaseResponse(response.statusCode, userResponse, null);
      } else if (response.statusCode != 500) {
        GenericResponse userResponse = GenericResponse.fromJson(responseBody);
        return BaseResponse(response.statusCode, null, userResponse.message);
      } else {
        return BaseResponse(response.statusCode, null, responseBody);
      }
    } catch (e) {
      return BaseResponse(
        null,
        null,
        e.toString(),
      );
    }
  }

  Future<BaseResponse> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String fcmToken,
  }) async {
    try {
      var url = ApiKeys.signUp;
      var params = HashMap();
      params["name"] = name;
      params["email"] = email;
      params["password"] = password;
      params["confirm_password"] = confirmPassword;
      params["fcm_token"] = fcmToken;
      params.removeWhere((key, value) => value == null || value == '');
      var response = await http.post(
        Uri.parse(url),
        body: json.encode(params),
        headers: {
          "content-type": "application/json",
        },
      );

      var responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        UserResponse userResponse = UserResponse.fromJson(responseBody);
        return BaseResponse(response.statusCode, userResponse, null);
      } else if (response.statusCode != 500) {
        GenericResponse userResponse = GenericResponse.fromJson(responseBody);
        return BaseResponse(response.statusCode, null, userResponse.message);
      } else {
        return BaseResponse(response.statusCode, null, responseBody);
      }
    } catch (e) {
      return BaseResponse(null, null, e.toString());
    }
  }

  Future<BaseResponse> signOut() async {
    try {
      var url = ApiKeys.signOut;

      var response = await http.delete(
        Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer ${PrefUtil().currentUser?.token ?? ''}",
        },
      );

      var responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        GenericResponse userResponse = GenericResponse.fromJson(responseBody);
        return BaseResponse(response.statusCode, userResponse, null);
      } else if (response.statusCode != 500) {
        GenericResponse userResponse = GenericResponse.fromJson(responseBody);
        return BaseResponse(response.statusCode, null, userResponse.message);
      } else {
        return BaseResponse(response.statusCode, null, responseBody);
      }
    } catch (e) {
      return BaseResponse(null, null, e.toString());
    }
  }

  Future<BaseResponse> sso({
    required String? email,
    required String? name,
    required String? googleId,
    required String? appleId,
  }) async {
    try {
      var url = ApiKeys.sso;
      var params = HashMap();
      params["name"] = email;
      params["email"] = email;
      params["google_id"] = googleId;
      params["apple_id"] = appleId;
      params.removeWhere((key, value) => value == null || value == '');
      var response = await http.post(
        Uri.parse(url),
        body: json.encode(params),
        headers: {
          "content-type": "application/json",
        },
      );

      var responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        UserResponse userResponse = UserResponse.fromJson(responseBody);
        return BaseResponse(response.statusCode, userResponse, null);
      } else if (response.statusCode != 500) {
        GenericResponse userResponse = GenericResponse.fromJson(responseBody);
        return BaseResponse(response.statusCode, null, userResponse.message);
      } else {
        return BaseResponse(response.statusCode, null, responseBody);
      }
    } catch (e) {
      return BaseResponse(null, null, e.toString());
    }
  }

  Future<BaseResponse> detail() async {
    try {
      var url = ApiKeys.detail;

      var response = await http.get(
        Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer ${PrefUtil().currentUser?.token ?? ''}",
        },
      );

      var responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        UserResponse userResponse = UserResponse.fromJson(responseBody);
        return BaseResponse(response.statusCode, userResponse, null);
      } else if (response.statusCode != 500) {
        GenericResponse userResponse = GenericResponse.fromJson(responseBody);
        return BaseResponse(response.statusCode, null, userResponse.message);
      } else {
        return BaseResponse(response.statusCode, null, responseBody);
      }
    } catch (e) {
      return BaseResponse(null, null, e.toString());
    }
  }

  Future<BaseResponse> edit({
    required String? email,
    required String? name,
  }) async {
    try {
      var url = ApiKeys.editProfile;

      var params = HashMap();
      params["email"] = email;
      params["name"] = name;
      params.removeWhere((key, value) => value == null || value == '');
      var response = await http.put(
        Uri.parse(url),
        body: json.encode(params),
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer ${PrefUtil().currentUser?.token ?? ''}",
        },
      );

      var responseBody = json.decode(response.body);
      print(responseBody);
      if (response.statusCode == 200) {
        UserResponse userResponse = UserResponse.fromJson(responseBody);
        return BaseResponse(response.statusCode, userResponse, null);
      } else if (response.statusCode != 500) {
        GenericResponse userResponse = GenericResponse.fromJson(responseBody);
        return BaseResponse(response.statusCode, null, userResponse.message);
      } else {
        return BaseResponse(response.statusCode, null, responseBody);
      }
    } catch (e) {
      return BaseResponse(null, null, e.toString());
    }
  }

  Future<BaseResponse> delete() async {
    try {
      var url = ApiKeys.deleteAccount;

      var response = await http.delete(
        Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer ${PrefUtil().currentUser?.token ?? ''}",
        },
      );

      var responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        GenericResponse userResponse = GenericResponse.fromJson(responseBody);
        return BaseResponse(response.statusCode, userResponse, null);
      } else if (response.statusCode != 500) {
        GenericResponse userResponse = GenericResponse.fromJson(responseBody);
        return BaseResponse(response.statusCode, null, userResponse.message);
      } else {
        return BaseResponse(response.statusCode, null, responseBody);
      }
    } catch (e) {
      return BaseResponse(null, null, e.toString());
    }
  }

  Future<BaseResponse> changePassword({
    required String oldPass,
    required String newPass,
    required String confirmPass,
  }) async {
    try {
      var url = ApiKeys.changePassword;

      var params = HashMap();
      params["old_password"] = oldPass;
      params["password"] = newPass;
      params["confirm_password"] = confirmPass;
      params.removeWhere((key, value) => value == null || value == '');
      var response = await http.post(
        Uri.parse(url),
        body: json.encode(params),
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer ${PrefUtil().currentUser?.token ?? ''}",
        },
      );

      var responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        GenericResponse userResponse = GenericResponse.fromJson(responseBody);
        return BaseResponse(response.statusCode, userResponse, null);
      } else if (response.statusCode != 500) {
        GenericResponse userResponse = GenericResponse.fromJson(responseBody);
        return BaseResponse(response.statusCode, null, userResponse.message);
      } else {
        return BaseResponse(response.statusCode, null, responseBody);
      }
    } catch (e) {
      return BaseResponse(null, null, e.toString());
    }
  }
}
