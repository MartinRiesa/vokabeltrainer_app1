// lib/core/level_manager.dart

import 'dart:async';
import 'dart:math';

import 'package:vokabeltrainer_app/core/vocab_loader.dart';
import 'package:vokabeltrainer_app/core/vocab_pair.dart';
import 'package:vokabeltrainer_app/core/question_generator.dart';

/// Steuert Level-Fortschritt, Streak-Logik und gewichtet die Auswahl.
class LevelManager {
  static const int levelGoal = 10;      // Anzahl richtiger Antworten in Folge, um aufzusteigen
  final Random _rand = Random();

  late final List<VocabPair> _pairs;    // Alle geladenen Vokabeln mit Fehlerzählern
  int level = 1;                        // Aktuelles Level (beginnt bei 1)
  int streak = 0;                       // Aktueller Streak (richtige Antworten in Folge)

  /// Initialisiert den Manager, lädt alle Wortpaare.
  Future<void> init() async {
    _pairs = await loadWordPairs();
  }

  /// Wählt ein VocabPair mit Wahrscheinlichkeit proportional zu (mistakes + 1).
  VocabPair _pickWeighted(List<VocabPair> list) {
    final totalWeight = list.fold<int>(0, (sum, p) => sum + p.mistakes + 1);
    var r = _rand.nextInt(totalWeight);
    for (var p in list) {
      r -= (p.mistakes + 1);
      if (r < 0) return p;
    }
    return list.last;
  }

  /// Erzeugt die nächste Frage aus den ersten (level * 7) Karten.
  Question nextQuestion() {
    // Bestimme den Pool für das aktuelle Level
    final maxIndex = (level * 7).clamp(1, _pairs.length);
    final subset = _pairs.sublist(0, maxIndex);

    // Wähle die Zielkarte gewichtet nach Fehlerhäufigkeit
    final target = _pickWeighted(subset);

    // Bereite Distraktoren vor: zuerst bis zu 2 bereits fehlbeantwortete Karten,
    // dann zusätzlich zufällige Karten aus dem Rest, bis insgesamt 3 Distraktoren.
    final others = List<VocabPair>.from(subset)..remove(target);

    // Distraktoren-Pool: nur bereits falsche Karten
    final wrongPool = others.where((p) => p.mistakes > 0).toList()..shuffle(_rand);
    final distractors = <String>[];

    // Nimm bis zu 2 aus den falsch-beantworteten Karten
    distractors.addAll(wrongPool.take(2).map((p) => p.de));

    // Fülle auf mit zufälligen Karten aus dem übrigen Pool
    final remaining = others.where((p) => !wrongPool.take(2).contains(p)).toList()..shuffle(_rand);
    while (distractors.length < 3 && remaining.isNotEmpty) {
      distractors.add(remaining.removeLast().de);
    }

    // Baue die Optionsliste und mische
    final options = <String>[target.de, ...distractors]..shuffle(_rand);

    // Erstelle und liefere die Frage, mit Rückverweis auf die Quelldaten
    return Question(
      prompt: 'Was bedeutet "${target.en}" auf Deutsch?',
      options: options,
      correctIndex: options.indexOf(target.de),
      sourcePair: target,
    );
  }

  /// Verarbeitet eine Antwort auf [q] mit Index [index].
  /// Gibt true zurück, wenn korrekt; erhöht bei Fehlern den Zähler.
  /// Managt außerdem Streak- und Level-Fortschritt:
  /// - Richtig: streak++; bei Erreichen von levelGoal → level++ und streak reset.
  /// - Falsch: streak reset und Fehlerzähler erhöht.
  bool answer(Question q, int index) {
    final isCorrect = index == q.correctIndex;
    final pair = q.sourcePair;
    if (isCorrect) {
      streak++;
      if (streak >= levelGoal) {
        level++;
        streak = 0;
      }
    } else {
      streak = 0;
      pair.mistakes++;
    }
    return isCorrect;
  }
}
