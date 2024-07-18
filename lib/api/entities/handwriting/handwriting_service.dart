import 'dart:collection';
import 'dart:convert';

import 'package:bailey/models/api/base/base_response.dart';
import 'package:bailey/models/api/generic/generic_response.dart';
import 'package:bailey/models/api/handwriting/list_response/handwriting_list_response.dart';
import 'package:bailey/models/api/handwriting/response/handwriting_response.dart';
import 'package:bailey/utility/pref/pref_util.dart';

import 'package:http/http.dart' as http;
import 'package:bailey/keys/api/api_keys.dart';

class HandwritingService {
  Future<BaseResponse> add({
    required String uploadId,
  }) async {
    try {
      var url = ApiKeys.addWriting;

      var params = HashMap();
      params["upload_id"] = uploadId;

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
        HandwritingResponse userResponse =
            HandwritingResponse.fromJson(responseBody);

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
      var url = ApiKeys.listWritings;

      var response = await http.get(
        Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer ${PrefUtil().currentUser?.token ?? ''}",
        },
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        HandwritingListResponse userResponse =
            HandwritingListResponse.fromJson(responseBody);

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

  Future<BaseResponse> delete({required String writingId}) async {
    try {
      var url = "${ApiKeys.deleteWriting}?id=$writingId";

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
}
