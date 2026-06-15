
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: AppColors.darkSidebar,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: Text('S', style: TextStyle(color: Colors.white, fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 28))),
                  ),
                  const SizedBox(height: 20),
                  RichText(text: const TextSpan(
                    style: TextStyle(fontFamily: 'Syne', fontSize: 32, fontWeight: FontWeight.w800),
                    children: [
                      TextSpan(text: 'Synexia', style: TextStyle(color: Colors.white)),
                      TextSpan(text: '.Dz', style: TextStyle(color: AppColors.primary)),
                    ],
                  )),
                  const SizedBox(height: 12),
                  const Text('Warehouse Management System', style: TextStyle(fontSize: 13, color: AppColors.darkTextMuted)),
                  const SizedBox(height: 60),
                  _FeatureItem(icon: Icons.inventory_2_outlined, label: 'Gestion de stock en temps réel'),
                  _FeatureItem(icon: Icons.receipt_long_outlined, label: 'Validation intelligente des factures'),
                  _FeatureItem(icon: Icons.notifications_outlined, label: 'Alertes instantanées'),
                  _FeatureItem(icon: Icons.bar_chart_rounded, label: 'Rapports et analyses'),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Connexion', style: Theme.of(context).textTheme.displayMedium),
                    const SizedBox(height: 6),
                    const Text('Accès réservé aux utilisateurs autorisés', style: TextStyle(fontSize: 13, color: AppColors.darkTextMuted)),
                    const SizedBox(height: 40),
                    const Text('Nom d\'utilisateur', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _usernameCtrl,
                      decoration: const InputDecoration(hintText: 'Entrez votre identifiant'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    const Text('Mot de passe', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: 'Entrez votre mot de passe',
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 16),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(auth),
                    ),
                    const SizedBox(height: 28),
                    Obx(() {
                      if (auth.error.value.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.danger.withOpacity(0.2))),
                            child: Row(children: [
                              const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.danger),
                              const SizedBox(width: 8),
                              Text(auth.error.value, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                            ]),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() => SynButton(label: 'Se connecter', isLoading: auth.isLoading.value, onTap: () => _submit(auth))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit(AuthController auth) {
    if (_usernameCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) return;
    auth.login(_usernameCtrl.text.trim(), _passwordCtrl.text);
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 40),
      child: Row(children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.darkTextMuted)),
      ]),
    );
  }
}
