import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gsecsurvey/models/question.dart';

class FirestoreService {
  static final ref = FirebaseFirestore.instance
      .collection('questions')
      .withConverter(
          fromFirestore: Question.fromFirestore,
          toFirestore: (Question q, _) => q.toFirestore());

  // add a new question
  static Future<void> addQuestion(Question question) async {
    await ref.doc(question.id).set(question);
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
