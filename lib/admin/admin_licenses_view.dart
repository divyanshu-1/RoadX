import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/license_model.dart';
import '../services/license_service.dart';
import 'widgets/admin_theme.dart';
import '../theme.dart';
import '../utils/custom_snackbar.dart';
import '../widgets/loading_indicator.dart';

/// Admin license management page providing full CRUD and seeding capabilities.
class AdminLicensesView extends StatefulWidget {
  const AdminLicensesView({super.key});

  @override
  State<AdminLicensesView> createState() => _AdminLicensesViewState();
}

class _AdminLicensesViewState extends State<AdminLicensesView> {
  final LicenseService _licenseService = LicenseService();
  final TextEditingController _searchController = TextEditingController();
  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LicenseModel> _filterLicenses(List<LicenseModel> licenses, String query) {
    if (query.isEmpty) return licenses;
    final lowerQuery = query.toLowerCase();
    return licenses.where((license) {
      final name = license.name.toLowerCase();
      final licenseNo = license.licenseNo.toLowerCase();
      final type = license.vehicleType.toLowerCase();
      return name.contains(lowerQuery) ||
          licenseNo.contains(lowerQuery) ||
          type.contains(lowerQuery);
    }).toList();
  }

  Future<void> _seedSampleData() async {
    setState(() => _isSeeding = true);
    try {
      await _licenseService.seedSampleLicenses();
      if (mounted) {
        CustomSnackBar.success(context, 'Successfully seeded 20 RTO licenses!');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.error(context, 'Failed to seed data: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSeeding = false);
      }
    }
  }

  void _showAddEditLicenseDialog({LicenseModel? license}) {
    final isEdit = license != null;
    final formKey = GlobalKey<FormState>();

    final licenseNoController = TextEditingController(text: license?.licenseNo ?? '');
    final nameController = TextEditingController(text: license?.name ?? '');
    final issueDateController = TextEditingController(text: license?.issueDate ?? '');
    final expiryDateController = TextEditingController(text: license?.expiryDate ?? '');

    String vehicleType = license?.vehicleType ?? 'Car';
    String status = license?.status ?? 'Active';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B), // Premium Slate dark background
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isEdit ? 'Edit RTO License' : 'Add RTO License',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // License Number
                      _buildModalLabel('LICENSE NUMBER'),
                      TextFormField(
                        controller: licenseNoController,
                        enabled: !isEdit,
                        style: const TextStyle(color: Colors.white),
                        textCapitalization: TextCapitalization.characters,
                        decoration: _modalInputDecoration(
                          hint: 'e.g. MH100001',
                          icon: Icons.badge_outlined,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'License number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Name
                      _buildModalLabel('FULL NAME'),
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _modalInputDecoration(
                          hint: 'Enter cardholder name',
                          icon: Icons.person_outline,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Vehicle Type & Status Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildModalLabel('VEHICLE TYPE'),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: vehicleType,
                                      isExpanded: true,
                                      dropdownColor: const Color(0xFF0F172A),
                                      style: const TextStyle(color: Colors.white),
                                      items: ['Car', 'SUV', 'Truck', 'Motorcycle', 'Van', 'Bus', 'Other']
                                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                          .toList(),
                                      onChanged: (v) {
                                        if (v != null) setModalState(() => vehicleType = v);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildModalLabel('STATUS'),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: status,
                                      isExpanded: true,
                                      dropdownColor: const Color(0xFF0F172A),
                                      style: const TextStyle(color: Colors.white),
                                      items: ['Active', 'Suspended', 'Expired']
                                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                          .toList(),
                                      onChanged: (v) {
                                        if (v != null) setModalState(() => status = v);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Issue Date
                      _buildModalLabel('ISSUE DATE'),
                      TextFormField(
                        controller: issueDateController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _modalInputDecoration(
                          hint: 'YYYY-MM-DD',
                          icon: Icons.calendar_today_outlined,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Issue date is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Expiry Date
                      _buildModalLabel('EXPIRY DATE'),
                      TextFormField(
                        controller: expiryDateController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _modalInputDecoration(
                          hint: 'YYYY-MM-DD',
                          icon: Icons.event_busy_outlined,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Expiry date is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          
                          final newLicense = LicenseModel(
                            licenseNo: licenseNoController.text.trim().toUpperCase(),
                            name: nameController.text.trim(),
                            vehicleType: vehicleType,
                            issueDate: issueDateController.text.trim(),
                            expiryDate: expiryDateController.text.trim(),
                            status: status,
                          );

                          try {
                            if (isEdit) {
                              await _licenseService.updateLicense(
                                newLicense.licenseNo,
                                newLicense.toMap(),
                              );
                              if (context.mounted) {
                                CustomSnackBar.success(context, 'License updated successfully!');
                              }
                            } else {
                              await _licenseService.addLicense(newLicense.toMap());
                              if (context.mounted) {
                                CustomSnackBar.success(context, 'License added successfully!');
                              }
                            }
                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            if (context.mounted) {
                              CustomSnackBar.error(context, 'Failed to save license: $e');
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminTheme.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isEdit ? 'Save Changes' : 'Create License',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(String licenseNo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text(
            'Delete License',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete the license record $licenseNo? This action cannot be undone.',
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _licenseService.deleteLicense(licenseNo);
                  if (context.mounted) {
                    CustomSnackBar.success(context, 'License deleted successfully.');
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    CustomSnackBar.error(context, 'Failed to delete: $e');
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdminSectionHeader(
          title: 'Licenses Database',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isSeeding)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AdminTheme.accent,
                    ),
                  ),
                )
              else
                IconButton(
                  tooltip: 'Seed sample licenses',
                  icon: const Icon(Icons.storage_rounded, color: AdminTheme.accent),
                  onPressed: _seedSampleData,
                ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditLicenseDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.accent,
                  foregroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.add_card, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
        ),
        AdminGlassSearchBar(
          controller: _searchController,
          hintText: 'Search by license number or name...',
        ),

          Expanded(
            child: StreamBuilder<List<LicenseModel>>(
              stream: _licenseService.streamLicenses().map(
                (snap) => snap.docs
                    .map(
                      (doc) => LicenseModel.fromMap(doc.data(), doc.id),
                    )
                    .toList(),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: AppLoadingIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading licenses: ${snapshot.error}',
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  );
                }

                final allLicenses = snapshot.data ?? [];
                final filteredLicenses = _filterLicenses(allLicenses, _searchController.text);

                if (filteredLicenses.isEmpty) {
                  return AdminEmptyState(
                    message: _searchController.text.isEmpty
                        ? 'No license records found'
                        : 'No licenses match your search',
                  );
                }

                return AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredLicenses.length,
                    itemBuilder: (context, index) {
                      final license = filteredLicenses[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _LicenseCard(
                              license: license,
                              onEdit: () => _showAddEditLicenseDialog(license: license),
                              onDelete: () => _showDeleteConfirmation(license.licenseNo),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
    );
  }

  Widget _buildModalLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 8),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AdminTheme.accent,
          letterSpacing: 1,
        ),
      ),
    );
  }

  InputDecoration _modalInputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.white38),
      fillColor: Colors.white.withOpacity(0.05),
      hintStyle: const TextStyle(color: Colors.white38),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AdminTheme.accent, width: 1.5),
      ),
    );
  }
}

/// Custom premium card UI for RTO driving licenses.
class _LicenseCard extends StatelessWidget {
  final LicenseModel license;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LicenseCard({
    required this.license,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getVehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case 'car':
      case 'suv':
        return Icons.directions_car_rounded;
      case 'motorcycle':
        return Icons.motorcycle_rounded;
      case 'truck':
      case 'van':
        return Icons.local_shipping_rounded;
      case 'bus':
        return Icons.directions_bus_rounded;
      default:
        return Icons.badge_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF10B981); // Emerald Green
      case 'suspended':
        return const Color(0xFFF59E0B); // Amber Yellow
      case 'expired':
        return const Color(0xFFEF4444); // Rose Red
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(license.status);
    final vehicleIcon = _getVehicleIcon(license.vehicleType);

    return AdminGlassBox(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                  ),
                  child: Icon(vehicleIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        license.licenseNo,
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AdminTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        license.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AdminTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    license.status.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _meta(Icons.calendar_today, 'Issued: ${license.issueDate}'),
                _meta(Icons.event_busy, 'Expires: ${license.expiryDate}'),
                _meta(Icons.directions_car_filled_outlined, license.vehicleType),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: AdminTheme.accent),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Color(0xFFF87171)),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AdminTheme.textMuted),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 11, color: AdminTheme.textMuted),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
