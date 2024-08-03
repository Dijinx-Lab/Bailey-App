import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/args/change_password/change_password_args.dart';
import 'package:bailey/models/args/pick_finger/pick_finger_args.dart';
import 'package:bailey/models/args/pick_hand/pick_hand_args.dart';
import 'package:bailey/models/args/preview_image/preview_image_args.dart';
import 'package:bailey/models/args/process_print/process_print_args.dart';
import 'package:bailey/views/auth/change_password/change_password_screen.dart';
import 'package:bailey/views/auth/forgot_password/forgot_password_screen.dart';
import 'package:bailey/views/base/base_screen.dart';
import 'package:bailey/views/fingerprint/process_print/process_print_screen.dart';
import 'package:bailey/views/fingerprint/tips/tips_screen.dart';
import 'package:bailey/views/fingerprint/view_prints/view_prints_screen.dart';
import 'package:bailey/views/handwriting/handwriting_screen.dart';
import 'package:bailey/views/intro/onboarding/onboarding_screen.dart';
import 'package:bailey/views/auth/sign_in/sign_in_screen.dart';
import 'package:bailey/views/auth/sign_up/sign_up_screen.dart';
import 'package:bailey/views/intro/splash/splash_screen.dart';
import 'package:bailey/views/fingerprint/pick_finger/pick_finger_screen.dart';
import 'package:bailey/views/fingerprint/pick_hand/pick_hand_screen.dart';
import 'package:bailey/views/photo/photo_screen.dart';
import 'package:bailey/views/preview_image/preview_image_screen.dart';
import 'package:bailey/views/success/successful_scan_screen.dart';
import 'package:flutter/material.dart';

class NavigatorRoutes {
  static List<String> upTransitionRoutes = [tipsRoute];
  static List<String> fadeTransitionRoutes = [
    onboardingRoute,
    previewImageRoute
  ];

  static Route<dynamic> allRoutes(RouteSettings settings) {
    Widget page = _getPageForRoute(settings.name, settings.arguments);

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
        page = ChangePasswordScreen(
          arguments: settings.arguments as ChangePasswordArgs,
        );
      case baseRoute:
        page = const BaseScreen();
      case pickHandRoute:
        page = PickHandScreen(
          arguments: settings.arguments as PickHandArgs,
        );
      case pickFingerRoute:
        page = PickFingerScreen(
          arguments: settings.arguments as PickFingerArgs,
        );
      case processPrintRoute:
        page = ProcessPrintScreen(
          arguments: settings.arguments as ProcessPrintArgs,
        );
      case successRoute:
        page = const SuccessfulScanScreen();
      case viewPrintsRoute:
        page = const ViewPrintsScreen();
      case photosRoute:
        page = const PhotoScreen();
      case handwritingsRoute:
        page = const HandwritingScreen();
      case tipsRoute:
        page = const TipsScreen();
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

  static Widget _getPageForRoute(String? routeName, Object? arguments) {
    switch (routeName) {
      case initialRouteWithNoArgs:
        return const SplashScreen();
      case onboardingRoute:
        return const OnboardingScreen();
      case signinRoute:
        return const SignInScreen();
      case signupRoute:
        return const SignUpScreen();
      case forgotPasswordRoute:
        return const ForgotPasswordScreen();
      case changePasswordRoute:
        return ChangePasswordScreen(arguments: arguments as ChangePasswordArgs);
      case baseRoute:
        return const BaseScreen();
      case pickHandRoute:
        return PickHandScreen(arguments: arguments as PickHandArgs);
      case pickFingerRoute:
        return PickFingerScreen(arguments: arguments as PickFingerArgs);
      case processPrintRoute:
        return ProcessPrintScreen(arguments: arguments as ProcessPrintArgs);
      case successRoute:
        return const SuccessfulScanScreen();
      case viewPrintsRoute:
        return const ViewPrintsScreen();
      case photosRoute:
        return const PhotoScreen();
      case handwritingsRoute:
        return const HandwritingScreen();
      case tipsRoute:
        return const TipsScreen();
      case previewImageRoute:
        return PreviewImageScreen(arguments: arguments as PreviewImageArgs);
      default:
        return const SplashScreen();
    }
  }

  static upTransition(Widget page, RouteSettings routeSettings) {
    return PageRouteBuilder(
      settings: routeSettings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.easeInOut;
        var slideTween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var fadeTween =
            Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
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
