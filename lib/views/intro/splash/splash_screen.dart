import 'package:bailey/keys/routes/route_keys.dart';
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
    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      Navigator.of(context).pushReplacementNamed(onboardingRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
