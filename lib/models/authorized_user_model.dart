/// Authorized driver under `owners/{uid}/vehicles/{vehicleId}/authorizedDrivers/{id}`.
class AuthorizedUserModel {
  final String authUserId;
  final String userName;
  final String phone;
  final String cardId;
  final String relation;
  final String status;
  final int? accessTime;
  final String vehicleId;
  final String vehicleNumber;

  const AuthorizedUserModel({
    required this.authUserId,
    required this.userName,
    required this.phone,
    required this.cardId,
    required this.relation,
    this.status = 'Inactive',
    this.accessTime,
    this.vehicleId = '',
    this.vehicleNumber = '',
  });

  bool get isActive => status.toLowerCase() == 'active';
  bool get isUnauthorized =>
      status.toLowerCase().contains('unauthorized') ||
      status.toLowerCase() == 'inactive';

  factory AuthorizedUserModel.fromMap(
    String id,
    Map<dynamic, dynamic> map, {
    String vehicleId = '',
    String vehicleNumber = '',
  }) {
    return AuthorizedUserModel(
      authUserId: id,
      userName: map['userName']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      cardId: map['cardId']?.toString() ?? '',
      relation: map['relation']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Inactive',
      accessTime: _ts(map['accessTime']),
      vehicleId: vehicleId,
      vehicleNumber:
          vehicleNumber.isNotEmpty
              ? vehicleNumber
              : (map['vehicleNumber']?.toString() ?? ''),
    );
  }

  static int? _ts(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  Map<String, dynamic> toMap() => {
        'userName': userName,
        'phone': phone,
        'cardId': cardId,
        'relation': relation,
        'status': status,
        'accessTime': accessTime ?? DateTime.now().millisecondsSinceEpoch,
      };
}
