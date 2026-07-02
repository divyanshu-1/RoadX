import 'authorized_user_model.dart';

/// Owner profile stored under `owners/{uid}` in Realtime Database.
class OwnerModel {
  final String uid;
  final String ownerName;
  final String email;
  final String phone;
  final String aadhaar;
  final String vehicleNumber;
  final String vehicleType;
  final String rcNumber;
  final String address;
  final int? createdAt;
  final String licenseNo;
  final String licenseImageUrl;
  final String role;
  final List<AuthorizedUserModel> authorizedUsers;

  const OwnerModel({
    required this.uid,
    required this.ownerName,
    required this.email,
    this.phone = '',
    this.aadhaar = '',
    this.vehicleNumber = '',
    this.vehicleType = 'Other',
    this.rcNumber = '',
    this.address = '',
    this.createdAt,
    this.licenseNo = '',
    this.licenseImageUrl = '',
    this.role = 'CarOwner',
    this.authorizedUsers = const [],
  });

  String get name => ownerName;

  factory OwnerModel.fromMap(String uid, Map<dynamic, dynamic> map) {
    return OwnerModel(
      uid: uid,
      ownerName: map['ownerName']?.toString() ??
          map['name']?.toString() ??
          map['fullName']?.toString() ??
          '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? map['mobile']?.toString() ?? '',
      aadhaar: map['aadhaar']?.toString() ?? '',
      vehicleNumber: map['vehicleNumber']?.toString() ?? '',
      vehicleType: map['vehicleType']?.toString() ?? 'Other',
      rcNumber: map['rcNumber']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      createdAt: _parseTimestamp(map['createdAt'] ?? map['registeredAt']),
      licenseNo: map['licenseNo']?.toString() ?? '',
      licenseImageUrl: map['licenseImageUrl']?.toString() ?? '',
      role: map['role']?.toString() ?? 'CarOwner',
      authorizedUsers: _parseAuthorizedUsers(map['authorizedUsers']),
    );
  }

  static List<AuthorizedUserModel> _parseAuthorizedUsers(dynamic raw) {
    if (raw == null || raw is! Map) return [];
    return raw.entries.map((e) {
      if (e.value is Map) {
        return AuthorizedUserModel.fromMap(
          e.key.toString(),
          e.value as Map<dynamic, dynamic>,
        );
      }
      return null;
    }).whereType<AuthorizedUserModel>().toList();
  }

  static int? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  Map<String, dynamic> toMap() => {
        'ownerName': ownerName,
        'email': email,
        'phone': phone,
        if (aadhaar.isNotEmpty) 'aadhaar': aadhaar,
        if (vehicleNumber.isNotEmpty) 'vehicleNumber': vehicleNumber,
        if (vehicleType.isNotEmpty) 'vehicleType': vehicleType,
        if (rcNumber.isNotEmpty) 'rcNumber': rcNumber,
        if (address.isNotEmpty) 'address': address,
        'createdAt': createdAt ?? DateTime.now().millisecondsSinceEpoch,
        'licenseNo': licenseNo,
        if (licenseImageUrl.isNotEmpty) 'licenseImageUrl': licenseImageUrl,
        'role': role,
      };

  String get formattedRegistrationDate {
    if (createdAt == null) return 'N/A';
    final dt = DateTime.fromMillisecondsSinceEpoch(createdAt!);
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  int get activeAuthorizedCount =>
      authorizedUsers.where((u) => u.isActive).length;

  OwnerModel copyWith({
    String? vehicleNumber,
    String? vehicleType,
    String? rcNumber,
  }) {
    return OwnerModel(
      uid: uid,
      ownerName: ownerName,
      email: email,
      phone: phone,
      aadhaar: aadhaar,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      rcNumber: rcNumber ?? this.rcNumber,
      address: address,
      createdAt: createdAt,
      licenseNo: licenseNo,
      role: role,
      licenseImageUrl: licenseImageUrl,
      authorizedUsers: authorizedUsers,
    );
  }
}
