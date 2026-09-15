import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCnMd6crxxIWxygL7B2nll5M8TeqfB8ZzY',
    appId: '1:834165535660:web:d41e5af7d820377b334009',
    messagingSenderId: '834165535660',
    projectId: 'clearmoney-a55a0',
    authDomain: 'clearmoney-a55a0.firebaseapp.com',
    storageBucket: 'clearmoney-a55a0.firebasestorage.app',
  );
}