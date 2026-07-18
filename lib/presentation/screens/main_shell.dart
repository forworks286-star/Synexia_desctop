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
import '../screens/iot/iot_screen.dart';
import '../screens/securite/securite_screen.dart';
import '../screens/fabrication/fabrication_screen.dart';
import '../screens/approbations/approbations_screen.dart';
import '../../domain/models/models.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<AppSettingsController>();
    final auth     = Get.find<AuthController>();

    return Scaffold(
      body: Row(
        children: [
          const DesktopSidebar(),
          const VerticalDivider(width: 1),
          Expanded(
            child: Obx(() {
              final role  = auth.user.value?.role;
              final index = settings.selectedNavIndex.value;

              final screens = <int, Widget>{
                0: const DashboardScreen(),
                1: const ProduitsScreen(),
                2: const FacturesScreen(),
                3: const AlertesScreen(),
                5: const SettingsScreen(),
                7: const IoTScreen(),
                8: const SecuriteScreen(),
              };

              if (role == UserRole.admin || role == UserRole.manager) {
                screens[4] = const RapportsScreen();
                screens[9] = const FabricationScreen();
                screens[10] = const ApprobationsScreen();
              }
              if (role == UserRole.admin) {
                screens[6] = const SuperAdminScreen();
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: screens[index] ?? const DashboardScreen(),
              );
            }),
          ),
        ],
      ),
    );
  }
}