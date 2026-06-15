import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('fr'),
    Locale('ar'),
    Locale('en'),
  ];

  static final Map<String, Map<String, String>> _strings = {
    'fr': {
      'app_name': 'Synexia',
      'nav_home': 'Accueil',
      'nav_scan': 'Scanner',
      'nav_invoices': 'Factures',
      'nav_profile': 'Profil',
      'home_greeting': 'Bonjour,',
      'home_products': 'Produits',
      'home_entries': 'Entrées',
      'home_exits': 'Sorties',
      'home_alerts': 'Alertes',
      'home_recent_movements': 'Derniers mouvements',
      'scan_title': 'Scanner un produit',
      'scan_instruction': 'Placez le code QR dans le cadre',
      'scan_found': 'Produit trouvé',
      'scan_not_found': 'Produit introuvable',
      'scan_validate': 'Valider',
      'scan_cancel': 'Annuler',
      'scan_quantity': 'Quantité',
      'invoice_title': 'Factures',
      'invoice_detected': 'Facture détectée',
      'invoice_supplier': 'Fournisseur',
      'invoice_date': 'Date',
      'invoice_amount_ht': 'Montant HT',
      'invoice_amount_ttc': 'Montant TTC',
      'invoice_stamp': 'Cachet',
      'invoice_signature': 'Signature',
      'invoice_stamp_detected': 'Cachet détecté',
      'invoice_signature_detected': 'Signature détectée',
      'invoice_sign_bio': 'Apposer ma signature biométrique',
      'invoice_pending': 'En attente',
      'invoice_validated': 'Validée',
      'invoice_rejected': 'Rejetée',
      'profile_title': 'Mon profil',
      'profile_bio_active': 'Authentification biométrique active',
      'profile_role': 'Rôle',
      'profile_last_login': 'Dernière connexion',
      'profile_fingerprint': 'Empreinte',
      'profile_fingerprint_registered': 'Enregistrée',
      'profile_access_limited': 'Accès limité : Scan & modification stock uniquement',
      'role_stockiste': 'Stockiste',
      'role_manager': 'Manager',
      'login_title': 'Connexion',
      'login_username': 'Nom d\'utilisateur',
      'login_password': 'Mot de passe',
      'login_button': 'Se connecter',
      'login_bio': 'Connexion biométrique',
      'status_normal': 'Normal',
      'status_low': 'Stock bas',
      'status_critical': 'Critique',
      'error_network': 'Erreur réseau. Vérifiez votre connexion.',
      'error_auth': 'Identifiants incorrects.',
      'error_server': 'Erreur serveur. Réessayez plus tard.',
      'loading': 'Chargement...',
      'retry': 'Réessayer',
      'save': 'Enregistrer',
      'close': 'Fermer',
      'confirm': 'Confirmer',
      'settings_title': 'Paramètres',
      'settings_theme': 'Thème',
      'settings_language': 'Langue',
      'settings_dark': 'Sombre',
      'settings_light': 'Clair',
      'today': 'Aujourd\'hui',
    },
    'ar': {
      'app_name': 'سينيكسيا',
      'nav_home': 'الرئيسية',
      'nav_scan': 'مسح',
      'nav_invoices': 'الفواتير',
      'nav_profile': 'الملف الشخصي',
      'home_greeting': 'مرحباً،',
      'home_products': 'المنتجات',
      'home_entries': 'المداخل',
      'home_exits': 'المخارج',
      'home_alerts': 'التنبيهات',
      'home_recent_movements': 'آخر التحركات',
      'scan_title': 'مسح منتج',
      'scan_instruction': 'ضع رمز QR داخل الإطار',
      'scan_found': 'تم العثور على المنتج',
      'scan_not_found': 'المنتج غير موجود',
      'scan_validate': 'تأكيد',
      'scan_cancel': 'إلغاء',
      'scan_quantity': 'الكمية',
      'invoice_title': 'الفواتير',
      'invoice_detected': 'تم اكتشاف فاتورة',
      'invoice_supplier': 'المورد',
      'invoice_date': 'التاريخ',
      'invoice_amount_ht': 'المبلغ بدون ضريبة',
      'invoice_amount_ttc': 'المبلغ مع الضريبة',
      'invoice_stamp': 'الختم',
      'invoice_signature': 'التوقيع',
      'invoice_stamp_detected': 'تم اكتشاف الختم',
      'invoice_signature_detected': 'تم اكتشاف التوقيع',
      'invoice_sign_bio': 'إضافة توقيعي البيومتري',
      'invoice_pending': 'قيد الانتظار',
      'invoice_validated': 'مصادق عليها',
      'invoice_rejected': 'مرفوضة',
      'profile_title': 'ملفي الشخصي',
      'profile_bio_active': 'المصادقة البيومترية مفعّلة',
      'profile_role': 'الدور',
      'profile_last_login': 'آخر تسجيل دخول',
      'profile_fingerprint': 'بصمة الإصبع',
      'profile_fingerprint_registered': 'مسجلة',
      'profile_access_limited': 'وصول محدود: المسح وتعديل المخزون فقط',
      'role_stockiste': 'أمين المخزن',
      'role_manager': 'المدير',
      'login_title': 'تسجيل الدخول',
      'login_username': 'اسم المستخدم',
      'login_password': 'كلمة المرور',
      'login_button': 'دخول',
      'login_bio': 'الدخول البيومتري',
      'status_normal': 'عادي',
      'status_low': 'مخزون منخفض',
      'status_critical': 'حرج',
      'error_network': 'خطأ في الشبكة. تحقق من اتصالك.',
      'error_auth': 'بيانات الدخول غير صحيحة.',
      'error_server': 'خطأ في الخادم. حاول مرة أخرى.',
      'loading': 'جاري التحميل...',
      'retry': 'إعادة المحاولة',
      'save': 'حفظ',
      'close': 'إغلاق',
      'confirm': 'تأكيد',
      'settings_title': 'الإعدادات',
      'settings_theme': 'المظهر',
      'settings_language': 'اللغة',
      'settings_dark': 'داكن',
      'settings_light': 'فاتح',
      'today': 'اليوم',
    },
    'en': {
      'app_name': 'Synexia',
      'nav_home': 'Home',
      'nav_scan': 'Scan',
      'nav_invoices': 'Invoices',
      'nav_profile': 'Profile',
      'home_greeting': 'Hello,',
      'home_products': 'Products',
      'home_entries': 'Entries',
      'home_exits': 'Exits',
      'home_alerts': 'Alerts',
      'home_recent_movements': 'Recent movements',
      'scan_title': 'Scan a product',
      'scan_instruction': 'Place the QR code in the frame',
      'scan_found': 'Product found',
      'scan_not_found': 'Product not found',
      'scan_validate': 'Validate',
      'scan_cancel': 'Cancel',
      'scan_quantity': 'Quantity',
      'invoice_title': 'Invoices',
      'invoice_detected': 'Invoice detected',
      'invoice_supplier': 'Supplier',
      'invoice_date': 'Date',
      'invoice_amount_ht': 'Amount excl. tax',
      'invoice_amount_ttc': 'Amount incl. tax',
      'invoice_stamp': 'Stamp',
      'invoice_signature': 'Signature',
      'invoice_stamp_detected': 'Stamp detected',
      'invoice_signature_detected': 'Signature detected',
      'invoice_sign_bio': 'Add biometric signature',
      'invoice_pending': 'Pending',
      'invoice_validated': 'Validated',
      'invoice_rejected': 'Rejected',
      'profile_title': 'My profile',
      'profile_bio_active': 'Biometric authentication active',
      'profile_role': 'Role',
      'profile_last_login': 'Last login',
      'profile_fingerprint': 'Fingerprint',
      'profile_fingerprint_registered': 'Registered',
      'profile_access_limited': 'Limited access: Scan & stock modification only',
      'role_stockiste': 'Stock keeper',
      'role_manager': 'Manager',
      'login_title': 'Login',
      'login_username': 'Username',
      'login_password': 'Password',
      'login_button': 'Sign in',
      'login_bio': 'Biometric login',
      'status_normal': 'Normal',
      'status_low': 'Low stock',
      'status_critical': 'Critical',
      'error_network': 'Network error. Check your connection.',
      'error_auth': 'Invalid credentials.',
      'error_server': 'Server error. Try again later.',
      'loading': 'Loading...',
      'retry': 'Retry',
      'save': 'Save',
      'close': 'Close',
      'confirm': 'Confirm',
      'settings_title': 'Settings',
      'settings_theme': 'Theme',
      'settings_language': 'Language',
      'settings_dark': 'Dark',
      'settings_light': 'Light',
      'today': 'Today',
    },
  };

  String get(String key) {
    final lang = locale.languageCode;
    return _strings[lang]?[key] ?? _strings['fr']?[key] ?? key;
  }

  String get appName => get('app_name');
  String get navHome => get('nav_home');
  String get navScan => get('nav_scan');
  String get navInvoices => get('nav_invoices');
  String get navProfile => get('nav_profile');
  String get homeGreeting => get('home_greeting');
  String get homeProducts => get('home_products');
  String get homeEntries => get('home_entries');
  String get homeExits => get('home_exits');
  String get homeAlerts => get('home_alerts');
  String get homeRecentMovements => get('home_recent_movements');
  String get scanTitle => get('scan_title');
  String get scanInstruction => get('scan_instruction');
  String get scanFound => get('scan_found');
  String get scanNotFound => get('scan_not_found');
  String get scanValidate => get('scan_validate');
  String get scanCancel => get('scan_cancel');
  String get scanQuantity => get('scan_quantity');
  String get invoiceTitle => get('invoice_title');
  String get invoiceDetected => get('invoice_detected');
  String get invoiceSupplier => get('invoice_supplier');
  String get invoiceDate => get('invoice_date');
  String get invoiceAmountHt => get('invoice_amount_ht');
  String get invoiceAmountTtc => get('invoice_amount_ttc');
  String get invoiceStamp => get('invoice_stamp');
  String get invoiceSignature => get('invoice_signature');
  String get invoiceStampDetected => get('invoice_stamp_detected');
  String get invoiceSignatureDetected => get('invoice_signature_detected');
  String get invoiceSignBio => get('invoice_sign_bio');
  String get invoicePending => get('invoice_pending');
  String get invoiceValidated => get('invoice_validated');
  String get invoiceRejected => get('invoice_rejected');
  String get profileTitle => get('profile_title');
  String get profileBioActive => get('profile_bio_active');
  String get profileRole => get('profile_role');
  String get profileLastLogin => get('profile_last_login');
  String get profileFingerprint => get('profile_fingerprint');
  String get profileFingerprintRegistered => get('profile_fingerprint_registered');
  String get profileAccessLimited => get('profile_access_limited');
  String get roleStockiste => get('role_stockiste');
  String get roleManager => get('role_manager');
  String get loginTitle => get('login_title');
  String get loginUsername => get('login_username');
  String get loginPassword => get('login_password');
  String get loginButton => get('login_button');
  String get loginBio => get('login_bio');
  String get statusNormal => get('status_normal');
  String get statusLow => get('status_low');
  String get statusCritical => get('status_critical');
  String get errorNetwork => get('error_network');
  String get errorAuth => get('error_auth');
  String get errorServer => get('error_server');
  String get loading => get('loading');
  String get retry => get('retry');
  String get save => get('save');
  String get close => get('close');
  String get confirm => get('confirm');
  String get settingsTitle => get('settings_title');
  String get settingsTheme => get('settings_theme');
  String get settingsLanguage => get('settings_language');
  String get settingsDark => get('settings_dark');
  String get settingsLight => get('settings_light');
  String get today => get('today');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['fr', 'ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
