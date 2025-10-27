import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final api = ApiService();
  Map<String, dynamic>? me;
  Map<String, List<String>> _selectedValues = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      me = await api.getMe();
      if (mounted) setState(() {});
    } catch (e) {
      // Utiliser des données mock si l'API ne fonctionne pas
      me = {
        'firstName': 'Victor',
        'email': 'victor@example.com',
        'phone': '+33676952345',
        'preferences': {
          'ambiance': ['Lounge', 'Chic'],
          'music': ['Jazz', 'Electro'],
          'drinks': ['Cocktails', 'Vin'],
          'priceLevel': 'Moyen',
          'language': 'Français',
          'units': 'kilomètres'
        }
      };
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: me == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
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
                  children: [
                    // Photo de profil
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 2,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 48,
                            backgroundColor: Color(0xFFF3F4F6),
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
                            ),
                            child: null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF9B7BFF),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Section Informations
                    _buildSection(
                      'Informations',
                      [
                        _buildInfoItem('Numéro de téléphone',
                            me!['phone'] ?? '+33676952345', 'phone'),
                        _buildInfoItem('Adresse e-mail',
                            me!['email'] ?? 'victor@example.com', 'email'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section Préférences Bar & Alcool
                    _buildSection(
                      'Préférences Bar & Alcool',
                      [
                        _buildInfoItem(
                            'Ambiance préférée',
                            _formatPreferences(me!['preferences']?['ambiance']),
                            'ambiance'),
                        _buildInfoItem(
                            'Musique préférée',
                            _formatPreferences(me!['preferences']?['music']),
                            'music'),
                        _buildInfoItem(
                            'Boissons préférées',
                            _formatPreferences(me!['preferences']?['drinks']),
                            'drinks'),
                        _buildInfoItem(
                            'Niveau de prix',
                            me!['preferences']?['priceLevel'] ?? 'Moyen',
                            'priceLevel'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section Notifications
                    _buildSection(
                      'Notifications',
                      [
                        _buildInfoItem('Notifications push', 'Activées',
                            'pushNotifications'),
                        _buildInfoItem(
                            'E-mail', 'Activées', 'emailNotifications'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section Langue et Région
                    _buildSection(
                      'Langue et Région',
                      [
                        _buildInfoItem(
                            'Langue de choix',
                            me!['preferences']?['language'] ?? 'Français',
                            'language'),
                        _buildInfoItem(
                            'Unités de mesures',
                            me!['preferences']?['units'] ?? 'kilomètres',
                            'units'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, String field) {
    return GestureDetector(
      onTap: () => _showEditDialog(label, value, field),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1F2937),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPreferences(dynamic preferences) {
    if (preferences == null) return 'Non défini';
    if (preferences is List) {
      return preferences.join(', ');
    }
    return preferences.toString();
  }

  void _showEditDialog(String label, String currentValue, String field) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier $label'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (field == 'ambiance' || field == 'music' || field == 'drinks')
              _buildMultiSelectField(field, currentValue)
            else
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: label,
                  border: const OutlineInputBorder(),
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
              final newValue =
                  field == 'ambiance' || field == 'music' || field == 'drinks'
                      ? _getSelectedValues(field)
                      : controller.text;
              _saveField(field, newValue);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B7BFF),
            ),
            child: const Text('Sauvegarder',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectField(String field, String currentValue) {
    List<String> options = [];
    List<String> selected =
        currentValue.split(', ').where((e) => e.isNotEmpty).toList();

    switch (field) {
      case 'ambiance':
        options = [
          'Lounge',
          'Chic',
          'Dance',
          'Intime',
          'Festif',
          'Décontracté'
        ];
        break;
      case 'music':
        options = [
          'Jazz',
          'Electro',
          'Rock',
          'Pop',
          'Classique',
          'Rap',
          'Reggae'
        ];
        break;
      case 'drinks':
        options = [
          'Cocktails',
          'Vin',
          'Bière',
          'Whisky',
          'Champagne',
          'Spiritueux'
        ];
        break;
    }

    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: options
            .map((option) => CheckboxListTile(
                  title: Text(option),
                  value: selected.contains(option),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selected.add(option);
                      } else {
                        selected.remove(option);
                      }
                    });
                    // Stocker les valeurs sélectionnées pour les récupérer plus tard
                    _selectedValues[field] = selected;
                  },
                ))
            .toList(),
      ),
    );
  }

  String _getSelectedValues(String field) {
    return _selectedValues[field]?.join(', ') ?? '';
  }

  void _saveField(String field, dynamic newValue) {
    setState(() {
      if (field == 'phone' || field == 'email') {
        me![field] = newValue;
      } else if (field == 'pushNotifications' ||
          field == 'emailNotifications') {
        // Gérer les notifications
        me![field] = newValue;
      } else {
        // Gérer les préférences
        if (me!['preferences'] == null) {
          me!['preferences'] = {};
        }
        if (field == 'ambiance' || field == 'music' || field == 'drinks') {
          me!['preferences'][field] =
              newValue.split(', ').where((e) => e.isNotEmpty).toList();
        } else {
          me!['preferences'][field] = newValue;
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Informations mises à jour !'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }
}
