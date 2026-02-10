import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'bar_detail_page.dart';

class AllBarsPage extends StatefulWidget {
  const AllBarsPage({super.key});

  @override
  State<AllBarsPage> createState() => _AllBarsPageState();
}

class _AllBarsPageState extends State<AllBarsPage> {
  final api = ApiService();
  List<Map<String, dynamic>> bars = [];
  bool loading = true;
  String? filterAmbiance;
  String? filterPrice;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final fetched = await api.getBars();
      bars = fetched
          .map<Map<String, dynamic>>((b) => {
                ...b as Map<String, dynamic>,
                'imageUrl': (b as Map<String, dynamic>)['coverImage'] ??
                    'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=400&h=300&fit=crop',
                'pintPrice': (b as Map<String, dynamic>)['pintPrice'] ?? '€€',
              })
          .toList();
    } catch (_) {
      bars = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de charger les bars')),
        );
      }
    }
    if (mounted) setState(() => loading = false);
  }

  List<Map<String, dynamic>> get filteredBars {
    return bars.where((bar) {
      final ambOk = filterAmbiance == null ||
          (bar['ambiance'] ?? []).contains(filterAmbiance);
      final priceOk = filterPrice == null || bar['priceLevel'] == filterPrice;
      return ambOk && priceOk;
    }).toList();
  }

  List<String> get ambiances => {
        for (final b in bars) ...List<String>.from(b['ambiance'] ?? [])
      }.toList();

  List<String> get priceLevels => {
        for (final b in bars)
          if (b['priceLevel'] != null) b['priceLevel'].toString()
      }.toList();

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
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: Column(
                children: [
                  _buildFilters(),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredBars.length,
                      itemBuilder: (context, index) {
                        final bar = filteredBars[index];
                        return _buildBarCard(bar);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: filterAmbiance,
              decoration: const InputDecoration(
                  labelText: 'Ambiance', border: OutlineInputBorder()),
              items: ambiances
                  .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                  .toList(),
              onChanged: (v) => setState(
                  () => filterAmbiance = v?.isEmpty == true ? null : v),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: filterPrice,
              decoration: const InputDecoration(
                  labelText: 'Prix', border: OutlineInputBorder()),
              items: priceLevels
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => filterPrice = v?.isEmpty == true ? null : v),
            ),
          ),
          IconButton(
            tooltip: 'Réinitialiser',
            onPressed: () => setState(() {
              filterAmbiance = null;
              filterPrice = null;
            }),
            icon: const Icon(Icons.refresh),
          )
        ],
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
                          bar['pintPrice'] ?? '€€',
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
                    bar['address'] ?? 'Adresse inconnue',
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
                        Icons.music_note,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          (bar['music'] ?? []).join(', '),
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
                        Icons.wallet,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        bar['priceLevel'] ?? '€',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
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
