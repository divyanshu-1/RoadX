import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_constants.dart';

/// Central Firebase Realtime Database access and safe parsing helpers.
class FirebaseService {
  static FirebaseDatabase? _database;

  /// Call once after [Firebase.initializeApp] in main.dart.
  static Future<void> initialize() async {
    _database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: AppConstants.rtdbUrl,
    );
    if (kDebugMode) {
      _database!.setLoggingEnabled(true);
    }
  }

  static FirebaseDatabase get database {
    if (_database == null) {
      throw StateError(
        'FirebaseService not initialized. Call FirebaseService.initialize() in main().',
      );
    }
    return _database!;
  }

  static DatabaseReference ref([String? path]) {
    if (path == null || path.isEmpty) return database.ref();
    return database.ref(path);
  }

  /// Normalize plate: uppercase, no spaces.
  static String normalizePlate(String plate) {
    return plate.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
  }

  /// Safely parse RTDB snapshot as `Map<String, dynamic>`.
  static Map<String, dynamic>? snapshotToMap(DataSnapshot snapshot) {
    if (!snapshot.exists || snapshot.value == null) return null;
    final value = snapshot.value;
    if (value is! Map) return null;
    return value.map(
      (key, val) => MapEntry(key.toString(), val),
    );
  }

  /// Parse children under a list node (e.g. owners/, challans/).
  static List<T> parseChildren<T>(
    DataSnapshot snapshot,
    T? Function(String key, Map<dynamic, dynamic> data) mapChild,
  ) {
    final raw = snapshotToMap(snapshot);
    if (raw == null) return [];
    final results = <T>[];
    for (final entry in raw.entries) {
      final child = entry.value;
      if (child is Map) {
        final mapped = mapChild(entry.key, child);
        if (mapped != null) results.add(mapped);
      }
    }
    return results;
  }

  static String friendlyError(Object error) {
    if (error is FirebaseException) {
      return error.message ?? 'Firebase error: ${error.code}';
    }
    final text = error.toString();
    if (text.contains('Permission denied')) {
      return 'Permission denied. Sign in and publish Realtime Database rules that allow authenticated reads on owners/ and challans/.';
    }
    return text.replaceFirst('Exception: ', '').split('\n').first;
  }
}
