import '../models/license_model.dart';

/// Repository interface defining license operations.
abstract class LicenseRepository {
  /// Fetch a single license by its license number.
  Future<LicenseModel?> getLicense(String licenseNo);

  /// Add a new license document.
  Future<void> addLicense(LicenseModel license);

  /// Update an existing license document.
  Future<void> updateLicense(LicenseModel license);

  /// Delete a license document by its number.
  Future<void> deleteLicense(String licenseNo);

  /// Stream of all licenses for real-time admin view.
  Stream<List<LicenseModel>> streamLicenses();

  /// Batch seed sample licenses for testing.
  Future<void> seedLicenses(List<LicenseModel> licenses);
}
