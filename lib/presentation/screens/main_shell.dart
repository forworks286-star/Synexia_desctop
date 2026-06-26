import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/controllers.dart';
import '../widgets/sidebar.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/produits/produits_screen.dart';
import '../screens/factures/factures_screen.dart';
import '../screens/alertes/alertes_screen.dart';
import '../screens/rapports/rapports_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/super_admin/super_admin_screen.dart';
import '../../domain/models/models.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<AppSettingsController>();

    final auth = Get.find<AuthController>();
    final role = auth.user.value?.role;

    final screens = [
      const DashboardScreen(),
      const ProduitsScreen(),
      if (role == UserRole.admin || role == UserRole.manager)
        const FacturesScreen()
      else
        const ProduitsScreen(),
      const AlertesScreen(),
      if (role == UserRole.admin || role == UserRole.manager)
        const RapportsScreen()
      else
        const AlertesScreen(),
      const SettingsScreen(),
      if (role == UserRole.admin)
        const SuperAdminScreen(),
    ];

    return Scaffold(
      body: Row(
        children: [
          const DesktopSidebar(),
          const VerticalDivider(width: 1),
          Expanded(
            child: Obx(() => AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: screens[settings.selectedNavIndex.value],
            )),
          ),
        ],
      ),
    );
  }
}
