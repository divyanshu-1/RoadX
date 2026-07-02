import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/challan_model.dart';
import '../models/owner_model.dart';
import '../models/registered_vehicle_model.dart';
import '../services/challan_service.dart';
import '../services/firebase_service.dart';
import '../services/vehicle_service.dart';

/// Cached realtime RTO data — owners, challans, stats, search.
class RtoDashboardStats {
  final int totalVehicles;
  final int totalOwners;
  final int totalChallans;
  final int pendingChallans;

  const RtoDashboardStats({
    this.totalVehicles = 0,
    this.totalOwners = 0,
    this.totalChallans = 0,
    this.pendingChallans = 0,
  });
}

class RtoDataProvider extends ChangeNotifier {
  final VehicleService _vehicleService = VehicleService();
  final ChallanService _challanService = ChallanService();

  List<OwnerModel> _owners = [];
  List<ChallanModel> _challans = [];
  List<Map<String, String>> _vehicleIndex = [];
  bool _loading = true;
  bool _refreshing = false;
  String? _error;

  StreamSubscription<List<OwnerModel>>? _ownersSub;
  StreamSubscription<List<ChallanModel>>? _challansSub;

  List<OwnerModel> get owners => List.unmodifiable(_owners);
  List<ChallanModel> get challans => List.unmodifiable(_challans);
  bool get isLoading => _loading;
  bool get isRefreshing => _refreshing;
  String? get error => _error;
  bool get hasData => _owners.isNotEmpty || _challans.isNotEmpty;

  List<RegisteredVehicleModel> get registeredVehicles {
    if (_vehicleIndex.isNotEmpty) {
      return _vehicleIndex.map((entry) {
        final ownerUid = entry['ownerUid'] ?? '';
        final plate = entry['plate'] ?? '';
        final type = entry['vehicleType'] ?? 'Other';
        final owner = _owners.where((o) => o.uid == ownerUid).firstOrNull;
        final pending = _challanService.pendingForOwner(_challans, ownerUid);
        final total = _challanService.countForVehicle(_challans, plate);
        return RegisteredVehicleModel(
          ownerUID: ownerUid,
          ownerName: owner?.ownerName ?? 'Unknown',
          vehicleNumber: plate,
          vehicleType: type,
          registrationDate: owner?.formattedRegistrationDate ?? 'N/A',
          challanStatus: pending > 0
              ? '$pending Pending'
              : (total > 0 ? '$total Issued' : 'Clear'),
          pendingChallanCount: pending,
          totalChallanCount: total,
        );
      }).toList();
    }

    return _owners
        .where((o) => o.vehicleNumber.isNotEmpty)
        .map((owner) {
          final pending = _challanService.pendingForOwner(_challans, owner.uid);
          final total =
              _challanService.countForVehicle(_challans, owner.vehicleNumber);
          return RegisteredVehicleModel.fromOwner(
            owner,
            pendingChallans: pending,
            totalChallans: total,
          );
        })
        .toList();
  }

  RtoDashboardStats get stats {
    final vehicleCount = registeredVehicles.length;
    return RtoDashboardStats(
      totalVehicles: vehicleCount > 0 ? vehicleCount : _owners.length,
      totalOwners: _owners.length,
      totalChallans: _challans.length,
      pendingChallans: _challanService.countPending(_challans),
    );
  }

  /// Start realtime listeners (call once from RTO shell).
  void startListening() {
    if (_ownersSub != null) return;

    _loading = true;
    notifyListeners();

    _ownersSub = _vehicleService.watchOwners().listen(
      (data) async {
        _owners = data;
        try {
          _vehicleIndex = await _vehicleService.fetchAllRegisteredPlates();
        } catch (_) {}
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = FirebaseService.friendlyError(e);
        _loading = false;
        notifyListeners();
      },
    );

    _challansSub = _challanService.watchChallans().listen(
      (data) {
        _challans = data;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = FirebaseService.friendlyError(e);
        _loading = false;
        notifyListeners();
      },
    );
  }

  /// Manual refresh without duplicate stream subscriptions.
  Future<void> refresh() async {
    _refreshing = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _vehicleService.fetchOwnersOnce(),
        _challanService.fetchChallansOnce(),
        _vehicleService.fetchAllRegisteredPlates(),
      ]);
      _owners = results[0] as List<OwnerModel>;
      _challans = results[1] as List<ChallanModel>;
      _vehicleIndex = results[2] as List<Map<String, String>>;
      _error = null;
    } catch (e) {
      _error = FirebaseService.friendlyError(e);
    } finally {
      _refreshing = false;
      _loading = false;
      notifyListeners();
    }
  }

  /// Search cached owners by plate (no extra Firebase read).
  OwnerModel? findOwnerByPlate(String vehicleNumber) {
    return _vehicleService.findByVehicleNumber(_owners, vehicleNumber);
  }

  /// Search with network fallback if cache empty.
  Future<OwnerModel?> searchVehicle(String vehicleNumber) async {
    final plate = FirebaseService.normalizePlate(vehicleNumber);
    if (plate.isEmpty) return null;

    var found = findOwnerByPlate(plate);
    if (found != null) return found;

    if (_owners.isEmpty) {
      await refresh();
      found = findOwnerByPlate(plate);
    }
    if (found != null) return found;

    return _vehicleService.findByVehicleNumberFromDb(plate);
  }

  List<RegisteredVehicleModel> filterVehicles({
    String query = '',
    bool pendingOnly = false,
  }) {
    var list = registeredVehicles;
    if (pendingOnly) {
      list = list.where((v) => v.pendingChallanCount > 0).toList();
    }
    if (query.trim().isEmpty) return list;
    final q = query.trim().toLowerCase();
    return list.where((v) {
      return v.vehicleNumber.toLowerCase().contains(q) ||
          v.ownerName.toLowerCase().contains(q) ||
          v.vehicleType.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _ownersSub?.cancel();
    _challansSub?.cancel();
    super.dispose();
  }
}
