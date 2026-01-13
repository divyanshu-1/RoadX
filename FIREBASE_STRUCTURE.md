# RoadX Firebase Collection Structure

This document outlines the complete Firebase Firestore collection structure for the RoadX application.

## Collections Overview

1. **users** - User accounts
2. **vehicles** - Registered vehicles
3. **vehicle_documents** - Vehicle documents (Insurance, PUC, RC)
4. **drivers** - Authorized drivers
5. **incidents** - Reported incidents
6. **challans** - Traffic challans (for future implementation)

---

## 1. users Collection

**Path:** `users/{uid}`

**Document Structure:**
```json
{
  "uid": "string (document ID)",
  "name": "string (optional)",
  "email": "string (required)",
  "isAdmin": "boolean (default: false)",
  "createdAt": "timestamp (server timestamp)"
}
```

**Example:**
```json
{
  "uid": "abc123xyz",
  "name": "John Doe",
  "email": "john@example.com",
  "isAdmin": false,
  "createdAt": "2024-01-15T10:30:00Z"
}
```

**Indexes Required:**
- None (single document queries by uid)

---

## 2. vehicles Collection

**Path:** `vehicles/{vehicleId}`

**Document Structure:**
```json
{
  "vehicleId": "string (document ID)",
  "owner_uid": "string (required, references users.uid)",
  "engine_no": "string (required)",
  "chassis_no": "string (required)",
  "vehicle_no": "string (required, format: MH12AB1234)",
  "model": "string (required, one of: Sedan, SUV, Hatchback, Coupe, Convertible, Wagon, Van, Truck, Motorcycle, Other)",
  "createdAt": "timestamp (server timestamp)"
}
```

**Example:**
```json
{
  "vehicleId": "veh_abc123",
  "owner_uid": "abc123xyz",
  "engine_no": "ENG123456789",
  "chassis_no": "CHS987654321",
  "vehicle_no": "MH12AB1234",
  "model": "Sedan",
  "createdAt": "2024-01-15T10:35:00Z"
}
```

**Indexes Required:**
- `owner_uid` (for querying user's vehicles)

**Query Example:**
```dart
FirebaseFirestore.instance
  .collection('vehicles')
  .where('owner_uid', isEqualTo: userId)
  .snapshots()
```

---

## 3. vehicle_documents Collection

**Path:** `vehicle_documents/{documentId}`

**Document Structure:**
```json
{
  "documentId": "string (document ID)",
  "vehicleId": "string (required, references vehicles.vehicleId)",
  "insurance_url": "string (optional, Firebase Storage URL)",
  "insurance_expiry": "timestamp (optional)",
  "puc_url": "string (optional, Firebase Storage URL)",
  "puc_expiry": "timestamp (optional)",
  "rc_url": "string (optional, Firebase Storage URL)",
  "rc_expiry": "timestamp (optional)",
  "createdAt": "timestamp (server timestamp)"
}
```

**Example:**
```json
{
  "documentId": "doc_xyz789",
  "vehicleId": "veh_abc123",
  "insurance_url": "https://firebasestorage.googleapis.com/.../insurance.jpg",
  "insurance_expiry": "2025-12-31T23:59:59Z",
  "puc_url": "https://firebasestorage.googleapis.com/.../puc.jpg",
  "puc_expiry": "2024-06-30T23:59:59Z",
  "rc_url": "https://firebasestorage.googleapis.com/.../rc.jpg",
  "rc_expiry": "2026-01-15T23:59:59Z",
  "createdAt": "2024-01-15T10:40:00Z"
}
```

**Indexes Required:**
- `vehicleId` (for querying vehicle documents)

**Query Example:**
```dart
FirebaseFirestore.instance
  .collection('vehicle_documents')
  .where('vehicleId', isEqualTo: vehicleId)
  .snapshots()
```

**Storage Path:**
- `vehicle_documents/{vehicleId}/{documentType}_{timestamp}.jpg`

---

## 4. drivers Collection

**Path:** `drivers/{driverId}`

**Document Structure:**
```json
{
  "driverId": "string (document ID)",
  "vehicleId": "string (required, references vehicles.vehicleId)",
  "name": "string (required)",
  "phone": "string (required)",
  "dl_number": "string (required, Driving License Number)",
  "dl_expiry": "timestamp (required)",
  "isActive": "boolean (required, default: true, ON/OFF driver control)",
  "createdAt": "timestamp (server timestamp)"
}
```

**Example:**
```json
{
  "driverId": "drv_abc456",
  "vehicleId": "veh_abc123",
  "name": "Rajesh Kumar",
  "phone": "+919876543210",
  "dl_number": "DL1234567890123",
  "dl_expiry": "2027-05-20T23:59:59Z",
  "isActive": true,
  "createdAt": "2024-01-15T10:45:00Z"
}
```

**Indexes Required:**
- `vehicleId` (for querying vehicle drivers)
- `isActive` (optional, for filtering active drivers)

**Query Example:**
```dart
FirebaseFirestore.instance
  .collection('drivers')
  .where('vehicleId', isEqualTo: vehicleId)
  .where('isActive', isEqualTo: true)
  .snapshots()
```

---

## 5. incidents Collection

**Path:** `incidents/{incidentID}`

**Document Structure:**
```json
{
  "incidentID": "string (document ID)",
  "userId": "string (required, references users.uid)",
  "vehicle_no": "string (required)",
  "type": "string (required, one of: theft, scam_fraud, unauthorized_driver, other)",
  "owner_name": "string (required)",
  "timestamp": "timestamp (server timestamp)"
}
```

**Example:**
```json
{
  "incidentID": "inc_xyz123",
  "userId": "abc123xyz",
  "vehicle_no": "MH12AB1234",
  "type": "theft",
  "owner_name": "John Doe",
  "timestamp": "2024-01-15T11:00:00Z"
}
```

**Indexes Required:**
- `userId` + `timestamp` (composite index for user incidents)
- `timestamp` (for ordering incidents)

**Query Example:**
```dart
FirebaseFirestore.instance
  .collection('incidents')
  .where('userId', isEqualTo: userId)
  .orderBy('timestamp', descending: true)
  .snapshots()
```

---

## 6. challans Collection (Future Implementation)

**Path:** `challans/{challanId}`

**Document Structure:**
```json
{
  "challanId": "string (document ID)",
  "vehicleId": "string (required, references vehicles.vehicleId)",
  "amount": "number (required, in rupees)",
  "status": "string (required, one of: Paid, Pending)",
  "issuedDate": "timestamp (required)"
}
```

**Example:**
```json
{
  "challanId": "chl_abc789",
  "vehicleId": "veh_abc123",
  "amount": 500,
  "status": "Pending",
  "issuedDate": "2024-01-15T12:00:00Z"
}
```

**Indexes Required:**
- `vehicleId` (for querying vehicle challans)
- `status` (optional, for filtering by status)

---

## Firestore Security Rules (Recommended)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Vehicles - owners can read/write their own, admins can read all
    match /vehicles/{vehicleId} {
      allow read: if request.auth != null && 
        (resource.data.owner_uid == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true);
      allow create: if request.auth != null && 
        request.resource.data.owner_uid == request.auth.uid;
      allow update, delete: if request.auth != null && 
        resource.data.owner_uid == request.auth.uid;
    }
    
    // Vehicle Documents - owners can read/write their vehicle's documents
    match /vehicle_documents/{docId} {
      allow read, write: if request.auth != null && 
        (resource.data.vehicleId in 
         get(/databases/$(database)/documents/vehicles).where('owner_uid', '==', request.auth.uid).data.vehicleId ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true);
    }
    
    // Drivers - owners can read/write drivers for their vehicles
    match /drivers/{driverId} {
      allow read, write: if request.auth != null && 
        (resource.data.vehicleId in 
         get(/databases/$(database)/documents/vehicles).where('owner_uid', '==', request.auth.uid).data.vehicleId ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true);
    }
    
    // Incidents - users can create, read their own; admins can read all
    match /incidents/{incidentId} {
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true);
    }
    
    // Challans - owners can read their vehicle's challans
    match /challans/{challanId} {
      allow read: if request.auth != null && 
        (resource.data.vehicleId in 
         get(/databases/$(database)/documents/vehicles).where('owner_uid', '==', request.auth.uid).data.vehicleId ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true);
    }
  }
}
```

---

## Required Firestore Indexes

Create these composite indexes in Firebase Console:

1. **incidents collection:**
   - Fields: `userId` (Ascending), `timestamp` (Descending)

2. **drivers collection:**
   - Fields: `vehicleId` (Ascending), `isActive` (Ascending) [Optional]

3. **challans collection:**
   - Fields: `vehicleId` (Ascending), `status` (Ascending) [Future]

---

## Data Relationships

```
users (1) ──< (many) vehicles
vehicles (1) ──< (many) vehicle_documents
vehicles (1) ──< (many) drivers
vehicles (1) ──< (many) challans
users (1) ──< (many) incidents
```

---

## Notes

1. **Document IDs:** Use auto-generated IDs for all collections except where specified
2. **Timestamps:** Always use `FieldValue.serverTimestamp()` for consistency
3. **References:** Use string references (not Firestore references) for cross-collection links
4. **Validation:** Validate data on client side before writing to Firestore
5. **Indexes:** Create indexes before deploying to production to avoid query errors

---

## Migration Notes

If migrating from old structure:
- Old: `users/{uid}/vehicles/{vehicleId}` → New: `vehicles/{vehicleId}` with `owner_uid` field
- Old: `vehicles/{vehicleId}/authorizedUsers/{userId}` → New: `drivers/{driverId}` with `vehicleId` field
- Old: `incident` collection → New: `incidents` collection with updated structure
