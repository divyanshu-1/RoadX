const functions = require('firebase-functions');
const admin = require('firebase-admin');
const geohash = require('geohash');
const twilio = require('twilio');

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// Helper function to calculate distance between two coordinates (Haversine formula)
function getDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Radius of the Earth in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  const distance = R * c; // Distance in km
  return distance;
}

// Find nearby police stations or patrol units within radius (km)
// Location feature temporarily disabled - returns empty array for now
async function findNearbyStations(lat, lng, radiusKm = 5) {
  // Temporarily disabled location-based station finding
  // Returns empty array - can be enabled later when location permissions are properly handled
  return [];
  
  /* Original implementation commented out - can be re-enabled later:
  const incidentGeohash = geohash.encode(lat, lng, 7); // Precision ~0.6km
  
  const nearbyStations = [];
  
  try {
    // Query police_stations collection
    const stationsSnapshot = await db.collection('police_stations')
      .where('geohash', '>=', incidentGeohash.substring(0, 4))
      .where('geohash', '<=', incidentGeohash.substring(0, 4) + '\uf8ff')
      .get();
    
    stationsSnapshot.forEach(doc => {
      const station = doc.data();
      if (station.location && station.location.lat && station.location.lng) {
        const distance = getDistance(lat, lng, station.location.lat, station.location.lng);
        if (distance <= radiusKm) {
          nearbyStations.push({
            id: doc.id,
            ...station,
            distance: distance
          });
        }
      }
    });
    
    // Query patrols collection
    const patrolsSnapshot = await db.collection('patrols')
      .where('geohash', '>=', incidentGeohash.substring(0, 4))
      .where('geohash', '<=', incidentGeohash.substring(0, 4) + '\uf8ff')
      .where('status', '==', 'active')
      .get();
    
    patrolsSnapshot.forEach(doc => {
      const patrol = doc.data();
      if (patrol.location && patrol.location.lat && patrol.location.lng) {
        const distance = getDistance(lat, lng, patrol.location.lat, patrol.location.lng);
        if (distance <= radiusKm) {
          nearbyStations.push({
            id: doc.id,
            ...patrol,
            distance: distance,
            type: 'patrol'
          });
        }
      }
    });
    
    // Sort by distance
    nearbyStations.sort((a, b) => a.distance - b.distance);
    
    return nearbyStations;
  } catch (error) {
    console.error('Error finding nearby stations:', error);
    return [];
  }
  */
}

// Send FCM push notifications to nearby stations
async function sendPushNotifications(nearbyStations, incidentData) {
  const notifications = [];
  
  for (const station of nearbyStations) {
    if (station.fcmToken) {
      const message = {
        notification: {
          title: `Emergency: ${incidentData.type}`,
          body: `Incident reported at ${incidentData.location.lat.toFixed(4)}, ${incidentData.location.lng.toFixed(4)}`,
        },
        data: {
          type: 'incident',
          incidentId: incidentData.incidentId,
          incidentType: incidentData.type,
          lat: incidentData.location.lat.toString(),
          lng: incidentData.location.lng.toString(),
          vehicleId: incidentData.vehicleId,
        },
        token: station.fcmToken,
      };
      
      notifications.push(
        messaging.send(message).catch(error => {
          console.error(`Error sending notification to ${station.id}:`, error);
          return null;
        })
      );
    }
  }
  
  await Promise.all(notifications);
}

// Send SMS alerts via Twilio
async function sendSMSAlerts(nearbyStations, ownerContact, incidentData) {
  const accountSid = functions.config().twilio?.account_sid;
  const authToken = functions.config().twilio?.auth_token;
  const fromNumber = functions.config().twilio?.from_number;
  
  if (!accountSid || !authToken || !fromNumber) {
    console.warn('Twilio not configured. Skipping SMS alerts.');
    return;
  }
  
  const client = twilio(accountSid, authToken);
  const smsPromises = [];
  
  // Send SMS to nearby stations
  for (const station of nearbyStations) {
    if (station.phone) {
      const distanceText = station.distance ? `${station.distance.toFixed(2)}km` : 'unknown distance';
      const message = `EMERGENCY ALERT: ${incidentData.type} reported. Location: ${incidentData.location.lat}, ${incidentData.location.lng}. Distance: ${distanceText}. Incident ID: ${incidentData.incidentId}`;
      
      smsPromises.push(
        client.messages.create({
          body: message,
          from: fromNumber,
          to: station.phone
        }).catch(error => {
          console.error(`Error sending SMS to ${station.phone}:`, error);
          return null;
        })
      );
    }
  }
  
  // Send SMS to owner's emergency contacts if available
  // This would require an emergency_contacts field in user document
  // For now, we'll skip this part
  
  await Promise.all(smsPromises);
}

// Report Incident Cloud Function
exports.reportIncident = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const ownerId = context.auth.uid;
  const {
    vehicleId,
    type,
    location,
    ownerContact,
    driverName,
    driverLicenseNumber,
    notes,
    driverPhotoUrl,
    otherDetails
  } = data;
  
  // Validate required fields (location is optional for now)
  if (!vehicleId || !type || !ownerContact) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
  }
  
  // Use placeholder location if not provided
  const incidentLocation = location || { lat: 19.0760, lng: 72.8777 }; // Default to Mumbai
  
  try {
    // Verify vehicle belongs to owner
    const vehicleDoc = await db.collection('users').doc(ownerId)
      .collection('vehicles').doc(vehicleId).get();
    
    if (!vehicleDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Vehicle not found or not owned by user');
    }
    
    // Calculate geohash for location (if location is provided, otherwise use placeholder)
    const incidentGeohash = incidentLocation.lat && incidentLocation.lng 
      ? geohash.encode(incidentLocation.lat, incidentLocation.lng, 9)
      : 'placeholder';
    
    // Create incident document
    const incidentRef = db.collection('incidents').doc();
    const incidentId = incidentRef.id;
    const timestamp = admin.firestore.FieldValue.serverTimestamp();
    
    const incidentData = {
      incidentId,
      vehicleId,
      ownerId,
      type,
      location: {
        lat: incidentLocation.lat,
        lng: incidentLocation.lng,
        geohash: incidentGeohash
      },
      timestamp,
      ownerContact,
      status: 'reported',
      driverName: driverName || null,
      driverLicenseNumber: driverLicenseNumber || null,
      notes: notes || null,
      driverPhotoUrl: driverPhotoUrl || null,
      otherDetails: otherDetails || null,
      acknowledgedBy: null,
      acknowledgedAt: null,
      resolvedAt: null,
      eta: null
    };
    
    await incidentRef.set(incidentData);
    
    // Find nearby police stations and patrols (returns empty array for now)
    const nearbyStations = await findNearbyStations(incidentLocation.lat, incidentLocation.lng, 5);
    
    // Send push notifications (will be empty for now since nearbyStations is empty)
    await sendPushNotifications(nearbyStations, {
      ...incidentData,
      incidentId,
      location: incidentLocation
    });
    
    // Send SMS alerts (will be empty for now since nearbyStations is empty)
    await sendSMSAlerts(nearbyStations, ownerContact, {
      ...incidentData,
      incidentId,
      location: incidentLocation
    });
    
    return { incidentId, nearbyStationsCount: nearbyStations.length };
  } catch (error) {
    console.error('Error reporting incident:', error);
    throw new functions.https.HttpsError('internal', 'Failed to report incident', error);
  }
});

// Acknowledge Incident Cloud Function
exports.acknowledgeIncident = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const { incidentId, responderId, responderName, eta } = data;
  
  if (!incidentId || !responderId) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
  }
  
  try {
    const incidentRef = db.collection('incidents').doc(incidentId);
    const incidentDoc = await incidentRef.get();
    
    if (!incidentDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Incident not found');
    }
    
    const updateData = {
      status: 'acknowledged',
      acknowledgedBy: responderId,
      acknowledgedAt: admin.firestore.FieldValue.serverTimestamp(),
      responderName: responderName || null,
      eta: eta || null
    };
    
    await incidentRef.update(updateData);
    
    // Send notification to owner
    const incidentData = incidentDoc.data();
    const ownerDoc = await db.collection('users').doc(incidentData.ownerId).get();
    const ownerData = ownerDoc.data();
    
    if (ownerData && ownerData.fcmToken) {
      await messaging.send({
        notification: {
          title: 'Incident Acknowledged',
          body: `${responderName || 'Authority'} is responding to your incident`,
        },
        data: {
          type: 'incident_acknowledged',
          incidentId: incidentId
        },
        token: ownerData.fcmToken
      });
    }
    
    return { success: true };
  } catch (error) {
    console.error('Error acknowledging incident:', error);
    throw new functions.https.HttpsError('internal', 'Failed to acknowledge incident', error);
  }
});

// Update incident status (for resolving incidents)
exports.updateIncidentStatus = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const { incidentId, status } = data;
  
  if (!incidentId || !status) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
  }
  
  if (!['acknowledged', 'in_progress', 'resolved'].includes(status)) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid status');
  }
  
  try {
    const incidentRef = db.collection('incidents').doc(incidentId);
    const updateData = {
      status: status
    };
    
    if (status === 'resolved') {
      updateData.resolvedAt = admin.firestore.FieldValue.serverTimestamp();
    }
    
    await incidentRef.update(updateData);
    
    return { success: true };
  } catch (error) {
    console.error('Error updating incident status:', error);
    throw new functions.https.HttpsError('internal', 'Failed to update incident status', error);
  }
});

