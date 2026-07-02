import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/challan_model.dart';
import '../../utils/app_constants.dart';
import '../../widgets/status_badge.dart';

Widget userSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      title.toUpperCase(),
      style: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppConstants.ownerAccent,
        letterSpacing: 1.2,
      ),
    ),
  );
}

Widget userEmptyNote(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      text,
      style: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 13),
    ),
  );
}

Widget userGlassCard({
  required String title,
  required IconData icon,
  required Widget child,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white.withValues(alpha: 0.06),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppConstants.ownerAccent, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppConstants.ownerAccent,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

Widget userChallanTile(ChallanModel c) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      color: Colors.white.withValues(alpha: 0.04),
      border: Border.all(
        color: c.isPending
            ? const Color(0xFFF59E0B).withValues(alpha: 0.35)
            : Colors.white10,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                c.reason,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '₹${c.fineAmount}',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (c.vehicleNumber.isNotEmpty)
          Text(
            c.vehicleNumber,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF94A3B8),
            ),
          ),
        Row(
          children: [
            if (c.issuedDate.isNotEmpty)
              Text(
                c.issuedDate,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
            const Spacer(),
            Text(
              c.displayStatus,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: c.isPaid ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget userDriverTile({
  required String name,
  required String phone,
  required String relation,
  required String status,
  VoidCallback? onEdit,
  VoidCallback? onRemove,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white10),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                phone,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              Text(
                relation,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        StatusBadge(status: status, compact: true),
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF94A3B8), size: 20),
            onPressed: onEdit,
          ),
        if (onRemove != null)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
            onPressed: onRemove,
          ),
      ],
    ),
  );
}
