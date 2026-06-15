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
    final auth = Get.find<AuthController>();

    final items = [
      _NavItem(icon: Icons.grid_view_rounded, label: 'Dashboard', index: 0),
      _NavItem(icon: Icons.inventory_2_outlined, label: 'Produits', index: 1),
      _NavItem(icon: Icons.receipt_long_outlined, label: 'Factures', index: 2),
      _NavItem(icon: Icons.notifications_outlined, label: 'Alertes', index: 3),
      _NavItem(icon: Icons.bar_chart_rounded, label: 'Rapports', index: 4),
      _NavItem(icon: Icons.settings_outlined, label: 'Paramètres', index: 5),
    ];

    return Container(
      width: 220,
      color: AppColors.darkSidebar,
      child: Column(
        children: [
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Text('S', style: TextStyle(color: Colors.white, fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 14))),
                ),
                const SizedBox(width: 10),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontFamily: 'Syne', fontSize: 16, fontWeight: FontWeight.w800),
                    children: [
                      TextSpan(text: 'Synexia', style: TextStyle(color: Colors.white)),
                      TextSpan(text: '.Dz', style: TextStyle(color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Obx(() => Column(
              children: items.map((item) => _SidebarItem(
                item: item,
                selected: settings.selectedNavIndex.value == item.index,
                onTap: () => settings.setNav(item.index),
              )).toList(),
            )),
          ),
          const Divider(color: AppColors.darkBorder, height: 1),
          Obx(() => Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      auth.user.value?.fullName.isNotEmpty == true ? auth.user.value!.fullName[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(auth.user.value?.fullName ?? '', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                      Text(auth.user.value?.role == UserRole.manager ? 'Manager' : 'Stockiste', style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 10)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.darkTextMuted),
                  onPressed: auth.logout,
                  tooltip: 'Déconnexion',
                ),
              ],
            ),
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
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
  final VoidCallback onTap;

  const _SidebarItem({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.primary.withOpacity(0.3) : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(item.icon, size: 17, color: selected ? AppColors.primary : AppColors.darkTextMuted),
            const SizedBox(width: 10),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? Colors.white : AppColors.darkTextMuted,
                fontFamily: selected ? 'Syne' : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
