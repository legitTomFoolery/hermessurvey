import 'package:flutter/material.dart';
import 'package:gsecsurvey/features/home/data/models/question_model.dart';
import 'package:gsecsurvey/shared/data/services/firestore_service.dart';

class QuestionStore extends ChangeNotifier {
  final List<Question> _questions = [];
  bool _hasLoaded = false;
  bool _isLoading = false;

  List<Question> get questions => List.unmodifiable(_questions);
  bool get isLoading => _isLoading;

  void addQuestion(Question question) async {
    await FirestoreService.addQuestion(question);
    _questions.add(question);
    notifyListeners();
  }

  void removeQuestion(Question question) async {
    await FirestoreService.deleteQuestion(question);
    _questions.remove(question);
    notifyListeners();
  }

  Future<void> fetchQuestionsOnce() async {
    if (!_hasLoaded && !_isLoading) {
      _isLoading = true;
      notifyListeners();

      try {
        _questions.clear();
        final snapshot = await FirestoreService.getQuestionsOnce();

        final List<Question> newQuestions = [];
        for (var doc in snapshot.docs) {
          newQuestions.add(doc.data());
        }

        // Sort questions numerically by the number before the first hyphen
        newQuestions.sort((a, b) {
          final aNum = int.tryParse(a.id.split('-').first) ?? 0;
          final bNum = int.tryParse(b.id.split('-').first) ?? 0;
          return aNum.compareTo(bNum);
        });

        // Update questions list
        _questions
          ..clear()
          ..addAll(newQuestions);

        _hasLoaded = true;
      } catch (e) {
        _hasLoaded = false;
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void reset() {
    _questions.clear();
    _hasLoaded = false;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _questions.clear();
    _hasLoaded = false;
    _isLoading = false;
    super.dispose();
  }
}
