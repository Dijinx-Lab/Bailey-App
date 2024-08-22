import 'dart:io';

import 'package:bailey/api/delegate/api_service.dart';
import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/api/user/response/user_response.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/auth/auth_util.dart';
import 'package:bailey/utility/misc/misc.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
import 'package:bailey/widgets/inputs/text_field/m_text_field.dart';
import 'package:bailey/widgets/loading/custom_loading.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _showPassword = false;
  bool _rememberMe = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => _checkValidity());
    _passwordController.addListener(() => _checkValidity());
  }

  _checkValidity() {
    _isValid = _emailController.text != "" && _passwordController.text != "";
    setState(() {});
  }

  Future<String?> _getFcmToken() async {
    try {
      await _firebaseMessaging.requestPermission();
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print(e);
      return null;
    }
  }

  _signInWithEmail() async {
    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text;

      FocusManager.instance.primaryFocus?.unfocus();
      SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));
      String? fcmToken = await _getFcmToken();
      ApiService.signIn(
              email: email, password: password, fcmToken: fcmToken ?? 'x')
          .then((value) {
        SmartDialog.dismiss();
        UserResponse? apiResponse =
            ApiService.processResponse(value, context) as UserResponse?;
        if (apiResponse != null) {
          if (apiResponse.success == true) {
            PrefUtil().isLoggedIn = true;
            PrefUtil().rememberMe = _rememberMe;
            PrefUtil().currentUser = apiResponse.data?.user;
            print(apiResponse.data?.user?.toJson());
            print(PrefUtil().currentUser);
            Navigator.of(context)
                .pushNamedAndRemoveUntil(baseRoute, (route) => false);
          } else {
            ToastUtils.showCustomSnackbar(
                context: context,
                contentText: apiResponse.message ?? "",
                type: "fail");
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }

  _signInWithGoogle() async {
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));
    String fcmToken = await _getFcmToken() ?? "x";
    AuthUtil.signInWithGoogle().then((userCredential) {
      if (userCredential == null) {
        SmartDialog.dismiss();
        return;
      }
      String email = userCredential.user?.email ?? "";
      String name = userCredential.user?.displayName ??
          userCredential.user?.providerData[0].displayName ??
          "";
      String googleId = userCredential.user!.uid;
      ApiService.sso(
              email: email,
              name: name,
              googleId: googleId,
              appleId: null,
              fcmToken: fcmToken)
          .then((value) async {
        SmartDialog.dismiss();
        if (value.error == null) {
          UserResponse? apiResponse =
              ApiService.processResponse(value, context) as UserResponse?;
          if (apiResponse != null) {
            if (apiResponse.success == true) {
              PrefUtil().isLoggedIn = true;
              PrefUtil().rememberMe = true;
              PrefUtil().currentUser = apiResponse.data?.user;
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(baseRoute, (route) => false);
            } else {
              ToastUtils.showCustomSnackbar(
                  context: context,
                  contentText: apiResponse.message ?? "",
                  type: "fail");
            }
          }
        } else {
          ToastUtils.showCustomSnackbar(
              context: context, contentText: value.error ?? "", type: "fail");
        }
      });
    });
  }

  _signInWithApple() async {
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));
    String fcmToken = await _getFcmToken() ?? "x";
    AuthUtil.signInWithApple().then((appleUserCredential) {
      if (appleUserCredential == null) {
        SmartDialog.dismiss();
        return;
      }
      if (appleUserCredential.userCredential.user == null) {
        SmartDialog.dismiss();
        return;
      }
      String email = appleUserCredential.userCredential.user!.email ??
          appleUserCredential.email;
      String name = appleUserCredential.userCredential.user!.displayName ??
          appleUserCredential.fullName;
      String appleId = appleUserCredential.userCredential.user!.uid;
      ApiService.sso(
              email: email,
              name: name,
              googleId: null,
              appleId: appleId,
              fcmToken: fcmToken)
          .then((value) async {
        SmartDialog.dismiss();
        if (value.error == null) {
          UserResponse? apiResponse =
              ApiService.processResponse(value, context) as UserResponse?;
          if (apiResponse != null) {
            if (apiResponse.success == true) {
              PrefUtil().isLoggedIn = true;
              PrefUtil().rememberMe = true;
              PrefUtil().currentUser = apiResponse.data?.user;
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(baseRoute, (route) => false);
            } else {
              ToastUtils.showCustomSnackbar(
                  context: context,
                  contentText: apiResponse.message ?? "",
                  type: "fail");
            }
          }
        } else {
          ToastUtils.showCustomSnackbar(
              context: context, contentText: value.error ?? "", type: "fail");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => unfocusScreen(),
      child: Scaffold(
          body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Image.asset(
              'assets/images/signin_image.png',
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * .6,
              fit: BoxFit.cover,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20),
                child: Image.asset(
                  'assets/icons/ic_logo_black.png',
                  width: 95,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * .45),
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: ColorStyle.backgroundColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Login with email address',
                          textAlign: TextAlign.center,
                          style: TypeStyle.h1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      MTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: 'ic_mail',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      MTextField(
                        controller: _passwordController,
                        obscuretext: !_showPassword,
                        label: 'Password',
                        keyboardType: TextInputType.text,
                        icon: 'ic_lock',
                        trailing: IconButton(
                          onPressed: () {
                            setState(() => _showPassword = !_showPassword);
                          },
                          icon: SvgPicture.asset(
                            'assets/icons/ic_eye.svg',
                            color: _showPassword ? ColorStyle.whiteColor : null,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            visualDensity: VisualDensity.compact,
                            onChanged: (val) {
                              setState(() => _rememberMe = !_rememberMe);
                            },
                          ),
                          Expanded(
                            child: Text(
                              'Remember me',
                              style: TypeStyle.body,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context)
                                .pushNamed(forgotPasswordRoute),
                            child: Text(
                              'Forgot Password?',
                              style: TypeStyle.info,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: MRoundedButton(
                          'Login',
                          () => _signInWithEmail(),
                          isEnabled: _isValid,
                        ),
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () => Navigator.of(context)
                            .pushReplacementNamed(signupRoute),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don’t have an account? ',
                              style: TypeStyle.body,
                            ),
                            Text(
                              'Sign up',
                              style: TypeStyle.info,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      InkWell(
                        onTap: () => (),
                        child: IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: ColorStyle.borderColor,
                                ),
                              ),
                              Text(
                                '\t\tor continue with\t\t',
                                style: TypeStyle.body,
                              ),
                              const Expanded(
                                child: Divider(
                                  color: ColorStyle.borderColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => _signInWithGoogle(),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/ic_google.svg',
                                    height: 20,
                                    width: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Google ',
                                    style: TypeStyle.body,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: Platform.isIOS ? 10 : 0),
                          !Platform.isIOS
                              ? Container()
                              : Expanded(
                                  child: TextButton(
                                    onPressed: () => _signInWithApple(),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/ic_apple.svg',
                                          height: 20,
                                          width: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Apple',
                                          style: TypeStyle.body,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
