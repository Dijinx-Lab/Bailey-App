import 'dart:typed_data';

import 'package:bailey/api/entities/commons/commons_service.dart';
import 'package:bailey/api/entities/fingerprint/fingerprint_service.dart';
import 'package:bailey/api/entities/handwriting/handwriting_service.dart';
import 'package:bailey/api/entities/photo/photo_service.dart';
import 'package:bailey/api/entities/session/session_service.dart';
import 'package:bailey/api/entities/upload/upload_service.dart';
import 'package:bailey/api/entities/user/user_service.dart';
import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/api/base/base_response.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:flutter/material.dart';

class ApiService {
  //UTIL
  static dynamic processResponse(BaseResponse response, BuildContext ctx) {
    if (response.status == 401) {
      PrefUtil().currentUser = null;
      PrefUtil().isLoggedIn = false;
      Navigator.of(ctx).pushNamedAndRemoveUntil(signinRoute, (route) => false);
      ToastUtils.showCustomSnackbar(
          context: ctx, contentText: "Session expired", type: "fail");
      return null;
    } else if (response.error == null) {
      return response.snapshot;
    } else {
      if (response.error == null) {
        ToastUtils.showCustomSnackbar(
            context: ctx,
            contentText: "An error occured, please try again later",
            type: "fail");
        return null;
      }
      if (response.error!.contains("Connection refused")) {
        ToastUtils.showCustomSnackbar(
            context: ctx,
            contentText:
                "Could not connect to our server, please make sure you have a stable internet connection",
            type: "fail");
        return null;
      } else {
        ToastUtils.showCustomSnackbar(
            context: ctx, contentText: response.error ?? "", type: "fail");
        return null;
      }
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
    required String? fcmToken,
  }) =>
      UserService().sso(
          name: name,
          email: email,
          googleId: googleId,
          appleId: appleId,
          fcmToken: fcmToken);

  static Future<BaseResponse> editProfile({
    required String? email,
    required String? name,
    required String? fcmToken,
    required String? companyName,
    required String? companyLocation,
  }) =>
      UserService().edit(
        name: name,
        email: email,
        fcmToken: fcmToken,
        companyName: companyName,
        companyLocation: companyLocation,
      );

  static Future<BaseResponse> changePassword({
    required String oldPass,
    required String newPass,
    required String confirmPass,
  }) =>
      UserService().changePassword(
          oldPass: oldPass, newPass: newPass, confirmPass: confirmPass);

  static Future<BaseResponse> forgotPassword({
    required String email,
    required String newPass,
    required String confirmPass,
  }) =>
      UserService().forgotPassword(
          email: email, newPass: newPass, confirmPass: confirmPass);

  static Future<BaseResponse> sendVerificationCode({
    required String type,
    required String email,
  }) =>
      UserService().sendVerificationCode(
        type: type,
        email: email,
      );

  static Future<BaseResponse> verifyCode({
    required String type,
    required String email,
    required String code,
  }) =>
      UserService().verifyCode(
        type: type,
        email: email,
        code: code,
      );

  static Future<BaseResponse> signOut() => UserService().signOut();

  static Future<BaseResponse> userDetail() => UserService().detail();

  static Future<BaseResponse> deleteAccount() => UserService().delete();

  static Future<BaseResponse> userCompleteDetail() =>
      UserService().completeDetail();

  //UPLOAD
  static Future<BaseResponse> upload({
    required String folder,
    required String filePath,
    required String fileName,
  }) =>
      UploadService().upload(
        folder: folder,
        filePath: filePath,
        fileName: fileName,
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

  static Future<BaseResponse> deletePhotosBySession(
          {required String sessionId}) =>
      PhotoService().deleteBySession(
        sessionId: sessionId,
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

  static Future<BaseResponse> deleteWritingsBySession(
          {required String sessionId}) =>
      HandwritingService().deleteBySession(
        sessionId: sessionId,
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
    required String printId,
    required String uploadId,
  }) =>
      FingerprintService().edit(
        printId: printId,
        uploadId: uploadId,
      );

  static Future<BaseResponse> listPrints() => FingerprintService().list();

  static Future<BaseResponse> deletePrint({required String printId}) =>
      FingerprintService().delete(
        printId: printId,
      );

  static Future<BaseResponse> prcoessPrint({
    required Uint8List fileBytes,
  }) =>
      FingerprintService().process(
        fileBytes: fileBytes,
      );

  static Future<BaseResponse> deletePrintsBySession(
          {required String sessionId}) =>
      FingerprintService().deleteBySession(
        sessionId: sessionId,
      );

  //SESSION
  static Future<BaseResponse> addSession({
    required String firstname,
    required String lastname,
    required String dateOfBirth,
  }) =>
      SessionService().add(
        firstname: firstname,
        lastname: lastname,
        dateOfBirth: dateOfBirth,
      );

  static Future<BaseResponse> listSessions() => SessionService().list();

  static Future<BaseResponse> deleteSession({
    required String id,
  }) =>
      SessionService().delete(
        id: id,
      );

  //COMMONTS
  static Future<BaseResponse> getTermsLink() => CommonsService().getTermsLink();
}
