// lib/ui/question_screen.dart

import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/level_manager.dart';
import 'package:vokabeltrainer_app/core/question_generator.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({Key? key}) : super(key: key);

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final LevelManager _manager = LevelManager();
  late Question _question;
  bool _answered = false;
  int? _wrongIndex;

  @override
  void initState() {
    super.initState();
    // Initialisierung der Logik
    _manager.init().then((_) {
      setState(() => _question = _manager.nextQuestion());
    });
  }

  void _handleAnswer(int idx) {
    if (_answered) return;
    final correct = _manager.answer(_question, idx);
    if (correct) {
      // Bei richtiger Antwort sofort neue Frage
      setState(() {
        _answered = false;
        _wrongIndex = null;
        _question = _manager.nextQuestion();
      });
    } else {
      // Bei falscher Antwort erst markieren
      setState(() {
        _answered = true;
        _wrongIndex = idx;
      });
    }
  }

  void _restartLevel() {
    setState(() {
      _answered = false;
      _wrongIndex = null;
      // LevelManager.streak ist bereits auf 0 gesetzt
      _question = _manager.nextQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Noch keine Frage geladen?
    if (_manager.streak == 0 && (_question == null)) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${_manager.level} – Streak: ${_manager.streak}/${LevelManager.levelGoal}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_question.prompt, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            ..._question.options.asMap().entries.map((e) {
              final idx = e.key;
              final text = e.value;
              Color? bg;
              if (_answered) {
                if (idx == _question.correctIndex) bg = Colors.green;
                else if (idx == _wrongIndex) bg = Colors.red;
              }
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  onPressed: () => _handleAnswer(idx),
                  style: ElevatedButton.styleFrom(backgroundColor: bg),
                  child: Text(text),
                ),
              );
            }),
            const Spacer(),
            if (_answered)
              ElevatedButton(
                onPressed: _restartLevel,
                child: const Text('Level neu starten'),
              ),
          ],
        ),
      ),
    );
  }
}
