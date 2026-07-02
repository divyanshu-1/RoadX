/// Domain model representing a driving license document in Firestore.
class LicenseModel {
  final String licenseNo;
  final String name;
  final String vehicleType;
  final String issueDate;
  final String expiryDate;
  final String status;

  LicenseModel({
    required this.licenseNo,
    required this.name,
    required this.vehicleType,
    required this.issueDate,
    required this.expiryDate,
    required this.status,
  });

  /// Factory constructor to create a [LicenseModel] from Firestore document map.
  factory LicenseModel.fromMap(Map<String, dynamic> map, String docId) {
    return LicenseModel(
      licenseNo: docId,
      name: map['name']?.toString() ?? '',
      vehicleType: map['vehicleType']?.toString() ?? '',
      issueDate: map['issueDate']?.toString() ?? '',
      expiryDate: map['expiryDate']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Active',
    );
  }

  /// Serialize this model into a map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'licenseNo': licenseNo,
      'name': name,
      'vehicleType': vehicleType,
      'issueDate': issueDate,
      'expiryDate': expiryDate,
      'status': status,
    };
  }
}
