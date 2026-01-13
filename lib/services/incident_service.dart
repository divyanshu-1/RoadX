import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class IncidentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Get user's vehicles from Firestore
  Future<List<Map<String, dynamic>>> getUserVehicles() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('vehicles')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'carName': data['carName'] ?? '',
        'numberPlate': data['numberPlate'] ?? '',
        ...data,
      };
    }).toList();
  }

  /// Get placeholder location (location feature temporarily disabled)
  Future<Map<String, double>> getCurrentLocation() async {
    // Placeholder location - can be updated later when location permissions are handled
    // Using default coordinates (can be set to user's default location or city center)
    return {
      'lat': 19.0760, // Default to Mumbai coordinates - update as needed
      'lng': 72.8777,
    };
  }

  /// Get owner contact details from Firestore
  Future<Map<String, String>> getOwnerContactDetails() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    final userDoc = await _firestore.collection('users').doc(uid).get();
    final userData = userDoc.data() ?? {};

    final user = _auth.currentUser;
    return {
      'email': user?.email ?? userData['email'] ?? '',
      'phone': userData['phone'] ?? '',
      'name': userData['name'] ?? user?.displayName ?? '',
    };
  }

  /// Upload driver photo and return download URL
  Future<String?> uploadDriverPhoto(File imageFile, String incidentId) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      final ref = _storage
          .ref()
          .child('incidents')
          .child(incidentId)
          .child('driver_photo.jpg');

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  /// Report an incident directly to Firestore
  /// (Cloud Function call removed - can be added back later when needed)
  Future<String> reportIncident({
    required String vehicleId,
    required String type,
    required Map<String, double> location,
    required Map<String, String> ownerContact,
    String? driverName,
    String? driverLicenseNumber,
    String? notes,
    String? driverPhotoUrl,
    String? otherDetails,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      // Verify vehicle belongs to owner
      final vehicleDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('vehicles')
          .doc(vehicleId)
          .get();

      if (!vehicleDoc.exists) {
        throw Exception('Vehicle not found or not owned by user');
      }

      // Create incident document directly in Firestore
      final incidentRef = _firestore.collection('incidents').doc();
      final incidentId = incidentRef.id;

      // Store incident data
      await incidentRef.set({
        'incidentId': incidentId,
        'vehicleId': vehicleId,
        'ownerId': uid,
        'type': type,
        'location': {
          'lat': location['lat'],
          'lng': location['lng'],
          'geohash': 'placeholder', // Location feature disabled
        },
        'timestamp': FieldValue.serverTimestamp(),
        'ownerContact': ownerContact,
        'status': 'reported',
        'driverName': driverName,
        'driverLicenseNumber': driverLicenseNumber,
        'notes': notes,
        'driverPhotoUrl': driverPhotoUrl,
        'otherDetails': otherDetails,
        'acknowledgedBy': null,
        'acknowledgedAt': null,
        'responderName': null,
        'eta': null,
        'resolvedAt': null,
      });

      // Note: Cloud Function features (nearby station finding, SMS alerts, push notifications)
      // are disabled for now. Can be enabled by calling Cloud Function instead of direct Firestore write.

      return incidentId;
    } catch (e) {
      throw Exception('Failed to report incident: $e');
    }
  }

  /// Get incidents for current user
  Stream<QuerySnapshot> getUserIncidents() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('incidents')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Get a single incident by ID
  Future<DocumentSnapshot> getIncident(String incidentId) async {
    return await _firestore.collection('incidents').doc(incidentId).get();
  }

  /// Cancel an incident (within cancel window)
  Future<void> cancelIncident(String incidentId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    await _firestore.collection('incidents').doc(incidentId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  /// Format incident status for display
  String getStatusDisplay(String status) {
    switch (status) {
      case 'reported':
        return 'Reported';
      case 'acknowledged':
        return 'Acknowledged';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  /// Get status color
  Color getStatusColor(String status) {
    switch (status) {
      case 'reported':
        return const Color(0xFFFF6B6B); // Red
      case 'acknowledged':
        return const Color(0xFF4ECDC4); // Teal
      case 'in_progress':
        return const Color(0xFFFFD93D); // Yellow
      case 'resolved':
        return const Color(0xFF6BCF7F); // Green
      case 'cancelled':
        return const Color(0xFF95A5A6); // Grey
      default:
        return const Color(0xFF95A5A6);
    }
  }
}

