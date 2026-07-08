import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/api_client.dart';



class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});
  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _verified = false;
  String? _error;
  String? _adminToken;

  Future<void> _verify() async {
    setState(() { _loading = true; _error = null; });
    try {
      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 5)));
      final response = await dio.post(AppConfig.superAdminLogin, data: {
        'username': AppConfig.superAdminUser,
        'password': _passCtrl.text,
      });
      final token = response.data['access'] as String;
      setState(() { _verified = true; _loading = false; _adminToken = token; });
    } on DioException catch (_) {
      setState(() { _loading = false; _error = 'Mot de passe incorrect'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_verified) return _buildLoginView();
    return SuperAdminPanelScreen(adminToken: _adminToken!);
  }

  Widget _buildLoginView() {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppColors.warning, size: 22),
                ),
                const SizedBox(width: 14),
                Text('Super Admin', style: Theme.of(context).textTheme.displayMedium),
              ]),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.2)),
                ),
                child: const Text(
                  'Zone réservée à l\'administrateur système.\nCette zone permet de gérer les utilisateurs et les droits d\'accès.',
                  style: TextStyle(fontSize: 12, color: AppColors.warning, height: 1.5),
                ),
              ),
              const SizedBox(height: 28),
              const Text('Mot de passe système', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'Entrez le mot de passe Super Admin',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 16),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                onSubmitted: (_) => _verify(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.danger.withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.danger),
                    const SizedBox(width: 8),
                    Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                  ]),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
                  onPressed: _loading ? null : _verify,
                  child: _loading
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Accéder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SuperAdminPanelScreen extends StatefulWidget {
  final String adminToken;
  const SuperAdminPanelScreen({super.key, required this.adminToken});
  @override
  State<SuperAdminPanelScreen> createState() => _SuperAdminPanelScreenState();
}

class _SuperAdminPanelScreenState extends State<SuperAdminPanelScreen> {
  late final Dio _dio;
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.adminToken}',
      },
    ));
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await _dio.get(AppConfig.usersAll);
      setState(() {
        _users = List<Map<String, dynamic>>.from(r.data['results'] as List);
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _addUser() async {
    final fullName = TextEditingController();
    final username = TextEditingController();
    final password = TextEditingController();
    String role = 'stockiste';

    await showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Ajouter un utilisateur'),
      content: StatefulBuilder(builder: (ctx, ss) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: fullName,
            decoration: const InputDecoration(labelText: 'Nom complet')),
          const SizedBox(height: 10),
          TextField(controller: username,
            decoration: const InputDecoration(labelText: 'Nom d\'utilisateur')),
          const SizedBox(height: 10),
          TextField(controller: password, obscureText: true,
            decoration: const InputDecoration(labelText: 'Mot de passe')),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: role,
            decoration: const InputDecoration(labelText: 'Rôle'),
            items: const [
                DropdownMenuItem(value: 'admin',       child: Text('Admin')),
                DropdownMenuItem(value: 'manager',     child: Text('Manager')),
                DropdownMenuItem(value: 'stockiste',   child: Text('Stockiste')),
                DropdownMenuItem(value: 'agent_kiosk', child: Text('Agent Kiosk')),
              ],
            onChanged: (v) => ss(() => role = v!),
          ),
        ],
      )),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () async {
            try {
              await _dio.post(AppConfig.usersAll, data: {
                'full_name': fullName.text.trim(),
                'username':  username.text.trim(),
                'password':  password.text,
                'role':      role,
                'permissions': _defaultPermissions(role),
              });
              if (ctx.mounted) Navigator.pop(ctx);
              _load();
            } on DioException catch (e) {
              final detail = e.response?.data?['detail'];
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(detail == 'error_username_exists'
                      ? 'Nom d\'utilisateur déjà utilisé'
                      : 'Erreur — vérifiez les champs'),
                  backgroundColor: AppColors.danger,
                ));
              }
            }
          },
          child: const Text('Ajouter'),
        ),
      ],
    ));
  }

  List<String> _defaultPermissions(String role) {
    switch (role) {
      case 'admin':     return ['valider_facture', 'modifier_stock', 'voir_camera', 'gerer_utilisateurs'];
      case 'manager':   return ['valider_facture', 'modifier_stock', 'voir_camera'];
      case 'stockiste': return ['modifier_stock'];
      default:          return [];
    }
  }

  Future<void> _toggleActive(Map<String, dynamic> user) async {
    try {
      await _dio.put('${AppConfig.usersAll}/${user['id']}',
        data: {'is_active': !(user['is_active'] as bool)});
      _load();
    } catch (_) {}
  }

  Future<void> _resetPassword(Map<String, dynamic> user) async {
    final ctrl = TextEditingController();
    await showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('Réinitialiser mot de passe — ${user['full_name']}'),
      content: TextField(controller: ctrl, obscureText: true,
        decoration: const InputDecoration(labelText: 'Nouveau mot de passe')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () async {
            try {
              await _dio.put('${AppConfig.usersAll}/${user['id']}/reset-password',
                data: {'new_password': ctrl.text});
              if (ctx.mounted) Navigator.pop(ctx);
            } catch (_) {}
          },
          child: const Text('Confirmer'),
        ),
      ],
    ));
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':      return AppColors.danger;
      case 'manager':    return AppColors.primary;
      case 'stockiste':  return AppColors.success;
      default:           return AppColors.darkTextMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.shield_outlined, color: AppColors.warning, size: 20),
              const SizedBox(width: 10),
              Text('Gestion des utilisateurs',
                style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addUser,
                icon: const Icon(Icons.person_add_outlined, size: 16),
                label: const Text('Ajouter'),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Actualiser'),
              ),
            ]),
            const SizedBox(height: 24),
            if (_loading)
              const Center(child: CircularProgressIndicator(color: AppColors.primary))
            else
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(children: const [
                        Expanded(flex: 3, child: Text('NOM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.darkTextMuted, letterSpacing: 0.1))),
                        Expanded(flex: 2, child: Text('USERNAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.darkTextMuted, letterSpacing: 0.1))),
                        Expanded(flex: 2, child: Text('RÔLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.darkTextMuted, letterSpacing: 0.1))),
                        Expanded(flex: 1, child: Text('STATUT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.darkTextMuted, letterSpacing: 0.1))),
                        SizedBox(width: 120),
                      ]),
                    ),
                    const Divider(height: 1, color: AppColors.darkBorder),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _users.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.darkBorder),
                        itemBuilder: (_, i) {
                          final u = _users[i];
                          final isActive = u['is_active'] as bool? ?? true;
                          final role = u['role'] as String? ?? '';
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Row(children: [
                              Expanded(flex: 3, child: Text(u['full_name'] as String? ?? '',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                              Expanded(flex: 2, child: Text('@${u['username']}',
                                style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.darkTextMuted))),
                              Expanded(flex: 2, child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _roleColor(role).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(role, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _roleColor(role))),
                              )),
                              Expanded(flex: 1, child: Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.success : AppColors.darkTextMuted,
                                  shape: BoxShape.circle,
                                ),
                              )),
                              SizedBox(
                                width: 120,
                                child: Row(children: [
                                  if (role != 'admin') ...[
                                    IconButton(
                                      icon: Icon(
                                        isActive ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                                        size: 16,
                                        color: isActive ? AppColors.danger : AppColors.success,
                                      ),
                                      onPressed: () => _toggleActive(u),
                                      tooltip: isActive ? 'Désactiver' : 'Activer',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.key_outlined, size: 16, color: AppColors.warning),
                                      onPressed: () => _resetPassword(u),
                                      tooltip: 'Réinitialiser mot de passe',
                                    ),
                                  ],
                                ]),
                              ),
                            ]),
                          );
                        },
                      ),
                    ),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}