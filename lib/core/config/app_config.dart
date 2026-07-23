import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  AppConfig._();

  static String _baseUrl = 'http://localhost:8000';
  static const int connectTimeout = 8000;
  static const int receiveTimeout = 8000;

  static Future<void> loadSavedServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('server_url') ?? _baseUrl;
  }

  static Future<void> setServerUrl(String url) async {
    _baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', url);
  }

  static String get baseUrl => _baseUrl;
 
  static bool get isConfigured {
    return _baseUrl != 'http://localhost:8000';
  }

  static String get apiBase => '$_baseUrl/api/v1';
  static String get wsUrl => _baseUrl.replaceFirst('http', 'ws');

  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'current_user';
  static const String themeKey = 'app_theme';
  static const String localeKey = 'app_locale';

  static String get authLogin => '$apiBase/auth/login';
  static String get authRefresh => '$apiBase/auth/refresh';
  static String get authLogout => '$apiBase/auth/logout';

  static String get stockProducts => '$apiBase/stock/produits';
  static String get stockScanQr => '$apiBase/stock/scan';
  static String get stockMovements => '$apiBase/stock/mouvements';

  static String get facturesAll => '$apiBase/factures';
  static String get ocrReceive => '$apiBase/integrations/ocr-result';
  static String get facturesValidate => '$apiBase/factures/{id}/valider';

  static String get alertesHistory => '$apiBase/alertes';
  static String get alertesRealtime => '$wsUrl/ws/alertes';

  static String get dashboardStats           => '$apiBase/dashboard/stats';
  static String get dashboardMovementsChart  => '$apiBase/dashboard/movements-chart';
  static String get stockCommandesAuto       => '$apiBase/stock/commandes-auto';
  static String get stockAlertesStock        => '$apiBase/stock/alertes-stock';
  static String get usersSetupStatus => '$apiBase/users/setup/status';
  static String get usersSetup       => '$apiBase/users/setup';
  static String get usersAll         => '$apiBase/users';
  static String get superAdminVerify => '$apiBase/users/super-admin/verify';
  static String get superAdminLogin   => '$apiBase/users/super-admin/login';
  static String get stockProduitsCreate => '$apiBase/stock/produits';
  static String get stockLots => '$apiBase/stock/lots';
  static String get stockFournisseurs => '$apiBase/stock/fournisseurs';
  static String get dashboardIot         => '$apiBase/dashboard/iot';
  static String get integrationsAuto     => '$apiBase/integrations/automation-events/latest';
  static String get integrationsFaceEvents => '$apiBase/integrations/face-events';
  static String get alertesActive => '$apiBase/alertes/active';
  static const String superAdminUser = 'synexia_root';

  static String get factureLignes => '$apiBase/factures/{id}/lignes';
  static String get ligneDelete => '$apiBase/lignes/{id}';
  static String get produitHistoriquePrix => '$apiBase/produits/{id}/historique-prix';
  static String get factureDetail => '$apiBase/factures/{id}';
  static String get facturesRejeter => '$apiBase/factures/{id}/rejeter';
  static String get produitAjoutManuelComplet => '$apiBase/stock/produits/ajout-manuel-complet';

  static String get facturesManuelle => '$apiBase/factures/manuelle';
  static String get factureCompleterModification => '$apiBase/factures/{id}/completer-modification';
  static String get factureConfirmerOcr => '$apiBase/factures/{id}/confirmer-ocr';
  static String get factureEmplacementsOcr => '$apiBase/factures/{id}/emplacements-ocr';
  static String get lotQr => '$apiBase/stock/lots/{id}/qr';
  static String get lotSuggere => '$apiBase/stock/produits/{id}/lot-suggere';

  static String get demandesModification => '$apiBase/demandes/modification';
  static String get demandeApprouver => '$apiBase/demandes/modification/{id}/approuver';
  static String get demandeRefuser => '$apiBase/demandes/modification/{id}/refuser';

  static String get appairageGenerer => '$apiBase/appairage/generer';

  static String get bomAll => '$apiBase/bom';
  static String get bomDuProduit => '$apiBase/bom/produit/{id}';
  static String get ordresFabrication => '$apiBase/bom/ordres-fabrication';

}