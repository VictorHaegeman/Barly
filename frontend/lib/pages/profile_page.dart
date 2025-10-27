import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final api = ApiService();
  Map<String, dynamic> userInfo = {
    'phone': '+33676952345',
    'email': 'zebi.hassoul@gmail.com',
    'pushNotifications': true,
    'emailNotifications': false,
    'language': 'Français',
    'units': 'kilomètres',
    // Préférences bars et alcool
    'preferredAmbiance': ['Chic', 'Décontracté'],
    'preferredMusic': ['Jazz', 'Pop'],
    'preferredDrinks': ['Cocktails', 'Vin'],
    'priceLevel': '€€',
    'favoriteBars': ['Le Comptoir du 7ème', 'L\'Oasis Urbaine'],
  };

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Photo de profil
              _buildProfilePicture(),
              const SizedBox(height: 30),

              // Contenu principal dans une carte blanche
              Container(
                width: double.infinity,
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
                    _buildSection('Informations', [
                      _buildInfoItem(
                          'Numéro de téléphone', userInfo['phone'], 'phone'),
                      _buildInfoItem(
                          'Adresse e-mail', userInfo['email'], 'email'),
                    ]),
                    _buildDivider(),
                    _buildSection('Préférences Bars & Alcool', [
                      _buildMultiSelectItem('Ambiance préférée',
                          userInfo['preferredAmbiance'], 'preferredAmbiance'),
                      _buildMultiSelectItem('Musique préférée',
                          userInfo['preferredMusic'], 'preferredMusic'),
                      _buildMultiSelectItem('Boissons préférées',
                          userInfo['preferredDrinks'], 'preferredDrinks'),
                      _buildInfoItem('Niveau de prix', userInfo['priceLevel'],
                          'priceLevel'),
                      _buildMultiSelectItem('Bars favoris',
                          userInfo['favoriteBars'], 'favoriteBars'),
                    ]),
                    _buildDivider(),
                    _buildSection('Notifications', [
                      _buildToggleItem('Notifications push',
                          userInfo['pushNotifications'], 'pushNotifications'),
                      _buildToggleItem('E-mail', userInfo['emailNotifications'],
                          'emailNotifications'),
                    ]),
                    _buildDivider(),
                    _buildSection('Langue et Région', [
                      _buildInfoItem(
                          'Langue de choix', userInfo['language'], 'language'),
                      _buildInfoItem(
                          'Unités de mesures', userInfo['units'], 'units'),
                    ]),
                    _buildDivider(),
                    _buildSection('Compte', [
                      _buildLogoutButton(),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: const Color(0xFFE5E7EB),
          child: ClipOval(
            child: Image.network(
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.person,
                size: 60,
                color: Color(0xFF9B7BFF),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _showPhotoOptions,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF9B7BFF),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, String field) {
    return InkWell(
      onTap: () => _showEditDialog(label, value, field),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
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

  Widget _buildToggleItem(String label, bool value, String field) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              setState(() {
                userInfo[field] = newValue;
              });
            },
            activeColor: const Color(0xFF9B7BFF),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectItem(
      String label, List<String> values, String field) {
    return InkWell(
      onTap: () => _showMultiSelectDialog(label, values, field),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    values.isEmpty ? 'Aucune sélection' : values.join(', '),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFE5E7EB),
      margin: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  void _showEditDialog(String label, String currentValue, String field) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userInfo[field] = controller.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Information mise à jour')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B7BFF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _showMultiSelectDialog(
      String label, List<String> currentValues, String field) {
    // Définir les options disponibles selon le type de préférence
    List<String> availableOptions = [];
    switch (field) {
      case 'preferredAmbiance':
        availableOptions = [
          'Chic',
          'Décontracté',
          'Festif',
          'Intimiste',
          'Branché',
          'Cosy'
        ];
        break;
      case 'preferredMusic':
        availableOptions = [
          'Jazz',
          'Pop',
          'Rock',
          'Électro',
          'Latino',
          'Classique',
          'Hip-Hop'
        ];
        break;
      case 'preferredDrinks':
        availableOptions = [
          'Cocktails',
          'Vin',
          'Bière',
          'Spiritueux',
          'Sans alcool',
          'Champagne'
        ];
        break;
      case 'favoriteBars':
        availableOptions = [
          'Le Comptoir du 7ème',
          'L\'Oasis Urbaine',
          'Le Bar d\'Or',
          'Le Speakeasy',
          'Cocktail Corner',
          'Le Vin & Co'
        ];
        break;
    }

    Map<String, bool> selectedOptions = {};
    for (String option in availableOptions) {
      selectedOptions[option] = currentValues.contains(option);
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Modifier $label'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableOptions.length,
              itemBuilder: (context, index) {
                String option = availableOptions[index];
                return CheckboxListTile(
                  title: Text(option),
                  value: selectedOptions[option] ?? false,
                  onChanged: (bool? value) {
                    setState(() {
                      selectedOptions[option] = value ?? false;
                    });
                  },
                  activeColor: const Color(0xFF9B7BFF),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                List<String> newValues = selectedOptions.entries
                    .where((entry) => entry.value)
                    .map((entry) => entry.key)
                    .toList();

                setState(() {
                  userInfo[field] = newValues;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Préférences mises à jour')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B7BFF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sauvegarder'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: _showLogoutDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.logout,
              color: Colors.red[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Se déconnecter',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.red[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
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

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Changer la photo de profil',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Fonctionnalité bientôt disponible')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Fonctionnalité bientôt disponible')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Supprimer la photo'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Photo supprimée')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Se déconnecter',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await api.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}
