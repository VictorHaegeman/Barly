import 'package:flutter/material.dart';
import '../widgets/simple_map_widget.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool isMapView = true;

  List<Map<String, dynamic>> bars = [
    {
      'id': '1',
      'name': 'Le Comptoir du 7ème',
      'price': '8-12€',
      'desc': 'Bar à cocktails branché',
      'image':
          'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=400&h=300&fit=crop',
    },
    {
      'id': '2',
      'name': 'L\'Oasis Urbaine',
      'price': '15-25€',
      'desc': 'Rooftop avec vue panoramique',
      'image':
          'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=400&h=300&fit=crop',
    },
    {
      'id': '3',
      'name': 'Le Bar d\'Or',
      'price': '5-8€',
      'desc': 'Ambiance cosy et chaleureuse',
      'image':
          'https://images.unsplash.com/photo-1572116469696-31de0f17cc34?w=400&h=300&fit=crop',
    },
    {
      'id': '4',
      'name': 'Le Speakeasy',
      'price': '12-18€',
      'desc': 'Bar clandestin vintage',
      'image':
          'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=400&h=300&fit=crop',
    },
    {
      'id': '5',
      'name': 'Cocktail Corner',
      'price': '10-15€',
      'desc': 'Spécialités cocktails créatifs',
      'image':
          'https://images.unsplash.com/photo-1544148103-0773bf10d330?w=400&h=300&fit=crop',
    },
    {
      'id': '6',
      'name': 'Le Vin & Co',
      'price': '6-12€',
      'desc': 'Bar à vin et tapas',
      'image':
          'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb?w=400&h=300&fit=crop',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FA),
      body: Column(
        children: [
          // Toggle au-dessus de l'AppBar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: _buildToggle(),
          ),
          // Contenu principal
          Expanded(
            child: isMapView ? _buildMapView() : _buildListView(),
          ),
        ],
      ),
      floatingActionButton: Column(
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
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
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
            ),
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SimpleMapWidget(bars: bars),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bars.length,
      itemBuilder: (context, index) {
        final bar = bars[index];
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
                  image: DecorationImage(
                    image: NetworkImage(bar['image'] as String),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Fallback to icon if image fails to load
                    },
                  ),
                ),
                child: bar['image'] == null
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
                        bar['name'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bar['desc'] as String,
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
                          bar['price'] as String,
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
                    'price': priceController.text,
                    'desc': descController.text,
                    'image':
                        'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=400&h=300&fit=crop',
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bar ajouté avec succès !')),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Localisation activée')),
    );
  }
}
