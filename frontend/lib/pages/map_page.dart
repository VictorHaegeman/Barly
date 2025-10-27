import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool showList = true;

  final bars = [
    {
      'name': 'Le Comptoir d’Or',
      'desc':
          'Ambiance chic et feutrée, cocktails signature et lumière dorée pour une soirée élégante au cœur de la ville.',
      'image':
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',
      'price': '6,50€',
      'lat': 48.8566,
      'lng': 2.3522,
    },
    {
      'name': 'L’Oasis Urbaine',
      'desc':
          'Bar tropical niché dans le centre-ville — plantes, mojitos et bonne humeur garantis.',
      'image':
          'https://images.unsplash.com/photo-1604908177079-0c7b6a19b4de?w=400',
      'price': '5,90€',
      'lat': 48.869,
      'lng': 2.303,
    },
    {
      'name': 'Le Verre à Soi',
      'desc':
          'Cave-bar intimiste où chaque vin raconte une histoire, accompagnée de planches locales.',
      'image':
          'https://images.unsplash.com/photo-1570197788417-0e82375c9371?w=400',
      'price': '7,00€',
      'lat': 48.86,
      'lng': 2.377,
    },
    {
      'name': 'Les Frères Houblon',
      'desc':
          'Le rendez-vous des amateurs de bières artisanales. Dégustation, convivialité et fous rires assurés.',
      'image':
          'https://images.unsplash.com/photo-1618220179428-22790b461013?w=400',
      'price': '6,00€',
      'lat': 48.858,
      'lng': 2.341,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barly',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Color(0xFF9B7BFF))),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(40),
              selectedColor: Colors.white,
              color: Colors.black87,
              fillColor: const Color(0xFF9B7BFF),
              borderColor: Colors.black87,
              isSelected: [showList, !showList],
              onPressed: (index) {
                setState(() => showList = index == 0);
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Liste', style: TextStyle(fontSize: 16)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Carte', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: showList ? _buildListView() : _buildMapView(),
            ),
          ),
        ],
      ),
    );
  }

  /// --- Vue Liste ---
  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const Divider(height: 32),
      itemCount: bars.length,
      itemBuilder: (context, i) {
        final bar = bars[i];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(bar['image']!,
                  width: 90, height: 90, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bar['name']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(bar['desc']!,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text('Pinte : ${bar['price']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.purple)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// --- Vue Carte ---
  Widget _buildMapView() {
    final markers = bars.map((bar) {
      return Marker(
        markerId: MarkerId(bar['name']!),
        position: LatLng(bar['lat'] as double, bar['lng'] as double),
        infoWindow: InfoWindow(
          title: bar['name'],
          snippet: 'Pinte : ${bar['price']}',
        ),
      );
    }).toSet();

    return GoogleMap(
      initialCameraPosition:
          const CameraPosition(target: LatLng(48.8566, 2.3522), zoom: 13),
      markers: markers,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
    );
  }
}
