import 'package:flutter/material.dart';
import 'package:gsecsurvey/models/question.dart';
import 'package:gsecsurvey/services/firestore_service.dart';

class QuestionStore extends ChangeNotifier {
  final List<Question> _questions = [];

  get questions => _questions;

  // add question
  void addQuestion(Question question) async {
    await FirestoreService.addQuestion(question);

    _questions.add(question);
    notifyListeners();
  }

  // remove question
  void removeQuestion(Question question) async {
    await FirestoreService.deleteQuestion(question);

    _questions.remove(question);
    notifyListeners();
  }

  // initially fetch questions
  void fetchQuestionsOnce() async {
    if (questions.length == 0) {
      final snapshot = await FirestoreService.getQuestionsOnce();

      for (var doc in snapshot.docs) {
        _questions.add(doc.data());
      }

      notifyListeners();
    }
  }
}
