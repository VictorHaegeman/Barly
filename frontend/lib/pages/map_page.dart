import 'package:flutter/material.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool showList = true;

  final bars = [
    {
      'name': 'Le Comptoir d\'Or',
      'desc':
          'Ambiance chic et feutrée, cocktails signature et lumière dorée pour une soirée élégante au cœur de la ville.',
      'image': 'assets/images/bar_cover.jpg',
      'price': '6,50€',
      'lat': 48.8566,
      'lng': 2.3522,
    },
    {
      'name': 'L\'Oasis Urbaine',
      'desc':
          'Bar tropical niché dans le centre-ville — plantes, mojitos et bonne humeur garantis.',
      'image': 'assets/images/hero_party.jpg',
      'price': '5,90€',
      'lat': 48.869,
      'lng': 2.303,
    },
    {
      'name': 'Le Verre à Soi',
      'desc':
          'Cave-bar intimiste où chaque vin raconte une histoire, accompagnée de planches locales.',
      'image': 'assets/images/bar_cover.jpg',
      'price': '7,00€',
      'lat': 48.86,
      'lng': 2.377,
    },
    {
      'name': 'Les Frères Houblon',
      'desc':
          'Le rendez-vous des amateurs de bières artisanales. Dégustation, convivialité et fous rires assurés.',
      'image': 'assets/images/hero_party.jpg',
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateBarDialog,
        backgroundColor: const Color(0xFF9B7BFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// --- Toggle Stylé ---
  Widget _buildToggle() {
    return Center(
      child: Container(
        width: 200, // Largeur fixe réduite
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Stack(
          children: [
            // Bulle animée (fond lavande)
            AnimatedAlign(
              alignment:
                  showList ? Alignment.centerLeft : Alignment.centerRight,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                width: 97, // Largeur fixe pour chaque option
                height: 44,
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B7BFF),
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),

            // Texte "Liste" et "Carte"
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => showList = true),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                      ),
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
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => showList = false),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                      ),
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
      padding: const EdgeInsets.all(20),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemCount: bars.length,
      itemBuilder: (context, i) {
        final bar = bars[i];
        return Container(
          padding: const EdgeInsets.all(16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF9B7BFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF9B7BFF).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Image.network(
                  'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=150&h=150&fit=crop',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.local_bar,
                      color: Color(0xFF9B7BFF),
                      size: 32,
                    );
                  },
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
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      bar['desc'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9B7BFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF9B7BFF).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Pinte : ${bar['price'] as String}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9B7BFF),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// --- Vue Carte ---
  Widget _buildMapView() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 64,
              color: Color(0xFF9B7BFF),
            ),
            SizedBox(height: 16),
            Text(
              'Carte des bars',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Google Maps sera intégré ici',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateBarDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un bar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nom du bar',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(
                labelText: 'Prix d\'une pinte (ex: 6,50€)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                final newBar = {
                  'id': 'b${DateTime.now().millisecondsSinceEpoch}',
                  'name': nameCtrl.text,
                  'desc': descCtrl.text.isNotEmpty
                      ? descCtrl.text
                      : 'Nouveau bar ajouté par la communauté.',
                  'price': priceCtrl.text.isNotEmpty ? priceCtrl.text : '6,50€',
                };
                setState(() {
                  bars.insert(0, newBar);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bar ajouté avec succès !'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B7BFF),
            ),
            child: const Text('Ajouter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
