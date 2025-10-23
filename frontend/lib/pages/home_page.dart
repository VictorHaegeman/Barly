import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/barly_card.dart';
import '../widgets/barly_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final api = ApiService();
  List<dynamic> bars = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      bars = await api.getBars();
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barly')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Salut 👋',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 20)),
                    const SizedBox(height: 16),
                    CarouselSlider(
                      options: CarouselOptions(
                          height: 160, enlargeCenterPage: true, autoPlay: true),
                      items: bars.map((b) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(fit: StackFit.expand, children: [
                            Image.asset('assets/images/bar_cover.jpg',
                                fit: BoxFit.cover),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                color: Colors.black45,
                                child: Text(b['name'] ?? 'Bar',
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ),
                            )
                          ]),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text('Recommandés pour toi',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ...bars.map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: BarlyCard(
                            title: b['name'] ?? 'Bar',
                            subtitle: (b['ambiance'] ?? []).join(', '),
                            onTap: () {},
                          ),
                        )),
                    const SizedBox(height: 16),
                    BarlyButton(
                        label: 'Voir sur la carte',
                        onPressed: () => Navigator.pushNamed(context, '/map')),
                  ]),
            ),
    );
  }
}
