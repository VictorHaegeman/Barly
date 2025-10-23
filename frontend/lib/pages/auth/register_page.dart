import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/barly_button.dart';
import '../../theme/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final firstCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final Map<String, List<String>> prefs = {
    'ambiance': [],
    'music': [],
    'drinks': [],
  };
  bool loading = false;
  bool obscurePassword = true;
  final api = ApiService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Créer mon compte',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Rejoins la communauté Barly',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // Formulaire
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: firstCtrl,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person_outline,
                            color: AppTheme.lavender.withOpacity(0.7)),
                        labelText: 'Prénom',
                        labelStyle:
                            const TextStyle(color: AppTheme.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppTheme.lavender.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppTheme.lavender.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppTheme.lavender, width: 2),
                        ),
                        filled: true,
                        fillColor: AppTheme.bg,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.mail_outline,
                            color: AppTheme.lavender.withOpacity(0.7)),
                        labelText: 'Email',
                        labelStyle:
                            const TextStyle(color: AppTheme.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppTheme.lavender.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppTheme.lavender.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppTheme.lavender, width: 2),
                        ),
                        filled: true,
                        fillColor: AppTheme.bg,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passCtrl,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline,
                            color: AppTheme.lavender.withOpacity(0.7)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppTheme.lavender.withOpacity(0.7),
                          ),
                          onPressed: () => setState(
                              () => obscurePassword = !obscurePassword),
                        ),
                        labelText: 'Mot de passe',
                        labelStyle:
                            const TextStyle(color: AppTheme.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppTheme.lavender.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppTheme.lavender.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppTheme.lavender, width: 2),
                        ),
                        filled: true,
                        fillColor: AppTheme.bg,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Préférences
                    _MultiChips(
                      title: 'Ambiance',
                      options: const ['Cosy', 'Dance', 'Chill', 'Lounge'],
                      onChanged: (v) => prefs['ambiance'] = v,
                    ),
                    const SizedBox(height: 16),
                    _MultiChips(
                      title: 'Musique',
                      options: const ['House', 'Pop', 'Jazz', 'RnB', 'Rock'],
                      onChanged: (v) => prefs['music'] = v,
                    ),
                    const SizedBox(height: 16),
                    _MultiChips(
                      title: 'Boissons',
                      options: const ['Cocktails', 'Bières', 'Vins', 'Soft'],
                      onChanged: (v) => prefs['drinks'] = v,
                    ),
                    const SizedBox(height: 32),

                    if (loading)
                      const CircularProgressIndicator(color: AppTheme.lavender)
                    else
                      BarlyButton(
                        label: 'Créer mon compte',
                        onPressed: _register,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (firstCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      await api.register(firstCtrl.text, emailCtrl.text, passCtrl.text, prefs);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppTheme.warning,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}

class _MultiChips extends StatefulWidget {
  final String title;
  final List<String> options;
  final ValueChanged<List<String>> onChanged;

  const _MultiChips({
    required this.title,
    required this.options,
    required this.onChanged,
  });

  @override
  State<_MultiChips> createState() => _MultiChipsState();
}

class _MultiChipsState extends State<_MultiChips> {
  final List<String> current = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppTheme.text,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in widget.options)
              FilterChip(
                label: Text(
                  option,
                  style: TextStyle(
                    color: current.contains(option)
                        ? Colors.white
                        : AppTheme.lavender,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                selected: current.contains(option),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      current.add(option);
                    } else {
                      current.remove(option);
                    }
                  });
                  widget.onChanged(List.of(current));
                },
                selectedColor: AppTheme.lavender,
                checkmarkColor: Colors.white,
                backgroundColor: AppTheme.lavender.withOpacity(0.1),
                side: BorderSide(
                  color: AppTheme.lavender.withOpacity(0.3),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
