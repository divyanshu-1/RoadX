import 'package:cloud_firestore/cloud_firestore.dart';

// ── Result model ─────────────────────────────────────────────────────────────

/// Outcome of a license verification attempt during owner registration.
class LicenseVerificationResult {
  final bool success;
  final String? errorMessage;
  final Map<String, dynamic>? licenseData;

  const LicenseVerificationResult._({
    required this.success,
    this.errorMessage,
    this.licenseData,
  });

  factory LicenseVerificationResult.ok(Map<String, dynamic> data) =>
      LicenseVerificationResult._(success: true, licenseData: data);

  factory LicenseVerificationResult.fail(String message) =>
      LicenseVerificationResult._(success: false, errorMessage: message);
}

// ── Service ──────────────────────────────────────────────────────────────────

class LicenseService {
  LicenseService();
  static final LicenseService instance = LicenseService();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Verification (used during owner registration) ─────────────────────────

  /// Verifies license existence, active status, and name match against
  /// Firestore `licenses/{licenseNo}`.
  ///
  /// Returns a [LicenseVerificationResult] where [LicenseVerificationResult.success]
  /// is the boolean pass/fail value required by registration gates.
  ///
  /// Optional [aadhaar] is reserved for future License + Name + Aadhaar validation.
  Future<LicenseVerificationResult> verifyOwnerLicense({
    required String licenseNo,
    required String ownerName,
    String? aadhaar,
  }) async {
    final id = licenseNo.trim().toUpperCase();
    if (id.isEmpty) {
      return LicenseVerificationResult.fail('Invalid License Number');
    }

    try {
      final snap = await _db.collection('licenses').doc(id).get();

      if (!snap.exists || snap.data() == null) {
        return LicenseVerificationResult.fail('Invalid License Number');
      }

      final data = snap.data()!;

      final status = (data['status'] as String? ?? '').trim().toLowerCase();
      if (status != 'active') {
        return LicenseVerificationResult.fail('License is not active');
      }

      final recordName = (data['name'] as String? ?? '').trim().toLowerCase();
      final enteredName = ownerName.trim().toLowerCase();
      if (recordName != enteredName) {
        return LicenseVerificationResult.fail(
          'Name does not match license records',
        );
      }

      // Future: validate aadhaar against data['aadhaar'] when [aadhaar] is provided.
      // if (aadhaar != null && aadhaar.trim().isNotEmpty) { ... }

      return LicenseVerificationResult.ok(data);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return LicenseVerificationResult.fail(
          'Unable to verify license. Firestore rules must allow reading licenses during signup.',
        );
      }
      if (e.code == 'unavailable' || e.code == 'network-request-failed') {
        return LicenseVerificationResult.fail(
          'Network error. Please check your connection.',
        );
      }
      return LicenseVerificationResult.fail(
        'Firebase error: ${e.message ?? e.code}',
      );
    } catch (_) {
      return LicenseVerificationResult.fail(
        'Network error. Please check your connection.',
      );
    }
  }

  /// Convenience wrapper — returns `true` only when [verifyOwnerLicense] succeeds.
  Future<bool> isOwnerLicenseValid({
    required String licenseNo,
    required String ownerName,
    String? aadhaar,
  }) async {
    final result = await verifyOwnerLicense(
      licenseNo: licenseNo,
      ownerName: ownerName,
      aadhaar: aadhaar,
    );
    return result.success;
  }

  // ── Admin CRUD ────────────────────────────────────────────────────────────

  Stream<QuerySnapshot<Map<String, dynamic>>> streamLicenses() =>
      _db.collection('licenses').orderBy('licenseNo').snapshots();

  Future<void> addLicense(Map<String, dynamic> data) async {
    final id = (data['licenseNo'] as String? ?? '').trim().toUpperCase();
    if (id.isEmpty) throw Exception('License number is required');
    await _db.collection('licenses').doc(id).set({
      ...data,
      'licenseNo': id,
    });
  }

  Future<void> updateLicense(String licenseNo, Map<String, dynamic> data) =>
      _db
          .collection('licenses')
          .doc(licenseNo.trim().toUpperCase())
          .update(data);

  Future<void> deleteLicense(String licenseNo) =>
      _db
          .collection('licenses')
          .doc(licenseNo.trim().toUpperCase())
          .delete();

  // ── Seed ─────────────────────────────────────────────────────────────────

  /// Seeds sample licenses into Firestore (dev/testing only).
  Future<void> seedSampleLicenses() async {
    final samples = [
      {
        'licenseNo': 'MH100001',
        'name': 'Rahul Sharma',
        'aadhaar': '123456789012',
        'status': 'Active',
        'vehicleType': 'LMV',
        'issueDate': '2025-01-01',
        'expiryDate': '2045-01-01',
      },
      {
        'licenseNo': 'MH100002',
        'name': 'Priya Patel',
        'aadhaar': '987654321098',
        'status': 'Active',
        'vehicleType': 'LMV',
        'issueDate': '2024-06-01',
        'expiryDate': '2044-06-01',
      },
      {
        'licenseNo': 'MH100003',
        'name': 'Arjun Mehta',
        'aadhaar': '456789012345',
        'status': 'Expired',
        'vehicleType': 'HMV',
        'issueDate': '2015-03-15',
        'expiryDate': '2020-03-15',
      },
    ];

    final batch = _db.batch();
    for (final s in samples) {
      final id = s['licenseNo'] as String;
      final ref = _db.collection('licenses').doc(id);
      final snap = await ref.get();
      if (!snap.exists) batch.set(ref, s);
    }
    await batch.commit();
  }
}
