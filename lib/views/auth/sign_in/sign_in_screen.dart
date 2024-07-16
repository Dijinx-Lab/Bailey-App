import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/misc/misc.dart';
import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
import 'package:bailey/widgets/inputs/text_field/m_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
  }

  _signInWithEmail() {
    String email = _emailController.text;
    String password = _passwordController.text;

    
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
                          () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                baseRoute, (route) => false);
                          },
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
                              'Login with socials ',
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
