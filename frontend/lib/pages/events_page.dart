import 'package:flutter/material.dart';
import 'dart:math';
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
  final Set<String> expandedDetails = <String>{};
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
          .map<Map<String, dynamic>>(
              (raw) => _normalizeEvent(Map<String, dynamic>.from(raw)))
          .toList();
    } catch (_) {
      events = [];
      if (mounted) {
        final msg = authed
            ? 'Impossible de charger les evenements'
            : 'Connecte-toi pour voir / creer des evenements';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    }
    if (mounted) setState(() => loading = false);
  }

  Map<String, dynamic> _normalizeEvent(Map<String, dynamic> e) {
    final participantsRaw = e['participants'];
    final participantsCount = participantsRaw is List
        ? participantsRaw.length
        : (participantsRaw is num ? participantsRaw.toInt() : 0);

    final isPrivate = e['isPrivate'] == true ||
        e['is_private'] == true ||
        e['visibility']?.toString().toLowerCase() == 'private';
    final isFree = e['isFree'] != false && e['is_free'] != false;
    final ticketPrice = e['ticket_price']?.toString().trim();
    final fallbackPrice = e['price']?.toString().trim();
    final computedPrice = isPrivate
        ? 'Code requis'
        : (isFree
            ? 'Gratuit'
            : (ticketPrice != null && ticketPrice.isNotEmpty
                ? ticketPrice
                : (fallbackPrice?.isNotEmpty == true
                    ? fallbackPrice!
                    : 'Payant')));

    return {
      ...e,
      'title': e['title']?.toString() ?? 'Evenement',
      'bar': e['barName']?.toString() ?? e['bar']?.toString() ?? 'Bar',
      'date': e['date']?.toString(),
      'participantsCount': participantsCount,
      'price': computedPrice,
      'isFree': isFree,
      'ticket_price': e['ticket_price'],
      'type': e['type']?.toString() ?? 'Evenement',
      'isPrivate': isPrivate,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6FA),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Evenements',
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
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemCount: events.length,
                    itemBuilder: (_, i) => _buildEventCard(events[i], i),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateEventDialog,
        backgroundColor: const Color(0xFF7C3AED),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, size: 64, color: Color(0xFF7C3AED)),
          const SizedBox(height: 16),
          Text(authed
              ? 'Aucun evenement pour le moment'
              : 'Connecte-toi pour voir / creer des evenements'),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, int index) {
    final date = DateTime.tryParse(event['date']?.toString() ?? '');
    final participantsCount = event['participantsCount'] as int? ?? 0;
    final type = event['type']?.toString() ?? 'Evenement';
    final isPrivate = event['isPrivate'] == true;
    final eventKey = _eventKey(event, index);
    final showDetails = expandedDetails.contains(eventKey);
    final description =
        (event['description']?.toString().trim().isNotEmpty ?? false)
            ? event['description'].toString().trim()
            : 'Description indisponible pour le moment.';
    final ctaLabel = isPrivate
        ? 'Je participe avec un code d evenement'
        : _ctaPriceLabel(event['price']);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _chipLabel(type, const Color(0xFF7C3AED)),
              const Spacer(),
              _chipLabel(
                isPrivate ? 'Prive' : 'Ouvert',
                isPrivate ? const Color(0xFFEF4444) : const Color(0xFF10B981),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                setState(() {
                  if (showDetails) {
                    expandedDetails.remove(eventKey);
                  } else {
                    expandedDetails.add(eventKey);
                  }
                });
              },
              child: Text(showDetails ? 'Masquer details' : 'Details'),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4B5563),
                  height: 1.4,
                ),
              ),
            ),
            crossFadeState: showDetails
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
          const SizedBox(height: 16),
          Text(
            event['title']?.toString() ?? 'Evenement',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(
                event['bar']?.toString() ?? 'Bar',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(
                date != null
                    ? '${date.day}/${date.month} a ${date.hour}h${date.minute.toString().padLeft(2, '0')}'
                    : 'Date non definie',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.people, size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(
                '$participantsCount participants',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _openEventDetail(event, focusJoin: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                ctaLabel,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }

  String _ctaPriceLabel(dynamic price) {
    final value = (price ?? '').toString().trim();
    if (value.isEmpty) return 'Gratuit';
    if (value.toLowerCase() == 'free') return 'Gratuit';
    return value;
  }

  String _eventKey(Map<String, dynamic> event, int index) {
    final id = event['id']?.toString();
    if (id != null && id.isNotEmpty) return id;
    return '$index-${event['title']}-${event['date']}-${event['bar']}';
  }

  Future<void> _openEventDetail(Map<String, dynamic> event,
      {bool focusJoin = false}) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EventDetailPage(event: event, focusJoinAction: focusJoin),
      ),
    );
    _load();
  }

  void _showCreateEventDialog() {
    showDialog(
      context: context,
      builder: (_) => _CreateEventDialog(onCreated: _onCreated),
    );
  }

  void _onCreated(Map<String, dynamic> event) {
    setState(() {
      events.insert(0, _normalizeEvent(event));
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
  final priceCtrl = TextEditingController();
  final privateCodeCtrl = TextEditingController();
  DateTime date = DateTime.now().add(const Duration(days: 1));
  String? barId;
  String eventType = 'Musique';
  bool isPrivate = false;
  bool isFree = true;
  final api = ApiService();
  List<Map<String, dynamic>> bars = [];
  bool loading = true;

  final eventTypes = const [
    'Musique',
    'Concert',
    'Degustation',
    'Soiree',
    'Autre'
  ];

  @override
  void initState() {
    super.initState();
    _loadBars();
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    priceCtrl.dispose();
    privateCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBars() async {
    try {
      final fetched = await api.getBars();
      bars = fetched
          .map<Map<String, dynamic>>((b) => Map<String, dynamic>.from(b))
          .toList();
      if (bars.isNotEmpty) {
        barId = bars.first['id']?.toString() ?? bars.first['_id']?.toString();
      }
    } catch (_) {
      bars = [];
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
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
              'Creer un evenement',
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
                labelText: 'Titre de l evenement',
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
              initialValue: eventType,
              decoration: const InputDecoration(
                labelText: 'Type d evenement',
                border: OutlineInputBorder(),
              ),
              items: eventTypes
                  .map((type) =>
                      DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => eventType = value ?? eventType),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<bool>(
              initialValue: isPrivate,
              decoration: const InputDecoration(
                labelText: 'Visibilite',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: false, child: Text('Ouvert')),
                DropdownMenuItem(value: true, child: Text('Prive')),
              ],
              onChanged: (value) => setState(() {
                isPrivate = value ?? false;
                if (isPrivate) {
                  isFree = true;
                  priceCtrl.clear();
                  privateCodeCtrl.text = _generateCode();
                } else {
                  privateCodeCtrl.clear();
                }
              }),
            ),
            const SizedBox(height: 16),
            if (!isPrivate) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Evenement gratuit'),
                value: isFree,
                onChanged: (value) => setState(() => isFree = value),
              ),
              if (!isFree) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Prix (ex: 12,99€)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ] else ...[
              TextField(
                controller: privateCodeCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Code prive (6 chiffres)',
                  hintText: 'Ex: 123456',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: barId,
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
              onChanged: (value) => setState(() => barId = value),
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
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Creer'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connecte-toi pour creer un evenement')),
        );
      }
      return;
    }
    if (titleCtrl.text.trim().isEmpty || barId == null) return;
    if (isPrivate &&
        !RegExp(r'^\\d{6}$').hasMatch(privateCodeCtrl.text.trim())) {
      privateCodeCtrl.text = _generateCode();
    }
    if (!isPrivate && !isFree && priceCtrl.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoute un prix ou active Gratuit')),
      );
      return;
    }

    try {
      final created = await api.createEvent(
        barId: barId!,
        title: titleCtrl.text.trim(),
        date: date.toIso8601String(),
        type: eventType,
        isPrivate: isPrivate,
        isFree: isPrivate ? true : isFree,
        ticketPrice: isPrivate || isFree ? null : priceCtrl.text.trim(),
        accessCode: isPrivate ? privateCodeCtrl.text.trim() : null,
        description: descriptionCtrl.text.trim(),
      );
      final barName = bars
          .firstWhere((b) =>
              (b['id']?.toString() ?? b['_id']?.toString()) == barId)['name']
          .toString();
      final event = {
        ...created,
        'barName': barName,
        'description': descriptionCtrl.text.trim(),
        'participantsCount': (created['participants'] as List?)?.length ?? 0,
        'isPrivate': isPrivate,
        'isFree': isPrivate ? true : isFree,
        'ticket_price': isPrivate || isFree ? null : priceCtrl.text.trim(),
        'price':
            isPrivate ? 'Code requis' : (isFree ? 'Gratuit' : priceCtrl.text),
      };
      widget.onCreated(event);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evenement cree'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la creation'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  String _generateCode() {
    final n = Random.secure().nextInt(900000) + 100000;
    return n.toString();
  }
}
