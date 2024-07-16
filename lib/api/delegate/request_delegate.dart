import 'package:bailey/api/entities/user_request_handler.dart';
import 'package:bailey/models/api/base/base_response.dart';

class RequestDelegate {
  //USER
  static Future<BaseResponse> signIn({
    required String email,
    required String password,
    required String fcmToken,
  }) =>
      UserRequestHandler().signIn(
        email: email,
        password: password,
        fcmToken: fcmToken,
      );

  static Future<BaseResponse> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String fcmToken,
  }) =>
      UserRequestHandler().signUp(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        fcmToken: fcmToken,
      );
}
