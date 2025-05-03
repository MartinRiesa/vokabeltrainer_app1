// lib/core/level_manager.dart

import 'dart:async';
import 'dart:math';

import 'package:vokabeltrainer_app/core/vocab_loader.dart';
import 'package:vokabeltrainer_app/core/question_generator.dart';

/// Steuert Level-Fortschritt und Streak-Logik.
class LevelManager {
  static const int levelGoal = 10;
  final Random _rand = Random();

  late final List<Map<String, String>> _pairs;
  int level = 1;
  int streak = 0;

  Future<void> init() async {
    _pairs = await loadWordPairs();
  }

  Question nextQuestion() {
    final maxIndex = (level * 7).clamp(0, _pairs.length);
    final subset = _pairs.sublist(0, maxIndex);
    final pair = subset[_rand.nextInt(subset.length)];
    final en = pair['en']!;
    final correct = pair['de']!;

    final distractors = subset
        .where((p) => p['de'] != correct)
        .map((p) => p['de']!)
        .toList()..shuffle(_rand);

    final wrongOptions = distractors.take(3).toList();
    final options = <String>[correct, ...wrongOptions]..shuffle(_rand);
    final correctIndex = options.indexOf(correct);

    return Question(
      prompt: 'Was bedeutet "$en" auf Deutsch?',
      options: options,
      correctIndex: correctIndex,
    );
  }

  bool answer(Question q, int index) {
    final isCorrect = index == q.correctIndex;
    if (isCorrect) {
      streak++;
      if (streak >= levelGoal) {
        level++;
        streak = 0;
      }
    } else {
      streak = 0;
    }
    return isCorrect;
  }
}
