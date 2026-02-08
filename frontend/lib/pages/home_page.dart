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
  List<Map<String, dynamic>> bars = [];
  List<Map<String, dynamic>> events = [];
  Map<String, dynamic> preferences = {
    'ambiance': <String>[],
    'music': <String>[],
    'drinks': <String>[],
  };
  String? prefPrice;
  List<Map<String, dynamic>> recommended = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _loadMe();
    try {
      final fetchedBars = await api.getBars();
      bars = fetchedBars
          .map<Map<String, dynamic>>((raw) {
            final b = Map<String, dynamic>.from(raw as Map);
            return {
              ...b,
              'imageUrl': b['coverImage'] ??
                  'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=400&h=300&fit=crop',
              'pintPrice': b['pintPrice'] ?? '€€',
            };
          })
          .toList();
    } catch (_) {
      bars = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de charger les bars (API)')),
        );
      }
    }

    try {
      final fetchedEvents = await api.getEvents();
      events = fetchedEvents
          .map<Map<String, dynamic>>((e) => {
                ...e as Map<String, dynamic>,
                'title': (e as Map<String, dynamic>)['title'] ?? 'Événement',
                'bar': (e as Map<String, dynamic>)['barName'] ??
                    (e as Map<String, dynamic>)['bar'] ??
                    'Bar',
                'date': (e as Map<String, dynamic>)['date']?.toString(),
                'participants':
                    (e as Map<String, dynamic>)['participants']?.length ?? 0,
                'price': 'Gratuit',
                'type': 'Événement',
              })
          .toList();
    } catch (_) {
      events = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connecte-toi pour voir les événements')),
        );
      }
    }

    recommended = _computeRecommendations();
    if (mounted) setState(() => loading = false);
  }

  Future<void> _loadMe() async {
    try {
      final me = await api.getMe();
      if (me != null) {
        final profile = Map<String, dynamic>.from(
            me['profile'] ?? me['preferences'] ?? {});
        preferences =
            Map<String, dynamic>.from(profile['prefs'] ?? preferences);
        prefPrice = profile['price_level']?.toString() ??
            me['priceLevel']?.toString();
      }
    } catch (_) {
      // si non connecté on garde des préférences vides
    }
  }

  List<Map<String, dynamic>> _computeRecommendations() {
    final prefAmb = List<String>.from(preferences['ambiance'] ?? []);
    final prefMusic = List<String>.from(preferences['music'] ?? []);
    final prefDrinks = List<String>.from(preferences['drinks'] ?? []);
    if (bars.isEmpty || (prefAmb.isEmpty && prefMusic.isEmpty && prefDrinks.isEmpty)) return [];

    final scored = bars.map<Map<String, dynamic>>((bar) {
      final amb = List<String>.from(bar['ambiance'] ?? []);
      final music = List<String>.from(bar['music'] ?? []);
      int score = 0;
      for (final a in amb) {
        if (prefAmb.contains(a)) score += 3;
      }
      for (final m in music) {
        if (prefMusic.contains(m)) score += 2;
      }
      for (final d in List<String>.from(bar['drinks'] ?? [])) {
        if (prefDrinks.contains(d)) score += 1;
      }
      if (prefPrice != null && bar['priceLevel'] == prefPrice) score += 1;
      // léger bonus si un rating existe
      if (bar['rating'] != null) {
        final r = double.tryParse(bar['rating'].toString()) ?? 0;
        score += r.round();
      }
      return {...bar, '_score': score};
    }).where((b) => (b['_score'] as int) > 0).toList();

    scored.sort((a, b) => (b['_score'] as int).compareTo(a['_score'] as int));
    return scored.take(5).toList();
  }

  Widget _matchBadge(Map<String, dynamic> bar) {
    final score = bar['_score'] ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.thumb_up, size: 14, color: Color(0xFF9B7BFF)),
          const SizedBox(width: 4),
          Text('Match $score', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
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
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(),
                    if (recommended.isNotEmpty) ...[
                    _sectionHeader(
                      title: 'Fait pour vous',
                      action: 'Voir tout',
                      onTap: () => Navigator.push(
                        context,
                          MaterialPageRoute(
                            builder: (context) => const AllBarsPage(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 190,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: recommended.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) => SizedBox(
                              width: 240,
                              child: Stack(
                                children: [
                                  _buildBarCard(recommended[i]),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: _matchBadge(recommended[i]),
                                  ),
                                ],
                              )),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                    _sectionHeader(
                      title: 'Bars tendance',
                      action: 'Voir tout',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllBarsPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (bars.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Aucun bar pour le moment'),
                      )
                    else
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
                    _sectionHeader(
                      title: 'Événements à venir',
                      action: 'Voir tout',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllEventsPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (events.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Connecte-toi pour voir les événements'),
                      )
                    else
                      ...events.map((event) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildEventCard(event),
                          )),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHero() {
    return Container(
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
    );
  }

  Widget _sectionHeader({required String title, required String action, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: Text(
              action,
              style: const TextStyle(color: Color(0xFF9B7BFF)),
            ),
          ),
        ],
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
                        (bar['music'] ?? bar['ambiance'] ?? []).join(', '),
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
                          bar['pintPrice'] ?? '€€',
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
                      date != null
                          ? '${date.day}/${date.month}'
                          : 'Date',
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
