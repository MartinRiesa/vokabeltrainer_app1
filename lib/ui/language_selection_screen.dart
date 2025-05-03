// lib/ui/language_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/vocab_loader.dart';
import 'package:vokabeltrainer_app/core/question_generator.dart';
import 'package:vokabeltrainer_app/ui/question_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  List<String> _langs = [];
  String? _source;
  String? _target;

  @override
  void initState() {
    super.initState();
    loadLanguages().then((list) {
      setState(() => _langs = list);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_langs.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Sprachen auswählen')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Muttersprache'),
              items: _langs
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              value: _source,
              onChanged: (v) => setState(() => _source = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Zu lernende Sprache'),
              items: _langs
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              value: _target,
              onChanged: (v) => setState(() => _target = v),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: (_source != null && _target != null && _source != _target)
                  ? () async {
                // Fragen erzeugen (hier nutzen wir source/target noch nicht filternd)
                final questions = await generateQuestions();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => QuestionScreen(questions: questions),
                  ),
                );
              }
                  : null,
              child: const Text('Starten'),
            ),
          ],
        ),
      ),
    );
  }
}
