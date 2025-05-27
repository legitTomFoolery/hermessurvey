import 'package:cloud_firestore/cloud_firestore.dart';

class SurveyResponse {
  final String id;
  final DateTime timestamp;
  final Map<String, String> responses;

  SurveyResponse({
    required this.id,
    required this.timestamp,
    required this.responses,
  });

  factory SurveyResponse.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Parse responses map
    final responsesData = data['responses'] as Map<String, dynamic>? ?? {};
    final responses = <String, String>{};
    responsesData.forEach((key, value) {
      responses[key] = value?.toString() ?? '';
    });

    // Parse timestamp
    DateTime parsedTimestamp;
    if (data['timestamp'] is Timestamp) {
      parsedTimestamp = (data['timestamp'] as Timestamp).toDate();
    } else {
      parsedTimestamp = DateTime.now();
    }

    return SurveyResponse(
      id: doc.id,
      timestamp: parsedTimestamp,
      responses: responses,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'responses': responses,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  String get formattedDate {
    return '${timestamp.month.toString().padLeft(2, '0')}/${timestamp.day.toString().padLeft(2, '0')}/${timestamp.year}';
  }

  String get formattedDateTime {
    return '$formattedDate ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // Extract specific response values
  String get date {
    return responses['1-date'] ?? '';
  }

  String get rotation {
    return responses['2-rotation'] ?? '';
  }

  String get attending {
    return responses['3-attending'] ?? '';
  }

  String get subtitle {
    final parts = <String>[];
    if (rotation.isNotEmpty) parts.add('Rotation: $rotation');
    if (attending.isNotEmpty) parts.add('Attending: $attending');
    if (parts.isEmpty && date.isNotEmpty) parts.add('Date: $date');
    return parts.isEmpty ? 'Survey Response' : parts.join(' • ');
  }

  // Get all question responses excluding the standard fields
  Map<String, String> get questionResponses {
    final filtered = <String, String>{};
    responses.forEach((key, value) {
      // Skip the standard fields (date, rotation, attending)
      if (!key.startsWith('1-date') &&
          !key.startsWith('2-rotation') &&
          !key.startsWith('3-attending')) {
        filtered[key] = value;
      }
    });
    return filtered;
  }
}
