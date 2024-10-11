import 'dart:convert';

import 'package:bailey/models/api/base/base_response.dart';
import 'package:bailey/models/api/link/link_response.dart';
import 'package:http/http.dart' as http;
import 'package:bailey/keys/api/api_keys.dart';

class CommonsService {
  Future<BaseResponse> getTermsLink() async {
    try {
      var url = ApiKeys.getTermsLink;

      var response = await http.get(
        Uri.parse(url),
        headers: {
          "content-type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        LinkResponse userResponse = LinkResponse.fromJson(responseBody);

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
