import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'core/theme/app_theme.dart';
import 'core/l10n/app_localizations.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/stock_repository_impl.dart';
import 'data/repositories/invoice_repository_impl.dart';
import 'data/repositories/alert_repository_impl.dart';
import 'presentation/controllers/controllers.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(AppSettingsController());
  Get.put(AuthController(AuthRepositoryImpl()));
  Get.put(StockController(StockRepositoryImpl()));
  Get.put(InvoiceController(InvoiceRepositoryImpl()));
  Get.put(AlertController(AlertRepositoryImpl()));

  runApp(const SynexiaDesktopApp());
}

class SynexiaDesktopApp extends StatelessWidget {
  const SynexiaDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<AppSettingsController>();

    return Obx(() => GetMaterialApp(
      title: 'Synexia.Dz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.isDark.value ? ThemeMode.dark : ThemeMode.light,
      locale: settings.currentLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/dashboard', page: () => const MainShell()),
      ],
    ));
  }
}
