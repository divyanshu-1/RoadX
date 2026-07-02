import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyCWImTEOp-3uC3prIHswk_brvtNE05DCS8',
      appId: '1:726016739872:android:fe50a7bcb7da10b02e0a45',
      messagingSenderId: '726016739872',
      projectId: 'mainroadx',
      storageBucket: 'mainroadx.firebasestorage.app',
      // Realtime Database URL from google-services.json
      databaseURL: 'https://mainroadx-default-rtdb.firebaseio.com',
    );
  }
}
