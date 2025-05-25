import 'package:flutter/material.dart';

class ResponseProvider with ChangeNotifier {
  final Map<String, String> _responses = {};
  List<String> _attendings = [];

  Map<String, String> get responses => _responses;
  List<String> get attendings => _attendings;

  void updateResponse(String questionId, String response) {
    _responses[questionId] = response;
    notifyListeners();
  }

  String? getResponse(String questionId) {
    return _responses[questionId];
  }

  void updateAttendings(List<String> newAttendings) {
    _attendings = newAttendings;
    notifyListeners();
  }

  void clearResponse(String questionId) {
    _responses[questionId] = "";
    notifyListeners();
  }
}
