import 'package:flutter/material.dart';

/// Shared colors and layout constants for dark modern UI.
class AppConstants {
  static const Color ownerAccent = Color(0xFF10B981);
  static const Color rtoAccent = Color(0xFFF59E0B);
  static const Color darkBgStart = Color(0xFF0F172A);
  static const Color darkBgEnd = Color(0xFF1E293B);

  static const Gradient darkBackground = LinearGradient(
    colors: [darkBgStart, darkBgEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const String rtdbUrl =
      'https://mainroadx-default-rtdb.firebaseio.com/';

  static const List<String> vehicleTypes = [
    'Two Wheeler',
    'Three Wheeler',
    'Car / Sedan',
    'SUV',
    'Truck',
    'Bus',
    'Other',
  ];

  static const List<String> violationTypes = [
    'Red Light Violation',
    'Over-speeding',
    'Drunk Driving',
    'No Helmet / Seatbelt',
    'Expired Insurance / PUC',
    'Dangerous Driving',
    'Illegal Parking',
    'Wrong Lane Driving',
  ];

  // RTO portal login (local validation + Firebase Anonymous Auth)
  static const String demoRtoOfficerId = 'RTO-8910';
  static const String demoRtoPasscode = '8910';
  static const String demoRtoEmail = 'rto.officer@roadx.demo';
  static const String demoRtoPassword = 'Rto@8910';
}
