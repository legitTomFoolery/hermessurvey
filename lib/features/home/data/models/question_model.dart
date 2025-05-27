import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  // Constructor
  Question({
    required this.name,
    required this.type,
    required this.id,
    required this.options,
    this.rotationDetails, // Additional field to store rotation related data
  });

  // Fields
  final String type;
  final String name;
  final String id;
  final List<String> options;
  final Map<String, List<String>>?
      rotationDetails; // For storing rotation-specific details

  // Convert question details to a map for Firestore
  Map<String, dynamic> toFirestore() {
    print('📄 DEBUG: Question.toFirestore() called');
    print('📄 DEBUG: Question ID: $id');
    print('📄 DEBUG: Question name: $name');
    print('📄 DEBUG: Question type: $type');
    print('📄 DEBUG: Question options: $options');
    print('📄 DEBUG: Question rotationDetails: $rotationDetails');

    final firestoreData = {
      'name': name,
      'type': type,
      'options': options,
      'map':
          rotationDetails, // Save as 'map' to match the field name in Firestore
    };

    print('📄 DEBUG: Final Firestore data: $firestoreData');
    return firestoreData;
  }

  // Create a Question instance from Firestore data
  factory Question.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;

    return Question(
      name: data['name'],
      type: data['type'] ?? 'Unknown', // Handle null or missing type
      id: snapshot.id,
      options: List<String>.from(data['options'] ?? []),
      rotationDetails: data['map'] == null
          ? null
          : (data['map'] as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, List<String>.from(value))),
    );
  }
}
