// File generated manually based on user provided config
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  // Using the provided config for all platforms for now as a fallback,
  // but ideally Android/iOS should have their own specific App IDs.
  // The user provided config looks like a Web config but contains general project info.
  
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAkVkAVCI8s3ecDE4biV4-dmuWsxe8oRj0',
    appId: '1:610220821727:web:c135c299761ba776cc6d6a',
    messagingSenderId: '610220821727',
    projectId: 'kayabsuk',
    authDomain: 'kayabsuk.firebaseapp.com',
    storageBucket: 'kayabsuk.firebasestorage.app',
  );

  // We will use the same config for Android/iOS temporarily if specific ones aren't provided,
  // knowing that some features (like Analytics/Crashlytics) might complain, but Firestore details are the same.
  // HOWEVER, for android/iOS, the appId is crucial. 
  // Since we don't have the explicit Android App ID for "kayabsuk", 
  // we will try to use the keys provided. 
  
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAkVkAVCI8s3ecDE4biV4-dmuWsxe8oRj0',
    appId: '1:610220821727:web:c135c299761ba776cc6d6a', // WARNING: This is a Web App ID, might fail on Android
    messagingSenderId: '610220821727',
    projectId: 'kayabsuk',
    storageBucket: 'kayabsuk.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAkVkAVCI8s3ecDE4biV4-dmuWsxe8oRj0',
    appId: '1:610220821727:web:c135c299761ba776cc6d6a', // WARNING: This is a Web App ID, might fail on iOS
    messagingSenderId: '610220821727',
    projectId: 'kayabsuk',
    storageBucket: 'kayabsuk.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAkVkAVCI8s3ecDE4biV4-dmuWsxe8oRj0',
    appId: '1:610220821727:web:c135c299761ba776cc6d6a', // WARNING: This is a Web App ID
    messagingSenderId: '610220821727',
    projectId: 'kayabsuk',
    storageBucket: 'kayabsuk.firebasestorage.app',
  );
}
