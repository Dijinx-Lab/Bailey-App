import 'package:bailey/api/entities/fingerprint/fingerprint_service.dart';
import 'package:bailey/api/entities/handwriting/handwriting_service.dart';
import 'package:bailey/api/entities/photo/photo_service.dart';
import 'package:bailey/api/entities/upload/upload_service.dart';
import 'package:bailey/api/entities/user/user_service.dart';
import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/api/base/base_response.dart';
import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:flutter/material.dart';

class ApiService {
  //UTIL
  static dynamic processResponse(BaseResponse response, BuildContext ctx) {
    if (response.error == null) {
      if (response.status == 401) {
        Navigator.of(ctx)
            .pushNamedAndRemoveUntil(signinRoute, (route) => false);
        ToastUtils.showCustomSnackbar(
            context: ctx, contentText: "Session expired", type: "fail");
        return null;
      } else {
        return response.snapshot;
      }
    } else {
      print(response.error);
      ToastUtils.showCustomSnackbar(
          context: ctx, contentText: response.error ?? "", type: "fail");
      return null;
    }
  }

  //USER
  static Future<BaseResponse> signIn({
    required String email,
    required String password,
    required String fcmToken,
  }) =>
      UserService().signIn(
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
      UserService().signUp(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        fcmToken: fcmToken,
      );

  static Future<BaseResponse> sso({
    required String? email,
    required String? name,
    required String? googleId,
    required String? appleId,
  }) =>
      UserService().sso(
        name: name,
        email: email,
        googleId: googleId,
        appleId: appleId,
      );

  static Future<BaseResponse> editProfile({
    required String? email,
    required String? name,
  }) =>
      UserService().edit(
        name: name,
        email: email,
      );

  static Future<BaseResponse> signOut() => UserService().signOut();

  static Future<BaseResponse> userDetail() => UserService().detail();

  static Future<BaseResponse> deleteAccount() => UserService().delete();

  //UPLOAD
  static Future<BaseResponse> upload({
    required String folder,
    required String filePath,
  }) =>
      UploadService().upload(
        folder: folder,
        filePath: filePath,
      );

  //PHOTO
  static Future<BaseResponse> addPhoto({
    required String uploadId,
  }) =>
      PhotoService().add(
        uploadId: uploadId,
      );

  static Future<BaseResponse> listPhotos() => PhotoService().list();

  static Future<BaseResponse> deletePhoto({required String photoId}) =>
      PhotoService().delete(
        photoId: photoId,
      );

  //HANDWRITING
  static Future<BaseResponse> addWriting({
    required String uploadId,
  }) =>
      HandwritingService().add(
        uploadId: uploadId,
      );

  static Future<BaseResponse> listWriting() => HandwritingService().list();

  static Future<BaseResponse> deleteWriting({required String writingId}) =>
      HandwritingService().delete(
        writingId: writingId,
      );

  //FINGERPRINT
  static Future<BaseResponse> addPrint({
    required String hand,
    required String finger,
    required String uploadId,
  }) =>
      FingerprintService().add(
        hand: hand,
        finger: finger,
        uploadId: uploadId,
      );

  static Future<BaseResponse> editPrint({
    required String uploadId,
  }) =>
      FingerprintService().edit(
        uploadId: uploadId,
      );

  static Future<BaseResponse> listPrints() => FingerprintService().list();

  static Future<BaseResponse> deletePrint({required String printId}) =>
      FingerprintService().delete(
        printId: printId,
      );
}
