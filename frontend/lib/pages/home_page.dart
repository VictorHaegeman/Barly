import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'bar_detail_page.dart';
import 'all_bars_page.dart';
import 'all_events_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final api = ApiService();
  List<dynamic> bars = [];
  List<dynamic> events = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Utiliser directement les données mock pour éviter les problèmes d'API
    bars = [
      {
        'id': 'b1',
        'name': 'Le Comptoir d\'Or',
        'ambiance': ['Chic', 'Lounge'],
        'priceLevel': 'Élevé',
        'rating': 4.8,
        'pintPrice': '8€',
        'imageUrl':
            'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=400&h=300&fit=crop',
      },
      {
        'id': 'b2',
        'name': 'L\'Oasis Urbaine',
        'ambiance': ['Tropical', 'Décontracté'],
        'priceLevel': 'Moyen',
        'rating': 4.5,
        'pintPrice': '6€',
        'imageUrl':
            'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=400&h=300&fit=crop',
      },
      {
        'id': 'b3',
        'name': 'Le Verre à Soi',
        'ambiance': ['Intimiste', 'Vin'],
        'priceLevel': 'Moyen',
        'rating': 4.7,
        'pintPrice': '5€',
        'imageUrl':
            'https://images.unsplash.com/photo-1572116469696-31de0f17cc34?w=400&h=300&fit=crop',
      },
    ];

    events = [
      {
        'id': 'e1',
        'title': 'Soirée House Music',
        'bar': 'Le Comptoir d\'Or',
        'date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'participants': 24,
        'price': '12€',
        'type': 'Musique',
      },
      {
        'id': 'e2',
        'title': 'Live Jazz Intime',
        'bar': 'L\'Oasis Urbaine',
        'date': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'participants': 18,
        'price': '8€',
        'type': 'Concert',
      },
      {
        'id': 'e3',
        'title': 'Dégustation de Vins',
        'bar': 'Le Verre à Soi',
        'date': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
        'participants': 12,
        'price': '15€',
        'type': 'Dégustation',
      },
      {
        'id': 'e4',
        'title': 'Soirée Bières Artisanales',
        'bar': 'Les Frères Houblon',
        'date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'participants': 32,
        'price': '10€',
        'type': 'Dégustation',
      },
    ];

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6FA),
        elevation: 0,
        title: const Text(
          'Barly',
          style: TextStyle(
            color: Color(0xFF9B7BFF),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header de bienvenue
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9B7BFF), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9B7BFF).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Salut ! 👋',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Découvre les meilleurs bars et événements près de chez toi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/map'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF9B7BFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Explorer',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bars tendance
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bars tendance',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AllBarsPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Voir tout',
                            style: TextStyle(color: Color(0xFF9B7BFF)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Carousel des bars
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 200,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      viewportFraction: 0.8,
                    ),
                    items: bars.map((bar) => _buildBarCard(bar)).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Événements à venir
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Événements à venir',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AllEventsPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Voir tout',
                            style: TextStyle(color: Color(0xFF9B7BFF)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Liste des événements
                  ...events.map((event) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildEventCard(event),
                      )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildBarCard(Map<String, dynamic> bar) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BarDetailPage(bar: bar),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  bar['imageUrl'] ?? '',
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9B7BFF).withOpacity(0.1),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_bar,
                        size: 40,
                        color: Color(0xFF9B7BFF),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bar['name'] ?? 'Bar',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    (bar['ambiance'] ?? []).join(', '),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (bar['ambiance'] ?? []).join(', '),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          bar['pintPrice'] ?? '5€',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final date = DateTime.tryParse(event['date'] ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône événement
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF9B7BFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event,
              color: Color(0xFF9B7BFF),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] ?? 'Événement',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event['bar'] ?? 'Bar',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date != null ? '${date.day}/${date.month}' : 'Date',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.people,
                      size: 12,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${event['participants'] ?? 0}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Prix
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              event['price'] ?? 'Gratuit',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
