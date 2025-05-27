import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gsecsurvey/app/config/environment_config.dart';
import 'package:gsecsurvey/features/home/data/models/question.dart';

class FirestoreService {
  static final _envConfig = EnvironmentConfig();

  static CollectionReference<Question> get ref => FirebaseFirestore.instance
      .collection(_envConfig.getCollectionName('questions'))
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
