import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../widgets/simple_map_widget.dart';
import '../config/google_maps_config.dart';
import 'bar_detail_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool isMapView = true;
  final api = ApiService();
  List<Map<String, dynamic>> bars = [];
  bool loading = true;
  GoogleMapController? mapController;

  bool get _useGoogleMap => GoogleMapsConfig.apiKey.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final fetched = await api.getBars();
      bars = fetched
          .map<Map<String, dynamic>>((b) => {
                ...b as Map<String, dynamic>,
                'imageUrl': (b as Map<String, dynamic>)['coverImage'] ??
                    'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=400&h=300&fit=crop',
              })
          .toList();
    } catch (_) {
      bars = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bars indisponibles (API)')),
        );
      }
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FA),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 22),
                  _buildToggle(),
                  const SizedBox(height: 18),
                  Expanded(
                    child: isMapView ? _buildMapView() : _buildListView(),
                  ),
                ],
              ),
            ),
      floatingActionButton: loading || !isMapView
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: _showCreateBarDialog,
                  backgroundColor: const Color(0xFF7C3AED),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: _getCurrentLocation,
                  backgroundColor: Colors.white,
                  child:
                      const Icon(Icons.my_location, color: Color(0xFF7C3AED)),
                ),
              ],
            ),
    );
  }

  Widget _buildToggle() {
    return Center(
      child: Container(
        width: 270,
        height: 52,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.black, width: 1),
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
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => isMapView = true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isMapView
                        ? const Color(0xFF7C3AED)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: Text(
                      'Carte',
                      style: TextStyle(
                        color:
                            isMapView ? Colors.white : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                        fontSize: 30 / 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => isMapView = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: !isMapView
                        ? const Color(0xFF7C3AED)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: Text(
                      'Liste',
                      style: TextStyle(
                        color:
                            !isMapView ? Colors.white : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                        fontSize: 30 / 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    if (!_useGoogleMap) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SimpleMapWidget(bars: bars),
      );
    }

    final markers = bars.where((b) => b['geo'] != null).map((bar) {
      final coords = bar['geo']['coordinates'];
      return Marker(
        markerId:
            MarkerId(bar['id']?.toString() ?? bar['_id']?.toString() ?? ''),
        position: LatLng(
            (coords[1] as num).toDouble(), (coords[0] as num).toDouble()),
        infoWindow: InfoWindow(title: bar['name']?.toString() ?? 'Bar'),
      );
    }).toSet();

    final first = markers.isNotEmpty
        ? markers.first.position
        : const LatLng(GoogleMapsConfig.defaultLatitude,
            GoogleMapsConfig.defaultLongitude);

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: first, zoom: 13),
      markers: markers,
      onMapCreated: (c) => mapController = c,
      myLocationEnabled: false,
      zoomControlsEnabled: true,
    );
  }

  Widget _buildListView() {
    if (bars.isEmpty) {
      return const Center(child: Text('Aucun bar'));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      itemCount: bars.length,
      separatorBuilder: (context, index) => const Divider(height: 30),
      itemBuilder: (context, index) {
        final bar = bars[index];
        final imageUrl = (bar['imageUrl'] ?? bar['coverImage'])?.toString();
        final ambiance = List<String>.from(bar['ambiance'] ?? []);
        final music = List<String>.from(bar['music'] ?? []);
        final description = (bar['description'] ?? '').toString().trim();
        final subtitle = description.isNotEmpty
            ? description
            : [
                if (ambiance.isNotEmpty) 'Ambiance ${ambiance.join(', ')}',
                if (music.isNotEmpty) 'Musique ${music.join(', ')}',
              ].join(' — ');

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BarDetailPage(bar: bar),
              ),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 84,
                  height: 84,
                  color: const Color(0xFFE9E9EE),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.local_bar,
                            color: Color(0xFF7C3AED),
                          ),
                        )
                      : const Icon(
                          Icons.local_bar,
                          color: Color(0xFF7C3AED),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bar['name']?.toString() ?? 'Bar',
                        style: const TextStyle(
                          fontSize: 32 / 2,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        subtitle.isNotEmpty ? subtitle : 'Bar à découvrir',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 24 / 2,
                          color: Color(0xFF6B7280),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateBarDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un bar'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du bar',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Prix (ex: 8-12€)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  descController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                setState(() {
                  bars.add({
                    'id': (bars.length + 1).toString(),
                    'name': nameController.text,
                    'priceLevel': priceController.text,
                    'ambiance': [descController.text],
                    'imageUrl':
                        'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=400&h=300&fit=crop',
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bar ajouté (mock)')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Veuillez remplir tous les champs')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _getCurrentLocation() {
    Geolocator.requestPermission().then((status) async {
      if (status == LocationPermission.deniedForever ||
          status == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission localisation refusée')),
        );
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLngZoom(
            LatLng(pos.latitude, pos.longitude), 15));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Localisation activée')),
      );
    });
  }
}
