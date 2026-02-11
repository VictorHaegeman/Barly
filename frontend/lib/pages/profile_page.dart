import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final api = ApiService();
  final _picker = ImagePicker();

  Map<String, dynamic> userInfo = {
    'firstName': 'Invite',
    'email': '',
    'phone': '',
    'avatarUrl': '',
    'pushNotifications': true,
    'emailNotifications': false,
    'ambiancePrefs': <String>[],
    'musicPrefs': <String>[],
    'drinkPrefs': <String>[],
    'priceLevel': '10 EUR',
  };

  bool loading = true;
  bool avatarUploading = false;
  static const _ambianceOptions = ['Cosy', 'Dance', 'Chill', 'Lounge'];
  static const _musicOptions = ['House', 'Pop', 'Jazz', 'RnB', 'Rock'];
  static const _drinkOptions = ['Cocktails', 'Bieres', 'Vins', 'Soft'];
  static const _presetBudgets = ['5 EUR', '10 EUR', '15 EUR'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final me = await api.getMe();
      if (me != null) {
        final prefs = Map<String, dynamic>.from(me['prefs'] ?? {});
        userInfo = {
          ...userInfo,
          'firstName': me['firstName'] ?? userInfo['firstName'],
          'email': me['email'] ?? userInfo['email'],
          'avatarUrl': me['avatarUrl'] ?? '',
          'phone': me['phone'] ?? '',
          'pushNotifications': me['notif_push'] ?? true,
          'emailNotifications': me['notif_email'] ?? false,
          'ambiancePrefs': List<String>.from(prefs['ambiance'] ?? []),
          'musicPrefs': List<String>.from(prefs['music'] ?? []),
          'drinkPrefs': List<String>.from(prefs['drinks'] ?? []),
          'priceLevel': me['price_level']?.toString() ?? userInfo['priceLevel'],
        };
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connecte-toi pour voir ton profil')),
        );
      }
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: Colors.black,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Profil',
                        style: TextStyle(
                          fontSize: 34 / 2,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildAvatar(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Informations'),
                  const Divider(height: 20),
                  _buildEditableRow(
                    label: 'Prenom',
                    value: _displayValue(userInfo['firstName']),
                    field: 'firstName',
                  ),
                  _buildEditableRow(
                    label: 'Numero de telephone',
                    value: _displayValue(userInfo['phone']),
                    field: 'phone',
                  ),
                  _buildEditableRow(
                    label: 'Adresse e-mail',
                    value: _displayValue(userInfo['email']),
                    field: 'email',
                  ),
                  const SizedBox(height: 10),
                  _buildSectionTitle('Notifications'),
                  const Divider(height: 20),
                  _buildActionRow(
                    label: 'Notifications push',
                    value: userInfo['pushNotifications'] == true
                        ? 'Activees'
                        : 'Desactivees',
                    onTap: () => _showNotificationSheet(
                      field: 'pushNotifications',
                      title: 'Notifications push',
                    ),
                  ),
                  _buildActionRow(
                    label: 'E-mail',
                    value: userInfo['emailNotifications'] == true
                        ? 'Actif'
                        : 'Desactive',
                    onTap: () => _showNotificationSheet(
                      field: 'emailNotifications',
                      title: 'Notifications e-mail',
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSectionTitle('Preferences bars'),
                  const Divider(height: 20),
                  _buildActionRow(
                    label: 'Ambiance preferee',
                    value: _displayList(userInfo['ambiancePrefs']),
                    onTap: () => _showMultiChoiceSheet(
                      title: 'Ambiance preferee',
                      keyName: 'ambiance',
                      field: 'ambiancePrefs',
                      options: _ambianceOptions,
                    ),
                  ),
                  _buildActionRow(
                    label: 'Musique preferee',
                    value: _displayList(userInfo['musicPrefs']),
                    onTap: () => _showMultiChoiceSheet(
                      title: 'Musique preferee',
                      keyName: 'music',
                      field: 'musicPrefs',
                      options: _musicOptions,
                    ),
                  ),
                  _buildActionRow(
                    label: 'Boissons preferees',
                    value: _displayList(userInfo['drinkPrefs']),
                    onTap: () => _showMultiChoiceSheet(
                      title: 'Boissons preferees',
                      keyName: 'drinks',
                      field: 'drinkPrefs',
                      options: _drinkOptions,
                    ),
                  ),
                  _buildActionRow(
                    label: 'Budget moyen (boisson)',
                    value: _budgetLabelForDisplay(userInfo['priceLevel']),
                    onTap: () => _showBudgetSheet(),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _showLogoutDialog,
                    icon: const Icon(Icons.logout),
                    label: const Text('Se deconnecter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade200),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = (userInfo['avatarUrl'] ?? '').toString();

    return GestureDetector(
      onTap: _showPhotoOptions,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFFE5E7EB),
            backgroundImage:
                avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            child: avatarUrl.isNotEmpty
                ? null
                : const Icon(
                    Icons.person,
                    color: Color(0xFF9CA3AF),
                    size: 34,
                  ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: avatarUploading
                  ? const Padding(
                      padding: EdgeInsets.all(5),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 36 / 2,
        fontWeight: FontWeight.w700,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _buildEditableRow({
    required String label,
    required String value,
    required String field,
  }) {
    return _buildActionRow(
      label: label,
      value: value,
      onTap: () =>
          _showEditDialog(label: label, field: field, currentValue: value),
    );
  }

  Widget _buildActionRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 34 / 2,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 33 / 2,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  String _displayValue(dynamic value) {
    final text = (value ?? '').toString().trim();
    return text.isEmpty ? 'Non renseigne' : text;
  }

  String _displayList(dynamic value) {
    final items = List<String>.from(value ?? const []);
    if (items.isEmpty) return 'Aucune selection';
    return items.join(', ');
  }

  String _budgetLabelForDisplay(dynamic value) {
    final raw = (value ?? '').toString().trim();
    if (raw.isEmpty) return 'Non renseigne';
    return raw;
  }

  Map<String, dynamic> _buildPrefsPayload({
    String? keyName,
    List<String>? values,
  }) {
    final prefs = <String, dynamic>{
      'ambiance': List<String>.from(userInfo['ambiancePrefs'] ?? const []),
      'music': List<String>.from(userInfo['musicPrefs'] ?? const []),
      'drinks': List<String>.from(userInfo['drinkPrefs'] ?? const []),
    };
    if (keyName != null && values != null) {
      prefs[keyName] = values;
    }
    return prefs;
  }

  Future<void> _dismissPopup(BuildContext popupContext) async {
    final localNavigator = Navigator.of(popupContext);
    final didPopLocal = await localNavigator.maybePop();
    if (didPopLocal || !mounted) return;
    await Navigator.of(context, rootNavigator: true).maybePop();
  }

  void _showEditDialog({
    required String label,
    required String field,
    required String currentValue,
  }) {
    final controller = TextEditingController(
      text: currentValue == 'Non renseigne' ? '' : currentValue,
    );

    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Modifier'),
        content: TextField(
          controller: controller,
          keyboardType:
              field == 'phone' ? TextInputType.phone : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              final value = controller.text.trim();
              try {
                await api.updateProfile(
                  firstName: field == 'firstName' ? value : null,
                  email: field == 'email' ? value : null,
                  phone: field == 'phone' ? value : null,
                );
                if (!mounted) return;
                setState(() => userInfo[field] = value);
                await _dismissPopup(dialogContext);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      field == 'email'
                          ? 'Email mise a jour. Verification possible selon la config auth.'
                          : 'Information mise a jour',
                    ),
                  ),
                );
              } catch (_) {
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('Erreur de sauvegarde')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
            ),
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSheet({
    required String field,
    required String title,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final current = userInfo[field] == true;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (sheetContext) {
        bool nextValue = current;
        bool saving = false;
        return StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  value: nextValue,
                  activeThumbColor: const Color(0xFF7C3AED),
                  title: const Text('Activer'),
                  onChanged: (v) => setSheetState(() => nextValue = v),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: saving
                        ? null
                        : () async {
                            setSheetState(() => saving = true);
                            try {
                              await api
                                  .updateProfile(
                                    notifPush: field == 'pushNotifications'
                                        ? nextValue
                                        : null,
                                    notifEmail: field == 'emailNotifications'
                                        ? nextValue
                                        : null,
                                  )
                                  .timeout(const Duration(seconds: 12));
                              if (!mounted) return;
                              setState(() => userInfo[field] = nextValue);
                              if (sheetContext.mounted) {
                                await _dismissPopup(sheetContext);
                              }
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Preference enregistree'),
                                ),
                              );
                            } catch (e) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Impossible de sauvegarder la preference: $e',
                                  ),
                                ),
                              );
                            } finally {
                              if (sheetContext.mounted) {
                                setSheetState(() => saving = false);
                              }
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                    ),
                    child: Text(saving ? 'Enregistrement...' : 'Enregistrer'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBudgetSheet() {
    final messenger = ScaffoldMessenger.of(context);
    final initial = _budgetLabelForDisplay(userInfo['priceLevel']);
    final presets = List<String>.from(_presetBudgets);
    if (!presets.contains(initial) && initial != 'Non renseigne') {
      presets.add(initial);
    }
    String selected = presets.contains(initial) ? initial : '10 EUR';
    bool saving = false;
    final customCtrl = TextEditingController();
    final customFocus = FocusNode();

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setStateSheet) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Budget moyen (boisson)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...presets.map(
                  (item) => ListTile(
                    dense: true,
                    title: Text(item),
                    trailing: selected == item
                        ? const Icon(Icons.check, color: Color(0xFF7C3AED))
                        : null,
                    onTap: () {
                      setStateSheet(() => selected = item);
                      customFocus.unfocus();
                    },
                  ),
                ),
                ListTile(
                  dense: true,
                  title: const Text('Montant personnalise'),
                  trailing: selected == 'custom'
                      ? const Icon(Icons.check, color: Color(0xFF7C3AED))
                      : null,
                  onTap: () {
                    setStateSheet(() => selected = 'custom');
                    customFocus.requestFocus();
                  },
                ),
                if (selected == 'custom') ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: customCtrl,
                    focusNode: customFocus,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      prefixText: 'EUR ',
                      labelText: 'Montant',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: saving
                        ? null
                        : () async {
                            String valueToSave = selected;
                            if (selected == 'custom') {
                              final parsed =
                                  double.tryParse(customCtrl.text.trim());
                              if (parsed == null || parsed <= 0) {
                                messenger.showSnackBar(const SnackBar(
                                    content: Text('Montant invalide')));
                                return;
                              }
                              valueToSave =
                                  '${parsed.toStringAsFixed(parsed % 1 == 0 ? 0 : 2)} EUR';
                            }
                            setStateSheet(() => saving = true);
                            try {
                              await api.updateProfile(priceLevel: valueToSave);
                              if (!mounted) return;
                              setState(
                                  () => userInfo['priceLevel'] = valueToSave);
                              if (sheetContext.mounted) {
                                await _dismissPopup(sheetContext);
                              }
                              messenger.showSnackBar(const SnackBar(
                                  content: Text('Budget mis a jour')));
                            } catch (e) {
                              messenger.showSnackBar(SnackBar(
                                  content:
                                      Text('Impossible de sauvegarder: $e')));
                            } finally {
                              if (sheetContext.mounted) {
                                setStateSheet(() => saving = false);
                              }
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                    ),
                    child: Text(saving ? 'Enregistrement...' : 'Enregistrer'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMultiChoiceSheet({
    required String title,
    required String keyName,
    required String field,
    required List<String> options,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final selected = Set<String>.from(userInfo[field] ?? const []);
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        bool saving = false;
        return StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: options.map((item) {
                    final active = selected.contains(item);
                    return FilterChip(
                      label: Text(item),
                      selected: active,
                      selectedColor:
                          const Color(0xFF7C3AED).withValues(alpha: 0.2),
                      checkmarkColor: const Color(0xFF7C3AED),
                      onSelected: (v) => setSheetState(() {
                        if (v) {
                          selected.add(item);
                        } else {
                          selected.remove(item);
                        }
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: saving
                        ? null
                        : () async {
                            setSheetState(() => saving = true);
                            try {
                              final updated = selected.toList()..sort();
                              await api
                                  .updateProfile(
                                    prefs: _buildPrefsPayload(
                                      keyName: keyName,
                                      values: updated,
                                    ),
                                  )
                                  .timeout(const Duration(seconds: 12));
                              if (!mounted) return;
                              setState(() => userInfo[field] = updated);
                              if (sheetContext.mounted) {
                                await _dismissPopup(sheetContext);
                              }
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Preferences enregistrees'),
                                ),
                              );
                            } catch (e) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Impossible de sauvegarder ces preferences: $e',
                                  ),
                                ),
                              );
                            } finally {
                              if (sheetContext.mounted) {
                                setSheetState(() => saving = false);
                              }
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                    ),
                    child: Text(saving ? 'Enregistrement...' : 'Enregistrer'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChoiceDialog({
    required String title,
    required List<String> options,
    required String selectedValue,
    required Future<void> Function(String value) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...options.map((item) {
              final selected = selectedValue == item;
              return ListTile(
                dense: true,
                title: Text(item),
                trailing: selected
                    ? const Icon(Icons.check, color: Color(0xFF7C3AED))
                    : null,
                onTap: () async {
                  try {
                    await onSelected(item);
                  } catch (_) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Erreur de sauvegarde')),
                    );
                  }
                  if (!mounted) return;
                  await _dismissPopup(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Changer la photo de profil',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _handleAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choisir dans la galerie'),
              onTap: () {
                Navigator.pop(context);
                _handleAvatar(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAvatar(ImageSource source) async {
    if (avatarUploading) return;
    setState(() => avatarUploading = true);
    try {
      final file = await _picker.pickImage(source: source, maxWidth: 900);
      if (file == null) {
        if (mounted) setState(() => avatarUploading = false);
        return;
      }
      final bytes = await file.readAsBytes();
      final url = await api.uploadAvatar(bytes: bytes, fileName: file.name);
      if (!mounted) return;
      setState(() => userInfo['avatarUrl'] = url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo mise a jour')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload impossible. Verifie le bucket avatars.'),
        ),
      );
    } finally {
      if (mounted) setState(() => avatarUploading = false);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se deconnecter'),
        content: const Text('Tu veux vraiment te deconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              await api.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Se deconnecter'),
          ),
        ],
      ),
    );
  }
}
