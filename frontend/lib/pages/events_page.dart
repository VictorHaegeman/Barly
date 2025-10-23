import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

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
    try {
      events = await api.getEvents();
    } catch (_) {
      // fallback mock si backend indisponible
      events = [
        {
          'id': 'e1',
          'title': 'Soirée House',
          'date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        },
        {
          'id': 'e2',
          'title': 'Live Jazz',
          'date': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        }
      ];
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Événements')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: events.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final e = events[i];
                return ListTile(
                  title: Text(e['title']?.toString() ?? 'Event'),
                  subtitle: Text(DateTime.tryParse(e['date']?.toString() ?? '')
                          ?.toLocal()
                          .toString() ??
                      ''),
                  trailing: FilledButton(
                    onPressed: () async {
                      await api.joinEvent(e['id']?.toString() ?? e['_id']);
                      if (!mounted) return;
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Inscription envoyée')));
                      }
                    },
                    child: const Text('Je participe'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const _CreateEventDialog(),
        ),
        child: const Icon(Icons.add),
      ),
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
  DateTime date = DateTime.now().add(const Duration(days: 1));
  String barId = 'b1';
  final api = ApiService();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Créer un event'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
            controller: titleCtrl,
            decoration: const InputDecoration(labelText: 'Titre')),
        const SizedBox(height: 8),
        DropdownButton<String>(
            value: barId,
            items: const [
              DropdownMenuItem(value: 'b1', child: Text('Lavender Club')),
              DropdownMenuItem(value: 'b2', child: Text('Sway Bar')),
              DropdownMenuItem(value: 'b3', child: Text('Purple Lounge')),
            ],
            onChanged: (v) => setState(() => barId = v ?? 'b1')),
      ]),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler')),
        FilledButton(
          onPressed: () async {
            await httpPostEvent(barId, titleCtrl.text, date);
            if (!mounted) return;
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Event créé')));
            }
          },
          child: const Text('Créer'),
        )
      ],
    );
  }

  Future<void> httpPostEvent(String barId, String title, DateTime date) async {
    final res = await api.token.then((t) => http.post(
        Uri.parse('${api.baseUrl}/api/events'),
        headers: {
          'Content-Type': 'application/json',
          if (t != null) 'Authorization': 'Bearer $t',
        },
        body:
            '{"barId":"$barId","title":"$title","date":"${date.toIso8601String()}"}'));
    if (res.statusCode >= 400) throw Exception('Erreur création');
  }
}
