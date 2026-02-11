import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({
    super.key,
    required this.event,
    this.focusJoinAction = false,
  });

  final Map<String, dynamic> event;
  final bool focusJoinAction;

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final api = ApiService();
  bool joining = false;

  bool get isPrivate =>
      widget.event['isPrivate'] == true ||
      widget.event['is_private'] == true ||
      widget.event['visibility']?.toString().toLowerCase() == 'private';

  int get participantsCount {
    final raw =
        widget.event['participantsCount'] ?? widget.event['participants'];
    if (raw is List) return raw.length;
    if (raw is num) return raw.toInt();
    return 0;
  }

  bool get isFree {
    final raw = widget.event['isFree'] ?? widget.event['is_free'];
    if (raw is bool) return raw;
    return true;
  }

  String get priceLabel {
    if (isPrivate) return 'Code requis';
    final ticketPrice = widget.event['ticket_price']?.toString().trim();
    if (ticketPrice != null && ticketPrice.isNotEmpty) return ticketPrice;
    final fallback = widget.event['price']?.toString().trim();
    if (fallback == null || fallback.isEmpty) return 'Gratuit';
    return fallback;
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
          'Details evenement',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B21B6), Color(0xFF9333EA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.event, size: 72, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.focusJoinAction)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Tu es sur la page de participation. Verifie les infos puis confirme.',
                  style: TextStyle(
                    color: Color(0xFF5B21B6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip(
                        widget.event['type']?.toString() ?? 'Evenement',
                        const Color(0xFF7C3AED),
                      ),
                      _chip(
                        isPrivate ? 'Prive' : 'Ouvert a inscription',
                        isPrivate
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.event['title']?.toString() ?? 'Evenement',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _infoRow(
                    Icons.location_on,
                    'Lieu',
                    widget.event['bar']?.toString() ?? 'Bar',
                  ),
                  const SizedBox(height: 10),
                  _infoRow(Icons.calendar_today, 'Date',
                      _formatDate(widget.event['date']?.toString())),
                  const SizedBox(height: 10),
                  _infoRow(Icons.people, 'Participants', '$participantsCount'),
                  const SizedBox(height: 10),
                  _infoRow(
                    Icons.payments_outlined,
                    'Prix',
                    priceLabel,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPrivate
                        ? 'Evenement prive: participation sur invitation.'
                        : 'Evenement ouvert: inscription immediate possible.',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: joining ? null : _handleJoinAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPrivate
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: joining
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isPrivate
                                  ? 'Je participe avec un code d evenement'
                                  : 'Confirmer ma participation',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF7C3AED)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
      ],
    );
  }

  Future<void> _handleJoinAction() async {
    if (!api.isAuthenticated) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecte-toi pour participer')),
      );
      return;
    }

    String? privateCode;
    if (isPrivate) {
      privateCode = await _askPrivateCode();
      if (privateCode == null) return;
    }

    final id =
        widget.event['id']?.toString() ?? widget.event['_id']?.toString();
    if (id == null || id.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID evenement introuvable')),
      );
      return;
    }

    setState(() => joining = true);
    try {
      await api.joinEvent(
        id,
        isPrivate: isPrivate,
        privateCode: privateCode,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription confirmee'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('Code prive')
                ? 'Code prive invalide'
                : 'Erreur lors de l inscription',
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => joining = false);
    }
  }

  Future<String?> _askPrivateCode() async {
    final controller = TextEditingController();
    String? result;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Code d evenement prive'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            hintText: 'Entrez le code a 6 chiffres',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final code = controller.text.trim();
              if (!RegExp(r'^\d{6}$').hasMatch(code)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Le code doit contenir 6 chiffres'),
                  ),
                );
                return;
              }
              result = code;
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
            ),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
    return result;
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return 'Non definie';
    final date = DateTime.tryParse(value);
    if (date == null) return 'Non definie';
    return '${date.day}/${date.month} a ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }
}
