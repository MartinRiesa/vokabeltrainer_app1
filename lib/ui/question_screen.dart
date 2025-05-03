// lib/ui/question_screen.dart

import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/question_generator.dart';

class QuestionScreen extends StatefulWidget {
  final List<Question> questions;
  const QuestionScreen({Key? key, required this.questions}) : super(key: key);

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int _current = 0;
  bool _answered = false;
  int? _wrongIndex;

  /// Wird aufgerufen, wenn der Nutzer eine Option tippt.
  void _answer(int index) {
    if (_answered) return; // bereits beantwortet
    final correctIdx = widget.questions[_current].correctIndex;

    if (index == correctIdx) {
      // richtig: sofort zur nächsten Frage
      _goNext();
    } else {
      // falsch: markiere und zeige Weiter-Button
      setState(() {
        _answered = true;
        _wrongIndex = index;
      });
    }
  }

  /// Wechsel auf die nächste Frage oder Neustart
  void _goNext() {
    setState(() {
      _answered = false;
      _wrongIndex = null;
      if (_current < widget.questions.length - 1) {
        _current++;
      } else {
        _current = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[_current];
    return Scaffold(
      appBar: AppBar(
        title: Text('Frage ${_current + 1}/${widget.questions.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(q.prompt, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),

            // Antwort-Buttons
            ...q.options.asMap().entries.map((e) {
              final idx = e.key;
              final label = e.value;
              Color? bg;
              if (_answered) {
                if (idx == q.correctIndex) {
                  bg = Colors.green;
                } else if (idx == _wrongIndex) {
                  bg = Colors.red;
                }
              }
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  onPressed: () => _answer(idx),
                  style: ElevatedButton.styleFrom(backgroundColor: bg),
                  child: Text(label),
                ),
              );
            }),

            const Spacer(),

            // Weiter-Button nur bei falscher Antwort
            if (_answered)
              ElevatedButton(
                onPressed: _goNext,
                child: const Text('Weiter'),
              ),
          ],
        ),
      ),
    );
  }
}
