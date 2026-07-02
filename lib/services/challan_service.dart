import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import '../models/challan_model.dart';
import '../models/owner_model.dart';
import '../models/vehicle_model.dart';
import 'firebase_service.dart';

/// Traffic challans under `challans/` node.
class ChallanService {
  DatabaseReference get _challansRef => FirebaseService.ref('challans');
  DatabaseReference get _vehiclesRef => FirebaseService.ref('vehicles');
  DatabaseReference get _ownersRef => FirebaseService.ref('owners');

  Future<List<ChallanModel>> fetchChallansOnce() async {
    try {
      final snapshot = await _challansRef.get();
      return FirebaseService.parseChildren<ChallanModel>(
        snapshot,
        (key, data) => ChallanModel.fromMap(key, data),
      );
    } catch (e) {
      throw Exception(FirebaseService.friendlyError(e));
    }
  }

  Stream<List<ChallanModel>> watchChallans() {
    return _challansRef.onValue.map((event) {
      return FirebaseService.parseChildren<ChallanModel>(
        event.snapshot,
        (key, data) => ChallanModel.fromMap(key, data),
      );
    });
  }

  Future<String> issueChallan({
    required String vehicleNumber,
    required String ownerUID,
    required String ownerName,
    required String violationType,
    required int fineAmount,
    required String officerName,
    required String issuedDate,
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    if (ownerUID.isEmpty) throw Exception('Invalid owner');
    if (fineAmount <= 0) throw Exception('Invalid fine amount');
    if (address.trim().isEmpty) throw Exception('Address is required');

    final ref = _challansRef.push();
    final id = ref.key;
    if (id == null) throw Exception('Failed to generate challan ID');

    final now = DateTime.now();
    await ref.set({
      'vehicleNumber': FirebaseService.normalizePlate(vehicleNumber),
      'ownerUID': ownerUID,
      'ownerName': ownerName,
      'violationType': violationType,
      'fineAmount': fineAmount,
      'amount': fineAmount,
      'officerName': officerName,
      'latitude': latitude,
      'longitude': longitude,
      'address': address.trim(),
      'issuedDate': issuedDate,
      'createdAt': now.toIso8601String(),
      'status': 'pending',
      'paymentStatus': 'unpaid',
    });
    return id;
  }

  Stream<List<ChallanModel>> watchChallansForOwner(String ownerUID) {
    return watchChallans().map(
      (list) => list.where((c) => c.ownerUID == ownerUID).toList()
        ..sort((a, b) => b.issuedDate.compareTo(a.issuedDate)),
    );
  }

  Future<void> markChallanPaid(String challanId) async {
    await _challansRef.child(challanId).update({
      'status': 'accepted',
      'paymentStatus': 'paid',
    });
  }

  int countPending(List<ChallanModel> challans) =>
      challans.where((c) => c.isPending).length;

  int pendingForOwner(List<ChallanModel> challans, String ownerUID) =>
      challans.where((c) => c.ownerUID == ownerUID && c.isPending).length;

  int countForVehicle(List<ChallanModel> challans, String vehicleNumber) {
    final plate = FirebaseService.normalizePlate(vehicleNumber);
    return challans.where((c) => c.vehicleNumber == plate).length;
  }

  int totalPendingAmount(List<ChallanModel> challans) => challans
      .where((c) => c.isPending)
      .fold(0, (sum, c) => sum + c.fineAmount);

  int countPaid(List<ChallanModel> challans) =>
      challans.where((c) => c.isPaid).length;

  /// All vehicles from `vehicles/` with owner name and challan totals.
  Future<List<VehicleModel>> getRegisteredVehicles() async {
    try {
      final results = await Future.wait([
        _vehiclesRef.get(),
        fetchChallansOnce(),
        _ownersRef.get(),
      ]);
      final vehiclesSnap = results[0] as DataSnapshot;
      final challans = results[1] as List<ChallanModel>;
      final ownersSnap = results[2] as DataSnapshot;

      final ownersByUid = <String, OwnerModel>{};
      for (final owner in FirebaseService.parseChildren<OwnerModel>(
        ownersSnap,
        (key, data) => OwnerModel.fromMap(key, data),
      )) {
        ownersByUid[owner.uid] = owner;
      }

      if (!vehiclesSnap.exists || vehiclesSnap.value is! Map) return [];

      final list = <VehicleModel>[];
      for (final entry in (vehiclesSnap.value as Map).entries) {
        if (entry.value is! Map) continue;
        final data = entry.value as Map;
        final plate = FirebaseService.normalizePlate(entry.key.toString());
        final ownerUid = data['ownerUid']?.toString() ?? '';
        final owner = ownersByUid[ownerUid];
        final total = countForVehicle(challans, plate);

        list.add(
          VehicleModel.fromGlobalIndex(
            plate: plate,
            ownerUid: ownerUid,
            vehicleType: data['vehicleType']?.toString() ??
                owner?.vehicleType ??
                'Other',
            ownerName: owner?.ownerName ?? data['ownerName']?.toString() ?? '',
            totalChallanCount: total,
            rcNumber: data['rcNumber']?.toString() ?? owner?.rcNumber ?? '',
          ),
        );
      }

      list.sort((a, b) => a.vehicleNo.compareTo(b.vehicleNo));
      return list;
    } catch (e) {
      throw Exception(FirebaseService.friendlyError(e));
    }
  }

  /// Live vehicle list for RTO challan tab (vehicles + challans index).
  Stream<List<VehicleModel>> watchRegisteredVehicles() {
    late StreamController<List<VehicleModel>> controller;
    StreamSubscription<DatabaseEvent>? vehiclesSub;
    StreamSubscription<DatabaseEvent>? challansSub;

    Future<void> emit() async {
      if (controller.isClosed) return;
      try {
        controller.add(await getRegisteredVehicles());
      } catch (e) {
        controller.addError(Exception(FirebaseService.friendlyError(e)));
      }
    }

    controller = StreamController<List<VehicleModel>>(
      onListen: () async {
        await emit();
        vehiclesSub = _vehiclesRef.onValue.listen((_) => emit());
        challansSub = _challansRef.onValue.listen((_) => emit());
      },
      onCancel: () async {
        await vehiclesSub?.cancel();
        await challansSub?.cancel();
      },
    );
    return controller.stream;
  }

  Future<List<ChallanModel>> getVehicleChallans(String vehicleNumber) async {
    final plate = FirebaseService.normalizePlate(vehicleNumber);
    if (plate.isEmpty) return [];
    try {
      final all = await fetchChallansOnce();
      return _filterChallansForPlate(all, plate);
    } catch (e) {
      throw Exception(FirebaseService.friendlyError(e));
    }
  }

  Stream<List<ChallanModel>> watchVehicleChallans(String vehicleNumber) {
    final plate = FirebaseService.normalizePlate(vehicleNumber);
    return watchChallans().map(
      (list) => _filterChallansForPlate(list, plate),
    );
  }

  List<ChallanModel> _filterChallansForPlate(
    List<ChallanModel> list,
    String plate,
  ) {
    return list.where((c) => c.vehicleNumber == plate).toList()
      ..sort((a, b) => b.effectiveDate.compareTo(a.effectiveDate));
  }

  /// Deletes every challan for [vehicleNumber] and nested challan refs.
  Future<void> resetVehicleChallans(String vehicleNumber) async {
    final plate = FirebaseService.normalizePlate(vehicleNumber);
    if (plate.isEmpty) throw Exception('Invalid vehicle number');

    try {
      final challans = await getVehicleChallans(plate);
      if (challans.isEmpty) return;

      String? ownerUid;
      for (final c in challans) {
        if (c.ownerUID.isNotEmpty) {
          ownerUid = c.ownerUID;
          break;
        }
      }

      if (ownerUid == null || ownerUid.isEmpty) {
        final vSnap = await _vehiclesRef.child(plate).get();
        if (vSnap.exists && vSnap.value is Map) {
          ownerUid = (vSnap.value as Map)['ownerUid']?.toString();
        }
      }

      final updates = <String, dynamic>{};
      for (final c in challans) {
        updates['challans/${c.id}'] = null;
      }

      updates['vehicles/$plate/challans'] = null;

      if (ownerUid != null && ownerUid.isNotEmpty) {
        updates['owners/$ownerUid/challans'] = null;
        final ownerVehiclesSnap =
            await _ownersRef.child('$ownerUid/vehicles').get();
        if (ownerVehiclesSnap.exists && ownerVehiclesSnap.value is Map) {
          for (final entry in (ownerVehiclesSnap.value as Map).entries) {
            if (entry.value is! Map) continue;
            final vData = entry.value as Map;
            final vNo = FirebaseService.normalizePlate(
              vData['vehicleNo']?.toString() ?? '',
            );
            if (vNo == plate) {
              updates['owners/$ownerUid/vehicles/${entry.key}/challans'] =
                  null;
            }
          }
        }
      }

      await FirebaseService.ref().update(updates);
    } catch (e) {
      throw Exception(FirebaseService.friendlyError(e));
    }
  }
}
