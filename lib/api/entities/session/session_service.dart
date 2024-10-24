import 'dart:collection';
import 'dart:convert';

import 'package:bailey/models/api/base/base_response.dart';
import 'package:bailey/models/api/generic/generic_response.dart';
import 'package:bailey/models/api/session/list_response/session_list_response.dart';
import 'package:bailey/models/api/session/response/session_response.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:http/http.dart' as http;
import 'package:bailey/keys/api/api_keys.dart';

class SessionService {
  Future<BaseResponse> add({
    required String firstname,
    required String lastname,
    required String dateOfBirth,
  }) async {
    try {
      var url = ApiKeys.addSession;

      var params = HashMap();
      params["first_name"] = firstname;
      params["last_name"] = lastname;
      params["date_of_birth"] = dateOfBirth;
      params.removeWhere((key, value) => value == null || value == '');

      var response = await http.post(
        Uri.parse(url),
        body: json.encode(params),
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer ${PrefUtil().currentUser?.token ?? ''}",
        },
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        SessionResponse userResponse = SessionResponse.fromJson(responseBody);

        return BaseResponse(response.statusCode, userResponse, null);
      } else {
        return BaseResponse(response.statusCode, null, response.body);
      }
    } catch (e) {
      return BaseResponse(
        null,
        null,
        e.toString(),
      );
    }
  }

  Future<BaseResponse> delete({
    required String id,
  }) async {
    try {
      var url = "${ApiKeys.deleteSession}?id=$id";

      var response = await http.delete(
        Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer ${PrefUtil().currentUser?.token ?? ''}",
        },
      );


      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        GenericResponse userResponse = GenericResponse.fromJson(responseBody);

        return BaseResponse(response.statusCode, userResponse, null);
      } else {
        return BaseResponse(response.statusCode, null, response.body);
      }
    } catch (e) {
      return BaseResponse(
        null,
        null,
        e.toString(),
      );
    }
  }

  Future<BaseResponse> list() async {
    try {
      var url = ApiKeys.listSession;

      var response = await http.get(
        Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer ${PrefUtil().currentUser?.token ?? ''}",
        },
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        SessionListResponse userResponse =
            SessionListResponse.fromJson(responseBody);

        return BaseResponse(response.statusCode, userResponse, null);
      } else {
        return BaseResponse(response.statusCode, null, response.body);
      }
    } catch (e) {
      return BaseResponse(
        null,
        null,
        e.toString(),
      );
    }
  }
}
