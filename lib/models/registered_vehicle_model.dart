import 'owner_model.dart';

/// Vehicle record derived from owner registration for RTO lists.
class RegisteredVehicleModel {
  final String ownerUID;
  final String ownerName;
  final String vehicleNumber;
  final String vehicleType;
  final String registrationDate;
  final String challanStatus;
  final int pendingChallanCount;
  final int totalChallanCount;

  const RegisteredVehicleModel({
    required this.ownerUID,
    required this.ownerName,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.registrationDate,
    required this.challanStatus,
    required this.pendingChallanCount,
    this.totalChallanCount = 0,
  });

  factory RegisteredVehicleModel.fromOwner(
    OwnerModel owner, {
    int pendingChallans = 0,
    int totalChallans = 0,
  }) {
    return RegisteredVehicleModel(
      ownerUID: owner.uid,
      ownerName: owner.ownerName,
      vehicleNumber: owner.vehicleNumber,
      vehicleType: owner.vehicleType,
      registrationDate: owner.formattedRegistrationDate,
      challanStatus: pendingChallans > 0
          ? '$pendingChallans Pending'
          : (totalChallans > 0 ? '$totalChallans Issued' : 'Clear'),
      pendingChallanCount: pendingChallans,
      totalChallanCount: totalChallans,
    );
  }
}
