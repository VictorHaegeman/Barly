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
  List<Map<String, dynamic>> events = [];
  bool authed = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    authed = api.isAuthenticated;
    try {
      final fetched = await api.getEvents();
      events = fetched
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
            : 'Connecte-toi pour voir / créer des événements';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recherche bientôt dispo')),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : events.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemCount: events.length,
                    itemBuilder: (_, i) => _buildEventCard(events[i]),
                  ),
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
          const Icon(Icons.event_busy, size: 64, color: Color(0xFF9B7BFF)),
          const SizedBox(height: 16),
          Text(authed
              ? 'Aucun événement pour le moment'
              : 'Connecte-toi pour voir / créer des événements'),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          Text(
            event['title'] ?? 'Événement',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _joinEvent(event),
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
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailPage(event: event),
              ),
            ),
            child: const Text('Détails'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinEvent(Map<String, dynamic> event) async {
    try {
      final id = event['id']?.toString() ?? event['_id'];
      await api.joinEvent(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription envoyée !'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (_) {
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
      builder: (_) => _CreateEventDialog(onCreated: _onCreated),
    );
  }

  void _onCreated(Map<String, dynamic> event) {
    setState(() {
      events.insert(0, event);
    });
  }
}

class _CreateEventDialog extends StatefulWidget {
  const _CreateEventDialog({required this.onCreated});
  final ValueChanged<Map<String, dynamic>> onCreated;

  @override
  State<_CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<_CreateEventDialog> {
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  DateTime date = DateTime.now().add(const Duration(days: 1));
  String? barId;
  String eventType = 'Musique';
  final api = ApiService();
  List<Map<String, dynamic>> bars = [];
  bool loading = true;

  final eventTypes = ['Musique', 'Concert', 'Dégustation', 'Soirée', 'Autre'];

  @override
  void initState() {
    super.initState();
    _loadBars();
  }

  Future<void> _loadBars() async {
    try {
      final fetched = await api.getBars();
      bars = fetched.map<Map<String, dynamic>>((b) => Map<String, dynamic>.from(b as Map)).toList();
      if (bars.isNotEmpty) barId = bars.first['id']?.toString() ?? bars.first['_id']?.toString();
    } catch (_) {
      bars = [];
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Dialog(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
    }
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
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: eventType,
              decoration: const InputDecoration(
                labelText: 'Type d\'événement',
                border: OutlineInputBorder(),
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
              ),
              items: bars.map((bar) {
                final id = bar['id']?.toString() ?? bar['_id']?.toString();
                return DropdownMenuItem(
                  value: id,
                  child: Text(bar['name']?.toString() ?? 'Bar'),
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
    if (!api.isAuthenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Connecte-toi pour créer un événement')));
      }
      return;
    }
    if (titleCtrl.text.isEmpty || barId == null) return;

    try {
      final created = await api.createEvent(
          barId: barId!,
          title: titleCtrl.text,
          date: date.toIso8601String(),
          type: eventType);
      final event = {
        ...created,
        'bar': bars.firstWhere((b) => (b['id']?.toString() ?? b['_id']?.toString()) == barId)['name'],
        'participants': (created['participants'] as List?)?.length ?? 0,
      };
      widget.onCreated(event);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Événement créé !'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (_) {
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
