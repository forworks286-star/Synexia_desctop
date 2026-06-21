import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';
import '../../../domain/models/models.dart';
import '../setup/server_setup_screen.dart';
import '../../../core/config/app_config.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<AppSettingsController>();
    final auth = Get.find<AuthController>();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Paramètres'),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _AppearanceCard(settings: settings)),
              const SizedBox(width: 20),
              Expanded(child: _AccountCard(auth: auth)),
              const SizedBox(width: 20),
              Expanded(child: _ConnectionCard()),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppearanceCard extends StatelessWidget {
  final AppSettingsController settings;
  const _AppearanceCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    return SynCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'APPARENCE'),
          const SizedBox(height: 20),
          const Text('Thème', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Obx(() => Row(children: [
            _ThemeOption(label: 'Sombre', icon: Icons.dark_mode_outlined, selected: settings.isDark.value, onTap: () { if (!settings.isDark.value) settings.toggleTheme(); }),
            const SizedBox(width: 10),
            _ThemeOption(label: 'Clair', icon: Icons.light_mode_outlined, selected: !settings.isDark.value, onTap: () { if (settings.isDark.value) settings.toggleTheme(); }),
          ])),
          const SizedBox(height: 24),
          const Text('Langue', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Obx(() => Row(children: [
            for (final l in [('fr', 'Français'), ('ar', 'العربية'), ('en', 'English')])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _LangOption(code: l.$1, label: l.$2, selected: settings.locale.value == l.$1, onTap: () => settings.changeLocale(l.$1)),
              ),
          ])),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final AuthController auth;
  const _AccountCard({required this.auth});

  @override
  Widget build(BuildContext context) {
    return SynCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'COMPTE'),
          const SizedBox(height: 20),
          Obx(() {
            final user = auth.user.value;
            if (user == null) return const SizedBox.shrink();
            return Column(
              children: [
                Row(children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 18))),
                  ),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user.fullName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    Text('@${user.username}', style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                      child: Text(user.role == UserRole.manager ? 'Manager' : 'Stockiste', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                  ]),
                ]),
                const SizedBox(height: 20),
                const Divider(color: AppColors.darkBorder),
                const SizedBox(height: 16),
                SynButton(label: 'Déconnexion', outline: true, color: AppColors.danger, icon: Icons.logout_rounded, onTap: auth.logout),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SynCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'CONNEXION SERVEUR'),
          const SizedBox(height: 20),
          _InfoRow(
              label: 'Adresse API',
              value: AppConfig.baseUrl,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: 'WebSocket',
              value: AppConfig.wsUrl,
            ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Base de données', value: 'PostgreSQL — On-premise'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.success.withOpacity(0.2))),
            child: Row(children: const [
              Icon(Icons.circle, size: 8, color: AppColors.success),
              SizedBox(width: 8),
              Text('Connecté au serveur local', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () =>
                  Get.to(() => const ServerSetupScreen(allowBack: true)),
              child: const Text('Modifier l\'adresse'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted, letterSpacing: 0.08, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
    ]);
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ThemeOption({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.primary : AppColors.darkBorder),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: selected ? AppColors.primary : AppColors.darkTextMuted),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? AppColors.primary : AppColors.darkTextMuted)),
        ]),
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String code;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangOption({required this.code, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.primary : AppColors.darkBorder),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.darkTextMuted)),
      ),
    );
  }
}
