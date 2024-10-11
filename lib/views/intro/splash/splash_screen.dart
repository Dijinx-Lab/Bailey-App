import 'package:bailey/api/delegate/api_service.dart';
import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/api/user/response/user_response.dart';
import 'package:bailey/models/args/code/code_args.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _errorOccured = false;

  @override
  void initState() {
    _moveToFullScreen();
    _moveToNextScreen();
    super.initState();
  }

  @override
  void dispose() {
    _exitFullScreen();
    super.dispose();
  }

  _moveToFullScreen() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  _exitFullScreen() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  _moveToNextScreen() {
    if (!PrefUtil().isOnboarded) {
      Future.delayed(const Duration(milliseconds: 2000)).then((value) {
        Navigator.of(context).pushReplacementNamed(onboardingRoute);
      });
    } else {
      if (PrefUtil().isLoggedIn) {
        if (PrefUtil().rememberMe) {
          _getAccountDetails();
        } else {
          PrefUtil().isLoggedIn = false;
          PrefUtil().currentUser = null;
          Future.delayed(const Duration(milliseconds: 2000)).then((value) {
            Navigator.of(context).pushReplacementNamed(signinRoute);
          });
        }
      } else {
        Future.delayed(const Duration(milliseconds: 2000)).then((value) {
          Navigator.of(context).pushReplacementNamed(signinRoute);
        });
      }
    }
  }

  _getAccountDetails() {
    ApiService.userDetail().then((value) async {
      UserResponse? apiResponse =
          ApiService.processResponse(value, context) as UserResponse?;
      if (apiResponse != null) {
        if (apiResponse.success == true) {
          PrefUtil().currentUser = apiResponse.data?.user;
          if (PrefUtil().currentUser?.emailVerifiedOn == null) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              verifyCodeRoute,
              arguments: CodeArgs(
                email: PrefUtil().currentUser!.email!,
                code: null,
                forPassword: false,
              ),
              (e) => false,
            );
          } else if (PrefUtil().currentUser?.companyName == null ||
              PrefUtil().currentUser?.companyName == "") {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(companyDetailRoute, (route) => false);
          } else {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(newSessionRoute, (route) => false);
          }
        } else {
          setState(() {
            _errorOccured = true;
          });

          ToastUtils.showCustomSnackbar(
              context: context,
              contentText: apiResponse.message ?? "",
              type: "fail");
        }
      } else {
        if (mounted) {
          await Future.delayed(Durations.medium1);
          setState(() {
            _errorOccured = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyle.blackColor,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: Image.asset(
                  'assets/icons/ic_logo_white.png',
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:
                    const EdgeInsets.only(bottom: 50.0, right: 30, left: 30),
                child: _errorOccured
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: MRoundedButton(
                              'Refresh',
                              () => _getAccountDetails(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                              "There was an error connecting to our server, please check your connection and try again",
                              textAlign: TextAlign.center,
                              style: TypeStyle.h3),
                        ],
                      )
                    : const Text(
                        "Powered By  |  D I J I N X",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: ColorStyle.secondaryTextColor,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
