import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'bar_detail_page.dart';

class AllBarsPage extends StatefulWidget {
  const AllBarsPage({super.key});

  @override
  State<AllBarsPage> createState() => _AllBarsPageState();
}

class _AllBarsPageState extends State<AllBarsPage> {
  List<Map<String, dynamic>> bars = [
    {
      'id': 'b1',
      'name': 'Le Comptoir d\'Or',
      'ambiance': ['Chic', 'Lounge'],
      'priceLevel': 'Élevé',
      'rating': 4.8,
      'pintPrice': '8€',
      'imageUrl':
          'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=400&h=300&fit=crop',
      'description': 'Un bar chic et sophistiqué au cœur de Paris',
      'address': '123 Rue de Rivoli, 75001 Paris',
      'phone': '+33 1 42 36 78 90',
      'hours': '18h00 - 02h00',
    },
    {
      'id': 'b2',
      'name': 'L\'Oasis Urbaine',
      'ambiance': ['Tropical', 'Décontracté'],
      'priceLevel': 'Moyen',
      'rating': 4.5,
      'pintPrice': '6€',
      'imageUrl':
          'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=400&h=300&fit=crop',
      'description': 'Une ambiance tropicale en plein centre-ville',
      'address': '45 Boulevard Saint-Germain, 75005 Paris',
      'phone': '+33 1 43 25 67 89',
      'hours': '17h00 - 01h00',
    },
    {
      'id': 'b3',
      'name': 'Le Verre à Soi',
      'ambiance': ['Intimiste', 'Vin'],
      'priceLevel': 'Moyen',
      'rating': 4.7,
      'pintPrice': '5€',
      'imageUrl':
          'https://images.unsplash.com/photo-1572116469696-31de0f17cc34?w=400&h=300&fit=crop',
      'description': 'Bar à vin intimiste avec sélection soignée',
      'address': '78 Rue de la Paix, 75002 Paris',
      'phone': '+33 1 40 15 30 45',
      'hours': '16h00 - 00h00',
    },
    {
      'id': 'b4',
      'name': 'Le Speakeasy',
      'ambiance': ['Vintage', 'Cocktails'],
      'priceLevel': 'Élevé',
      'rating': 4.9,
      'pintPrice': '12€',
      'imageUrl':
          'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=400&h=300&fit=crop',
      'description': 'Bar clandestin avec cocktails d\'exception',
      'address': '12 Rue des Archives, 75004 Paris',
      'phone': '+33 1 48 04 12 34',
      'hours': '19h00 - 03h00',
    },
    {
      'id': 'b5',
      'name': 'Cocktail Corner',
      'ambiance': ['Moderne', 'Créatif'],
      'priceLevel': 'Moyen',
      'rating': 4.6,
      'pintPrice': '7€',
      'imageUrl':
          'https://images.unsplash.com/photo-1544148103-0773bf10d330?w=400&h=300&fit=crop',
      'description': 'Cocktails créatifs dans un cadre moderne',
      'address': '56 Avenue des Champs-Élysées, 75008 Paris',
      'phone': '+33 1 42 56 78 90',
      'hours': '18h30 - 02h30',
    },
    {
      'id': 'b6',
      'name': 'Le Vin & Co',
      'ambiance': ['Cosy', 'Dégustation'],
      'priceLevel': 'Moyen',
      'rating': 4.4,
      'pintPrice': '6€',
      'imageUrl':
          'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb?w=400&h=300&fit=crop',
      'description': 'Bar à vin cosy avec tapas délicieuses',
      'address': '89 Rue Montmartre, 75002 Paris',
      'phone': '+33 1 40 28 91 23',
      'hours': '15h00 - 23h00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tous les bars',
          style: GoogleFonts.poppins(
            color: AppTheme.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.text),
            onPressed: () {
              // TODO: Implémenter la recherche
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recherche bientôt disponible')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bars.length,
        itemBuilder: (context, index) {
          final bar = bars[index];
          return _buildBarCard(bar);
        },
      ),
    );
  }

  Widget _buildBarCard(Map<String, dynamic> bar) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BarDetailPage(bar: bar),
          ),
        );
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                bar['imageUrl'] ?? '',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.lavender.withOpacity(0.1),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.local_bar,
                      size: 60,
                      color: AppTheme.lavender,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          bar['name'] ?? 'Bar',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.text,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.lavender.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          bar['pintPrice'] ?? '5€',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lavender,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bar['description'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          bar['address'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        bar['hours'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            bar['rating']?.toString() ?? '4.0',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.text,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
