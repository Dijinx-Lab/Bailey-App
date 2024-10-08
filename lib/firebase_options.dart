// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA0tjgYv8rSDTRy1-OhYHJlCeX_5elYBZw',
    appId: '1:75617206819:android:5a69e29322555d874d6796',
    messagingSenderId: '75617206819',
    projectId: 'mobile-print-capture-app',
    storageBucket: 'mobile-print-capture-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAG9AtqG9R2Q0EUJsJvBX5MZgVcAl2d4A0',
    appId: '1:75617206819:ios:24d3170c36ed35a94d6796',
    messagingSenderId: '75617206819',
    projectId: 'mobile-print-capture-app',
    storageBucket: 'mobile-print-capture-app.appspot.com',
    androidClientId: '75617206819-n5elmo8kh10aeiq5tm0j701qntvv646n.apps.googleusercontent.com',
    iosClientId: '75617206819-skbhfj2topemqul0kaihb06gi733cano.apps.googleusercontent.com',
    iosBundleId: 'com.dijinx.bailey',
  );
}
