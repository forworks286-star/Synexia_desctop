import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/design/theme_extension.dart';
import '../../core/design/radii.dart';
import 'decor/corner_lines.dart';
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
    final colors   = context.colors;
    final role = auth.user.value?.role;
    final t = AppLocalizations.of(context);

    final items = [
      _NavItem(icon: Icons.grid_view_rounded,       label: t.navDashboard,   index: 0),
      _NavItem(icon: Icons.inventory_2_outlined,    label: t.homeProducts,    index: 1),
      if (role == UserRole.admin || role == UserRole.manager)
        _NavItem(icon: Icons.precision_manufacturing_outlined, label: t.navManufacturing, index: 9),
      _NavItem(icon: Icons.description_outlined,    label: t.navPurchaseOrders, index: 11),
      _NavItem(icon: Icons.qr_code_2_rounded,        label: t.navQrCodes,     index: 12),
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
      width: 216,
      color: colors.sidebar,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: CornerFlowLines(color: colors.primary, width: 216, height: 140),
            ),
          ),
          Column(
        children: [
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [colors.primary, colors.secondary],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: AppRadii.rSm,
                ),
                child: const Center(
                  child: Text('S',
                      style: TextStyle(color: Colors.white, fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 10),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontFamily: 'Syne', fontSize: 15, fontWeight: FontWeight.w800, color: colors.text),
                  children: [
                    TextSpan(text: 'Synexia', style: TextStyle(color: colors.text)),
                    TextSpan(text: '.Dz', style: TextStyle(color: colors.primary)),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 26),
          Expanded(
            child: Obx(() => ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
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
                      item: item,
                      selected: settings.selectedNavIndex.value == item.index,
                      badge: badge,
                      onTap: () => settings.setNav(item.index),
                    );
                  }).toList(),
                )),
          ),
          Divider(color: colors.border, height: 1),
          Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                child: Row(children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.18),
                      borderRadius: AppRadii.rMd,
                    ),
                    child: Center(
                      child: Text(
                        auth.user.value?.fullName.isNotEmpty == true ? auth.user.value!.fullName[0].toUpperCase() : 'U',
                        style: TextStyle(color: colors.primary, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(auth.user.value?.fullName ?? '',
                            style: TextStyle(color: colors.text, fontSize: 12, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis),
                        Text(roleLabel(t, auth.user.value?.role),
                            style: TextStyle(color: colors.textMuted, fontSize: 10, letterSpacing: 0.1)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.logout_rounded, size: 15, color: colors.textMuted),
                    onPressed: auth.logout,
                    tooltip: t.logout,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  ),
                ]),
              )),
          const SizedBox(height: 6),
        ],
          ),
        ],
      ),
    );
  }
}

String roleLabel(AppLocalizations t, UserRole? role) {
  switch (role) {
    case UserRole.admin:      return t.roleAdmin;
    case UserRole.manager:    return t.roleManager;
    case UserRole.stockiste:  return t.roleStockiste;
    case UserRole.agentKiosk: return t.roleAgentKiosk;
    default:                  return '';
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
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? colors.primary.withOpacity(0.14) : Colors.transparent,
            borderRadius: AppRadii.rMd,
            border: Border.all(color: selected ? colors.primary.withOpacity(0.4) : Colors.transparent),
          ),
          child: Row(children: [
            Icon(item.icon, size: 17, color: selected ? colors.primary : colors.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? colors.text : colors.textMuted,
                ),
              ),
            ),
            if (badge > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: colors.danger, borderRadius: AppRadii.rPill),
                child: Text('$badge', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
          ]),
        ),
      ),
    );
  }
}