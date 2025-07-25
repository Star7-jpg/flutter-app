// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBD3o37jLsjJwc5dkItanKGoe1Y3QsDAb0',
    appId: '1:946273216492:web:91b6ed0935759b89c642c9',
    messagingSenderId: '946273216492',
    projectId: 'aulas-app-d69a0',
    authDomain: 'aulas-app-d69a0.firebaseapp.com',
    storageBucket: 'aulas-app-d69a0.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCda10jAwhstB2nlVuik4Do1G1b-CeDgUI',
    appId: '1:946273216492:android:127aec3b1ec45212c642c9',
    messagingSenderId: '946273216492',
    projectId: 'aulas-app-d69a0',
    storageBucket: 'aulas-app-d69a0.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBD3o37jLsjJwc5dkItanKGoe1Y3QsDAb0',
    appId: '1:946273216492:web:10fd88187a288b44c642c9',
    messagingSenderId: '946273216492',
    projectId: 'aulas-app-d69a0',
    authDomain: 'aulas-app-d69a0.firebaseapp.com',
    storageBucket: 'aulas-app-d69a0.firebasestorage.app',
  );
}
