class RecommendationService {
  static String? normalizeProfilePriceLevel(dynamic value) {
    final raw = (value ?? '').toString().trim();
    if (raw.isEmpty) return null;
    switch (raw) {
      case '\u20ac':
      case '\u20ac\u20ac':
      case '\u20ac\u20ac\u20ac':
        return raw;
      case '5 EUR':
      case '10 EUR':
      case '20 EUR':
        return '\u20ac';
      case '15 EUR':
      case '25 EUR':
      case '35 EUR':
        return '\u20ac\u20ac';
      case '30 EUR+':
      case '40 EUR+':
      case '60 EUR+':
        return '\u20ac\u20ac\u20ac';
      default:
        final numeric = double.tryParse(
          raw.replaceAll(RegExp(r'[^0-9\.]'), ''),
        );
        if (numeric != null) {
          if (numeric <= 20) return '\u20ac';
          if (numeric <= 35) return '\u20ac\u20ac';
          return '\u20ac\u20ac\u20ac';
        }
        return raw;
    }
  }

  static String normalizeText(String value) {
    return value
        .toLowerCase()
        .replaceAll('\u00e0', 'a')
        .replaceAll('\u00e1', 'a')
        .replaceAll('\u00e2', 'a')
        .replaceAll('\u00e4', 'a')
        .replaceAll('\u00e3', 'a')
        .replaceAll('\u00e5', 'a')
        .replaceAll('\u00e6', 'ae')
        .replaceAll('\u00e7', 'c')
        .replaceAll('\u00e8', 'e')
        .replaceAll('\u00e9', 'e')
        .replaceAll('\u00ea', 'e')
        .replaceAll('\u00eb', 'e')
        .replaceAll('\u00ec', 'i')
        .replaceAll('\u00ed', 'i')
        .replaceAll('\u00ee', 'i')
        .replaceAll('\u00ef', 'i')
        .replaceAll('\u00f1', 'n')
        .replaceAll('\u00f2', 'o')
        .replaceAll('\u00f3', 'o')
        .replaceAll('\u00f4', 'o')
        .replaceAll('\u00f6', 'o')
        .replaceAll('\u00f5', 'o')
        .replaceAll('\u0153', 'oe')
        .replaceAll('\u00f9', 'u')
        .replaceAll('\u00fa', 'u')
        .replaceAll('\u00fb', 'u')
        .replaceAll('\u00fc', 'u')
        .replaceAll('\u00fd', 'y')
        .replaceAll('\u00ff', 'y')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static Set<String> keywords(Iterable<String> values) {
    final out = <String>{};
    for (final value in values) {
      final normalized = normalizeText(value);
      if (normalized.isEmpty) continue;
      for (final token in normalized.split(' ')) {
        if (token.length < 2) continue;
        out.add(token);
        if (token.endsWith('s') && token.length > 3) {
          out.add(token.substring(0, token.length - 1));
        }
      }
    }
    return out;
  }

  static int descriptionPreferenceScore({
    required String description,
    required List<String> prefAmb,
    required List<String> prefMusic,
    required List<String> prefDrinks,
  }) {
    final normalizedDescription = normalizeText(description);
    if (normalizedDescription.isEmpty) return 0;
    final descriptionTokens = normalizedDescription
        .split(' ')
        .where((token) => token.length >= 2)
        .toSet();

    int score = 0;
    for (final token in keywords(prefAmb)) {
      if (descriptionTokens.contains(token)) score += 2;
    }
    for (final token in keywords(prefMusic)) {
      if (descriptionTokens.contains(token)) score += 1;
    }
    for (final token in keywords(prefDrinks)) {
      if (descriptionTokens.contains(token)) score += 1;
    }
    return score;
  }

  static List<Map<String, dynamic>> computeRecommendations({
    required List<Map<String, dynamic>> bars,
    required Map<String, dynamic> preferences,
    String? prefPrice,
    int limit = 5,
  }) {
    final prefAmb = List<String>.from(preferences['ambiance'] ?? const []);
    final prefMusic = List<String>.from(preferences['music'] ?? const []);
    final prefDrinks = List<String>.from(preferences['drinks'] ?? const []);
    final prefAmbKeywords = keywords(prefAmb);
    final prefMusicKeywords = keywords(prefMusic);
    final prefDrinksKeywords = keywords(prefDrinks);

    if (bars.isEmpty ||
        (prefAmb.isEmpty && prefMusic.isEmpty && prefDrinks.isEmpty)) {
      return const [];
    }

    final scored = bars
        .map<Map<String, dynamic>>((bar) {
          final amb = List<String>.from(bar['ambiance'] ?? const []);
          final music = List<String>.from(bar['music'] ?? const []);
          final description = (bar['description'] ?? '').toString();
          int score = 0;

          for (final a in amb) {
            if (prefAmbKeywords.contains(normalizeText(a))) score += 3;
          }
          for (final m in music) {
            if (prefMusicKeywords.contains(normalizeText(m))) score += 2;
          }
          for (final d in List<String>.from(bar['drinks'] ?? const [])) {
            if (prefDrinksKeywords.contains(normalizeText(d))) score += 1;
          }

          score += descriptionPreferenceScore(
            description: description,
            prefAmb: prefAmb,
            prefMusic: prefMusic,
            prefDrinks: prefDrinks,
          );

          if (prefPrice != null && bar['priceLevel'] == prefPrice) score += 1;

          if (bar['rating'] != null) {
            final rating = double.tryParse(bar['rating'].toString()) ?? 0;
            score += rating.round();
          }
          return {...bar, '_score': score};
        })
        .where((b) => (b['_score'] as int) > 0)
        .toList();

    scored.sort((a, b) => (b['_score'] as int).compareTo(a['_score'] as int));
    return scored.take(limit).toList();
  }
}
