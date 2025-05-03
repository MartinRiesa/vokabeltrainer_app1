// lib/core/vocab_loader.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Liest die erste Zeile der CSV und liefert die verfügbaren Sprachen.
/// Beispiel-Rückgabe: ['en', 'de', 'fr']
Future<List<String>> loadLanguages() async {
  final raw = await rootBundle.loadString('assets/Vokabeln alle.csv');
  final firstLine = raw.split('\n').first;
  return firstLine.split(';').map((s) => s.trim()).toList();
}

/// Lädt Wortpaare aus der CSV-Datei assets/Vokabeln alle.csv.
/// Erwartetes Format: Header-Zeile, danach pro Zeile: Englisch;Deutsch
Future<List<Map<String, String>>> loadWordPairs() async {
  final raw = await rootBundle.loadString('assets/Vokabeln alle.csv');
  final lines = const LineSplitter().convert(raw);
  final pairs = <Map<String, String>>[];

  for (var i = 1; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;
    final parts = line.split(';');
    if (parts.length >= 2) {
      pairs.add({
        'en': parts[0].trim(),
        'de': parts[1].trim(),
      });
    }
  }
  return pairs;
}
