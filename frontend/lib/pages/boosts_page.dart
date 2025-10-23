import 'package:flutter/material.dart';
import '../widgets/price_pill.dart';
import '../widgets/barly_button.dart';

class BoostsPage extends StatefulWidget {
  const BoostsPage({super.key});

  @override
  State<BoostsPage> createState() => _BoostsPageState();
}

class _BoostsPageState extends State<BoostsPage> {
  final controller = PageController();
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sway')),
      body: Column(children: [
        const SizedBox(height: 12),
        Expanded(
          child: PageView(
            controller: controller,
            onPageChanged: (i) => setState(() => index = i),
            children: const [
              _BoostsSlide(),
              _RewindsSlide(),
              _SubsSlide(),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) => _dot(i == index))),
        const SizedBox(height: 16),
      ]),
    );
  }

  static Widget _dot(bool active) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
            color: active ? Colors.purple : Colors.purple.shade100,
            shape: BoxShape.circle),
      );
}

class _BoostsSlide extends StatelessWidget {
  const _BoostsSlide();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Boost profil ⚡',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        const SizedBox(height: 12),
        const Row(children: [
          Expanded(child: PricePill(label: '1 Boost', price: '7,99€')),
          SizedBox(width: 12),
          Expanded(child: PricePill(label: '3 Boosts', price: '19,99€')),
          SizedBox(width: 12),
          Expanded(child: PricePill(label: '5 Boosts', price: '29,99€')),
        ]),
        const Spacer(),
        BarlyButton(
            label: 'Sélectionner',
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Achat à venir')))),
      ]),
    );
  }
}

class _RewindsSlide extends StatelessWidget {
  const _RewindsSlide();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Rewinds ⏪',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        const SizedBox(height: 12),
        const Row(children: [
          Expanded(
              child: PricePill(
                  label: '15', price: '24,99€', icon: Icons.fast_rewind)),
          SizedBox(width: 12),
          Expanded(
              child: PricePill(
                  label: '30', price: '39,99€', icon: Icons.fast_rewind)),
        ]),
        const Spacer(),
        BarlyButton(
            label: 'Sélectionner',
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Achat à venir')))),
      ]),
    );
  }
}

class _SubsSlide extends StatelessWidget {
  const _SubsSlide();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Abonnements',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        const SizedBox(height: 12),
        const Row(children: [
          Expanded(
              child: PricePill(
                  label: 'Light',
                  price: '1 boost/mois',
                  icon: Icons.star_border)),
          SizedBox(width: 12),
          Expanded(
              child: PricePill(
                  label: 'Gold',
                  price: '1 boost/sem + 10 rew',
                  icon: Icons.workspace_premium)),
          SizedBox(width: 12),
          Expanded(
              child: PricePill(
                  label: 'Platinum',
                  price: '5 boosts/sem + rew ∞',
                  icon: Icons.diamond)),
        ]),
        const Spacer(),
        BarlyButton(
            label: 'Sélectionner',
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Achat à venir')))),
      ]),
    );
  }
}
