import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/routes/navigator_routes.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefUtil().init();
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
