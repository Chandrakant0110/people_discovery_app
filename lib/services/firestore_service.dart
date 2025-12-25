import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:people_discovery_app/models/user_model.dart';
import 'package:people_discovery_app/models/portfolio_model.dart';

/// Service for interacting with Cloud Firestore
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference _portfoliosCollection(String userId) =>
      _firestore.collection('portfolios').doc(userId).collection('items');

  /// Check if user profile exists
  Future<bool> userProfileExists(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('[FirestoreService] Error checking user profile: $e');
      return false;
    }
  }

  /// Get user profile by ID
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('[FirestoreService] Error getting user profile: $e');
      return null;
    }
  }

  /// Create or update user profile
  Future<bool> createOrUpdateUserProfile(UserModel user) async {
    try {
      await _usersCollection.doc(user.userId).set(
            user.toFirestore(),
            SetOptions(merge: true),
          );
      return true;
    } catch (e) {
      print('[FirestoreService] Error creating/updating user profile: $e');
      return false;
    }
  }

  /// Update user profile (partial update)
  Future<bool> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _usersCollection.doc(userId).update(updates);
      return true;
    } catch (e) {
      print('[FirestoreService] Error updating user profile: $e');
      return false;
    }
  }

  /// Stream user profile changes
  Stream<UserModel?> streamUserProfile(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Add portfolio item
  Future<String?> addPortfolioItem(PortfolioItem item) async {
    try {
      final docRef = await _portfoliosCollection(item.userId).add(
        item.toFirestore(),
      );
      
      // Update user's project count
      await _incrementProjectCount(item.userId);
      
      return docRef.id;
    } catch (e) {
      print('[FirestoreService] Error adding portfolio item: $e');
      return null;
    }
  }

  /// Get all portfolio items for a user
  Future<List<PortfolioItem>> getPortfolioItems(String userId) async {
    try {
      final querySnapshot = await _portfoliosCollection(userId)
          .orderBy('order')
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => PortfolioItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('[FirestoreService] Error getting portfolio items: $e');
      return [];
    }
  }

  /// Stream portfolio items for a user
  Stream<List<PortfolioItem>> streamPortfolioItems(String userId) {
    return _portfoliosCollection(userId)
        .orderBy('order')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PortfolioItem.fromFirestore(doc))
            .toList());
  }

  /// Delete portfolio item
  Future<bool> deletePortfolioItem(String userId, String portfolioId) async {
    try {
      await _portfoliosCollection(userId).doc(portfolioId).delete();
      
      // Update user's project count
      await _decrementProjectCount(userId);
      
      return true;
    } catch (e) {
      print('[FirestoreService] Error deleting portfolio item: $e');
      return false;
    }
  }

  /// Update portfolio item
  Future<bool> updatePortfolioItem(
    String userId,
    String portfolioId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _portfoliosCollection(userId).doc(portfolioId).update(updates);
      return true;
    } catch (e) {
      print('[FirestoreService] Error updating portfolio item: $e');
      return false;
    }
  }

  /// Increment user's project count
  Future<void> _incrementProjectCount(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'projectCount': FieldValue.increment(1),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('[FirestoreService] Error incrementing project count: $e');
    }
  }

  /// Decrement user's project count
  Future<void> _decrementProjectCount(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'projectCount': FieldValue.increment(-1),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('[FirestoreService] Error decrementing project count: $e');
    }
  }

  /// Update last seen timestamp
  Future<void> updateLastSeen(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'lastSeen': Timestamp.now(),
      });
    } catch (e) {
      print('[FirestoreService] Error updating last seen: $e');
    }
  }
}

