import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:office_app/models/asset_model.dart';

import 'package:office_app/models/user_model.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'assets';
  static const String _userCollection = 'users';

  static String? get currentUserId => _auth.currentUser?.uid;

  // Get user profile
  static Stream<UserProfile?> getUserProfile() {
    final uid = currentUserId;
    if (uid == null) return Stream.value(null);

    return _db.collection(_userCollection).doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return UserProfile.fromMap(snapshot.data()!, uid);
    });
  }

  // Get profile directly (non-stream)
  static Future<UserProfile?> getUserProfileFuture() async {
    final uid = currentUserId;
    if (uid == null) return null;

    final doc = await _db.collection(_userCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(doc.data()!, uid);
  }

  // Update user profile
  static Future<void> updateUserProfile(UserProfile profile) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    // Sanitize data
    final sanitizedData = {
      'displayName': profile.displayName.trim(),
      'email': profile.email.trim(),
      'phoneNumber': profile.phoneNumber.trim(),
      'designation': profile.designation.trim(),
      'companyName': profile.companyName.trim(),
      'bio': profile.bio.trim(),
      'photoUrl': profile.photoUrl.trim(),
    };

    await _db.collection(_userCollection).doc(uid).set(
          sanitizedData,
          SetOptions(merge: true),
        );
  }

  // Get assets for the current user only
  static Stream<List<AssetRecord>> getAssets() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);
    
    return _db
        .collection(_collection)
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AssetRecord.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Add a single asset with userId
  static Future<void> addAsset(AssetRecord asset) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    String managerName = asset.managedByName;
    if (managerName.isEmpty) {
      final profile = await getUserProfileFuture();
      managerName = profile?.displayName ?? 'System';
    }

    await _db.collection(_collection).add({
      ...asset.toJson(),
      'userId': uid,
      'managedByName': managerName,
    });
  }

  // Bulk add assets with userId
  static Future<int> bulkAddAssets(List<AssetRecord> assets) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    final profile = await getUserProfileFuture();
    final managerName = profile?.displayName ?? 'Bulk Import';

    final batch = _db.batch();
    int count = 0;

    for (var asset in assets) {
      final docRef = _db.collection(_collection).doc();
      batch.set(docRef, {
        ...asset.toJson(),
        'userId': uid,
        'managedByName': asset.managedByName.isEmpty ? managerName : asset.managedByName,
      });
      count++;
      
      if (count % 500 == 0) {
        await batch.commit();
      }
    }

    if (count % 500 != 0) {
      await batch.commit();
    }
    
    return count;
  }

  // Migration: Assign userId to documents that don't have one
  static Future<int> migrateUnclaimedAssets() async {
    final uid = currentUserId;
    if (uid == null) return 0;

    final snapshot = await _db.collection(_collection).where('userId', isNull: true).get();
    if (snapshot.docs.isEmpty) return 0;

    final batch = _db.batch();
    int count = 0;

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'userId': uid});
      count++;
      if (count % 500 == 0) await batch.commit();
    }

    if (count % 500 != 0) await batch.commit();
    return count;
  }

  // Update an asset
  static Future<void> updateAsset(AssetRecord asset) async {
    if (asset.id != null) {
      await _db.collection(_collection).doc(asset.id).update(asset.toJson());
    }
  }

  // Delete an asset
  static Future<void> deleteAsset(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  // Delete multiple assets using a batch
  static Future<void> deleteAssets(List<String> ids) async {
    final batch = _db.batch();
    for (var id in ids) {
      batch.delete(_db.collection(_collection).doc(id));
    }
    await batch.commit();
  }
}
