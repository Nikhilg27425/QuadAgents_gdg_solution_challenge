import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAbiVusGebbTLOPd06Abmtdysmz1Hx5HIM',
    authDomain: 'ngo-connect-9fb62.firebaseapp.com',
    projectId: 'ngo-connect-9fb62',
    storageBucket: 'ngo-connect-9fb62.firebasestorage.app',
    messagingSenderId: '370226649583',
    appId: '1:370226649583:web:24a715b3925856a159be1a',
    measurementId: 'G-G0FN0TJBVW',
  );
}