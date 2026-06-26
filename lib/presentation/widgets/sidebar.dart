import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../controllers/controllers.dart';
import '../../domain/models/models.dart';

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<AppSettingsController>();
    final auth     = Get.find<AuthController>();
    final alerts   = Get.find<AlertController>();

    final auth = Get.find<AuthController>();
    final role = auth.user.value?.role;

    final items = [
      _NavItem(icon: Icons.grid_view_rounded,       label: 'Dashboard',   index: 0),
      _NavItem(icon: Icons.inventory_2_outlined,    label: 'Produits',    index: 1),
      if (role == UserRole.admin || role == UserRole.manager)
        _NavItem(icon: Icons.receipt_long_outlined, label: 'Factures',    index: 2),
      _NavItem(icon: Icons.notifications_outlined,  label: 'Alertes',     index: 3),
      if (role == UserRole.admin || role == UserRole.manager)
        _NavItem(icon: Icons.bar_chart_rounded,     label: 'Rapports',    index: 4),
      _NavItem(icon: Icons.settings_outlined,       label: 'Paramètres',  index: 5),
      if (role == UserRole.admin)
        _NavItem(icon: Icons.admin_panel_settings_outlined, label: 'Admin', index: 6),
    ];

    return Container(
      width: 200,
      color: AppColors.darkSidebar,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Center(child: Text('S',
                  style: TextStyle(color: Colors.white, fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 13))),
              ),
              const SizedBox(width: 9),
              RichText(text: const TextSpan(
                style: TextStyle(fontFamily: 'Syne', fontSize: 14, fontWeight: FontWeight.w800),
                children: [
                  TextSpan(text: 'Synexia', style: TextStyle(color: Colors.white)),
                  TextSpan(text: '.Dz',     style: TextStyle(color: AppColors.primary)),
                ],
              )),
            ]),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: Obx(() => Column(
              children: items.map((item) {
                final badge = item.index == 3 ? alerts.unreadCount.value : 0;
                return _SidebarItem(
                  item:     item,
                  selected: settings.selectedNavIndex.value == item.index,
                  badge:    badge,
                  onTap:    () => settings.setNav(item.index),
                );
              }).toList(),
            )),
          ),
          const Divider(color: AppColors.darkBorder, height: 1),
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text(
                  auth.user.value?.fullName.isNotEmpty == true
                      ? auth.user.value!.fullName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12),
                )),
              ),
              const SizedBox(width: 9),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auth.user.value?.fullName ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                  Text(_roleLabel(auth.user.value?.role),
                    style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 9, letterSpacing: 0.1)),
                ],
              )),
              IconButton(
                icon: const Icon(Icons.logout_rounded, size: 14, color: AppColors.darkTextMuted),
                onPressed: auth.logout,
                tooltip: 'Déconnexion',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ]),
          )),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  String _roleLabel(UserRole? role) {
    switch (role) {
      case UserRole.admin:      return 'Administrateur';
      case UserRole.manager:    return 'Manager';
      case UserRole.stockiste:  return 'Stockiste';
      case UserRole.agentKiosk: return 'Agent Kiosk';
      default:                  return '';
    }
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int index;
  _NavItem({required this.icon, required this.label, required this.index});
}

class _SidebarItem extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  const _SidebarItem({required this.item, required this.selected, required this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: selected ? AppColors.primary.withOpacity(0.35) : Colors.transparent),
        ),
        child: Row(children: [
          Icon(item.icon, size: 16,
            color: selected ? AppColors.primary : AppColors.darkTextMuted),
          const SizedBox(width: 9),
          Expanded(child: Text(item.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color:      selected ? Colors.white : AppColors.darkTextMuted,
            ),
          )),
          if (badge > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$badge',
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
        ]),
      ),
    );
  }
}