import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'event_detail_page.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final api = ApiService();
  List<dynamic> events = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Toujours utiliser les données mock pour avoir du contenu
    events = [
      {
        'id': 'e1',
        'title': 'Soirée House Music',
        'bar': 'Le Comptoir d\'Or',
        'date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'participants': 24,
        'price': '12€',
        'description':
            'Une soirée électro-house avec les meilleurs DJs de la scène parisienne.',
        'type': 'Musique',
      },
      {
        'id': 'e2',
        'title': 'Live Jazz Intime',
        'bar': 'L\'Oasis Urbaine',
        'date': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'participants': 18,
        'price': '8€',
        'description':
            'Concert de jazz acoustique dans une ambiance feutrée et chaleureuse.',
        'type': 'Concert',
      },
      {
        'id': 'e3',
        'title': 'Dégustation de Vins',
        'bar': 'Le Verre à Soi',
        'date': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
        'participants': 12,
        'price': '15€',
        'description':
            'Découverte de vins de la région avec un sommelier expert.',
        'type': 'Dégustation',
      },
      {
        'id': 'e4',
        'title': 'Soirée Bières Artisanales',
        'bar': 'Les Frères Houblon',
        'date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'participants': 32,
        'price': '10€',
        'description':
            'Tasting de bières artisanales locales avec les brasseurs.',
        'type': 'Dégustation',
      },
      {
        'id': 'e5',
        'title': 'Soirée Cocktails Signature',
        'bar': 'Le Comptoir d\'Or',
        'date': DateTime.now().add(const Duration(days: 10)).toIso8601String(),
        'participants': 28,
        'price': '18€',
        'description':
            'Découverte des cocktails signature du bar avec le barman expert.',
        'type': 'Dégustation',
      },
      {
        'id': 'e6',
        'title': 'Concert Rock Alternatif',
        'bar': 'L\'Oasis Urbaine',
        'date': DateTime.now().add(const Duration(days: 12)).toIso8601String(),
        'participants': 45,
        'price': '15€',
        'description':
            'Concert de rock alternatif avec des groupes locaux émergents.',
        'type': 'Concert',
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Événements',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : events.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemCount: events.length,
                  itemBuilder: (_, i) => _buildEventCard(events[i]),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateEventDialog(),
        backgroundColor: const Color(0xFF9B7BFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF9B7BFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.event,
              size: 60,
              color: Color(0xFF9B7BFF),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucun événement',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Créez le premier événement !',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final date = DateTime.tryParse(event['date'] ?? '');
    final participants = event['participants'] ?? 0;
    final type = event['type'] ?? 'Événement';

    return Container(
      padding: const EdgeInsets.all(20),
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
          // Header avec type et prix
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B7BFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF9B7BFF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  type,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9B7BFF),
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  event['price'] ?? 'Gratuit',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Titre
          Text(
            event['title'] ?? 'Événement',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),

          // Bar
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Text(
                event['bar'] ?? 'Bar',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Date et participants
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Text(
                date != null
                    ? '${date.day}/${date.month} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}'
                    : 'Date non définie',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.people,
                size: 16,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Text(
                '$participants participants',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            event['description'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // Bouton participer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailPage(event: event),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B7BFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Je participe',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _joinEvent(Map<String, dynamic> event) async {
    try {
      await api.joinEvent(event['id']?.toString() ?? event['_id']);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription envoyée !'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'inscription'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  void _showCreateEventDialog() {
    showDialog(
      context: context,
      builder: (_) => const _CreateEventDialog(),
    );
  }
}

class _CreateEventDialog extends StatefulWidget {
  const _CreateEventDialog();

  @override
  State<_CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<_CreateEventDialog> {
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  DateTime date = DateTime.now().add(const Duration(days: 1));
  String barId = 'b1';
  String eventType = 'Musique';
  final api = ApiService();

  final bars = [
    {'id': 'b1', 'name': 'Le Comptoir d\'Or'},
    {'id': 'b2', 'name': 'L\'Oasis Urbaine'},
    {'id': 'b3', 'name': 'Le Verre à Soi'},
    {'id': 'b4', 'name': 'Les Frères Houblon'},
  ];

  final eventTypes = ['Musique', 'Concert', 'Dégustation', 'Soirée', 'Autre'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Créer un événement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Titre de l\'événement',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF9B7BFF)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF9B7BFF)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: eventType,
              decoration: const InputDecoration(
                labelText: 'Type d\'événement',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF9B7BFF)),
                ),
              ),
              items: eventTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) => setState(() => eventType = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: barId,
              decoration: const InputDecoration(
                labelText: 'Bar',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF9B7BFF)),
                ),
              ),
              items: bars.map((bar) {
                return DropdownMenuItem(
                  value: bar['id'],
                  child: Text(bar['name']!),
                );
              }).toList(),
              onChanged: (value) => setState(() => barId = value!),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _createEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9B7BFF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Créer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createEvent() async {
    if (titleCtrl.text.isEmpty) return;

    try {
      // Simulation de création d'événement
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      // Créer le nouvel événement
      final newEvent = {
        'id': 'e${DateTime.now().millisecondsSinceEpoch}',
        'title': titleCtrl.text,
        'bar': bars.firstWhere((bar) => bar['id'] == barId)['name'],
        'date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'participants': 0,
        'price': 'Gratuit',
        'description': descriptionCtrl.text.isNotEmpty
            ? descriptionCtrl.text
            : 'Nouvel événement créé par la communauté.',
        'type': eventType,
      };

      // Ajouter à la liste des événements
      final parentState = context.findAncestorStateOfType<_EventsPageState>();
      if (parentState != null) {
        parentState.setState(() {
          parentState.events.insert(0, newEvent);
        });
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Événement créé avec succès !'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la création'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }
}
