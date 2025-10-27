import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'event_detail_page.dart';

class AllEventsPage extends StatefulWidget {
  const AllEventsPage({super.key});

  @override
  State<AllEventsPage> createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  List<Map<String, dynamic>> events = [
    {
      'id': 'e1',
      'title': 'Soirée House Music',
      'bar': 'Le Comptoir d\'Or',
      'date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      'participants': 24,
      'price': '12€',
      'type': 'Musique',
      'description': 'Une soirée électro-house avec les meilleurs DJs de Paris',
      'imageUrl':
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=300&fit=crop',
    },
    {
      'id': 'e2',
      'title': 'Dégustation de Vins',
      'bar': 'Le Verre à Soi',
      'date': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
      'participants': 15,
      'price': '25€',
      'type': 'Dégustation',
      'description': 'Découvrez une sélection de vins d\'exception',
      'imageUrl':
          'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb?w=400&h=300&fit=crop',
    },
    {
      'id': 'e3',
      'title': 'Open Mic Night',
      'bar': 'L\'Oasis Urbaine',
      'date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'participants': 30,
      'price': 'Gratuit',
      'type': 'Divertissement',
      'description': 'Venez partager vos talents ou simplement écouter',
      'imageUrl':
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=300&fit=crop',
    },
    {
      'id': 'e4',
      'title': 'Cocktail Masterclass',
      'bar': 'Le Speakeasy',
      'date': DateTime.now().add(const Duration(days: 10)).toIso8601String(),
      'participants': 12,
      'price': '35€',
      'type': 'Atelier',
      'description': 'Apprenez à créer des cocktails d\'exception',
      'imageUrl':
          'https://images.unsplash.com/photo-1544148103-0773bf10d330?w=400&h=300&fit=crop',
    },
    {
      'id': 'e5',
      'title': 'Soirée Jazz',
      'bar': 'Cocktail Corner',
      'date': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
      'participants': 20,
      'price': '18€',
      'type': 'Musique',
      'description': 'Une soirée jazz intimiste avec musiciens locaux',
      'imageUrl':
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=300&fit=crop',
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
          'Tous les événements',
          style: GoogleFonts.poppins(
            color: AppTheme.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppTheme.text),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final date = DateTime.tryParse(event['date'] ?? '');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(event: event),
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
                event['imageUrl'] ?? '',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppTheme.lavender.withOpacity(0.1),
                  ),
                  child: Center(
                    child: Icon(
                      _getEventTypeIcon(event['type']),
                      size: 50,
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
                          event['title'] ?? 'Événement',
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
                          event['price'] ?? 'Gratuit',
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
                    event['description'] ?? '',
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
                        Icons.local_bar,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event['bar'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date != null
                            ? '${date.day}/${date.month} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}'
                            : 'Date inconnue',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${event['participants']} participants',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
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

  IconData _getEventTypeIcon(String? type) {
    switch (type) {
      case 'Musique':
        return Icons.music_note;
      case 'Dégustation':
        return Icons.wine_bar;
      case 'Divertissement':
        return Icons.celebration;
      case 'Atelier':
        return Icons.school;
      default:
        return Icons.event;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Filtrer les événements',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('Musique'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filtre Musique appliqué')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.wine_bar),
              title: const Text('Dégustation'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filtre Dégustation appliqué')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.celebration),
              title: const Text('Divertissement'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Filtre Divertissement appliqué')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}
