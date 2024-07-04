import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/views/auth/change_password/change_password_screen.dart';
import 'package:bailey/views/auth/forgot_password/forgot_password_screen.dart';
import 'package:bailey/views/intro/onboarding/onboarding_screen.dart';
import 'package:bailey/views/auth/sign_in/sign_in_screen.dart';
import 'package:bailey/views/auth/sign_up/sign_up_screen.dart';
import 'package:bailey/views/intro/splash/splash_screen.dart';
import 'package:flutter/material.dart';

class NavigatorRoutes {
  static List<String> upTransitionRoutes = [];
  static List<String> fadeTransitionRoutes = [onboardingRoute];

  static Route<dynamic> allRoutes(RouteSettings settings) {
    Widget page = const SplashScreen();

    switch (settings.name) {
      case initialRouteWithNoArgs:
        page = const SplashScreen();
      case onboardingRoute:
        page = const OnboardingScreen();
      case signinRoute:
        page = const SignInScreen();
      case signupRoute:
        page = const SignUpScreen();
      case forgotPasswordRoute:
        page = const ForgotPasswordScreen();
      case changePasswordRoute:
        page = const ChangePasswordScreen();
    }

    if (upTransitionRoutes.contains(settings.name)) {
      return upTransition(page, settings);
    } else if (fadeTransitionRoutes.contains(settings.name)) {
      return fadeTransition(page, settings);
    } else {
      return MaterialPageRoute<dynamic>(
          settings: settings, builder: (_) => page);
    }
  }

  static upTransition(Widget page, RouteSettings routeSettings) {
    return PageRouteBuilder(
      settings: routeSettings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.decelerate;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static fadeTransition(Widget page, RouteSettings routeSettings) {
    return PageRouteBuilder(
      settings: routeSettings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = 0.0;
        var end = 1.0;
        var curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var opacityAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: opacityAnimation,
          child: child,
        );
      },
    );
  }
}
