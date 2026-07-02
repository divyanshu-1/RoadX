import 'package:firebase_database/firebase_database.dart';
import '../models/access_log_model.dart';
import 'firebase_service.dart';

/// Owner vehicle access history (replaces IoT logs).
class AccessLogService {
  DatabaseReference _logsRef(String ownerUid) =>
      FirebaseService.ref('owners/$ownerUid/access_logs');

  Stream<List<AccessLogModel>> watchAccessLogs(String ownerUid) {
    return _logsRef(ownerUid).onValue.map((event) {
      final logs = FirebaseService.parseChildren<AccessLogModel>(
        event.snapshot,
        (key, data) => AccessLogModel.fromMap(key, data),
      );
      logs.sort((a, b) => (b.timestamp ?? 0).compareTo(a.timestamp ?? 0));
      return logs;
    });
  }

  Future<void> logEvent({
    required String ownerUid,
    required String vehicleNumber,
    required String driverName,
    required String action,
    String detail = '',
    String status = 'Info',
  }) async {
    final ref = _logsRef(ownerUid).push();
    await ref.set({
      'vehicleNumber': vehicleNumber.trim().toUpperCase(),
      'driverName': driverName.trim(),
      'action': action.trim(),
      'detail': detail.trim(),
      'status': status.trim(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
