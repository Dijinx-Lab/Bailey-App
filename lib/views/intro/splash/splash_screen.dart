import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
      Future.delayed(const Duration(milliseconds: 2000)).then((value) {
        Navigator.of(context).pushReplacementNamed(signinRoute);
      });
    }
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
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 50.0),
                child: Text(
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
