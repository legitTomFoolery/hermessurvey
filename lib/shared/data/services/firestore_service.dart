import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gsecsurvey/app/config/environment_config.dart';
import 'package:gsecsurvey/features/home/data/models/question_model.dart';

class FirestoreService {
  static final _envConfig = EnvironmentConfig();

  static CollectionReference<Question> get ref => FirebaseFirestore.instance
      .collection(_envConfig.getCollectionName('questions'))
      .withConverter(
          fromFirestore: Question.fromFirestore,
          toFirestore: (Question q, _) => q.toFirestore());

  // add a new question
  static Future<void> addQuestion(Question question) async {
    print('🔥 DEBUG: FirestoreService.addQuestion() called');
    print('🔥 DEBUG: Question ID: ${question.id}');
    print('🔥 DEBUG: Question: $question');
    print('🔥 DEBUG: Question rotationDetails: ${question.rotationDetails}');

    try {
      await ref.doc(question.id).set(question);
      print('🔥 DEBUG: Question successfully saved to Firestore');
    } catch (e) {
      print('🔥 DEBUG: Error saving question to Firestore: $e');
      print('🔥 DEBUG: Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // get questions once with ordering
  static Future<QuerySnapshot<Question>> getQuestionsOnce() {
    return ref.orderBy('name').get();
  }

  // delete a question
  static Future<void> deleteQuestion(Question question) async {
    await ref.doc(question.id).delete();
  }
}
