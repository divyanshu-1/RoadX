import '../models/challan_model.dart';
import '../models/owner_model.dart';
import '../models/registered_vehicle_model.dart';
import '../rto/rto_data_provider.dart';
import 'challan_service.dart';
import 'vehicle_service.dart';

/// @deprecated Prefer [RtoDataProvider] for RTO UI.
class FirebaseRtoService {
  final VehicleService _vehicleService = VehicleService();
  final ChallanService _challanService = ChallanService();

  Stream<List<OwnerModel>> watchOwners() => _vehicleService.watchOwners();
  Stream<List<ChallanModel>> watchChallans() => _challanService.watchChallans();
  Stream<RtoDashboardStats> watchDashboardStats() {
    final provider = RtoDataProvider()..startListening();
    return Stream.periodic(const Duration(milliseconds: 100), (_) => provider.stats);
  }

  Stream<List<RegisteredVehicleModel>> watchRegisteredVehicles() {
    final provider = RtoDataProvider()..startListening();
    return Stream.periodic(
      const Duration(milliseconds: 100),
      (_) => provider.registeredVehicles,
    );
  }

  Future<OwnerModel?> findOwnerByVehicle(String vehicleNumber) =>
      _vehicleService.findByVehicleNumberFromDb(vehicleNumber);
}
