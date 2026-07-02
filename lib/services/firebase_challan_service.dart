import '../models/challan_model.dart';
import 'challan_service.dart';

/// @deprecated Use [ChallanService] directly.
class FirebaseChallanService {
  final ChallanService _inner = ChallanService();

  Future<String> issueChallan({
    required String vehicleNumber,
    required String ownerUID,
    required String violationType,
    required int fineAmount,
    required String location,
    required String officerName,
    required String issuedDate,
    String ownerName = '',
    double latitude = 0,
    double longitude = 0,
  }) =>
      _inner.issueChallan(
        vehicleNumber: vehicleNumber,
        ownerUID: ownerUID,
        ownerName: ownerName,
        violationType: violationType,
        fineAmount: fineAmount,
        officerName: officerName,
        issuedDate: issuedDate,
        latitude: latitude,
        longitude: longitude,
        address: location,
      );

  Stream<List<ChallanModel>> watchChallansForOwner(String ownerUID) =>
      _inner.watchChallansForOwner(ownerUID);

  Stream<List<ChallanModel>> watchAllChallans() => _inner.watchChallans();

  Future<void> markChallanPaid(String challanId) =>
      _inner.markChallanPaid(challanId);

  int countPending(List<ChallanModel> challans) =>
      _inner.countPending(challans);

  int totalPendingAmount(List<ChallanModel> challans) =>
      _inner.totalPendingAmount(challans);
}
