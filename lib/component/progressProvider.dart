import 'package:beelingual_app/controller/progressController.dart';
import 'package:flutter/material.dart';

class ProgressProvider extends ChangeNotifier {
  String _currentLevel = "Level 1";
  double _topicProgressBarPercentage = 0.0;
  bool _isLoading = false;

  String get currentLevel => _currentLevel;
  double get topicProgressBarPercentage => _topicProgressBarPercentage;
  bool get isLoading => _isLoading;

  ProgressProvider(BuildContext context) {
    Future.delayed(Duration.zero, () => fetchProgress(context, notifyOnStart: false));
  }

  Future<void> fetchProgress(BuildContext context, {bool notifyOnStart = true}) async {
    if (notifyOnStart) {
      _isLoading = true;
      Future.microtask(() => notifyListeners());
    }

    try {
      final progressData = await fetchUserProgress(context);

      if (progressData != null) {
        _currentLevel = "Tổng quan";
        var rawPercent = progressData['percent'];

        if (rawPercent is num) {
          _topicProgressBarPercentage = rawPercent.toDouble();
        } else {
          _topicProgressBarPercentage = 0.0;
        }

      } else {
        _currentLevel = "Tổng quan";
        _topicProgressBarPercentage = 0.0;
      }
    } catch (e) {
      print("Error fetching progress: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> reloadProgress(BuildContext context) async {
    await fetchProgress(context);
  }

  void clear() {
    _currentLevel = "Level 1";
    _topicProgressBarPercentage = 0.0;
    _isLoading = false;
    notifyListeners();
  }
}