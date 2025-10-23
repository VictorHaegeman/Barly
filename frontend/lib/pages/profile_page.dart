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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    me = await api.getMe();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: me == null
          ? const Center(child: Text('Connecte-toi pour voir ton profil'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(radius: 28, child: Icon(Icons.person)),
                    const SizedBox(height: 8),
                    Text(me!['firstName']?.toString() ?? 'Utilisateur',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(me!['email']?.toString() ?? ''),
                    const SizedBox(height: 16),
                    const Text('Préférences'),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, children: [
                      for (final a in List<String>.from(
                          me!['preferences']?['ambiance'] ?? []))
                        Chip(label: Text(a)),
                    ]),
                  ]),
            ),
    );
  }
}

