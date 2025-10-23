import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder map UI
    final bars = [
      {'name': 'Lavender Club', 'lat': 48.8566, 'lng': 2.3522},
      {'name': 'Sway Bar', 'lat': 48.869, 'lng': 2.303},
      {'name': 'Purple Lounge', 'lat': 48.86, 'lng': 2.377},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Carte')),
      body: ListView.builder(
        itemCount: bars.length,
        itemBuilder: (_, i) => ListTile(
          leading: const Icon(Icons.location_on, color: Colors.purple),
          title: Text(bars[i]['name'] as String),
          subtitle: Text('(${bars[i]['lat']}, ${bars[i]['lng']})'),
          onTap: () => showModalBottomSheet(
            context: context,
            showDragHandle: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (_) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bars[i]['name'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18)),
                    const SizedBox(height: 8),
                    const Text('Ambiance: Cosy • Note: 4.6'),
                    const SizedBox(height: 12),
                    FilledButton(
                        onPressed: () {}, child: const Text('Itinéraire')),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

