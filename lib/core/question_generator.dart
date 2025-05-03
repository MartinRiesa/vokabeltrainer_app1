// lib/core/question_generator.dart

import 'dart:async';
import 'dart:math';

import 'package:vokabeltrainer_app/core/vocab_loader.dart';

/// Repräsentiert eine einzelne Vokabel-Frage.
class Question {
  final String prompt;
  final List<String> options;    // alle Antwort-Labels
  final int correctIndex;        // Index in `options` der richtigen Antwort

  Question({
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });
}

/// Erzeugt asynchron alle Fragen für ein Level mit genau [levelCount] Vokabeln,
/// jeweils mit 1 korrekter + (numOptions-1) falschen Optionen.
/// Default: 7 Vokabeln pro Level, 4 Optionen pro Frage.
Future<List<Question>> generateQuestions({
  int levelCount = 7,
  int numOptions = 4,
}) async {
  final allPairs = await loadWordPairs();
  // Nur die ersten levelCount Paare verwenden
  final subset = allPairs.take(levelCount).toList();

  final rand = Random();
  final questions = <Question>[];

  for (var pair in subset) {
    final en = pair['en']!;
    final correct = pair['de']!;

    // Füll-Optionen nur aus de-Wörtern der subset
    final distractors = subset
        .where((p) => p['de'] != correct)
        .map((p) => p['de']!)
        .toList()
      ..shuffle(rand);

    // Nimm so viele wie möglich (max numOptions-1)
    final wrongOptions = distractors.take(numOptions - 1).toList();

    // Baue und mische Optionen
    final options = <String>[correct, ...wrongOptions]..shuffle(rand);
    final correctIndex = options.indexOf(correct);

    questions.add(Question(
      prompt: 'Was bedeutet "$en" auf Deutsch?',
      options: options,
      correctIndex: correctIndex,
    ));
  }

  return questions;
}
