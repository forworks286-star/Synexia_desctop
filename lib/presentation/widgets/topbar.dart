import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/design/theme_extension.dart';
import '../../core/design/radii.dart';
import '../../core/l10n/app_localizations.dart';
import '../controllers/controllers.dart';
import 'sidebar.dart' show roleLabel;

class DesktopTopbar extends StatelessWidget {
  const DesktopTopbar({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<AppSettingsController>();
    final auth     = Get.find<AuthController>();
    final alerts   = Get.find<AlertController>();
    final colors   = context.colors;
    final t = AppLocalizations.of(context);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Expanded(child: _TopbarSearch(hint: t.topbarSearchHint)),
          const SizedBox(width: 16),
          Obx(() => _IconButtonBadge(
                icon: settings.isDark.value ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                tooltip: settings.isDark.value ? t.settingsLight : t.settingsDark,
                onTap: settings.toggleTheme,
              )),
          const SizedBox(width: 10),
          Obx(() => _IconButtonBadge(
                icon: Icons.notifications_outlined,
                tooltip: t.homeAlerts,
                badge: alerts.unreadCount.value,
                onTap: () => settings.setNav(3),
              )),
          const SizedBox(width: 16),
          Container(width: 1, height: 28, color: colors.border),
          const SizedBox(width: 16),
          Obx(() => _ProfileMenu(
                name: auth.user.value?.fullName ?? '',
                role: roleLabel(t, auth.user.value?.role),
                onLogout: auth.logout,
                logoutLabel: t.logout,
              )),
        ],
      ),
    );
  }
}

class _TopbarSearch extends StatelessWidget {
  final String hint;
  const _TopbarSearch({required this.hint});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: AppRadii.rMd,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 18, color: colors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: TextStyle(fontSize: 13, color: colors.text),
              decoration: InputDecoration.collapsed(
                hintText: hint,
                hintStyle: TextStyle(fontSize: 13, color: colors.textMuted),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: colors.hover, borderRadius: AppRadii.rXs),
            child: Text('Ctrl+K', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colors.textMuted)),
          ),
        ],
      ),
    );
  }
}

class _IconButtonBadge extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final int badge;

  const _IconButtonBadge({required this.icon, required this.tooltip, required this.onTap, this.badge = 0});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.rMd,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colors.bg,
            borderRadius: AppRadii.rMd,
            border: Border.all(color: colors.border),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(child: Icon(icon, size: 18, color: colors.textMuted)),
              if (badge > 0)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(color: colors.danger, borderRadius: AppRadii.rPill),
                    child: Text('$badge', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  final String name;
  final String role;
  final VoidCallback onLogout;
  final String logoutLabel;

  const _ProfileMenu({required this.name, required this.role, required this.onLogout, required this.logoutLabel});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(borderRadius: AppRadii.rMd, side: BorderSide(color: colors.border)),
      color: colors.card,
      onSelected: (v) {
        if (v == 'logout') onLogout();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'logout',
          child: Row(children: [
            Icon(Icons.logout_rounded, size: 16, color: colors.danger),
            const SizedBox(width: 10),
            Text(logoutLabel, style: TextStyle(fontSize: 13, color: colors.text)),
          ]),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: colors.primary.withOpacity(0.14), borderRadius: AppRadii.rMd),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: TextStyle(color: colors.primary, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: colors.text)),
              Text(role, style: TextStyle(fontSize: 10, color: colors.textMuted)),
            ],
          ),
          const SizedBox(width: 4),
          Icon(Icons.expand_more_rounded, size: 16, color: colors.textMuted),
        ],
      ),
    );
  }
}