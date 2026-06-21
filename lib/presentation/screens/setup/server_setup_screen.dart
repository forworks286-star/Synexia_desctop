import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';

class ServerSetupScreen extends StatefulWidget {
  const ServerSetupScreen({super.key});

  @override
  State<ServerSetupScreen> createState() => _ServerSetupScreenState();
}

class _ServerSetupScreenState extends State<ServerSetupScreen> {
  final _ipCtrl = TextEditingController(text: '192.168.1.');
  final _portCtrl = TextEditingController(text: '8000');
  bool _testing = false;
  String? _error;

  Future<void> _connect() async {
    setState(() { _testing = true; _error = null; });

    final url = 'http://${_ipCtrl.text.trim()}:${_portCtrl.text.trim()}';
    await AppConfig.setServerUrl(url);

    setState(() => _testing = false);
    Get.offAll(() => const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 420,
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
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
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