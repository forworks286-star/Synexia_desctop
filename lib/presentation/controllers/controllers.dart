import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../core/config/app_config.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/repositories.dart';

class AuthController extends GetxController {
  final AuthRepository _repo;
  AuthController(this._repo);

  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final u = await _repo.getCurrentUser();
    if (u != null) {
      user.value = u;
      Get.offAllNamed('/dashboard');
      await Future.delayed(const Duration(milliseconds: 800));
      try {
        if (Get.isRegistered<StockController>())   Get.find<StockController>().loadAll();
        if (Get.isRegistered<InvoiceController>()) Get.find<InvoiceController>().loadInvoices();
        if (Get.isRegistered<AlertController>())   Get.find<AlertController>().loadAlerts();
      } catch (_) {}
    }
  }
  Future<void> login(String username, String password) async {
    isLoading.value = true; error.value = '';
    final result = await _repo.login(username, password);
    result.fold((e) => error.value = e, (u) { user.value = u; Get.offAllNamed('/dashboard'); });
    isLoading.value = false;
  }

  Future<void> logout() async {
    await _repo.logout(); user.value = null; Get.offAllNamed('/login');
  }

  bool get isAdmin   => user.value?.role == UserRole.admin;
  bool get isManager => user.value?.role == UserRole.manager || isAdmin;
  bool get canEdit   => isAdmin;
  bool get isSuperAdmin => user.value?.role == UserRole.admin;
  bool get canManageUsers => isSuperAdmin;
}

class StockController extends GetxController {
  final StockRepository _repo;
  StockController(this._repo);

  final RxList<Product> products = <Product>[].obs;
  final RxList<Movement> movements = <Movement>[].obs;
  final RxList<ChartPoint> chartPoints = <ChartPoint>[].obs;
  final RxList<CommandeAuto> commandesAuto = <CommandeAuto>[].obs;
  final Rx<DashboardStats?> stats = Rx<DashboardStats?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;
  final Rx<StockStatus?> statusFilter = Rx<StockStatus?>(null);
  final RxString categorieFilter = ''.obs;

  @override
  void onInit() { super.onInit(); loadAll(); }

  Future<void> loadAll() async {
    isLoading.value = true;
    await Future.wait([loadProducts(), loadMovements(), loadStats(), loadChart(), loadCommandesAuto()]);
    isLoading.value = false;
  }

  Future<void> loadChart() async {
    final r = await _repo.getMovementsChart();
    r.fold((_) {}, (p) => chartPoints.assignAll(p));
  }

  Future<void> loadCommandesAuto() async {
    final r = await _repo.getCommandesAuto();
    r.fold((_) {}, (c) => commandesAuto.assignAll(c));
  }

  Future<bool> validerCommande(int id) async {
    final r = await _repo.validerCommande(id);
    return r.fold((_) => false, (_) { loadCommandesAuto(); return true; });
  }

  Future<bool> rejeterCommande(int id) async {
    final r = await _repo.rejeterCommande(id);
    return r.fold((_) => false, (_) { loadCommandesAuto(); return true; });
  }

  List<String> get categories {
    final cats = products.map((p) => p.categorie ?? '').where((c) => c.isNotEmpty).toSet().toList();
    cats.sort();
    return cats;
  }

  Future<void> loadProducts() async {
    final r = await _repo.getProducts();
    r.fold((e) => error.value = e, (p) => products.assignAll(p));
  }

  Future<void> loadMovements() async {
    final r = await _repo.getMovements(limit: 50);
    r.fold((e) => error.value = e, (m) => movements.assignAll(m));
  }

  Future<void> loadStats() async {
    final r = await _repo.getDashboardStats();
    r.fold((e) => error.value = e, (s) => stats.value = s);
  }

  List<Product> get filteredProducts {
    return products.where((p) {
      final q = searchQuery.value.toLowerCase();
      final matchSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.sku.toLowerCase().contains(q) ||
          p.qrReference.toLowerCase().contains(q);
      final matchStatus   = statusFilter.value == null || p.status == statusFilter.value;
      final matchCategorie = categorieFilter.value.isEmpty || p.categorie == categorieFilter.value;
      return matchSearch && matchStatus && matchCategorie;
    }).toList();
  }
}

class InvoiceController extends GetxController {
  final InvoiceRepository _repo;
  InvoiceController(this._repo);

  final RxList<Invoice> invoices = <Invoice>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final Rx<InvoiceStatus?> statusFilter = Rx<InvoiceStatus?>(null);

  @override
  void onInit() { super.onInit(); loadInvoices(); }

  Future<void> loadInvoices() async {
    isLoading.value = true;
    final r = await _repo.getInvoices();
    r.fold((e) => error.value = e, (i) => invoices.assignAll(i));
    isLoading.value = false;
  }

  Future<bool> validateInvoice(int id) async {
    final r = await _repo.validateInvoice(id);
    return r.fold((_) => false, (_) { loadInvoices(); return true; });
  }

  Future<bool> rejectInvoice(int id) async {
    final r = await _repo.rejectInvoice(id);
    return r.fold((_) => false, (_) { loadInvoices(); return true; });
  }

  List<Invoice> get filteredInvoices {
    return statusFilter.value == null
        ? invoices
        : invoices.where((i) => i.status == statusFilter.value).toList();
  }
}

class AlertController extends GetxController {
  final AlertRepository _repo;
  AlertController(this._repo);

  final RxList<Alert> alerts = <Alert>[].obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() { super.onInit(); loadAlerts(); _listenRealtime(); }

  Future<void> loadAlerts() async {
    final r = await _repo.getAlerts();
    r.fold((_) {}, (list) { alerts.assignAll(list); _updateUnread(); });
  }

  void _listenRealtime() {
    _repo.alertStream().listen((a) { alerts.insert(0, a); _updateUnread(); });
  }

  void _updateUnread() => unreadCount.value = alerts.where((a) => !a.isRead).length;

  Future<void> markRead(int id) async {
    await _repo.markAsRead(id);
    final i = alerts.indexWhere((a) => a.id == id);
    if (i != -1) {
      final a = alerts[i];
      alerts[i] = Alert(id: a.id, level: a.level, title: a.title, message: a.message,
                        createdAt: a.createdAt, isRead: true, sourceModule: a.sourceModule);
      _updateUnread();
    }
  }

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    alerts.assignAll(alerts.map((a) => Alert(
      id: a.id, level: a.level, title: a.title, message: a.message,
      createdAt: a.createdAt, isRead: true, sourceModule: a.sourceModule,
    )).toList());
    _updateUnread();
  }
}

class AppSettingsController extends GetxController {
  final RxBool isDark = true.obs;
  final RxString locale = 'fr'.obs;
  final RxInt selectedNavIndex = 0.obs;

  @override
  void onInit() { super.onInit(); _loadPrefs(); }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    isDark.value = p.getBool(AppConfig.themeKey) ?? true;
    locale.value = p.getString(AppConfig.localeKey) ?? 'fr';
    _applyTheme(); _applyLocale();
  }

  Future<void> toggleTheme() async {
    isDark.value = !isDark.value;
    final p = await SharedPreferences.getInstance();
    await p.setBool(AppConfig.themeKey, isDark.value);
    _applyTheme();
  }

  Future<void> changeLocale(String code) async {
    locale.value = code;
    final p = await SharedPreferences.getInstance();
    await p.setString(AppConfig.localeKey, code);
    _applyLocale();
  }

  void setNav(int i) => selectedNavIndex.value = i;

  void _applyTheme() => Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);

  void _applyLocale() {
    final map = {'fr': const Locale('fr'), 'ar': const Locale('ar'), 'en': const Locale('en')};
    Get.updateLocale(map[locale.value] ?? const Locale('fr'));
  }

  Locale get currentLocale {
    final map = {'fr': const Locale('fr'), 'ar': const Locale('ar'), 'en': const Locale('en')};
    return map[locale.value] ?? const Locale('fr');
  }
}
