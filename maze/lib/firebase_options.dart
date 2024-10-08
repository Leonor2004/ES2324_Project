// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
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
  static final FirebaseOptions web = FirebaseOptions(
    apiKey: dotenv.env['WEB_API_KEY'] ?? 'default',
    appId: dotenv.env['WEB_APP_ID'] ?? 'default',
    messagingSenderId: dotenv.env['MESSAGE_SENDER_ID'] ?? 'default',
    projectId: dotenv.env['PROJECT_ID'] ?? 'default',
    authDomain: dotenv.env['AUTHDOMAIN'] ?? 'default',
    storageBucket: dotenv.env['STORAGE_BUCKET'] ?? 'default',
    databaseURL: dotenv.env['DATABASE_URL'] ?? 'default'
  );

  static final FirebaseOptions android = FirebaseOptions(
    apiKey: dotenv.env['ANDROID_API_KEY'] ?? 'default',
    appId: dotenv.env['ANDROID_APP_ID'] ?? 'default',
    messagingSenderId: dotenv.env['MESSAGE_SENDER_ID'] ?? 'default',
    projectId: dotenv.env['PROJECT_ID'] ?? 'default',
    storageBucket: dotenv.env['STORAGE_BUCKET'] ?? 'default',
    databaseURL: dotenv.env['DATABASE_URL'] ?? 'default'
  );

  static final FirebaseOptions ios = FirebaseOptions(
    apiKey: dotenv.env['IOS_API_KEY'] ?? 'default',
    appId: dotenv.env['IOS_APP_ID'] ?? 'default',
    messagingSenderId: dotenv.env['MESSAGE_SENDER_ID'] ?? 'default',
    projectId: dotenv.env['PROJECT_ID'] ?? 'default',
    storageBucket: dotenv.env['STORAGE_BUCKET'] ?? 'default',
    iosBundleId: dotenv.env['IOS_BUNDLE_ID'] ?? 'default',
  );

  static final FirebaseOptions macos = FirebaseOptions(
    apiKey: dotenv.env['MACOS_API_KEY'] ?? 'default',
    appId: dotenv.env['MACOS_APP_ID'] ?? 'default',
    messagingSenderId: dotenv.env['MESSAGE_SENDER_ID'] ?? 'default',
    projectId: dotenv.env['PROJECT_ID'] ?? 'default',
    storageBucket: dotenv.env['STORAGE_BUCKET'] ?? 'default',
    iosBundleId: dotenv.env['MACOS_BUNDLE_ID'] ?? 'default',
  );
}
