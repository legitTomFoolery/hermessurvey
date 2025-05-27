import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:gsecsurvey/app/config/environment_config.dart';
import 'package:gsecsurvey/features/admin/data/models/admin_user_extended_model.dart';

class EnhancedAdminService {
  static final _envConfig = EnvironmentConfig();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get collection references with environment configuration
  static CollectionReference get _usersCollection =>
      _firestore.collection(_envConfig.getCollectionName('users'));

  static CollectionReference get _surveyResponsesCollection =>
      _firestore.collection(_envConfig.getCollectionName('surveyResponses'));

  static CollectionReference get _userSubmissionsCollection =>
      _firestore.collection(_envConfig.getCollectionName('userSubmissions'));

  static CollectionReference get _questionsCollection =>
      _firestore.collection(_envConfig.getCollectionName('questions'));

  // Fetch all users from both Firebase Auth and custom collection
  static Future<List<EnhancedAdminUser>> getAllEnhancedUsers() async {
    try {
      // Get custom users from Firestore
      final customUsersSnapshot = await _usersCollection.get();
      final Map<String, DocumentSnapshot> customUsersMap = {};

      for (var doc in customUsersSnapshot.docs) {
        customUsersMap[doc.id] = doc;
      }

      // Get Firebase Auth users (this requires admin SDK in a real app)
      // For now, we'll work with the current user and any users in our custom collection
      final List<EnhancedAdminUser> allUsers = [];

      // Add users from custom collection
      for (var doc in customUsersSnapshot.docs) {
        final customUser = EnhancedAdminUser.fromFirestore(doc);
        allUsers.add(customUser);
      }

      // Note: In a production app, you would need Firebase Admin SDK to list all auth users
      // For now, we'll simulate this by checking if current user exists in auth
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Check if current user is already in our list
        final existingUserIndex =
            allUsers.indexWhere((user) => user.uid == currentUser.uid);

        if (existingUserIndex >= 0) {
          // Merge auth data with custom data
          final customDoc = customUsersMap[currentUser.uid];
          final mergedUser = EnhancedAdminUser.merge(currentUser, customDoc);
          allUsers[existingUserIndex] = mergedUser;
        } else {
          // Add auth-only user
          final authUser = EnhancedAdminUser.fromFirebaseAuth(currentUser);
          allUsers.add(authUser);
        }
      }

      return allUsers;
    } catch (e) {
      debugPrint('Error fetching enhanced users: $e');
      return [];
    }
  }

  // Toggle admin status for a user
  static Future<bool> toggleAdminStatus(String uid, bool isAdmin) async {
    try {
      await _usersCollection.doc(uid).set({
        'isAdmin': isAdmin,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugPrint('Error toggling admin status: $e');
      return false;
    }
  }

  // Delete a user account (requires admin privileges)
  static Future<bool> deleteUserAccount(String uid) async {
    try {
      // Delete from custom users collection
      await _usersCollection.doc(uid).delete();

      // Note: Deleting from Firebase Auth requires Admin SDK
      // In a production app, you would call a Cloud Function to delete the auth user
      // For now, we'll just remove from our custom collection

      return true;
    } catch (e) {
      debugPrint('Error deleting user account: $e');
      return false;
    }
  }

  // Reset user password (requires admin privileges)
  static Future<bool> resetUserPassword(String email) async {
    try {
      // Send password reset email
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      return false;
    }
  }

  // Create or update user in custom collection
  static Future<bool> createOrUpdateCustomUser(EnhancedAdminUser user) async {
    try {
      await _usersCollection
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Error creating/updating custom user: $e');
      return false;
    }
  }

  // Get submission summary data
  static Future<List<Map<String, dynamic>>> getSubmissionSummary() async {
    try {
      final snapshot = await _userSubmissionsCollection.get();

      List<Map<String, dynamic>> summaryData = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        summaryData.add({
          'email': doc.id,
          'submissionCount': data['submissionCount'] ?? 0,
        });
      }

      return summaryData;
    } catch (e) {
      debugPrint('Error getting submission summary: $e');
      return [];
    }
  }

  // Export collection data as a formatted string
  static Future<String> exportCollectionData(String collectionName) async {
    try {
      CollectionReference collection;

      switch (collectionName) {
        case 'users':
          collection = _usersCollection;
          break;
        case 'surveyResponses':
          collection = _surveyResponsesCollection;
          break;
        case 'userSubmissions':
          collection = _userSubmissionsCollection;
          break;
        case 'questions':
          collection = _questionsCollection;
          break;
        default:
          throw Exception('Unknown collection: $collectionName');
      }

      final snapshot = await collection.get();
      final data = snapshot.docs.map((doc) {
        final docData = doc.data() as Map<String, dynamic>;
        // Add document ID to the data
        return {'id': doc.id, ...docData};
      }).toList();

      if (data.isEmpty) {
        return 'No data found in $collectionName';
      }

      // Create a formatted string representation of the data
      final StringBuffer buffer = StringBuffer();
      buffer.writeln('Data from $collectionName:');
      buffer.writeln('');

      // Add headers
      final headers = data.first.keys.toList();
      buffer.writeln(headers.join('\t'));
      buffer.writeln('-' * 50);

      // Add data rows
      for (var rowData in data) {
        final rowValues = headers.map((header) {
          var value = rowData[header];

          // Handle special data types
          if (value is Timestamp) {
            value = value.toDate().toString();
          } else if (value is Map) {
            value = value.toString();
          } else if (value is List) {
            value = value.toString();
          }

          return value?.toString() ?? 'null';
        }).toList();

        buffer.writeln(rowValues.join('\t'));
      }

      return buffer.toString();
    } catch (e) {
      debugPrint('Error exporting collection data: $e');
      return 'Error: $e';
    }
  }
}
