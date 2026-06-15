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

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<AppSettingsController>();

    final screens = [
      const DashboardScreen(),
      const ProduitsScreen(),
      const FacturesScreen(),
      const AlertesScreen(),
      const RapportsScreen(),
      const SettingsScreen(),
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
