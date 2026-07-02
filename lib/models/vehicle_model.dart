/// Vehicle registered under `owners/{uid}/vehicles/{vehicleId}`.
class VehicleModel {
  final String vehicleId;
  final String vehicleNo;
  final String vehicleType;
  final String rcNumber;
  final int? addedAt;

  /// Populated for RTO challan management lists (`vehicles/` index).
  final String ownerUid;
  final String ownerName;
  final int totalChallanCount;

  const VehicleModel({
    required this.vehicleId,
    required this.vehicleNo,
    required this.vehicleType,
    this.rcNumber = '',
    this.addedAt,
    this.ownerUid = '',
    this.ownerName = '',
    this.totalChallanCount = 0,
  });

  /// Entry from global `vehicles/{plate}` index for RTO challan tab.
  factory VehicleModel.fromGlobalIndex({
    required String plate,
    required String ownerUid,
    required String vehicleType,
    String ownerName = '',
    int totalChallanCount = 0,
    String rcNumber = '',
  }) {
    return VehicleModel(
      vehicleId: plate,
      vehicleNo: plate,
      vehicleType: vehicleType,
      rcNumber: rcNumber,
      ownerUid: ownerUid,
      ownerName: ownerName,
      totalChallanCount: totalChallanCount,
    );
  }

  factory VehicleModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return VehicleModel(
      vehicleId: id,
      vehicleNo: map['vehicleNo']?.toString() ?? '',
      vehicleType: map['vehicleType']?.toString() ?? 'Other',
      rcNumber: map['rcNumber']?.toString() ?? '',
      addedAt: _ts(map['addedAt']),
    );
  }

  static int? _ts(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is Map) return DateTime.now().millisecondsSinceEpoch;
    return int.tryParse(v.toString());
  }

  Map<String, dynamic> toMap() => {
        'vehicleNo': vehicleNo,
        'vehicleType': vehicleType,
        'rcNumber': rcNumber,
        'addedAt': addedAt ?? DateTime.now().millisecondsSinceEpoch,
      };
}
