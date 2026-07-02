/// Vehicle access event under `owners/{uid}/access_logs/{logId}`.
class AccessLogModel {
  final String logId;
  final String vehicleNumber;
  final String driverName;
  final String action;
  final String detail;
  final String status;
  final int? timestamp;

  const AccessLogModel({
    required this.logId,
    required this.vehicleNumber,
    required this.driverName,
    required this.action,
    this.detail = '',
    this.status = 'Info',
    this.timestamp,
  });

  factory AccessLogModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return AccessLogModel(
      logId: id,
      vehicleNumber: map['vehicleNumber']?.toString() ?? '',
      driverName: map['driverName']?.toString() ?? '',
      action: map['action']?.toString() ?? '',
      detail: map['detail']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Info',
      timestamp: _ts(map['timestamp']),
    );
  }

  static int? _ts(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  String get formattedTime {
    if (timestamp == null) return 'N/A';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp!);
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
