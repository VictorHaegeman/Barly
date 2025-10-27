import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/google_maps_service.dart';

class BarMapWidget extends StatefulWidget {
  final List<Map<String, dynamic>> bars;

  const BarMapWidget({
    super.key,
    required this.bars,
  });

  @override
  State<BarMapWidget> createState() => _BarMapWidgetState();
}

class _BarMapWidgetState extends State<BarMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }

  @override
  void didUpdateWidget(BarMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bars != widget.bars) {
      _updateMarkers();
    }
  }

  void _updateMarkers() {
    setState(() {
      _markers = GoogleMapsService.createBarMarkers(widget.bars);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    GoogleMapsService.setController(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: GoogleMapsService.defaultCameraPosition,
          markers: _markers,
          mapType: MapType.normal,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          mapToolbarEnabled: false,
          onTap: (LatLng position) {
            // Optionnel : gérer les clics sur la carte
          },
        ),
      ),
    );
  }
}
