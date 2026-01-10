import 'package:flutter/material.dart';

import '../connect_api/api_connect.dart';
import '../model/dictionary.dart';

class UserVocabulary extends ChangeNotifier {
  List<UserVocabularyItem> _vocabList = [];
  bool _isLoading = false;

  List<UserVocabularyItem> get vocabList => _vocabList;
  bool get isLoading => _isLoading;

  UserVocabulary(BuildContext context) {
    fetchVocab(context);
  }

  void clear() {
    _vocabList.clear();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchVocab(BuildContext context) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();
    try {
      final List<UserVocabularyItem> newData = await fetchUserDictionary(context);

      _vocabList = newData;
    } catch (e) {
      print("Error fetching vocabulary in provider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadVocab(BuildContext context) async {
    await fetchVocab(context);
  }
}