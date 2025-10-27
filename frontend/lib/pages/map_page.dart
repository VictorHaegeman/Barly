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
      'image': 'assets/images/bar-pas-cher-paris-le-marigny-paris-3.webp',
      'price': '6,50€',
      'lat': 48.8566,
      'lng': 2.3522,
    },
    {
      'name': 'L’Oasis Urbaine',
      'desc':
          'Bar tropical niché dans le centre-ville — plantes, mojitos et bonne humeur garantis.',
      'image': 'assets/images/BAR.webp',
      'price': '5,90€',
      'lat': 48.869,
      'lng': 2.303,
    },
    {
      'name': 'Le Verre à Soi',
      'desc':
          'Cave-bar intimiste où chaque vin raconte une histoire, accompagnée de planches locales.',
      'image': 'assets/images/BAR1.webp',
      'price': '7,00€',
      'lat': 48.86,
      'lng': 2.377,
    },
    {
      'name': 'Les Frères Houblon',
      'desc':
          'Le rendez-vous des amateurs de bières artisanales. Dégustation, convivialité et fous rires assurés.',
      'image': 'assets/images/paris-france.webp',
      'price': '6,00€',
      'lat': 48.858,
      'lng': 2.341,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Barly',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF9B7BFF),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildToggle(), // ✅ ici on l’appelle simplement
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

  /// --- Toggle Stylé ---
  Widget _buildToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Stack(
          children: [
            // Bulle animée (fond violet)
            AnimatedAlign(
              alignment:
                  showList ? Alignment.centerLeft : Alignment.centerRight,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Container(
                width: (MediaQuery.of(context).size.width - 200) / 2,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF9B7BFF),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),

            // Texte "Liste" et "Carte"
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => showList = true),
                    child: Center(
                      child: Text(
                        "Liste",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: showList ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => showList = false),
                    child: Center(
                      child: Text(
                        "Carte",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: !showList ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
              child: Image.asset(
                bar['image'] as String,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bar['name'] as String,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bar['desc'] as String,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pinte : ${bar['price'] as String}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9B7BFF),
                    ),
                  ),
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
      final name = bar['name'] as String;
      final price = bar['price'] as String;
      final lat = bar['lat'] as double;
      final lng = bar['lng'] as double;

      return Marker(
        markerId: MarkerId(name),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: name,
          snippet: 'Pinte : $price',
        ),
      );
    }).toSet();

    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(48.8566, 2.3522),
        zoom: 13,
      ),
      markers: markers,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
    );
  }
}
