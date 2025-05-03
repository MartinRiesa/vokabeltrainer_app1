// lib/ui/question_screen.dart

import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/question_generator.dart';  // ← HIER HINZUFÜGEN
import 'package:vokabeltrainer_app/core/level_manager.dart';

class QuestionScreen extends StatefulWidget {
  final String source;
  final String target;

  const QuestionScreen({
    Key? key,
    required this.source,
    required this.target,
  }) : super(key: key);

  @override
  _QuestionScreenState createState() =>
      _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final LevelManager _manager = LevelManager();
  late Question _question;                // Question ist jetzt bekannt
  bool _answered = false;
  int? _wrongIndex;

  @override
  void initState() {
    super.initState();
    _manager.init().then((_) {
      setState(() => _question = _manager.nextQuestion());
    });
  }

  void _handleAnswer(int idx) {
    if (_answered) return;
    final correct = _manager.answer(_question, idx);
    if (correct) {
      setState(() {
        _answered = false;
        _wrongIndex = null;
        _question = _manager.nextQuestion();
      });
    } else {
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
      _question = _manager.nextQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Warten, bis _question gesetzt ist
    if (_question == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Level ${_manager.level} – Streak: ${_manager.streak}/${LevelManager.levelGoal}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            Text(_question.prompt,
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            ..._question.options
                .asMap()
                .entries
                .map((e) {
              final idx = e.key;
              final label = e.value;
              Color? bg;
              if (_answered) {
                if (idx == _question.correctIndex)
                  bg = Colors.green;
                else if (idx == _wrongIndex)
                  bg = Colors.red;
              }
              return Container(
                margin: const EdgeInsets.symmetric(
                    vertical: 4),
                child: ElevatedButton(
                  onPressed: () =>
                      _handleAnswer(idx),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: bg),
                  child: Text(label),
                ),
              );
            }),
            const Spacer(),
            if (_answered)
              ElevatedButton(
                onPressed: _restartLevel,
                child:
                const Text('Level neu starten'),
              ),
          ],
        ),
      ),
    );
  }
}
