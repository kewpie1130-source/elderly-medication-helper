import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError('目前測試請先用 Chrome Web 執行。');
      case TargetPlatform.iOS:
        throw UnsupportedError('目前測試請先用 Chrome Web 執行。');
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  // 💡 這裡先放一組完全成對、乾淨的預設虛擬字串，確保編譯器絕對不會卡住
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyFakeKey_ForTestingPurposeOnly_123456",
    authDomain: "elderly-medication-helper.firebaseapp.com",
    projectId: "elderly-medication-helper",
    storageBucket: "elderly-medication-helper.appspot.com",
    messagingSenderId: "1234567890",
    appId: "1:1234567890:web:abcdef1234567890",
    measurementId: "G-EXAMPLE123",
  );
}