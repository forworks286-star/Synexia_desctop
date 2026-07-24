import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dartz/dartz.dart';
import 'dart:convert';
import 'dart:async';
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
        if (Get.isRegistered<InvoiceController>()) {
          Get.find<InvoiceController>().loadInvoices();
          Get.find<InvoiceController>().loadDemandes();
          Get.find<InvoiceController>().loadFacturesACorriger();
          Get.find<InvoiceController>().loadFacturesEnAttenteModification();
          Get.find<InvoiceController>().loadFacturesOcrAVerifier();
        }
        if (Get.isRegistered<AlertController>())   Get.find<AlertController>().loadAlerts();
      } catch (_) {}
    }
  }
  Future<void> login(String username, String password) async {
    isLoading.value = true; error.value = '';
    final result = await _repo.login(username, password);
    result.fold((e) => error.value = e, (u) {
      user.value = u;
      Get.offAllNamed('/dashboard');
      if (Get.isRegistered<StockController>())   Get.find<StockController>().loadAll();
      if (Get.isRegistered<InvoiceController>()) {
        Get.find<InvoiceController>().loadInvoices();
        Get.find<InvoiceController>().loadDemandes();
        Get.find<InvoiceController>().loadFacturesACorriger();
        Get.find<InvoiceController>().loadFacturesEnAttenteModification();
        Get.find<InvoiceController>().loadFacturesOcrAVerifier();
      }
      if (Get.isRegistered<AlertController>())   Get.find<AlertController>().loadAlerts();
    });
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
  final RxList<IoTZone> iotZones = <IoTZone>[].obs;
  final RxList<FaceEvent> faceEvents = <FaceEvent>[].obs;
  final RxList<Invoice> factures = <Invoice>[].obs;
  final RxInt iotActiveAlarms = 0.obs;
  final Rx<DashboardStats?> stats = Rx<DashboardStats?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;
  final Rx<StockStatus?> statusFilter = Rx<StockStatus?>(null);
  final RxString categorieFilter = ''.obs;
  Future<Either<String, void>> ajoutManuelComplet(Map<String, dynamic> data) => _repo.ajoutManuelComplet(data);

  @override
  void onInit() { super.onInit(); loadAll(); }

  Future<void> loadAll() async {
    isLoading.value = true;
    await Future.wait([loadProducts(), loadMovements(), loadStats(), loadChart(), loadCommandesAuto(), loadIoT()]);
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

  Future<void> loadIoT() async {
    final r = await _repo.getIoTDashboard();
    r.fold((_) {}, (zones) {
      iotZones.assignAll(zones);
      iotActiveAlarms.value = zones.where((z) => z.hasAlarm).length;
    });
    final r2 = await _repo.getFaceEvents();
    r2.fold((_) {}, (events) => faceEvents.assignAll(events));
  }

  void handleWsAutomation(Map<String, dynamic> data) {
    final zoneId = data['zone_id'] as String? ?? '';
    final module = data['module'] as String? ?? '';
    final payload = data['payload'] as Map<String, dynamic>? ?? {};
    final idx = iotZones.indexWhere(
        (z) => z.zoneId == zoneId && z.module == module);
    final newZone = IoTZone(
      deviceId:    data['device_id'] ?? '',
      module:      module,
      zoneId:      zoneId,
      hasAlarm:    data['has_alarm'] ?? false,
      timestamp:   DateTime.now(),
      inputs:      Map<String, dynamic>.from(payload['inputs'] ?? {}),
      outputs:     Map<String, dynamic>.from(payload['outputs'] ?? {}),
      states:      Map<String, dynamic>.from(payload['states'] ?? {}),
      lighting:    Map<String, dynamic>.from(payload['lighting'] ?? {}),
      hvac:        Map<String, dynamic>.from(payload['hvac'] ?? {}),
      energy:      Map<String, dynamic>.from(payload['energy'] ?? {}),
      alarms:      Map<String, dynamic>.from(payload['alarms'] ?? {}),
      diagnostic:  Map<String, dynamic>.from(payload['diagnostic'] ?? {}),
      maintenance: Map<String, dynamic>.from(payload['maintenance'] ?? {}),
    );
    if (idx >= 0) { iotZones[idx] = newZone; }
    else          { iotZones.add(newZone); }
    iotActiveAlarms.value = iotZones.where((z) => z.hasAlarm).length;
  }

  Future<void> loadFactures() async {
    if (Get.isRegistered<InvoiceController>()) {
      Get.find<InvoiceController>().loadInvoices();
    }
  }


  List<String> get categories {
    final cats = products.map((p) => p.categorie ?? '').where((c) => c.isNotEmpty).toSet().toList();
    cats.sort();
    return cats;
  }

  Future<void> loadProducts() async {
    final r = await _repo.getProducts();
    r.fold((e) => error.value = e, (p) {
      products.assignAll(p);
      products.refresh();
    });
  }

  Future<void> loadMovements() async {
    final r = await _repo.getMovements(limit: 50);
    r.fold((e) => error.value = e, (m) => movements.assignAll(m));
  }

  Future<void> loadStats() async {
    final r = await _repo.getDashboardStats();
    r.fold((e) => error.value = e, (s) => stats.value = s);
  }

  final Rx<String?> typeStockFilter = Rx<String?>(null);

  List<Product> get filteredProducts {
    return products.toList().where((p) {
      final q = searchQuery.value.toLowerCase();
      final matchSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.sku.toLowerCase().contains(q) ||
          p.qrReference.toLowerCase().contains(q);
      final matchStatus   = statusFilter.value == null || p.status == statusFilter.value;
      final matchCategorie = categorieFilter.value.isEmpty || p.categorie == categorieFilter.value;
      final matchType = typeStockFilter.value == null || p.typeStock == typeStockFilter.value;
      return matchSearch && matchStatus && matchCategorie && matchType;
    }).toList();
  }
}

class InvoiceController extends GetxController {
  final InvoiceRepository _repo;
  InvoiceController(this._repo);

  final RxList<Invoice> invoices = <Invoice>[].obs;
  final RxList<DemandeModification> demandes = <DemandeModification>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final Rx<InvoiceStatus?> statusFilter = Rx<InvoiceStatus?>(null);
  final Rx<String?> typeFilter = Rx<String?>(null);


  @override
  void onInit() { super.onInit(); loadInvoices(); loadDemandes(); loadFacturesACorriger(); loadFacturesEnAttenteModification(); loadFacturesOcrAVerifier(); }

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

  Future<bool> rejectInvoice(int id, String motif) async {
    final r = await _repo.rejectInvoice(id, motif);
    return r.fold((_) => false, (_) { loadInvoices(); return true; });
  }

  Future<bool> creerFactureManuelle({required String fournisseurNom, required String date,
      required String typeFacture, required String typeStock, required double montantHt,
      required double montantTva, required double montantTtc,
      String? fournisseurNif, String? fournisseurNis, String? fournisseurRc,
      required String motifCreationManuelle,
      required List<Map<String, dynamic>> lignes, String? compteRenduDemande}) async {
    final r = await _repo.creerFactureManuelle(
      fournisseurNom: fournisseurNom, date: date, typeFacture: typeFacture, typeStock: typeStock,
      montantHt: montantHt, montantTva: montantTva, montantTtc: montantTtc,
      fournisseurNif: fournisseurNif, fournisseurNis: fournisseurNis, fournisseurRc: fournisseurRc,
      motifCreationManuelle: motifCreationManuelle, lignes: lignes,
      compteRenduDemande: compteRenduDemande,
    );
    return r.fold((_) => false, (_) { loadInvoices(); loadDemandes(); loadFacturesEnAttenteModification(); return true; });
  }

  Future<void> loadDemandes() async {
    final r = await _repo.getDemandes(statut: 'pending');
    r.fold((_) {}, (d) => demandes.assignAll(d));
  }


  Future<bool> approuverDemande(int id) async {
    final r = await _repo.approuverDemande(id);
    return r.fold((_) => false, (_) { loadDemandes(); loadInvoices(); return true; });
  }

  Future<bool> refuserDemande(int id, String? motif) async {
    final r = await _repo.refuserDemande(id, motif);
    return r.fold((_) => false, (_) { loadDemandes(); return true; });
  }
  
  final RxList<Invoice> facturesACorriger = <Invoice>[].obs;
  final RxList<Invoice> facturesEnAttenteModification = <Invoice>[].obs;
  final RxList<Invoice> facturesOcrAVerifier = <Invoice>[].obs;

  Future<void> loadFacturesOcrAVerifier() async {
    final r = await _repo.getFacturesParStatut('ocr_a_verifier');
    r.fold((_) {}, (l) => facturesOcrAVerifier.assignAll(l));
  }

  Future<bool> confirmerOcr(int factureId, List<Map<String, dynamic>> lignes) async {
    final r = await _repo.confirmerOcr(factureId, lignes);
    return r.fold((_) => false, (_) { loadInvoices(); loadFacturesOcrAVerifier(); return true; });
  }

  Future<bool> enregistrerEmplacementsOcr(int factureId, List<Map<String, dynamic>> lignes) async {
    final r = await _repo.enregistrerEmplacementsOcr(factureId, lignes);
    return r.fold((_) => false, (_) => true);
  }

  Future<bool> signalerErreurOcr(int factureId, String compteRendu) async {
    final r = await _repo.creerDemandeModification(factureId, compteRendu);
    return r.fold((_) => false, (_) { loadFacturesOcrAVerifier(); loadFacturesEnAttenteModification(); return true; });
  }

  Future<void> loadFacturesACorriger() async {
    final r = await _repo.getFacturesParStatut('modification_autorisee');
    r.fold((_) {}, (l) => facturesACorriger.assignAll(l));
  }

  Future<void> loadFacturesEnAttenteModification() async {
    final r = await _repo.getFacturesParStatut('en_attente_modification');
    r.fold((_) {}, (l) => facturesEnAttenteModification.assignAll(l));
  }

  Future<bool> completerModification({required int factureId, required String fournisseurNom,
      required String date, required double montantHt, required double montantTva,
      required double montantTtc, required List<Map<String, dynamic>> lignes}) async {
    final r = await _repo.completerModification(
      factureId: factureId, fournisseurNom: fournisseurNom, date: date,
      montantHt: montantHt, montantTva: montantTva, montantTtc: montantTtc, lignes: lignes,
    );
    return r.fold((_) => false, (_) { loadInvoices(); loadFacturesACorriger(); return true; });
  }

    List<Invoice> get filteredInvoices {
    return invoices.where((i) {
      final matchStatus = statusFilter.value == null || i.status == statusFilter.value;
      final matchType   = typeFilter.value == null   || i.typeFacture == typeFilter.value;
      return matchStatus && matchType;
    }).toList();
  }

}

class ManufacturingController extends GetxController {
  final ManufacturingRepository _repo;
  ManufacturingController(this._repo);

  final RxList<BomModel> boms = <BomModel>[].obs;
  final RxList<OrdreFabrication> ordres = <OrdreFabrication>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() { super.onInit(); loadAll(); }

  Future<void> loadAll() async {
    isLoading.value = true;
    await Future.wait([loadBoms(), loadOrdres()]);
    isLoading.value = false;
  }

  Future<void> loadBoms() async {
    final r = await _repo.getBoms();
    r.fold((e) => error.value = e, (b) => boms.assignAll(b));
  }

  Future<void> loadOrdres() async {
    final r = await _repo.getOrdresFabrication();
    r.fold((e) => error.value = e, (o) => ordres.assignAll(o));
  }

  Future<bool> creerBom({required int produitFiniId, String? nom, required List<Map<String, dynamic>> lignes}) async {
    final r = await _repo.creerBom(produitFiniId: produitFiniId, nom: nom, lignes: lignes);
    return r.fold((_) => false, (_) { loadBoms(); return true; });
  }

  Future<Either<String, Map<String, dynamic>>> creerOrdreFabrication({
      required int bomId, required double quantiteProduite, String? emplacement,
      String? dateFabrication, String? dateExpiration, String? numeroLot}) async {
    final r = await _repo.creerOrdreFabrication(
      bomId: bomId, quantiteProduite: quantiteProduite, emplacement: emplacement,
      dateFabrication: dateFabrication, dateExpiration: dateExpiration, numeroLot: numeroLot,
    );
    if (r.isRight()) { loadOrdres(); }
    return r;
  }

  Future<Either<String, Map<String, dynamic>>> getMaxRealisable(int bomId) => _repo.getMaxRealisable(bomId);
}


class AlertController extends GetxController {
  final AlertRepository _repo;
  AlertController(this._repo);

  final RxList<Alert> alerts = <Alert>[].obs;
  final RxInt unreadCount = 0.obs;
  final _appairageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get appairageStream => _appairageController.stream;
  void pushAppairage(Map<String, dynamic> data) => _appairageController.add(data);

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
                        createdAt: a.createdAt, isRead: true, sourceModule: a.sourceModule, type: a.type);
      _updateUnread();
    }
  }

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    alerts.assignAll(alerts.map((a) => Alert(
      id: a.id, level: a.level, title: a.title, message: a.message,
      createdAt: a.createdAt, isRead: true, sourceModule: a.sourceModule, type: a.type,
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
