import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bailey/models/api/base/base_response.dart';
import 'package:bailey/models/api/fingerprint/list_response/fingerprint_list_response.dart';
import 'package:bailey/models/api/fingerprint/processing_response/fingerprint_processing_response.dart';
import 'package:bailey/models/api/fingerprint/response/fingerprint_response.dart';
import 'package:bailey/models/api/generic/generic_response.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:bailey/keys/api/api_keys.dart';
import 'package:mime/mime.dart';

class FingerprintService {
  Future<BaseResponse> add({
    required String hand,
    required String finger,
    required String uploadId,
  }) async {
    try {
      var url = ApiKeys.addPrint;
      print(url);

      var params = HashMap();
      params["hand"] = hand;
      params["finger"] = finger;
      params["upload_id"] = uploadId;

      print(params);

      params.removeWhere((key, value) => value == null || value == '');
      var response = await http.post(
        Uri.parse(url),
        body: json.encode(params),
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer ${PrefUtil().currentUser?.token ?? ''}",
        },
      );

      print(response.body);

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
    required String printId,
    required String uploadId,
  }) async {
    try {
      var url = "${ApiKeys.editPrint}?id=$printId";

      var params = HashMap();

      params["upload_id"] = uploadId;

      params.removeWhere((key, value) => value == null || value == '');
      var response = await http.put(
        Uri.parse(url),
        body: json.encode(params),
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer ${PrefUtil().currentUser?.token ?? ''}",
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
          "Authorization": "Bearer ${PrefUtil().currentUser?.token ?? ''}",
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
          "Authorization": "Bearer ${PrefUtil().currentUser?.token ?? ''}",
        },
      );

      print(url);

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

  Future<BaseResponse> process({
    required Uint8List fileBytes,
  }) async {
    try {
      var url = ApiKeys.processingServices;

      var request = http.MultipartRequest("POST", Uri.parse(url));
      request.headers["x-api-key"] = dotenv.env['API-GATEWAY-KEY']!;
      request.headers["Content-Type"] = 'multipart/form-data';
      var mimeType = lookupMimeType('', headerBytes: fileBytes) ??
          'application/octet-stream';
      var mimeTypeParts = mimeType.split('/');
      http.MultipartFile uploadFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: DateTime.now().toIso8601String(),
        contentType: parser.MediaType(mimeTypeParts[0], mimeTypeParts[1]),
      );
      request.files.add(uploadFile);

      var value = await request.send();

      if (value.statusCode == 200) {
        final response = await http.Response.fromStream(value);
        var responseBody = json.decode(response.body);
        FingerprintProcessingResponse parsedResponse =
            FingerprintProcessingResponse.fromJson(responseBody);
        return BaseResponse(value.statusCode, parsedResponse, null);
      } else {
        final response = await http.Response.fromStream(value);
        print(response.body);
        return BaseResponse(value.statusCode, null, response.body);
      }
    } catch (e) {
      return BaseResponse(null, null, e.toString());
    }
  }
}
