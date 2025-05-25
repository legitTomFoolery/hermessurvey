import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gsecsurvey/core/environment_config.dart';
import 'package:gsecsurvey/models/admin_user.dart';

class AdminService {
  static final _envConfig = EnvironmentConfig();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get collection references with environment configuration
  static CollectionReference get _usersCollection =>
      _firestore.collection(_envConfig.getCollectionName('users'));

  static CollectionReference get _surveyResponsesCollection =>
      _firestore.collection(_envConfig.getCollectionName('surveyResponses'));

  static CollectionReference get _userSubmissionsCollection =>
      _firestore.collection(_envConfig.getCollectionName('userSubmissions'));

  static CollectionReference get _questionsCollection =>
      _firestore.collection(_envConfig.getCollectionName('questions'));

  // Fetch all users from Firestore
  static Future<List<AdminUser>> getAllUsers() async {
    try {
      final snapshot = await _usersCollection.get();

      // Get current Firebase Auth users
      List<AdminUser> users = [];

      // Create admin users from Firestore documents
      for (var doc in snapshot.docs) {
        users.add(AdminUser.fromFirestore(doc));
      }

      return users;
    } catch (e) {
      debugPrint('Error fetching users: $e');
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
