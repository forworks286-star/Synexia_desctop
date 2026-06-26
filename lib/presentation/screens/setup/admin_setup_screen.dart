import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';

class AdminSetupScreen extends StatefulWidget {
  const AdminSetupScreen({super.key});
  @override
  State<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends State<AdminSetupScreen> {
  final _fullNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _submit() async {
    final fullName = _fullNameCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm  = _confirmCtrl.text;

    if (fullName.isEmpty || username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Veuillez remplir tous les champs');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Les mots de passe ne correspondent pas');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Mot de passe trop court (minimum 6 caractères)');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
      ));
      await dio.post(AppConfig.usersSetup, data: {
        'full_name': fullName,
        'username':  username,
        'password':  password,
      });
      if (!mounted) return;
      Get.offAll(() => const LoginScreen());
    } on DioException catch (e) {
      final detail = e.response?.data?['detail'];
      setState(() {
        _loading = false;
        _error = detail == 'setup_already_done'
            ? 'Configuration déjà effectuée'
            : detail == 'error_password_too_short'
                ? 'Mot de passe trop court'
                : 'Erreur serveur';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Text('S', style: TextStyle(
                    color: Colors.white, fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 22))),
                ),
                const SizedBox(width: 14),
                Text('Synexia.Dz', style: Theme.of(context).textTheme.displayMedium),
              ]),
              const SizedBox(height: 32),
              Text('Configuration initiale', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              const Text(
                'Créez le compte administrateur de votre entrepôt.\nCette étape n\'apparaîtra qu\'une seule fois.',
                style: TextStyle(fontSize: 13, color: AppColors.darkTextMuted, height: 1.5),
              ),
              const SizedBox(height: 28),
              TextField(controller: _fullNameCtrl,
                decoration: const InputDecoration(labelText: 'Nom complet'),
                textInputAction: TextInputAction.next),
              const SizedBox(height: 14),
              TextField(controller: _usernameCtrl,
                decoration: const InputDecoration(labelText: 'Nom d\'utilisateur'),
                textInputAction: TextInputAction.next),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordCtrl, obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 16),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _confirmCtrl, obscureText: _obscure,
                decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
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
                    Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12))),
                  ]),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Créer le compte administrateur'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}