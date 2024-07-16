import 'dart:collection';
import 'dart:convert';

import 'package:bailey/models/api/base/base_response.dart';
import 'package:bailey/models/api/fingerprint/list_response/fingerprint_list_response.dart';
import 'package:bailey/models/api/fingerprint/response/fingerprint_response.dart';
import 'package:bailey/models/api/generic/generic_response.dart';
import 'package:bailey/utility/pref/pref_util.dart';

import 'package:http/http.dart' as http;
import 'package:bailey/keys/api/api_keys.dart';

class FingerprintService {
  Future<BaseResponse> add({
    required String hand,
    required String finger,
    required String uploadId,
  }) async {
    try {
      var url = ApiKeys.addPrint;

      var params = HashMap();
      params["hand"] = hand;
      params["finger"] = finger;
      params["upload_id"] = uploadId;

      params.removeWhere((key, value) => value == null || value == '');
      var response = await http.post(
        Uri.parse(url),
        body: json.encode(params),
        headers: {
          "content-type": "application/json",
          "authorization": PrefUtil().currentUser?.token ?? '',
        },
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        FingerprintResponse userResponse =
            FingerprintResponse.fromJson(responseBody);

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

  Future<BaseResponse> edit({
    required String uploadId,
  }) async {
    try {
      var url = ApiKeys.editPrint;

      var params = HashMap();

      params["upload_id"] = uploadId;

      params.removeWhere((key, value) => value == null || value == '');
      var response = await http.put(
        Uri.parse(url),
        body: json.encode(params),
        headers: {
          "content-type": "application/json",
          "authorization": PrefUtil().currentUser?.token ?? '',
        },
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        FingerprintResponse userResponse =
            FingerprintResponse.fromJson(responseBody);

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
      var url = ApiKeys.listPrints;

      var response = await http.get(
        Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "authorization": PrefUtil().currentUser?.token ?? '',
        },
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        FingerprintListResponse userResponse =
            FingerprintListResponse.fromJson(responseBody);

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

  Future<BaseResponse> delete({required String printId}) async {
    try {
      var url = "${ApiKeys.deletePrints}?id=$printId";

      var response = await http.delete(
        Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "authorization": PrefUtil().currentUser?.token ?? '',
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
}
