import 'package:bailey/api/delegate/api_service.dart';
import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/api/user/response/user_response.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/misc/misc.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
import 'package:bailey/widgets/inputs/text_field/m_text_field.dart';
import 'package:bailey/widgets/loading/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _showPassword = false;
  bool _agreeToTerms = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => _checkValidity());
    _emailController.addListener(() => _checkValidity());
    _passwordController.addListener(() => _checkValidity());
    _confirmPasswordController.addListener(() => _checkValidity());
  }

  _checkValidity() {
    _isValid = _emailController.text != "" &&
        _passwordController.text != "" &&
        _nameController.text != "" &&
        _confirmPasswordController.text != "" &&
        _agreeToTerms;
    setState(() {});
  }

  _signUpWithEmail() {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String cPassword = _confirmPasswordController.text;
    String fcmToken = 'x';
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));
    ApiService.signUp(
            email: email,
            password: password,
            fcmToken: fcmToken,
            confirmPassword: cPassword,
            name: name)
        .then((value) {
      SmartDialog.dismiss();
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
              'assets/images/signup_image.png',
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
                          'Create an account',
                          textAlign: TextAlign.center,
                          style: TypeStyle.h1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      MTextField(
                        controller: _nameController,
                        label: 'Name',
                        icon: 'ic_mail',
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 20),
                      MTextField(
                        controller: _emailController,
                        label: 'Email address',
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
                      const SizedBox(height: 20),
                      MTextField(
                        controller: _confirmPasswordController,
                        obscuretext: !_showPassword,
                        label: 'Repeat Password',
                        keyboardType: TextInputType.text,
                        icon: 'ic_lock_alt',
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
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            visualDensity: VisualDensity.compact,
                            onChanged: (val) {
                              _agreeToTerms = !_agreeToTerms;
                              _checkValidity();
                            },
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {},
                              child: Text.rich(
                                style: TypeStyle.body,
                                TextSpan(
                                  text:
                                      "By creating this account you are agree to our  ",
                                  children: [
                                    TextSpan(
                                      text: 'Terms and Conditions',
                                      style: TypeStyle.info.copyWith(
                                          decoration: TextDecoration.underline),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: MRoundedButton(
                          'Create an account',
                          () => _signUpWithEmail(),
                          isEnabled: _isValid,
                        ),
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () => Navigator.of(context)
                            .pushReplacementNamed(signinRoute),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?  ',
                              style: TypeStyle.body,
                            ),
                            Text(
                              'Log in',
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
                                '\t\tor\t\t',
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
                      InkWell(
                        onTap: () => (),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sign up with socials ',
                              style: TypeStyle.body,
                            ),
                            SvgPicture.asset(
                              'assets/icons/ic_next.svg',
                            ),
                          ],
                        ),
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
