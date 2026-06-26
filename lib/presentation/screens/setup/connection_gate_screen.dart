import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import 'server_setup_screen.dart';
import 'admin_setup_screen.dart';
import '../auth/login_screen.dart';

/// Point d'entrée unique de l'application.
/// Vérifie à CHAQUE démarrage si le serveur configuré répond réellement,
/// indépendamment du fait qu'une adresse soit déjà enregistrée localement.
class ConnectionGateScreen extends StatefulWidget {
  const ConnectionGateScreen({super.key});

  @override
  State<ConnectionGateScreen> createState() => _ConnectionGateScreenState();
}

class _ConnectionGateScreenState extends State<ConnectionGateScreen> {
  @override
  void initState() {
    super.initState();
    _checkServerHealth();
  }

  Future<void> _checkServerHealth() async {
    if (!AppConfig.isConfigured) {
      _goToSetup();
      return;
    }
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
      ));
      final response = await dio.get(AppConfig.baseUrl);
      if (response.statusCode == 200) {
        final setupResp = await dio.get(AppConfig.usersSetupStatus);
        final setupDone = setupResp.data['setup_done'] as bool? ?? false;
        if (!mounted) return;
        if (setupDone) {
          _goToLogin();
        } else {
          Get.offAll(() => const AdminSetupScreen());
        }
      } else {
        _goToSetup();
      }
    } catch (_) {
      _goToSetup();
    }
  }

  void _goToSetup() {
    if (!mounted) return;
    Get.offAll(() => const ServerSetupScreen());
  }

  void _goToLogin() {
    if (!mounted) return;
    Get.offAll(() => const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(child: Text('S', style: TextStyle(color: Colors.white, fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 26))),
            ),
            const SizedBox(height: 24),
            const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary)),
            const SizedBox(height: 16),
            const Text('Connexion au serveur...', style: TextStyle(fontSize: 13, color: AppColors.darkTextMuted)),
          ],
        ),
      ),
    );
  }
}
