import '../models/vehicle_model.dart';
import 'firebase_owner_service.dart';
import 'firebase_service.dart';

/// Owner vehicles under `owners/{uid}/vehicles` with legacy profile fallback.
class OwnerVehicleService {
  final FirebaseOwnerService _ownerService = FirebaseOwnerService();

  dynamic _vehiclesRef(String ownerUid) =>
      FirebaseService.ref('owners/$ownerUid/vehicles');

  Stream<List<VehicleModel>> watchVehicles(String ownerUid) {
    return FirebaseService.ref('owners/$ownerUid').onValue.asyncMap((event) async {
      await _ownerService.ensureLegacyVehicleMigrated(ownerUid);
      final vehiclesSnap = await _vehiclesRef(ownerUid).get();
      var vehicles = FirebaseService.parseChildren<VehicleModel>(
        vehiclesSnap,
        (key, data) => VehicleModel.fromMap(key, data),
      );

      if (vehicles.isEmpty && event.snapshot.value is Map) {
        final ownerData = event.snapshot.value as Map;
        final plate = ownerData['vehicleNumber']?.toString().trim().toUpperCase() ?? '';
        if (plate.isNotEmpty) {
          vehicles = [
            VehicleModel(
              vehicleId: 'legacy',
              vehicleNo: plate,
              vehicleType: ownerData['vehicleType']?.toString() ?? 'Other',
              rcNumber: ownerData['rcNumber']?.toString() ?? '',
            ),
          ];
        }
      }

      vehicles.sort((a, b) => (b.addedAt ?? 0).compareTo(a.addedAt ?? 0));
      return vehicles;
    });
  }

  Future<List<VehicleModel>> fetchVehiclesOnce(String ownerUid) async {
    await _ownerService.ensureLegacyVehicleMigrated(ownerUid);
    final snapshot = await _vehiclesRef(ownerUid).get();
    return FirebaseService.parseChildren<VehicleModel>(
      snapshot,
      (key, data) => VehicleModel.fromMap(key, data),
    );
  }
}
