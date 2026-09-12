import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDclSHFXiYYRHFjOyrnx0tUcohplZuT6aM',
    appId: '1:325688722848:web:99c8bea11558bf40f1d0c5',
    messagingSenderId: '325688722848',
    projectId: 'office-app-dc801',
    storageBucket: 'office-app-dc801.firebasestorage.app',
    authDomain: 'office-app-dc801.firebaseapp.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDclSHFXiYYRHFjOyrnx0tUcohplZuT6aM',
    appId: '1:325688722848:android:99c8bea11558bf40f1d0c5',
    messagingSenderId: '325688722848',
    projectId: 'office-app-dc801',
    storageBucket: 'office-app-dc801.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDclSHFXiYYRHFjOyrnx0tUcohplZuT6aM',
    appId: '1:325688722848:ios:99c8bea11558bf40f1d0c5',
    messagingSenderId: '325688722848',
    projectId: 'office-app-dc801',
    storageBucket: 'office-app-dc801.firebasestorage.app',
    iosBundleId: 'com.example.office_app',
  );
}
