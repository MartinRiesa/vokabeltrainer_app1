// lib/core/level_manager.dart

import 'dart:async';
import 'dart:math';

import 'package:vokabeltrainer_app/core/vocab_loader.dart';
import 'package:vokabeltrainer_app/core/question_generator.dart';

/// Steuert Level-Fortschritt und Streak-Logik.
class LevelManager {
  static const int levelGoal = 10;    // 10 richtige in Folge nötig
  final Random _rand = Random();

  late final List<Map<String, String>> _pairs;
  int level = 1;
  int streak = 0;

  /// Muss vor Verwendung aufgerufen werden, lädt alle Wortpaare.
  Future<void> init() async {
    _pairs = await loadWordPairs();
  }

  /// Erzeugt eine neue Frage aus den ersten (level * 7) Vokabeln.
  Question nextQuestion() {
    final maxIndex = (level * 7).clamp(0, _pairs.length);
    final subset = _pairs.sublist(0, maxIndex);
    // zufälliges Paar auswählen
    final pair = subset[_rand.nextInt(subset.length)];
    final en = pair['en']!;
    final correct = pair['de']!;

    // Distraktoren aus de-Wörtern im selben Subset
    final distractors = subset
        .where((p) => p['de'] != correct)
        .map((p) => p['de']!)
        .toList()
      ..shuffle(_rand);

    final wrongOptions = distractors.take(3).toList();
    final options = <String>[correct, ...wrongOptions]..shuffle(_rand);
    final correctIndex = options.indexOf(correct);

    return Question(
      prompt: 'Was bedeutet "$en" auf Deutsch?',
      options: options,
      correctIndex: correctIndex,
    );
  }

  /// Verarbeitet eine Antwort; gibt true zurück, wenn richtig.
  /// Bei richtig: streak++; bei false: streak = 0.
  /// Erreicht streak == levelGoal, steigt level++ und streak zurückgesetzt.
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
