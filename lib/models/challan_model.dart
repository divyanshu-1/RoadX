import '../services/firebase_service.dart';

/// Traffic challan stored under `challans/{challanId}`.
class ChallanModel {
  final String id;
  final String vehicleNumber;
  final String ownerUID;
  final String ownerName;
  final String violationType;
  final int fineAmount;
  final String officerName;
  final String status;
  final String paymentStatus;
  final String issuedDate;
  final DateTime? createdAt;
  final double latitude;
  final double longitude;
  final String address;

  const ChallanModel({
    required this.id,
    required this.vehicleNumber,
    required this.ownerUID,
    this.ownerName = '',
    required this.violationType,
    required this.fineAmount,
    required this.officerName,
    required this.status,
    this.paymentStatus = 'unpaid',
    required this.issuedDate,
    this.createdAt,
    this.latitude = 0,
    this.longitude = 0,
    this.address = '',
  });

  /// Alias for analytics / reports.
  int get amount => fineAmount;

  /// Display label for violation (maps legacy `reason` field).
  String get reason =>
      violationType.isNotEmpty ? violationType : 'Violation';

  String get displayStatus {
    if (isPaid) return 'Paid';
    if (isPending) return 'Pending';
    final s = status.trim();
    if (s.isEmpty) return 'Pending';
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }

  String get location => address;

  factory ChallanModel.fromMap(String id, Map<dynamic, dynamic> map) {
    final rawStatus = map['status']?.toString() ?? 'pending';
    final rawPayment = map['paymentStatus']?.toString();
    final normalizedStatus = rawStatus.toLowerCase();
    final payment = rawPayment?.toLowerCase() ??
        (normalizedStatus == 'paid' ? 'paid' : 'unpaid');

    final created =
        _parseDate(map['createdAt']) ?? _parseDate(map['issuedDate']);

    return ChallanModel(
      id: id,
      vehicleNumber: FirebaseService.normalizePlate(
        map['vehicleNumber']?.toString() ?? '',
      ),
      ownerUID: map['ownerUID']?.toString() ?? '',
      ownerName: map['ownerName']?.toString() ?? '',
      violationType: map['violationType']?.toString() ??
          map['reason']?.toString() ??
          '',
      fineAmount: map['fineAmount'] is int
          ? map['fineAmount'] as int
          : int.tryParse(
                map['fineAmount']?.toString() ?? map['amount']?.toString() ?? '',
              ) ??
              0,
      officerName: map['officerName']?.toString() ?? '',
      status: rawStatus,
      paymentStatus: payment,
      issuedDate: map['issuedDate']?.toString() ?? '',
      createdAt: created,
      latitude: _dbl(map['latitude']),
      longitude: _dbl(map['longitude']),
      address: map['address']?.toString() ??
          map['location']?.toString() ??
          '',
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.tryParse(value.toString());
  }

  static double _dbl(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  /// Workflow: accepted vs pending (legacy Paid counts as accepted).
  bool get isAccepted {
    final s = status.toLowerCase();
    return s == 'accepted' || s == 'paid';
  }

  bool get isPendingStatus {
    final s = status.toLowerCase();
    return s == 'pending' || s == 'unpaid';
  }

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  bool get isUnpaid => !isPaid;

  /// Legacy helpers used elsewhere in the app.
  bool get isPending => isPendingStatus && isUnpaid;

  bool get hasMapPin => latitude != 0 || longitude != 0;

  DateTime get effectiveDate =>
      createdAt ?? DateTime.tryParse(issuedDate) ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'vehicleNumber': vehicleNumber,
        'ownerUID': ownerUID,
        'ownerName': ownerName,
        'violationType': violationType,
        'fineAmount': fineAmount,
        'amount': fineAmount,
        'officerName': officerName,
        'status': status,
        'paymentStatus': paymentStatus,
        'issuedDate': issuedDate,
        'createdAt': (createdAt ?? effectiveDate).toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      };
}
