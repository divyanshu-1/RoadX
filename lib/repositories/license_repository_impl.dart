import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/license_model.dart';
import 'license_repository.dart';

/// Firestore implementation of [LicenseRepository] with local mock fallback.
class LicenseRepositoryImpl implements LicenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _licensesRef => _firestore.collection('licenses');

  static final List<LicenseModel> _sampleLicenses = [
    LicenseModel(
      licenseNo: 'MH100001',
      name: 'Aarav Mehta',
      vehicleType: 'Car',
      issueDate: '2020-05-12',
      expiryDate: '2030-05-11',
      status: 'Active',
    ),
    LicenseModel(
      licenseNo: 'MH100002',
      name: 'Diya Sharma',
      vehicleType: 'Truck',
      issueDate: '2018-09-20',
      expiryDate: '2028-09-19',
      status: 'Active',
    ),
    LicenseModel(
      licenseNo: 'MH100003',
      name: 'Vihaan Verma',
      vehicleType: 'Motorcycle',
      issueDate: '2022-01-15',
      expiryDate: '2032-01-14',
      status: 'Suspended',
    ),
    LicenseModel(
      licenseNo: 'MH100004',
      name: 'Ananya Patel',
      vehicleType: 'Car',
      issueDate: '2019-11-05',
      expiryDate: '2029-11-04',
      status: 'Active',
    ),
    LicenseModel(
      licenseNo: 'MH100005',
      name: 'Kabir Singh',
      vehicleType: 'Van',
      issueDate: '2015-06-30',
      expiryDate: '2025-06-29',
      status: 'Expired',
    ),
    LicenseModel(
      licenseNo: 'MH100006',
      name: 'Ishaan Gupta',
      vehicleType: 'Car',
      issueDate: '2021-03-18',
      expiryDate: '2031-03-17',
      status: 'Active',
    ),
    LicenseModel(
      licenseNo: 'MH100007',
      name: 'Kiara Joshi',
      vehicleType: 'SUV',
      issueDate: '2020-07-22',
      expiryDate: '2030-07-21',
      status: 'Active',
    ),
    LicenseModel(
      licenseNo: 'MH100008',
      name: 'Arjun Reddy',
      vehicleType: 'Motorcycle',
      issueDate: '2023-04-10',
      expiryDate: '2033-04-09',
      status: 'Active',
    ),
    LicenseModel(
      licenseNo: 'MH100009',
      name: 'Riya Sen',
      vehicleType: 'Car',
      issueDate: '2017-08-14',
      expiryDate: '2027-08-13',
      status: 'Active',
    ),
    LicenseModel(
      licenseNo: 'MH100010',
      name: 'Sai Kiran',
      vehicleType: 'Bus',
      issueDate: '2016-12-05',
      expiryDate: '2026-12-04',
      status: 'Active',
    ),
    LicenseModel(
      licenseNo: 'MH100011',
      name: 'Aditya Rao',
      vehicleType: 'Truck',
      issueDate: '2021-10-12',
      expiryDate: '2031-10-11',
      status: 'Active',
    ),
    LicenseModel(
      licenseNo: 'MH100012',
      name: 'Neha Nair',
      vehicleType: 'Car',
      issueDate: '2019-04-25',
      expiryDate: '2029-04-24',
      status: 'Active',
    ),
    LicenseModel(
      licenseNo: 'MH100013',
      name: 'Rohan Deshmukh',
      vehicleType: 'SUV',
      issueDate: '2022-08-01',
      expiryDate: '2032-07-31',
      status: 'Suspended',
    ),
    LicenseModel(
      licenseNo: 'MH100014',
      name: 'Pooja Hegde',
      vehicleType: 'Motorcycle',
      issueDate: '2020-12-20',
      expiryDate: '2030-12-19',
      status: 'Active',
    ),
    LicenseModel(
      licenseNo: 'MH100015',
      name: 'Vikram Malhotra',
      vehicleType: 'Van',
      issueDate: '2014-03-10',
      expiryDate: '2024-03-09',
      status: 'Expired',
    ),
    LicenseModel(
      licenseNo: 'MH100016',
      name: 'Shruti Iyer',
      vehicleType: 'Car',
      issueDate: '2021-06-15',
      expiryDate: '2031-06-14',
      status: 'Active',
    ),
    LicenseModel(
      licenseNo: 'MH100017',
      name: 'Gaurav Dubey',
      vehicleType: 'Car',
      issueDate: '2018-02-28',
      expiryDate: '2028-02-27',
      status: 'Active',
    ),
    LicenseModel(
      licenseNo: 'MH100018',
      name: 'Sneha Kulkarni',
      vehicleType: 'SUV',
      issueDate: '2023-01-11',
      expiryDate: '2033-01-10',
      status: 'Active',
    ),
    LicenseModel(
      licenseNo: 'MH100019',
      name: 'Kunal Kapoor',
      vehicleType: 'Motorcycle',
      issueDate: '2022-09-09',
      expiryDate: '2032-09-08',
      status: 'Active',
    ),
    LicenseModel(
      licenseNo: 'MH100020',
      name: 'Meera Nambiar',
      vehicleType: 'Car',
      issueDate: '2020-10-30',
      expiryDate: '2030-10-29',
      status: 'Active',
    ),
  ];

  @override
  Future<LicenseModel?> getLicense(String licenseNo) async {
    final cleanNo = licenseNo.trim().toUpperCase();
    try {
      final doc = await _licensesRef.doc(cleanNo).get();
      if (doc.exists && doc.data() != null) {
        return LicenseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      // Fall back silently to mock licenses if Firestore is inaccessible / permission-denied.
      debugPrint('Firestore error fetching license: $e. Falling back to local sample license check.');
    }

    // Fallback to sample seed list
    final match = _sampleLicenses.firstWhere(
      (l) => l.licenseNo == cleanNo,
      orElse: () => LicenseModel(
        licenseNo: '',
        name: '',
        vehicleType: '',
        issueDate: '',
        expiryDate: '',
        status: '',
      ),
    );
    return match.licenseNo.isEmpty ? null : match;
  }

  @override
  Future<void> addLicense(LicenseModel license) async {
    await _licensesRef
        .doc(license.licenseNo.trim().toUpperCase())
        .set(license.toMap());
  }

  @override
  Future<void> updateLicense(LicenseModel license) async {
    await _licensesRef
        .doc(license.licenseNo.trim().toUpperCase())
        .update(license.toMap());
  }

  @override
  Future<void> deleteLicense(String licenseNo) async {
    await _licensesRef.doc(licenseNo.trim().toUpperCase()).delete();
  }

  @override
  Stream<List<LicenseModel>> streamLicenses() {
    return _licensesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return LicenseModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  @override
  Future<void> seedLicenses(List<LicenseModel> licenses) async {
    final batch = _firestore.batch();
    for (final license in licenses) {
      final docRef = _licensesRef.doc(license.licenseNo.trim().toUpperCase());
      batch.set(docRef, license.toMap());
    }
    await batch.commit();
  }
}
