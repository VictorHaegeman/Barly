import 'package:flutter_test/flutter_test.dart';
import 'package:barly/services/recommendation_service.dart';

void main() {
  test('normalizeProfilePriceLevel maps legacy EUR format to euro tiers', () {
    expect(
      RecommendationService.normalizeProfilePriceLevel('15 EUR'),
      '\u20ac\u20ac',
    );
    expect(
      RecommendationService.normalizeProfilePriceLevel('40 EUR+'),
      '\u20ac\u20ac\u20ac',
    );
  });

  test('descriptionPreferenceScore is accent and case insensitive', () {
    final score = RecommendationService.descriptionPreferenceScore(
      description: 'Ambiance FESTIVE, bières et musique house toute la nuit',
      prefAmb: const ['Festive'],
      prefMusic: const ['House'],
      prefDrinks: const ['Bieres'],
    );

    expect(score, greaterThanOrEqualTo(4));
  });

  test('computeRecommendations ranks strongest profile match first', () {
    final bars = <Map<String, dynamic>>[
      {
        'name': 'Top Match',
        'ambiance': ['Cosy'],
        'music': ['Jazz'],
        'drinks': ['Bieres'],
        'description': 'Bar cosy avec bieres artisanales et live jazz',
        'priceLevel': '\u20ac\u20ac',
        'rating': 4.7,
      },
      {
        'name': 'Lower Match',
        'ambiance': ['Dance'],
        'music': ['House'],
        'drinks': ['Cocktails'],
        'description': 'Club dance',
        'priceLevel': '\u20ac\u20ac\u20ac',
        'rating': 3.8,
      },
    ];

    final recommendations = RecommendationService.computeRecommendations(
      bars: bars,
      preferences: {
        'ambiance': ['Cosy'],
        'music': ['Jazz'],
        'drinks': ['Bieres'],
      },
      prefPrice: '\u20ac\u20ac',
      limit: 5,
    );

    expect(recommendations, isNotEmpty);
    expect(recommendations.first['name'], equals('Top Match'));
    expect(recommendations.first['_score'], greaterThan(0));
  });
}
