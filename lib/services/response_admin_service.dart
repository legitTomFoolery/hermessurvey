import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gsecsurvey/core/environment_config.dart';
import 'package:gsecsurvey/models/survey_response.dart';

class ResponseAdminService {
  static final _envConfig = EnvironmentConfig();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get collection reference with environment configuration
  static CollectionReference get _surveyResponsesCollection =>
      _firestore.collection(_envConfig.getCollectionName('surveyResponses'));

  // Fetch all survey responses
  static Future<List<SurveyResponse>> getAllResponses() async {
    try {
      final snapshot = await _surveyResponsesCollection
          .orderBy('timestamp', descending: true)
          .get();

      List<SurveyResponse> responses = [];

      for (var doc in snapshot.docs) {
        try {
          responses.add(SurveyResponse.fromFirestore(doc));
        } catch (e) {
          debugPrint('Error parsing response document ${doc.id}: $e');
          // Continue with other documents even if one fails
        }
      }

      return responses;
    } catch (e) {
      debugPrint('Error fetching survey responses: $e');
      return [];
    }
  }

  // Delete a survey response
  static Future<bool> deleteResponse(String responseId) async {
    try {
      await _surveyResponsesCollection.doc(responseId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting survey response: $e');
      return false;
    }
  }

  // Get responses by date range (optional utility method)
  static Future<List<SurveyResponse>> getResponsesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _surveyResponsesCollection
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('timestamp', descending: true)
          .get();

      List<SurveyResponse> responses = [];

      for (var doc in snapshot.docs) {
        try {
          responses.add(SurveyResponse.fromFirestore(doc));
        } catch (e) {
          debugPrint('Error parsing response document ${doc.id}: $e');
        }
      }

      return responses;
    } catch (e) {
      debugPrint('Error fetching responses by date range: $e');
      return [];
    }
  }

  // Get responses by rotation (optional utility method)
  static Future<List<SurveyResponse>> getResponsesByRotation(
    String rotation,
  ) async {
    try {
      final snapshot = await _surveyResponsesCollection
          .where('responses.2-rotation', isEqualTo: rotation)
          .orderBy('timestamp', descending: true)
          .get();

      List<SurveyResponse> responses = [];

      for (var doc in snapshot.docs) {
        try {
          responses.add(SurveyResponse.fromFirestore(doc));
        } catch (e) {
          debugPrint('Error parsing response document ${doc.id}: $e');
        }
      }

      return responses;
    } catch (e) {
      debugPrint('Error fetching responses by rotation: $e');
      return [];
    }
  }
}
