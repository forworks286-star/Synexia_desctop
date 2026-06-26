import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';
import 'admin_setup_screen.dart';

class ServerSetupScreen extends StatefulWidget {
  final bool allowBack;
  const ServerSetupScreen({super.key, this.allowBack = false});

  @override
  State<ServerSetupScreen> createState() => _ServerSetupScreenState();
}

class _ServerSetupScreenState extends State<ServerSetupScreen> {
  late final TextEditingController _ipCtrl;
  late final TextEditingController _portCtrl;
  bool _testing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final currentUrl = AppConfig.baseUrl;
    final uri = Uri.tryParse(currentUrl);
    _ipCtrl = TextEditingController(text: uri?.host != 'localhost' ? (uri?.host ?? '192.168.1.') : '192.168.1.');
    _portCtrl = TextEditingController(text: (uri?.port ?? 8000).toString());
  }

  Future<void> _connect() async {
    final ip = _ipCtrl.text.trim();
    final port = _portCtrl.text.trim();

    if (ip.isEmpty || port.isEmpty) {
      setState(() => _error = 'Veuillez remplir tous les champs');
      return;
    }

    setState(() { _testing = true; _error = null; });

    final url = 'http://$ip:$port';

    try {
      final testDio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 5), receiveTimeout: const Duration(seconds: 5)));
      await testDio.get(url);

      await AppConfig.setServerUrl(url);
      if (!mounted) return;
      try {
        final setupDio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 5)));
        final setupResp = await setupDio.get(AppConfig.usersSetupStatus);
        final setupDone = setupResp.data['setup_done'] as bool? ?? false;
        if (!mounted) return;
        if (setupDone) {
          Get.offAll(() => const LoginScreen());
        } else {
          Get.offAll(() => const AdminSetupScreen());
        }
      } catch (_) {
        Get.offAll(() => const LoginScreen());
      }
    } catch (_) {
      setState(() {
        _testing = false;
        _error = 'Impossible de joindre le serveur. Vérifiez l\'adresse et que le serveur est démarré.';
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
              if (widget.allowBack)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                    label: const Text('Retour'),
                  ),
                ),
              Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Text('S', style: TextStyle(color: Colors.white, fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 22))),
                ),
                const SizedBox(width: 14),
                Text('Synexia.Dz', style: Theme.of(context).textTheme.displayMedium),
              ]),
              const SizedBox(height: 32),
              Text('Configuration du serveur', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              const Text('Entrez l\'adresse du serveur local de votre entrepôt', style: TextStyle(fontSize: 13, color: AppColors.darkTextMuted)),
              const SizedBox(height: 28),
              Row(children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _ipCtrl,
                    decoration: const InputDecoration(labelText: 'Adresse IP', hintText: '192.168.1.50'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _portCtrl,
                    decoration: const InputDecoration(labelText: 'Port'),
                  ),
                ),
              ]),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.danger.withOpacity(0.2))),
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
                  onPressed: _testing ? null : _connect,
                  child: _testing
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Se connecter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
