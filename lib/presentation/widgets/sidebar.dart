import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_localizations.dart';
import '../controllers/controllers.dart';
import '../../domain/models/models.dart';

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<AppSettingsController>();
    final auth     = Get.find<AuthController>();
    final alerts   = Get.find<AlertController>();
    final role = auth.user.value?.role;
    final t = AppLocalizations.of(context);

    final items = [
      _NavItem(icon: Icons.grid_view_rounded,       label: t.navDashboard,   index: 0),
      _NavItem(icon: Icons.inventory_2_outlined,    label: t.homeProducts,    index: 1),
      if (role == UserRole.admin || role == UserRole.manager)
        _NavItem(icon: Icons.precision_manufacturing_outlined, label: t.navManufacturing, index: 9),
      _NavItem(icon: Icons.description_outlined,    label: t.navPurchaseOrders, index: 11),
      _NavItem(icon: Icons.qr_code_2_rounded,        label: t.navQrCodes,     index: 12),
      // Factures : visible pour tous — chacun ne voit que ses propres factures
      // cote serveur (sauf admin/manager qui voient tout). Voir GET /factures.
      _NavItem(icon: Icons.receipt_long_outlined,   label: t.navInvoices,    index: 2),
      if (role == UserRole.admin || role == UserRole.manager)
        _NavItem(icon: Icons.fact_check_outlined,   label: t.navApprovals, index: 10),
      if (role == UserRole.admin || role == UserRole.manager)
        _NavItem(icon: Icons.sensors_rounded,       label: t.navIot,         index: 7),
      _NavItem(icon: Icons.notifications_outlined,  label: t.homeAlerts,     index: 3),
      if (role == UserRole.admin || role == UserRole.manager)
        _NavItem(icon: Icons.security_rounded,      label: t.navSecurity,    index: 8),
      if (role == UserRole.admin || role == UserRole.manager)
        _NavItem(icon: Icons.bar_chart_rounded,     label: t.navReports,    index: 4),
      if (role == UserRole.admin)
        _NavItem(icon: Icons.admin_panel_settings_outlined, label: t.navAdmin, index: 6),
      _NavItem(icon: Icons.settings_outlined,       label: t.navSettings,  index: 5),
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
                int badge = 0;
                if (item.index == 3) badge = alerts.unreadCount.value;
                if (item.index == 2) badge = alerts.unreadCountByType('facture');
                if (item.index == 1) badge = alerts.unreadCountByType('stock');
                if (item.index == 10 && Get.isRegistered<InvoiceController>()) {
                  final ic = Get.find<InvoiceController>();
                  badge = ic.demandes.length + ic.facturesEcartAValider.length;
                }
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
                  Text(_roleLabel(t, auth.user.value?.role),
                    style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 9, letterSpacing: 0.1)),
                ],
              )),
              IconButton(
                icon: const Icon(Icons.logout_rounded, size: 14, color: AppColors.darkTextMuted),
                onPressed: auth.logout,
                tooltip: t.logout,
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

  String _roleLabel(AppLocalizations t, UserRole? role) {
    switch (role) {
      case UserRole.admin:      return t.roleAdmin;
      case UserRole.manager:    return t.roleManager;
      case UserRole.stockiste:  return t.roleStockiste;
      case UserRole.agentKiosk: return t.roleAgentKiosk;
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