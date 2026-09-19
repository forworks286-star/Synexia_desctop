import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/theme_extension.dart';
import '../../../core/l10n/app_localizations.dart';
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
      final t = AppLocalizations.of(context);
      setState(() { _loading = false; _error = t.saWrongPassword; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_verified) return _buildLoginView();
    return SuperAdminPanelScreen(adminToken: _adminToken!);
  }

  Widget _buildLoginView() {
    final t = AppLocalizations.of(context);
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
                    color: AppPalette.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppPalette.warning.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppPalette.warning, size: 22),
                ),
                const SizedBox(width: 14),
                Text(t.saTitle, style: Theme.of(context).textTheme.displayMedium),
              ]),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppPalette.warning.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppPalette.warning.withOpacity(0.2)),
                ),
                child: Text(
                  t.saZoneNotice,
                  style: TextStyle(fontSize: 12, color: AppPalette.warning, height: 1.5),
                ),
              ),
              const SizedBox(height: 28),
              Text(t.saSystemPasswordLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: t.saPasswordHint,
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
                    color: AppPalette.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppPalette.danger.withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline_rounded, size: 14, color: AppPalette.danger),
                    const SizedBox(width: 8),
                    Text(_error!, style: const TextStyle(color: AppPalette.danger, fontSize: 12)),
                  ]),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppPalette.warning),
                  onPressed: _loading ? null : _verify,
                  child: _loading
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(t.saAccessButton),
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

    final t = AppLocalizations.of(context);
    await showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(t.saAddUserTitle),
      content: StatefulBuilder(builder: (ctx, ss) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: fullName,
            decoration: InputDecoration(labelText: t.setupFullNameLabel)),
          const SizedBox(height: 10),
          TextField(controller: username,
            decoration: InputDecoration(labelText: t.loginUsername)),
          const SizedBox(height: 10),
          TextField(controller: password, obscureText: true,
            decoration: InputDecoration(labelText: t.loginPassword)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: role,
            decoration: InputDecoration(labelText: t.saRoleLabel),
            items: [
                DropdownMenuItem(value: 'admin',       child: Text(t.saRoleAdminShort)),
                DropdownMenuItem(value: 'manager',     child: Text(t.roleManager)),
                DropdownMenuItem(value: 'stockiste',   child: Text(t.roleStockiste)),
                DropdownMenuItem(value: 'agent_kiosk', child: Text(t.roleAgentKiosk)),
              ],
            onChanged: (v) => ss(() => role = v!),
          ),
        ],
      )),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
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
                      ? t.saUsernameExists
                      : t.saCheckFieldsError),
                  backgroundColor: AppPalette.danger,
                ));
              }
            }
          },
          child: Text(t.addButton),
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
    final t = AppLocalizations.of(context);
    final ctrl = TextEditingController();
    await showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('${t.saResetPasswordTitlePrefix} ${user['full_name']}'),
      content: TextField(controller: ctrl, obscureText: true,
        decoration: InputDecoration(labelText: t.saNewPasswordLabel)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
        ElevatedButton(
          onPressed: () async {
            try {
              await _dio.put('${AppConfig.usersAll}/${user['id']}/reset-password',
                data: {'new_password': ctrl.text});
              if (ctx.mounted) Navigator.pop(ctx);
            } catch (_) {}
          },
          child: Text(t.confirm),
        ),
      ],
    ));
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':      return AppPalette.danger;
      case 'manager':    return AppPalette.primary;
      case 'stockiste':  return AppPalette.success;
      default:           return context.colors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.shield_outlined, color: AppPalette.warning, size: 20),
              const SizedBox(width: 10),
              Text(t.saUsersManagementTitle,
                style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addUser,
                icon: const Icon(Icons.person_add_outlined, size: 16),
                label: Text(t.addButton),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(t.dashboardRefresh),
              ),
            ]),
            const SizedBox(height: 24),
            if (_loading)
              const Center(child: CircularProgressIndicator(color: AppPalette.primary))
            else
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(children: [
                        Expanded(flex: 3, child: Text(t.saThName, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: context.colors.textMuted, letterSpacing: 0.1))),
                        Expanded(flex: 2, child: Text(t.saThUsername, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: context.colors.textMuted, letterSpacing: 0.1))),
                        Expanded(flex: 2, child: Text(t.saThRole, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: context.colors.textMuted, letterSpacing: 0.1))),
                        Expanded(flex: 1, child: Text(t.thStatus, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: context.colors.textMuted, letterSpacing: 0.1))),
                        const SizedBox(width: 120),
                      ]),
                    ),
                    Divider(height: 1, color: context.colors.border),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _users.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: context.colors.border),
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
                                style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: context.colors.textMuted))),
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
                                  color: isActive ? AppPalette.success : context.colors.textMuted,
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
                                        color: isActive ? AppPalette.danger : AppPalette.success,
                                      ),
                                      onPressed: () => _toggleActive(u),
                                      tooltip: isActive ? t.saDeactivateTooltip : t.saActivateTooltip,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.key_outlined, size: 16, color: AppPalette.warning),
                                      onPressed: () => _resetPassword(u),
                                      tooltip: t.saResetPasswordTooltip,
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