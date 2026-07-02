import 'package:firebase_database/firebase_database.dart';
import 'firebase_service.dart';

/// @deprecated Use [FirebaseService] directly.
class FirebaseDatabaseService {
  FirebaseDatabase get database => FirebaseService.database;
  DatabaseReference ref(String path) => FirebaseService.ref(path);
}
