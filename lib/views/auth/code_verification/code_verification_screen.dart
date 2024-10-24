import 'package:bailey/api/delegate/api_service.dart';
import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/api/generic/generic_response.dart';
import 'package:bailey/models/api/user/response/user_response.dart';
import 'package:bailey/models/args/change_password/change_password_args.dart';
import 'package:bailey/models/args/code/code_args.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/auth/auth_util.dart';
import 'package:bailey/utility/misc/misc.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
import 'package:bailey/widgets/loading/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:pinput/pinput.dart';

class CodeVerificationScreen extends StatefulWidget {
  final CodeArgs args;
  const CodeVerificationScreen({super.key, required this.args});

  @override
  State<CodeVerificationScreen> createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _animation;
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool showPinError = false;
  final int _time = 120;
  String _formattedTime = '';
  bool valid = false;

  @override
  void initState() {
    _startTimer();
    super.initState();
    _pinController.addListener(() => _checkValidity());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  _checkValidity() {
    valid = _pinController.text != "";
    setState(() {});
  }

  void _startTimer() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _time),
    );

    _animation = StepTween(
      begin: _time,
      end: 0,
    ).animate(_animationController)
      ..addListener(() {
        int currentSeconds = _animation.value;

        DateTime dateTime = DateTime(0, 0, 0, 0, 0, currentSeconds);

        setState(() {
          _formattedTime = DateFormat('mm:ss').format(dateTime);
        });
      });

    _animationController.forward(); // Start the countdown
  }

  void _restartTimer() {
    if (_animation.value == 0) {
      _sendVerification();
      _animationController.reset();
      _animationController.forward();
    }
  }

  _sendVerification() async {
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));

      ApiService.sendVerificationCode(
        email: widget.args.email,
        type: widget.args.forPassword ? "password" : "email",
      ).then((value) {
        SmartDialog.dismiss();
        GenericResponse? apiResponse =
            ApiService.processResponse(value, context) as GenericResponse?;

        if (apiResponse != null) {
          if (apiResponse.success == true) {
            ToastUtils.showCustomSnackbar(
                context: context, contentText: "Email resent", type: "success");
          } else {
            ToastUtils.showCustomSnackbar(
                context: context,
                contentText: apiResponse.message ?? "",
                type: "fail");
          }
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _checkVerification() async {
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));

      ApiService.verifyCode(
        email: widget.args.email,
        type: widget.args.forPassword ? "password" : "email",
        code: _pinController.text.trim(),
      ).then((value) {
        GenericResponse? apiResponse =
            ApiService.processResponse(value, context) as GenericResponse?;
        if (apiResponse != null) {
          if (apiResponse.success == true) {
            if (widget.args.forPassword) {
              SmartDialog.dismiss();
              Navigator.of(context).pushNamed(
                changePasswordRoute,
                arguments: ChangePasswordArgs(
                  action: 'forgot_pass',
                  email: widget.args.email,
                ),
              );
            } else {
              _getAccountDetails();
            }
          } else {
            SmartDialog.dismiss();
            setState(() {
              showPinError = true;
            });
          }
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _getAccountDetails() {
    ApiService.userDetail().then((value) async {
      UserResponse? apiResponse =
          ApiService.processResponse(value, context) as UserResponse?;
      SmartDialog.dismiss();
      if (apiResponse != null) {
        if (apiResponse.success == true) {
          PrefUtil().currentUser = apiResponse.data?.user;
          if (PrefUtil().currentUser?.companyName == null ||
              PrefUtil().currentUser?.companyName == "") {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(companyDetailRoute, (route) => false);
          } else {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(newSessionRoute, (route) => false);
          }
        } else {
          ToastUtils.showCustomSnackbar(
              context: context,
              contentText: apiResponse.message ?? "",
              type: "fail");
        }
      }
    });
  }

  _signOut() async {
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));
    if (PrefUtil().currentUser?.googleId != null ||
        PrefUtil().currentUser?.googleId != '') {
      await AuthUtil.signOut();
    }

    ApiService.signOut().then((value) {
      SmartDialog.dismiss();
      GenericResponse? apiResponse =
          ApiService.processResponse(value, context) as GenericResponse?;
      if (apiResponse != null) {
        if (apiResponse.success == true) {
          PrefUtil().isLoggedIn = false;
          PrefUtil().rememberMe = false;
          PrefUtil().currentUser = null;

          Navigator.of(context)
              .pushNamedAndRemoveUntil(signinRoute, (route) => false);
        } else {
          ToastUtils.showCustomSnackbar(
              context: context,
              contentText: apiResponse.message ?? "",
              type: "fail");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => unfocusScreen(),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          _signOut();
                        }
                      },
                      visualDensity: VisualDensity.compact,
                      icon: Navigator.of(context).canPop()
                          ? SvgPicture.asset('assets/icons/ic_chevron_back.svg')
                          : SvgPicture.asset(
                              'assets/icons/ic_logout.svg',
                              color: ColorStyle.whiteColor,
                              height: 25,
                            ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Verify Code',
                          style: TypeStyle.h2,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 40,
                    )
                  ],
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: Durations.medium1,
                  width: MediaQuery.of(context).viewInsets.bottom > 0
                      ? 50
                      : (MediaQuery.of(context).size.width / 2),
                  child: Image.asset(
                    'assets/images/forgotpass_image.png',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Verify Your Email',
                  style: TypeStyle.h1,
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    'Please check your email for a code, if you do not see our email please check your spam folder',
                    textAlign: TextAlign.center,
                    style: TypeStyle.body,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Pinput(
                  length: 4,
                  controller: _pinController,
                  focusNode: _focusNode,
                  autofocus: true,
                  errorText: "Invalid Code",
                  keyboardType: TextInputType.number,
                  forceErrorState: showPinError,
                  pinAnimationType: PinAnimationType.scale,
                  defaultPinTheme: _getPinTheme().copyWith(
                      decoration: BoxDecoration(
                    color: ColorStyle.backgroundColor,
                    border: Border.all(color: ColorStyle.secondaryTextColor),
                    borderRadius: BorderRadius.circular(6),
                  )),
                  focusedPinTheme: _getPinTheme().copyWith(
                      decoration: BoxDecoration(
                        color: ColorStyle.backgroundColor,
                        border: Border.all(color: ColorStyle.whiteColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      textStyle: const TextStyle(
                          color: ColorStyle.primaryTextColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  submittedPinTheme: _getPinTheme().copyWith(
                      decoration: BoxDecoration(
                        color: ColorStyle.secondaryTextColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: ColorStyle.blackColor),
                      ),
                      textStyle: const TextStyle(
                          color: ColorStyle.primaryTextColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  errorPinTheme: _getPinTheme().copyWith(
                      decoration: BoxDecoration(
                        color: ColorStyle.backgroundColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: ColorStyle.red100Color),
                      ),
                      textStyle: const TextStyle(
                          color: ColorStyle.red100Color,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  onChanged: (value) {},
                  onTap: () {
                    setState(() {
                      showPinError = false;
                    });
                  },
                  onCompleted: (value) {
                    if (_pinController.text == "1234") {
                      setState(() {
                        showPinError = true;
                      });
                    }
                  },
                  showCursor: true,
                  cursor: cursor,
                ),
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      _restartTimer();
                    },
                    child: Text.rich(
                      TextSpan(
                          text: "Didn't get an email? ",
                          style: TypeStyle.body,
                          children: [
                            TextSpan(
                                text: _animation.value == 0
                                    ? "Resend Code"
                                    : "Resend in $_formattedTime",
                                style: TypeStyle.h3)
                          ]),
                      textScaler: MediaQuery.of(context).textScaler,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: MRoundedButton(
                    'Verify',
                    () => _checkVerification(),
                    isEnabled: valid,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _getPinTheme() {
    return PinTheme(
      width: 70,
      height: 65,
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width >= 360 ? 8 : 4),
      textStyle: const TextStyle(
          color: Color.fromRGBO(70, 69, 66, 1),
          fontSize: 30,
          fontWeight: FontWeight.w400),
    );
  }

  final cursor = Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      width: 21,
      height: 1,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(137, 146, 160, 1),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
