import '../models/authorized_user_model.dart';
import 'access_log_service.dart';
import 'firebase_service.dart';

/// Authorized drivers scoped to a specific vehicle.
class AuthorizedUserService {
  final AccessLogService _accessLogService = AccessLogService();

  dynamic _driversRef(String ownerUid, String vehicleId) =>
      FirebaseService.ref(
        'owners/$ownerUid/vehicles/$vehicleId/authorizedDrivers',
      );

  dynamic _legacyDriversRef(String ownerUid) =>
      FirebaseService.ref('owners/$ownerUid/authorizedUsers');

  Stream<List<AuthorizedUserModel>> watchAllAuthorizedDrivers(String ownerUid) {
    return FirebaseService.ref('owners/$ownerUid').onValue.asyncMap((event) async {
      final drivers = <AuthorizedUserModel>[];

      if (event.snapshot.value is Map) {
        final root = event.snapshot.value as Map;

        final legacy = root['authorizedUsers'];
        if (legacy is Map) {
          final legacyVehicle = root['vehicleNumber']?.toString() ?? '';
          for (final entry in legacy.entries) {
            if (entry.value is Map) {
              drivers.add(
                AuthorizedUserModel.fromMap(
                  entry.key.toString(),
                  entry.value as Map<dynamic, dynamic>,
                  vehicleId: 'legacy',
                  vehicleNumber: legacyVehicle,
                ),
              );
            }
          }
        }
      }

      final vehiclesSnap = await FirebaseService.ref('owners/$ownerUid/vehicles').get();
      if (vehiclesSnap.exists && vehiclesSnap.value is Map) {
        for (final vehicleEntry in (vehiclesSnap.value as Map).entries) {
          final vehicleId = vehicleEntry.key.toString();
          final vehicleData = vehicleEntry.value;
          if (vehicleData is! Map) continue;
          final vehicleNo = vehicleData['vehicleNo']?.toString() ?? '';

          final authSnap = await _driversRef(ownerUid, vehicleId).get();
          if (!authSnap.exists || authSnap.value is! Map) continue;

          for (final driverEntry in (authSnap.value as Map).entries) {
            if (driverEntry.value is Map) {
              drivers.add(
                AuthorizedUserModel.fromMap(
                  driverEntry.key.toString(),
                  driverEntry.value as Map<dynamic, dynamic>,
                  vehicleId: vehicleId,
                  vehicleNumber: vehicleNo,
                ),
              );
            }
          }
        }
      }

      return drivers;
    });
  }

  Future<void> addAuthorizedDriver({
    required String ownerUid,
    required String vehicleId,
    required String vehicleNumber,
    required String userName,
    required String phone,
    required String cardId,
    required String relation,
  }) async {
    final targetId = vehicleId == 'legacy' ? await _resolveLegacyVehicleId(ownerUid) : vehicleId;
    final ref = _driversRef(ownerUid, targetId).push();
    await ref.set({
      'userName': userName.trim(),
      'phone': phone.trim(),
      'cardId': cardId.trim().toUpperCase(),
      'relation': relation.trim(),
      'status': 'Active',
      'vehicleNumber': vehicleNumber.trim().toUpperCase(),
      'accessTime': DateTime.now().millisecondsSinceEpoch,
    });

    await _accessLogService.logEvent(
      ownerUid: ownerUid,
      vehicleNumber: vehicleNumber,
      driverName: userName,
      action: 'Driver authorized',
      detail: '$relation • ID ${cardId.trim().toUpperCase()}',
      status: 'Active',
    );
  }

  Future<void> updateAuthorizedDriver({
    required String ownerUid,
    required String vehicleId,
    required String driverId,
    required String userName,
    required String phone,
    required String cardId,
    required String relation,
  }) async {
    final ref = vehicleId == 'legacy'
        ? _legacyDriversRef(ownerUid).child(driverId)
        : _driversRef(ownerUid, vehicleId).child(driverId);
    await ref.update({
      'userName': userName.trim(),
      'phone': phone.trim(),
      'cardId': cardId.trim().toUpperCase(),
      'relation': relation.trim(),
    });
  }

  Future<void> removeAuthorizedDriver({
    required String ownerUid,
    required String vehicleId,
    required String driverId,
  }) async {
    final ref = vehicleId == 'legacy'
        ? _legacyDriversRef(ownerUid).child(driverId)
        : _driversRef(ownerUid, vehicleId).child(driverId);
    await ref.remove();
  }

  Future<String> _resolveLegacyVehicleId(String ownerUid) async {
    final snap = await FirebaseService.ref('owners/$ownerUid/vehicles').get();
    if (snap.exists && snap.value is Map && (snap.value as Map).isNotEmpty) {
      return (snap.value as Map).keys.first.toString();
    }
    throw Exception('Register a vehicle before adding authorized drivers');
  }
}
