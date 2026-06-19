class AppConfig {
  AppConfig._();

  static const String _baseUrl = 'http://192.168.1.33:8000';

  static const String apiBase = '$_baseUrl/api/v1';

  static const String authLogin = '$apiBase/auth/login';
  static const String authRefresh = '$apiBase/auth/refresh';
  static const String authLogout = '$apiBase/auth/logout';

  static const String stockProducts = '$apiBase/stock/produits';
  static const String stockProduct = '$apiBase/stock/produits/{id}';
  static const String stockMovements = '$apiBase/stock/mouvements';
  static const String stockScanQr = '$apiBase/stock/scan';

  static const String facturesAll = '$apiBase/factures';
  static const String facturesGenerate = '$apiBase/factures/generate-pdf';
  static const String facturesValidate = '$apiBase/factures/{id}/valider';
  static const String ocrReceive = '$apiBase/ocr/receive';

  static const String alertesRealtime = '$_baseUrl/ws/alertes';
  static const String alertesHistory = '$apiBase/alertes';

  static const String dashboardStats = '$apiBase/dashboard/stats';

  static const int connectTimeout = 10000;
  static const int receiveTimeout = 30000;

  static const String tokenKey = 'synexia_token';
  static const String refreshTokenKey = 'synexia_refresh';
  static const String themeKey = 'synexia_theme';
  static const String localeKey = 'synexia_locale';
  static const String userKey = 'synexia_user';
}
