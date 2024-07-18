import 'dart:collection';
import 'dart:convert';

import 'package:bailey/models/api/base/base_response.dart';
import 'package:bailey/models/api/generic/generic_response.dart';
import 'package:bailey/models/api/photo/list_response/photo_list_response.dart';
import 'package:bailey/models/api/photo/response/photo_response.dart';
import 'package:bailey/utility/pref/pref_util.dart';

import 'package:http/http.dart' as http;
import 'package:bailey/keys/api/api_keys.dart';

class PhotoService {
  Future<BaseResponse> add({
    required String uploadId,
  }) async {
    try {
      var url = ApiKeys.addPhoto;

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
        PhotoResponse userResponse = PhotoResponse.fromJson(responseBody);

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
      var url = ApiKeys.listPhotos;

      var response = await http.get(
        Uri.parse(url),
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer ${PrefUtil().currentUser?.token ?? ''}",
        },
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        PhotoListResponse userResponse =
            PhotoListResponse.fromJson(responseBody);

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
    required String photoId,
  }) async {
    try {
      var url = "${ApiKeys.deletePhoto}?id=$photoId";

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
