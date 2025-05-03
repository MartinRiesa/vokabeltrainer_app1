// test/vocab_loader_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:vokabeltrainer_app/core/vocab_loader.dart';

void main() {
  // Binding initialisieren, damit rootBundle funktioniert
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loadWordPairs liefert mindestens ein Wortpaar', () async {
    final pairs = await loadWordPairs();
    expect(pairs, isNotEmpty);
    expect(pairs.first.containsKey('en'), true);
    expect(pairs.first.containsKey('de'), true);
  });
}
