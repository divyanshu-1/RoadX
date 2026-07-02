import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/owner_model.dart';
import 'access_log_service.dart';

class FirebaseOwnerService {
  FirebaseOwnerService();
  static final FirebaseOwnerService instance = FirebaseOwnerService();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;

  bool isOwnerLoggedIn() => _auth.currentUser != null;

  /// True when a real owner account is signed in (not RTO anonymous session).
  bool isOwnerAccountLoggedIn() {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return false;
    return true;
  }

  Future<OwnerModel?> getCurrentOwner() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || _auth.currentUser!.isAnonymous) return null;
    return fetchOwner(uid);
  }

  Future<OwnerModel?> fetchOwner(String uid) async {
    final snap = await _rtdb.ref('owners/$uid').get();
    if (!snap.exists || snap.value == null) return null;
    return OwnerModel.fromMap(uid, snap.value as Map<dynamic, dynamic>);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  String authErrorMessage(FirebaseAuthException e) =>
      _authErrorMessage(e.code);

  Future<UserCredential> registerOwner({
    String? fullName,
    String? ownerName,
    required String email,
    required String password,
    required String licenseNo,
    String? phone,
    String? aadhaar,
    String? address,
    String? authUserName,
    String? authUserPhone,
    String? authUserCardId,
    String? authUserRelation,
    String? licenseImageUrl,
  }) async {
    final name = (fullName ?? ownerName ?? '').trim();
    if (name.isEmpty) throw Exception('Owner name is required');

    late UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }

    final uid = credential.user!.uid;

    try {
      final ownerProfile = <String, dynamic>{
        'uid': uid,
        'ownerName': name,
        'fullName': name,
        'licenseNo': licenseNo.trim().toUpperCase(),
        'email': email.trim(),
        'phone': (phone ?? '').trim(),
        'aadhaar': (aadhaar ?? '').trim(),
        'address': (address ?? '').trim(),
        'role': 'owner',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (licenseImageUrl != null && licenseImageUrl.trim().isNotEmpty) {
        ownerProfile['licenseImageUrl'] = licenseImageUrl.trim();
      }

      if (authUserName != null && authUserName.trim().isNotEmpty) {
        ownerProfile['authorizedUser'] = {
          'name': authUserName.trim(),
          'phone': (authUserPhone ?? '').trim(),
          'cardId': (authUserCardId ?? '').trim(),
          'relation': (authUserRelation ?? '').trim(),
        };
      }

      await _rtdb.ref('owners/$uid').set(ownerProfile);
      await _rtdb.ref('users/$uid').set({
        'uid': uid,
        'email': email.trim(),
        'role': 'owner',
      });
    } catch (e) {
      try {
        await credential.user?.delete();
      } catch (_) {}
      if (e is FirebaseException) {
        throw Exception(
          'Account created but profile save failed: ${e.message ?? e.code}',
        );
      }
      rethrow;
    }

    return credential;
  }

  Future<UserCredential> signupOwner({
    required String fullName,
    required String email,
    required String mobile,
    required String licenseNo,
    required String password,
  }) =>
      registerOwner(
        fullName: fullName,
        email: email,
        password: password,
        licenseNo: licenseNo,
        phone: mobile,
      );

  Future<OwnerModel?> loginOwner({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signOut();
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) return null;
      return fetchOwner(uid);
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e.code));
    }
  }

  Stream<OwnerModel?> watchOwner(String uid) =>
      _rtdb.ref('owners/$uid').onValue.map((event) {
        final value = event.snapshot.value;
        if (value == null || value is! Map) return null;
        return OwnerModel.fromMap(uid, value);
      });

  Future<bool> isVehicleRegistered(String vehicleNo) async {
    final normalized = vehicleNo.trim().toUpperCase();
    final snap = await _rtdb.ref('vehicles/$normalized').get();
    return snap.exists;
  }

  /// Migrates legacy profile-level vehicle into `owners/{uid}/vehicles`.
  Future<void> ensureLegacyVehicleMigrated(String uid) async {
    final ownerSnap = await _rtdb.ref('owners/$uid').get();
    if (!ownerSnap.exists || ownerSnap.value is! Map) return;

    final data = ownerSnap.value as Map;
    final legacyPlate = data['vehicleNumber']?.toString().trim().toUpperCase() ?? '';
    if (legacyPlate.isEmpty) return;

    final vehiclesSnap = await _rtdb.ref('owners/$uid/vehicles').get();
    final hasSubVehicles =
        vehiclesSnap.exists && vehiclesSnap.value is Map && (vehiclesSnap.value as Map).isNotEmpty;

    if (hasSubVehicles) return;

    final ref = _rtdb.ref('owners/$uid/vehicles').push();
    await ref.set({
      'vehicleNo': legacyPlate,
      'vehicleType': data['vehicleType']?.toString() ?? 'Other',
      'rcNumber': data['rcNumber']?.toString() ?? '',
      'addedAt': DateTime.now().millisecondsSinceEpoch,
    });
    await _rtdb.ref('vehicles/$legacyPlate').set({
      'ownerUid': uid,
      'vehicleNo': legacyPlate,
      'vehicleType': data['vehicleType']?.toString() ?? 'Other',
      'rcNumber': data['rcNumber']?.toString() ?? '',
    });
  }

  Future<void> addVehicleForOwner({
    required String uid,
    required String vehicleNo,
    required String vehicleType,
    required String rcNumber,
  }) async {
    final normalized = vehicleNo.trim().toUpperCase();
    if (await isVehicleRegistered(normalized)) {
      throw Exception('Vehicle already registered');
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final accessLog = AccessLogService();
    final ref = _rtdb.ref('owners/$uid/vehicles').push();
    await ref.set({
      'vehicleNo': normalized,
      'vehicleType': vehicleType.trim(),
      'rcNumber': rcNumber.trim(),
      'addedAt': now,
    });
    await _rtdb.ref('vehicles/$normalized').set({
      'ownerUid': uid,
      'vehicleNo': normalized,
      'vehicleType': vehicleType.trim(),
      'rcNumber': rcNumber.trim(),
    });

    await accessLog.logEvent(
      ownerUid: uid,
      vehicleNumber: normalized,
      driverName: 'Owner',
      action: 'Vehicle registered',
      detail: '$vehicleType • RC $rcNumber',
      status: 'Registered',
    );
  }

  Future<void> updateOwnerProfile({
    required String uid,
    required String ownerName,
    required String phone,
    required String aadhaar,
    required String address,
  }) async {
    await _rtdb.ref('owners/$uid').update({
      'ownerName': ownerName.trim(),
      'phone': phone.trim(),
      'aadhaar': aadhaar.trim(),
      'address': address.trim(),
    });
  }

  Future<void> updateVehicleDetails({
    required String uid,
    required String vehicleId,
    required String vehicleNo,
    required String vehicleType,
    required String rcNumber,
  }) async {
    final plate = vehicleNo.trim().toUpperCase();
    await _rtdb.ref('owners/$uid/vehicles/$vehicleId').update({
      'vehicleType': vehicleType.trim(),
      'rcNumber': rcNumber.trim(),
    });
    await _rtdb.ref('vehicles/$plate').update({
      'vehicleType': vehicleType.trim(),
      'rcNumber': rcNumber.trim(),
    });
  }

  /// Upload license image to Storage and save URL under `owners/{uid}/licenseImageUrl`.
  Future<String> uploadLicenseImage({
    required String uid,
    required File imageFile,
  }) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('owners')
          .child(uid)
          .child('license.jpg');

      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();

      await _rtdb.ref('owners/$uid').update({
        'licenseImageUrl': downloadUrl,
      });

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception(
        'License image upload failed: ${e.message ?? e.code}',
      );
    } catch (e) {
      throw Exception('License image upload failed: $e');
    }
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Sign-in method not enabled. Enable Email/Password or Anonymous Auth in Firebase Console.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed ($code). Please try again.';
    }
  }
}
