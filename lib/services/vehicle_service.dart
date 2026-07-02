import 'package:firebase_database/firebase_database.dart';
import '../models/owner_model.dart';
import 'firebase_service.dart';

/// Vehicle / owner data from Realtime Database.
class VehicleService {
  DatabaseReference get _ownersRef => FirebaseService.ref('owners');
  DatabaseReference get _vehiclesIndexRef => FirebaseService.ref('vehicles');

  Stream<List<OwnerModel>> watchOwners() {
    return _ownersRef.onValue.map((event) {
      return FirebaseService.parseChildren<OwnerModel>(
        event.snapshot,
        (key, data) => OwnerModel.fromMap(key, data),
      );
    });
  }

  Future<List<OwnerModel>> fetchOwnersOnce() async {
    try {
      final snapshot = await _ownersRef.get();
      return FirebaseService.parseChildren<OwnerModel>(
        snapshot,
        (key, data) => OwnerModel.fromMap(key, data),
      );
    } catch (e) {
      throw Exception(FirebaseService.friendlyError(e));
    }
  }

  OwnerModel? findByVehicleNumber(
    List<OwnerModel> owners,
    String vehicleNumber,
  ) {
    final plate = FirebaseService.normalizePlate(vehicleNumber);
    if (plate.isEmpty) return null;
    for (final owner in owners) {
      if (FirebaseService.normalizePlate(owner.vehicleNumber) == plate) {
        return owner;
      }
    }
    return null;
  }

  Future<OwnerModel?> findByVehicleNumberFromDb(String vehicleNumber) async {
    final plate = FirebaseService.normalizePlate(vehicleNumber);
    if (plate.isEmpty) return null;

    try {
      final indexSnap = await _vehiclesIndexRef.child(plate).get();
      if (indexSnap.exists && indexSnap.value is Map) {
        final data = indexSnap.value as Map;
        final ownerUid = data['ownerUid']?.toString();
        if (ownerUid != null && ownerUid.isNotEmpty) {
          final ownerSnap = await _ownersRef.child(ownerUid).get();
          if (ownerSnap.exists && ownerSnap.value is Map) {
            final owner = OwnerModel.fromMap(
              ownerUid,
              ownerSnap.value as Map<dynamic, dynamic>,
            );
            return owner.copyWith(vehicleNumber: plate);
          }
        }
      }
    } catch (_) {
      // Fall through to owners scan.
    }

    final owners = await fetchOwnersOnce();
    return findByVehicleNumber(owners, vehicleNumber);
  }

  /// All vehicles from the global `vehicles/` index for RTO lists.
  Future<List<Map<String, String>>> fetchAllRegisteredPlates() async {
    final snap = await _vehiclesIndexRef.get();
    if (!snap.exists || snap.value is! Map) return [];

    final results = <Map<String, String>>[];
    for (final entry in (snap.value as Map).entries) {
      if (entry.value is Map) {
        final data = entry.value as Map;
        results.add({
          'plate': entry.key.toString(),
          'ownerUid': data['ownerUid']?.toString() ?? '',
          'vehicleType': data['vehicleType']?.toString() ?? '',
        });
      }
    }
    return results;
  }
}
