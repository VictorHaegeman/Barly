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
  bool authed = false;
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
    authed = api.isAuthenticated;
    await _loadMe();
    try {
      final fetchedBars = await api.getBars();
      bars = fetchedBars.map<Map<String, dynamic>>((raw) {
        final b = Map<String, dynamic>.from(raw as Map);
        return {
          ...b,
          'imageUrl': b['coverImage'] ??
              'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=400&h=300&fit=crop',
          'pintPrice': b['pintPrice'] ?? '€€',
        };
      }).toList();
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
        final msg = authed
            ? 'Impossible de charger les événements'
            : 'Connecte-toi pour voir les événements';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
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
        preferences = Map<String, dynamic>.from(me['prefs'] ?? preferences);
        prefPrice = me['price_level']?.toString();
      }
    } catch (_) {
      // si non connecté on garde des préférences vides
    }
  }

  List<Map<String, dynamic>> _computeRecommendations() {
    final prefAmb = List<String>.from(preferences['ambiance'] ?? []);
    final prefMusic = List<String>.from(preferences['music'] ?? []);
    final prefDrinks = List<String>.from(preferences['drinks'] ?? []);
    if (bars.isEmpty ||
        (prefAmb.isEmpty && prefMusic.isEmpty && prefDrinks.isEmpty)) return [];

    final scored = bars
        .map<Map<String, dynamic>>((bar) {
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
        })
        .where((b) => (b['_score'] as int) > 0)
        .toList();

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
          const Icon(Icons.thumb_up, size: 14, color: Color(0xFF7C3AED)),
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
            color: Color(0xFF7C3AED),
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
                    const SizedBox(height: 8),
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
                    if (authed)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: OutlinedButton.icon(
                          onPressed: _showCreateBarDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter un bar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF7C3AED),
                            side: const BorderSide(color: Color(0xFF7C3AED)),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(authed
                            ? 'Aucun événement pour le moment'
                            : 'Connecte-toi pour voir les événements'),
                      )
                    else
                      ...events.map((event) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildEventCard(event),
                          )),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionHeader(
      {required String title,
      required String action,
      required VoidCallback onTap}) {
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
              style: const TextStyle(color: Color(0xFF7C3AED)),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateBarDialog() {
    showDialog(
      context: context,
      builder: (_) => _CreateBarDialog(
        onCreated: (bar) {
          setState(() {
            bars.insert(0, bar);
          });
        },
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
                      color: const Color(0xFF7C3AED).withOpacity(0.1),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_bar,
                        size: 40,
                        color: Color(0xFF7C3AED),
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
              color: const Color(0xFF7C3AED).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event,
              color: Color(0xFF7C3AED),
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

class _CreateBarDialog extends StatefulWidget {
  const _CreateBarDialog({required this.onCreated});
  final ValueChanged<Map<String, dynamic>> onCreated;

  @override
  State<_CreateBarDialog> createState() => _CreateBarDialogState();
}

class _CreateBarDialogState extends State<_CreateBarDialog> {
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final coverCtrl = TextEditingController();
  final priceCtrl = TextEditingController(text: '€€');
  final descriptionCtrl = TextEditingController();
  List<String> ambiances = [];
  List<String> musics = [];
  bool loading = false;
  final api = ApiService();

  final ambianceOptions = const ['Cosy', 'Dance', 'Chill', 'Lounge'];
  final musicOptions = const ['House', 'Pop', 'Jazz', 'RnB', 'Rock'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajouter un bar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(
                labelText: 'Adresse',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: coverCtrl,
              decoration: const InputDecoration(
                labelText: 'Image (URL)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: ambianceOptions.map((opt) {
                final selected = ambiances.contains(opt);
                return ChoiceChip(
                  label: Text(opt),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      v ? ambiances.add(opt) : ambiances.remove(opt);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: musicOptions.map((opt) {
                final selected = musics.contains(opt);
                return ChoiceChip(
                  label: Text(opt),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      v ? musics.add(opt) : musics.remove(opt);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(
                labelText: 'Niveau de prix (€, €€, €€€)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Créer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (nameCtrl.text.isEmpty) return;
    setState(() => loading = true);
    try {
      final bar = await api.createBar(
        name: nameCtrl.text,
        address: addressCtrl.text,
        coverUrl: coverCtrl.text.isNotEmpty ? coverCtrl.text : null,
        ambiance: ambiances,
        music: musics,
        priceLevel: priceCtrl.text,
        description: descriptionCtrl.text,
      );
      widget.onCreated(bar);
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bar ajouté')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Impossible de créer le bar (vérifie que tu es connecté)')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}
