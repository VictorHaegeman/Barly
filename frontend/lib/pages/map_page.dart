import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../widgets/simple_map_widget.dart';
import '../config/google_maps_config.dart';

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
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _buildToggle(),
                ),
                Expanded(
                  child: isMapView ? _buildMapView() : _buildListView(),
                ),
              ],
            ),
      floatingActionButton: loading
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: _showCreateBarDialog,
                  backgroundColor: const Color(0xFF9B7BFF),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: _getCurrentLocation,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Color(0xFF9B7BFF)),
                ),
              ],
            ),
    );
  }

  Widget _buildToggle() {
    return Center(
      child: Container(
        width: 180,
        height: 36,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
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
                        ? const Color(0xFF9B7BFF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Carte',
                      style: TextStyle(
                        color: isMapView
                            ? Colors.white
                            : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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
                        ? const Color(0xFF9B7BFF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Liste',
                      style: TextStyle(
                        color: !isMapView
                            ? Colors.white
                            : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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
        markerId: MarkerId(bar['id']?.toString() ?? bar['_id']?.toString() ?? ''),
        position: LatLng((coords[1] as num).toDouble(), (coords[0] as num).toDouble()),
        infoWindow: InfoWindow(title: bar['name']?.toString() ?? 'Bar'),
      );
    }).toSet();

    final first = markers.isNotEmpty
        ? markers.first.position
        : const LatLng(GoogleMapsConfig.defaultLatitude, GoogleMapsConfig.defaultLongitude);

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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bars.length,
      itemBuilder: (context, index) {
        final bar = bars[index];
        final imageUrl = bar['imageUrl'] as String?;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  image: imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {},
                        )
                      : null,
                ),
                child: imageUrl == null
                    ? const Icon(
                        Icons.local_bar,
                        color: Color(0xFF9B7BFF),
                        size: 40,
                      )
                    : null,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bar['name'] as String? ?? 'Bar',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (bar['ambiance'] ?? []).join(', '),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          bar['priceLevel']?.toString() ?? '€',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10B981),
                          ),
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
              backgroundColor: const Color(0xFF9B7BFF),
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
