import 'package:bailey/firebase_options.dart';
import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/routes/navigator_routes.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PrefUtil().init();
  await dotenv.load(fileName: ".env");
  ColorStyle.setSystemStylePref();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bailey & Bailey',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      theme: ColorStyle.appTheme,
      initialRoute: initialRouteWithNoArgs,
      onGenerateRoute: NavigatorRoutes.allRoutes,
    );
  }
}
