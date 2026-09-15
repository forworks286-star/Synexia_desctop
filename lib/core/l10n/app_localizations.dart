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
      'nav_dashboard': 'Tableau de bord',
      'nav_manufacturing': 'Fabrication',
      'nav_purchase_orders': 'Bons de commande',
      'nav_qr_codes': 'Codes QR',
      'nav_approvals': 'Approbations',
      'nav_iot': 'IoT',
      'nav_security': 'Sécurité',
      'nav_reports': 'Rapports',
      'nav_admin': 'Admin',
      'nav_settings': 'Paramètres',
      'role_admin': 'Administrateur',
      'role_agent_kiosk': 'Agent Kiosk',
      'logout': 'Déconnexion',
      'login_subtitle': 'Accès réservé aux utilisateurs autorisés',
      'login_username_hint': 'Entrez votre identifiant',
      'login_password_hint': 'Entrez votre mot de passe',
      'login_admin_access': 'Accès administrateur système',
      'app_tagline': 'Warehouse Management System',
      'feature_stock_realtime': 'Gestion de stock en temps réel',
      'feature_invoice_validation': 'Validation intelligente des factures',
      'feature_alerts_instant': 'Alertes instantanées',
      'feature_reports_analytics': 'Rapports et analyses',
      'dashboard_refresh': 'Actualiser',
      'kpi_entries_today': 'Entrées / auj.',
      'kpi_exits_today': 'Sorties / auj.',
      'kpi_active_alerts': 'Alertes actives',
      'kpi_unread': 'non lues',
      'kpi_pending_invoices': 'Factures en attente',
      'kpi_total_stock_value': 'Valeur stock total',
      'chart_movements_title': 'MOUVEMENTS — 7 DERNIERS JOURS',
      'chart_no_data': 'Aucune donnée',
      'recent_alerts_title': 'ALERTES RÉCENTES',
      'no_alerts': 'Aucune alerte',
      'critical_stock_title': 'STOCK CRITIQUE',
      'all_normal': 'Tout est normal',
      'recent_movements_title': 'DERNIERS MOUVEMENTS',
      'no_movements': 'Aucun mouvement',
      'table_product': 'PRODUIT',
      'table_qty': 'QTÉ',
      'table_type': 'TYPE',
      'movement_entry': 'Entrée',
      'movement_exit': 'Sortie',
      'search_product_hint': 'SKU, nom, référence...',
      'filter_all_status': 'Tous les statuts',
      'add_button': 'Ajouter',
      'th_sku': 'SKU',
      'th_category': 'CATÉGORIE',
      'th_stock_available': 'STOCK DISPO',
      'th_value': 'VALEUR',
      'th_status': 'STATUT',
      'no_product': 'Aucun produit',
      'status_low_short': 'Bas',
      'filter_category_hint': 'Catégorie',
      'filter_all_categories': 'Toutes catégories',
      'detail_stock_physical': 'Stock physique',
      'detail_stock_available': 'Stock disponible',
      'detail_stock_reserved': 'Stock réservé',
      'detail_critical_threshold': 'Seuil critique',
      'detail_purchase_price': 'Prix achat',
      'detail_sale_price': 'Prix vente',
      'detail_pmp': 'PMP',
      'detail_stock_value': 'Valeur stock',
      'detail_tva': 'TVA',
      'detail_origin_country': 'Pays origine',
      'view_price_history': 'Voir historique des prix',
      'lots_title': 'LOTS',
      'lot_available': 'dispo',
      'lot_expiry': 'Exp:',
      'print_lot_qr_tooltip': 'Imprimer le QR de ce lot',
      'extra_fields_title': 'CHAMPS EXTRA',
      'add_product_title': 'Ajouter un produit',
      'add_product_choose_mode': 'Choisissez le mode d\'ajout :',
      'add_product_sheet_only': 'Fiche produit seulement\n(sans stock)',
      'add_product_with_stock': 'Avec stock initial\n(facture automatique)',
      'form_sku': 'SKU *',
      'form_qr_code': 'QR Code *',
      'form_product_name': 'Nom du produit *',
      'form_category': 'Catégorie',
      'form_stock_type': 'Type de stock',
      'form_purchase_price_ref': 'Prix achat référence',
      'form_sale_price_ref': 'Prix vente référence',
      'cancel': 'Annuler',
      'create': 'Créer',
      'error_sku_name_qr_required': 'SKU, Nom et QR Code sont obligatoires',
      'error_sku_qr_used': 'Erreur — SKU ou QR Code déjà utilisé',
      'toast_success': 'Succès',
      'toast_product_sheet_created': 'Fiche produit créée (stock à 0, en attente de facture)',
      'product_full_title': 'Produit avec stock initial',
      'product_full_subtitle': 'Une facture d\'ajustement sera créée automatiquement pour tracer cette entrée.',
      'form_supplier': 'Fournisseur',
      'form_origin_country': 'Pays d\'origine',
      'form_supplier_nif': 'NIF fournisseur',
      'form_supplier_nis': 'NIS fournisseur',
      'form_supplier_rc': 'RC fournisseur',
      'form_initial_qty': 'Quantité initiale *',
      'toast_product_invoice_created': 'Produit + facture d\'ajustement créés',
      'qr_lot_title': 'QR — Lot',
      'qr_print_instruction': 'Imprimez cette fenêtre (Ctrl+P) et collez le QR sur les cartons du lot.',
      'error_title': 'Erreur',
      'filter_type_all': 'Tout',
      'filter_type_merchandise': 'Marchandise',
      'filter_type_raw_material': 'Matière première',
      'filter_type_finished_product': 'Produit fini',
      'filter_type_consumable': 'Consommable',
      'po_new': 'Nouveau bon de commande',
      'po_no_supplier': 'Sans fournisseur',
      'po_articles_suffix': 'article(s)',
      'po_supplier_colon': 'Fournisseur :',
      'po_type_colon': 'Type :',
      'po_status_colon': 'Statut :',
      'po_quantity_short': 'Qté:',
      'po_price_estimate_short': 'Prix estimé:',
      'po_designation': 'Désignation',
      'po_quantity': 'Quantité',
      'po_price_estimate': 'Prix estimé',
      'po_supplier_optional': 'Fournisseur (optionnel)',
      'po_add_line': 'Ajouter une ligne',
      'po_created_title': 'Créé',
      'po_created_prefix': 'Bon de commande',
      'po_created_suffix': 'créé',
      'pdf_stock_type_label': 'Type de stock :',
      'pdf_header_total': 'Total',
      'qr_print_page_title': 'Codes QR à imprimer',
      'qr_none_pending': 'Aucun code QR en attente d\'impression',
      'qr_lot_label': 'Lot:',
      'qr_location_label': 'Emplacement:',
      'print_tooltip': 'Imprimer',
      'remove_from_list_tooltip': 'Retirer de la liste',
      'save_qr_dialog_title': 'Enregistrer le QR',
      'downloaded_title': 'Téléchargé',
      'downloaded_msg_prefix': 'Enregistré :',
      'download_button': 'Télécharger',
      'iot_zones_title': 'IoT — Zones',
      'iot_zone_label': 'Zone',
      'iot_all_zones': 'Toutes les zones',
      'iot_no_data': 'Aucune donnée IoT reçue',
      'iot_level_critical': 'CRITIQUE',
      'iot_level_alert': 'ALERTE',
      'iot_level_manual': 'MANUEL',
      'iot_level_normal': 'NORMAL',
      'iot_auto_resolved': '✓ Résolu automatiquement',
      'iot_needs_manual': '⚠ Nécessite une intervention manuelle',
      'mark_all_read': 'Tout marquer lu',
      'th_title': 'TITRE',
      'th_message': 'MESSAGE',
      'th_level': 'NIVEAU',
      'th_time': 'HEURE',
      'alert_level_warning': 'Avertissement',
      'alert_level_info': 'Info',
      'read_label': 'Lu',
      'new_label': 'Nouveau',
      'time_ago_minutes': 'Il y a {n} min',
      'time_ago_hours': 'Il y a {n}h',
      'approvals_page_title': 'Confirmation des changements',
      'approvals_gap_count': '{n} écart(s) bon de commande à valider',
      'examine_button': 'Examiner',
      'approvals_no_pending': 'Aucune demande en attente',
      'gap_title_prefix': 'Écart — Facture #',
      'gap_detected_title': 'ÉCARTS DÉTECTÉS',
      'gap_comment_title': 'COMMENTAIRE',
      'reject_button': 'Rejeter',
      'approve_button': 'Approuver',
      'rejected_title': 'Rejetée',
      'rejected_msg': 'La facture a été annulée',
      'approved_title': 'Approuvé',
      'approved_msg': 'La facture reprend son cours normal',
      'invoice_hash_prefix': 'Facture #',
      'requested_by_prefix': 'Demandé par',
      'gap_lock_notice': '🔒 Réglez d\'abord l\'écart bon de commande de cette facture (voir ci-dessus)',
      'view_invoice_button': 'Voir la facture',
      'refuse_button': 'Refuser',
      'refuse_reason_title': 'Motif du refus',
      'refuse_reason_hint': 'Pourquoi refuser cette demande ?',
      'confirm_refuse_button': 'Confirmer le refus',
      'ecart_fournisseur_different': '⚠ Fournisseur différent : commandé "{a}" → reçu "{b}"',
      'ecart_produit_non_commande': '⚠ "{a}" reçu mais non commandé (qté: {b})',
      'ecart_produit_manquant': '⚠ "{a}" commandé (qté: {b}) mais non reçu',
      'ecart_quantite_detail': 'quantité commandée {a} → reçue {b}',
      'ecart_prix_detail': 'prix estimé {a} → reçu {b}',
      'ecart_generic_prefix': '⚠ "{a}" : {b}',
      'fab_page_title': 'Fabrication (BOM & Ordres)',
      'fab_tab_recipes': 'Recettes (BOM)',
      'fab_tab_orders': 'Ordres de fabrication',
      'fab_new_recipe': 'Nouvelle recette',
      'fab_no_recipe': 'Aucune recette definie',
      'fab_product_hash_prefix': 'Produit #',
      'fab_per_unit_suffix': '(par unite)',
      'fab_loss_suffix': '— perte',
      'fab_produce_from_recipe': 'Produire à partir de cette recette',
      'fab_new_recipe_dialog_title': 'Nouvelle recette (BOM)',
      'fab_finished_product_label': 'Produit fini',
      'fab_component_label': 'Composant',
      'fab_qty_per_unit_label': 'Quantité / unité',
      'fab_loss_percent_label': '% perte',
      'fab_add_component': 'Ajouter un composant',
      'fab_produce_dialog_title_prefix': 'Produire :',
      'fab_max_realisable_prefix': 'Quantité maximale réalisable avec le stock actuel :',
      'fab_limited_by_prefix': 'limité par :',
      'fab_qty_produced_label': 'Quantité produite',
      'fab_location_optional_label': 'Emplacement (optionnel)',
      'fab_lot_number_optional_label': 'Numéro de lot (optionnel)',
      'fab_fabrication_date_label': 'Date de fabrication',
      'fab_expiration_date_label': 'Date de péremption (recommandé)',
      'fab_not_defined_pick': 'Non définie — appuyez pour choisir',
      'fab_confirm_production': 'Confirmer la production',
      'fab_production_recorded_title': 'Production enregistrée',
      'fab_lot_word': 'Lot',
      'fab_unit_cost_suffix': '— coût unitaire',
      'fab_no_orders': 'Aucun ordre de fabrication',
      'fab_quantity_colon': 'Quantité :',
      'fab_lot_colon': 'Lot :',
      'fab_per_unit_dzd_suffix': 'DZD / unité',
      'report_stock_title': 'Rapport de stock',
      'report_stock_desc': 'État complet de l\'inventaire avec niveaux critiques et historique des mouvements.',
      'report_invoices_title': 'Rapport des factures',
      'report_invoices_desc': 'Synthèse des factures validées, rejetées et en attente sur la période sélectionnée.',
      'report_alerts_title': 'Rapport des alertes',
      'report_alerts_desc': 'Journal complet des alertes système, stocks critiques et anomalies détectées.',
      'generate_pdf_button': 'Générer PDF',
      'global_summary_title': 'RÉSUMÉ GLOBAL',
      'stat_total_products': 'Total produits',
      'stat_critical_products': 'Produits critiques',
      'stat_validated_invoices': 'Factures validées',
      'stat_system_availability': 'Disponibilité système',
      'pdf_stock_report_title': 'SYNEXIA — Rapport de Stock',
      'pdf_generated_on_prefix': 'Généré le',
      'pdf_header_product': 'Produit',
      'pdf_header_stock_available': 'Stock dispo',
      'pdf_header_value_dzd': 'Valeur (DZD)',
      'pdf_total_stock_value_prefix': 'Total valeur stock:',
      'pdf_invoices_report_title': 'SYNEXIA — Rapport des Factures',
      'pdf_header_supplier': 'Fournisseur',
      'pdf_header_date': 'Date',
      'pdf_status_validated': 'Validée',
      'pdf_status_rejected': 'Rejetée',
      'pdf_status_pending': 'En attente',
      'pdf_validated_count_prefix': 'Validées:',
      'pdf_pending_count_prefix': 'En attente:',
      'pdf_rejected_count_prefix': 'Rejetées:',
      'pdf_alerts_report_title': 'SYNEXIA — Rapport des Alertes',
      'pdf_unread_label': 'Non lu',
      'hist_page_title': 'Historique Produit',
      'hist_search_hint': 'Rechercher un produit par nom ou SKU...',
      'hist_search_empty': 'Recherchez un produit pour voir son historique',
      'hist_avg_purchase_price': 'Prix achat moyen',
      'hist_avg_sale_price': 'Prix vente moyen',
      'hist_margin': 'Marge',
      'hist_lot_distribution_title': 'RÉPARTITION DU STOCK PAR LOT',
      'hist_no_active_lot': 'Aucun lot actif',
      'hist_units_suffix': 'unités',
      'hist_expires_prefix': 'Expire:',
      'hist_invoice_word': 'Facture',
      'hist_price_evolution_title': 'ÉVOLUTION DU PRIX D\'ACHAT',
      'hist_all_invoices_title': 'TOUTES LES FACTURES — CE PRODUIT',
      'hist_no_invoice_yet': 'Aucune facture pour ce produit pour le moment',
      'hist_no_validated_purchase': 'Aucun achat validé enregistré pour ce produit',
      'hist_single_purchase_prefix': 'Un seul achat validé',
      'hist_chart_appears_note': 'Le graphique apparaîtra dès qu\'il y aura 2 achats ou plus.',
      'hist_status_accepted': 'Acceptée',
      'hist_type_sale': 'Vente',
      'hist_type_purchase': 'Achat',
      'sec_page_title': 'Sécurité',
      'sec_access_control_title': 'CONTRÔLE D\'ACCÈS — FACE ID',
      'sec_th_person': 'PERSONNE',
      'sec_th_zone': 'ZONE',
      'sec_th_confidence': 'CONFIANCE',
      'sec_th_access': 'ACCÈS',
      'sec_no_face_event': 'Aucun événement Face ID',
      'sec_alerts_title': 'ALERTES SÉCURITÉ',
      'sec_no_security_alert': 'Aucune alerte sécurité',
      'sec_unknown_person': 'Inconnu',
      'sec_access_ok': '✓ OK',
      'sec_access_denied': '✗ Refusé',
      'settings_appearance_title': 'APPARENCE',
      'settings_theme_label': 'Thème',
      'settings_language_label': 'Langue',
      'settings_account_title': 'COMPTE',
      'settings_connection_title': 'CONNEXION SERVEUR',
      'settings_connected_local': 'Connecté au serveur local',
      'setup_fill_all_fields': 'Veuillez remplir tous les champs',
      'setup_passwords_mismatch': 'Les mots de passe ne correspondent pas',
      'setup_password_too_short': 'Mot de passe trop court (minimum 6 caractères)',
      'setup_already_done': 'Configuration déjà effectuée',
      'setup_password_too_short_server': 'Mot de passe trop court',
      'setup_server_error': 'Erreur serveur',
      'setup_initial_config_title': 'Configuration initiale',
      'setup_initial_config_desc': 'Créez le compte administrateur de votre entrepôt.\nCette étape n\'apparaîtra qu\'une seule fois.',
      'setup_full_name_label': 'Nom complet',
      'setup_confirm_password_label': 'Confirmer le mot de passe',
      'setup_create_admin_button': 'Créer le compte administrateur',
      'gate_connecting': 'Connexion au serveur...',
      'setup_back_button': 'Retour',
      'setup_server_config_title': 'Configuration du serveur',
      'setup_server_config_desc': 'Entrez l\'adresse du serveur local de votre entrepôt',
      'setup_ip_label': 'Adresse IP',
      'setup_port_label': 'Port',
      'setup_server_unreachable': 'Impossible de joindre le serveur. Vérifiez l\'adresse et que le serveur est démarré.',
      'sa_title': 'Super Admin',
      'sa_zone_notice': 'Zone réservée à l\'administrateur système.\nCette zone permet de gérer les utilisateurs et les droits d\'accès.',
      'sa_system_password_label': 'Mot de passe système',
      'sa_password_hint': 'Entrez le mot de passe Super Admin',
      'sa_wrong_password': 'Mot de passe incorrect',
      'sa_access_button': 'Accéder',
      'sa_users_management_title': 'Gestion des utilisateurs',
      'sa_add_user_title': 'Ajouter un utilisateur',
      'sa_username_exists': 'Nom d\'utilisateur déjà utilisé',
      'sa_check_fields_error': 'Erreur — vérifiez les champs',
      'sa_role_label': 'Rôle',
      'sa_reset_password_title_prefix': 'Réinitialiser mot de passe —',
      'sa_new_password_label': 'Nouveau mot de passe',
      'sa_role_admin_short': 'Admin',
      'sa_th_name': 'NOM',
      'sa_th_username': 'USERNAME',
      'sa_th_role': 'RÔLE',
      'sa_deactivate_tooltip': 'Désactiver',
      'sa_activate_tooltip': 'Activer',
      'sa_reset_password_tooltip': 'Réinitialiser mot de passe',
      'inv_page_actions_new_invoice': 'Nouvelle facture',
      'inv_banner_mismatch_count': '{n} facture(s) ne correspondent pas au bon de commande',
      'inv_view_and_report': 'Voir et signaler',
      'inv_banner_ocr_count': '{n} facture(s) OCR à vérifier',
      'inv_verify_button': 'Vérifier',
      'inv_banner_pending_mod_count': '{n} demande(s) de modification en attente d\'approbation',
      'inv_pending_admin': 'En attente admin',
      'inv_banner_to_correct_count': '{n} facture(s) à corriger — votre demande a été approuvée',
      'inv_correct_now': 'Corriger maintenant',
      'th_authentication': 'AUTHENTIFICATION',
      'stamp_label': 'Cachet',
      'signature_short_label': 'Sign.',
      'inv_validate_button': 'Valider',
      'motif_rejet_title': 'Motif du rejet',
      'motif_rejet_hint': 'Expliquez pourquoi cette facture est rejetée...',
      'confirm_reject_button': 'Confirmer le rejet',
      'invoice_rejected_toast': 'Facture rejetée',
      'filter_all_types': 'Tous les types',
      'type_purchases': 'Achats',
      'type_sales': 'Ventes',
      'status_validated_plural': 'Validées',
      'status_rejected_plural': 'Rejetées',
      'new_manual_invoice_title': 'Nouvelle facture manuelle',
      'manual_invoice_notice': 'Une facture créée manuellement reste en attente jusqu\'à vérification par un administrateur.',
      'type_label': 'Type',
      'category_label': 'Catégorie',
      'po_none': 'Aucun',
      'po_reserved_by_you_prefix': 'Bon de commande #',
      'po_reserved_by_you_suffix': '(réservé par vous)',
      'po_optional_label': 'Bon de commande (optionnel)',
      'supplier_client_label': 'Fournisseur / Client',
      'nif_optional_label': 'NIF (optionnel)',
      'nis_optional_label': 'NIS (optionnel)',
      'rc_optional_label': 'RC (optionnel)',
      'invoice_date_label': 'Date de la facture',
      'amount_ht_label': 'Montant HT',
      'tva_label': 'TVA',
      'amount_ttc_label': 'TTC',
      'reason_required_label': 'Motif (obligatoire)',
      'reason_hint': 'Pourquoi une saisie manuelle ?',
      'articles_title': 'ARTICLES',
      'add_article_button': 'Ajouter un article',
      'po_unavailable_title': 'Indisponible',
      'po_unavailable_msg': 'Ce bon de commande vient d\'être pris par un autre utilisateur',
      'problem_optional_label': 'Problème constaté (optionnel)',
      'problem_hint': 'Laissez les champs concernés vides, et expliquez ici précisément ce qui manque ou est incorrect.',
      'report_required_title': 'Compte-rendu requis',
      'report_required_msg': 'Expliquez le problème avant d\'envoyer une demande de modification',
      'reason_required_title': 'Motif requis',
      'reason_required_msg': 'Le champ "Motif (obligatoire)" doit être rempli',
      'supplier_required_title': 'Fournisseur requis',
      'supplier_required_msg': 'Le champ "Fournisseur / Client" doit être rempli',
      'qty_missing_title': 'Quantité manquante',
      'qty_missing_msg': 'Chaque article doit avoir une quantité supérieure à 0',
      'send_modification_request_button': 'Envoyer + demande de modification',
      'invoice_sent_title': 'Facture envoyée',
      'invoice_sent_msg': 'En confirmation de changement — un administrateur doit valider votre demande',
      'send_failed_title': 'Échec de l\'envoi',
      'send_failed_msg': 'Réessayez.',
      'send_button': 'Envoyer',
      'invoice_created_title': 'Facture créée',
      'invoice_created_msg': 'En attente de vérification par un administrateur',
      'new_product_switch_label': 'Produit inexistant (nouveau)',
      'search_existing_product_hint': 'Rechercher un produit existant...',
      'lot_location_prefilled_label': 'Emplacement de ce lot (pré-rempli, modifiable)',
      'new_product_name_label': 'Nom du nouveau produit',
      'barcode_label': 'Code-barres',
      'unit_label': 'Unité (kg, litre, pièce...)',
      'critical_threshold_label': 'Seuil critique',
      'location_label': 'Emplacement',
      'designation_retained_label': 'Désignation retenue',
      'qty_star_label': 'Qté *',
      'required_label': 'Requis',
      'line_total_price_label': 'Prix total (tel qu\'écrit sur la facture)',
      'unit_price_calc_label': 'Prix unitaire (calculé, modifiable)',
      'sale_price_optional_label': 'Prix vente (optionnel)',
      'manufacturing_label': 'Fabrication',
      'expiration_label': 'Expiration',
      'manufacturer_lot_label': 'N° de lot fabricant (si imprimé sur le produit)',
      'correct_invoice_title_prefix': 'Corriger la facture #',
      'corrected_articles_title': 'ARTICLES CORRIGÉS',
      'send_correction_button': 'Envoyer la correction',
      'invoice_corrected_title': 'Facture corrigée',
      'invoice_corrected_msg': 'La facture est de nouveau en attente de vérification',
      'correction_failed_title': 'Échec',
      'correction_failed_msg': 'La correction n\'a pas pu être envoyée. Réessayez.',
      'verify_ocr_title_prefix': 'Vérifier la facture OCR #',
      'ocr_detected_articles_title': 'ARTICLES DÉTECTÉS PAR OCR (lecture seule)',
      'pu_label': ' — PU:',
      'exp_inline_label': ' — Exp:',
      'new_product_location_hint': 'Emplacement (nouveau produit — non fourni par OCR)',
      'report_error_button': 'Signaler une erreur',
      'save_locations_button': 'Enregistrer les emplacements',
      'locations_saved_title': 'Emplacements enregistrés',
      'locations_saved_msg': 'Vous pouvez maintenant confirmer la facture',
      'confirm_button_word': 'Confirmer',
      'invoice_confirmed_title': 'Facture confirmée',
      'invoice_confirmed_msg': 'Elle est maintenant en attente de validation par l\'administrateur',
      'gaps_detected_title_prefix': 'Écarts détectés — Facture #',
      'your_comment_label': 'Votre commentaire pour l\'administrateur',
      'send_to_admin_button': 'Envoyer à l\'administrateur',
      'sent_title': 'Envoyé',
      'sent_awaiting_admin_msg': 'En attente de décision de l\'administrateur',
      'report_error_title': 'Signaler une erreur',
      'describe_error_label': 'Décrivez l\'erreur constatée',
      'send_request_button': 'Envoyer la demande',
      'request_sent_title': 'Demande envoyée',
      'request_sent_msg': 'En attente d\'approbation par l\'administrateur',
      'new_invoice_title': 'Nouvelle facture',
      'from_phone_ocr_title': 'Depuis un téléphone (OCR)',
      'from_phone_ocr_subtitle': 'Nécessite l\'application mobile',
      'manual_entry_title': 'Saisie manuelle',
      'manual_entry_subtitle': 'Remplir la facture directement ici',
      'invoice_category_title': 'Catégorie de la facture',
      'po_choice_title': 'Bon de commande (optionnel)',
      'none_word': 'Aucun',
      'receive_from_phone_title': 'Recevoir depuis un téléphone',
      'code_expired_title': 'Code expiré',
      'generate_new_code_button': 'Générer un nouveau code',
      'server_connection_error': 'Erreur de connexion au serveur',
      'expires_in_prefix': 'Expire dans',
      'mobile_instructions': 'Depuis l\'application mobile : entrez ce code ou scannez le QR.',
      'phone_connected_msg': 'Téléphone connecté — en attente de la photo...',
      'invoice_received_msg': 'Facture reçue !',
      'later_button': 'Plus tard',
      'verify_invoice_button': 'Vérifier la facture',
      'sale_word': 'Vente',
      'manual_adjustment_word': 'Ajustement manuel',
      'created_manually_label': 'Créée manuellement',
      'financial_summary_title': 'RÉSUMÉ FINANCIER',
      'ppa_label': 'PPA',
      'incoherence_detected_msg': 'Incohérence détectée entre le montant HT et le total des lignes.',
      'products_count_title': 'PRODUITS',
      'add_short_button': '+ Ajouter',
      'no_product_in_invoice': 'Aucun produit ajouté à cette facture',
      'existing_tag': '✅ Existant',
      'invoice_validated_success_msg': 'Facture validée — stock mis à jour',
      'add_product_to_invoice_title': 'Ajouter un produit à la facture',
      'quantity_word': 'Quantité',
      'line_total_invoice_label': 'Prix total (facture)',
      'sale_price_optional_label2': 'Prix de vente (optionnel)',
      'manufacturing_date_ymd_label': 'Date fabrication (AAAA-MM-JJ)',
      'expiration_date_ymd_label': 'Date expiration (AAAA-MM-JJ)',
      'rejection_reason_title': 'MOTIF DE REJET',
      'manual_creation_reason_label': 'Motif (création manuelle)',
      'invoice_cancelled': 'Annulée',
      'invoice_amount_tva': 'Montant TVA',
      'invoices_empty': 'Aucune facture',
      'th_invoice_number': 'N° FACTURE',
      'th_supplier_upper': 'FOURNISSEUR',
      'th_date_upper': 'DATE',
      'th_amount_ht_upper': 'MONTANT HT',
      'th_amount_ttc_upper': 'MONTANT TTC',
      'th_actions': 'ACTIONS',
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
      'nav_dashboard': 'لوحة التحكم',
      'nav_manufacturing': 'التصنيع',
      'nav_purchase_orders': 'أوامر الشراء',
      'nav_qr_codes': 'رموز QR',
      'nav_approvals': 'الموافقات',
      'nav_iot': 'إنترنت الأشياء',
      'nav_security': 'الأمان',
      'nav_reports': 'التقارير',
      'nav_admin': 'المشرف',
      'nav_settings': 'الإعدادات',
      'role_admin': 'مسؤول النظام',
      'role_agent_kiosk': 'وكيل كيوسك',
      'logout': 'تسجيل الخروج',
      'login_subtitle': 'الوصول مخصص للمستخدمين المصرح لهم فقط',
      'login_username_hint': 'أدخل اسم المستخدم',
      'login_password_hint': 'أدخل كلمة المرور',
      'login_admin_access': 'وصول مسؤول النظام',
      'app_tagline': 'نظام إدارة المخازن',
      'feature_stock_realtime': 'إدارة المخزون في الوقت الفعلي',
      'feature_invoice_validation': 'مصادقة ذكية على الفواتير',
      'feature_alerts_instant': 'تنبيهات فورية',
      'feature_reports_analytics': 'تقارير وتحليلات',
      'dashboard_refresh': 'تحديث',
      'kpi_entries_today': 'المداخل / اليوم',
      'kpi_exits_today': 'المخارج / اليوم',
      'kpi_active_alerts': 'التنبيهات النشطة',
      'kpi_unread': 'غير مقروءة',
      'kpi_pending_invoices': 'فواتير قيد الانتظار',
      'kpi_total_stock_value': 'القيمة الإجمالية للمخزون',
      'chart_movements_title': 'التحركات — آخر 7 أيام',
      'chart_no_data': 'لا توجد بيانات',
      'recent_alerts_title': 'أحدث التنبيهات',
      'no_alerts': 'لا توجد تنبيهات',
      'critical_stock_title': 'مخزون حرج',
      'all_normal': 'كل شيء طبيعي',
      'recent_movements_title': 'آخر التحركات',
      'no_movements': 'لا توجد تحركات',
      'table_product': 'المنتج',
      'table_qty': 'الكمية',
      'table_type': 'النوع',
      'movement_entry': 'دخول',
      'movement_exit': 'خروج',
      'search_product_hint': 'SKU، الاسم، المرجع...',
      'filter_all_status': 'كل الحالات',
      'add_button': 'إضافة',
      'th_sku': 'SKU',
      'th_category': 'الفئة',
      'th_stock_available': 'المخزون المتاح',
      'th_value': 'القيمة',
      'th_status': 'الحالة',
      'no_product': 'لا يوجد منتج',
      'status_low_short': 'منخفض',
      'filter_category_hint': 'الفئة',
      'filter_all_categories': 'كل الفئات',
      'detail_stock_physical': 'المخزون الفعلي',
      'detail_stock_available': 'المخزون المتاح',
      'detail_stock_reserved': 'المخزون المحجوز',
      'detail_critical_threshold': 'الحد الحرج',
      'detail_purchase_price': 'سعر الشراء',
      'detail_sale_price': 'سعر البيع',
      'detail_pmp': 'السعر المتوسط الموزون',
      'detail_stock_value': 'قيمة المخزون',
      'detail_tva': 'الضريبة',
      'detail_origin_country': 'بلد المنشأ',
      'view_price_history': 'عرض تاريخ الأسعار',
      'lots_title': 'الدفعات',
      'lot_available': 'متاح',
      'lot_expiry': 'الانتهاء:',
      'print_lot_qr_tooltip': 'طباعة رمز QR لهذه الدفعة',
      'extra_fields_title': 'حقول إضافية',
      'add_product_title': 'إضافة منتج',
      'add_product_choose_mode': 'اختر طريقة الإضافة:',
      'add_product_sheet_only': 'بطاقة منتج فقط\n(بدون مخزون)',
      'add_product_with_stock': 'مع مخزون ابتدائي\n(فاتورة تلقائية)',
      'form_sku': 'SKU *',
      'form_qr_code': 'رمز QR *',
      'form_product_name': 'اسم المنتج *',
      'form_category': 'الفئة',
      'form_stock_type': 'نوع المخزون',
      'form_purchase_price_ref': 'سعر الشراء المرجعي',
      'form_sale_price_ref': 'سعر البيع المرجعي',
      'cancel': 'إلغاء',
      'create': 'إنشاء',
      'error_sku_name_qr_required': 'SKU، الاسم ورمز QR إلزاميون',
      'error_sku_qr_used': 'خطأ — SKU أو رمز QR مستخدم من قبل',
      'toast_success': 'تم بنجاح',
      'toast_product_sheet_created': 'تم إنشاء بطاقة المنتج (المخزون 0، بانتظار الفاتورة)',
      'product_full_title': 'منتج مع مخزون ابتدائي',
      'product_full_subtitle': 'سيتم إنشاء فاتورة تعديل تلقائياً لتتبع هذا الدخول.',
      'form_supplier': 'المورّد',
      'form_origin_country': 'بلد المنشأ',
      'form_supplier_nif': 'الرقم الجبائي للمورّد (NIF)',
      'form_supplier_nis': 'رقم التعريف الإحصائي للمورّد (NIS)',
      'form_supplier_rc': 'السجل التجاري للمورّد (RC)',
      'form_initial_qty': 'الكمية الابتدائية *',
      'toast_product_invoice_created': 'تم إنشاء المنتج وفاتورة التعديل',
      'qr_lot_title': 'QR — الدفعة',
      'qr_print_instruction': 'اطبع هذه النافذة (Ctrl+P) وألصق رمز QR على صناديق الدفعة.',
      'error_title': 'خطأ',
      'filter_type_all': 'الكل',
      'filter_type_merchandise': 'بضاعة',
      'filter_type_raw_material': 'مادة أولية',
      'filter_type_finished_product': 'منتج تام',
      'filter_type_consumable': 'مواد استهلاكية',
      'po_new': 'أمر شراء جديد',
      'po_no_supplier': 'بدون مورّد',
      'po_articles_suffix': 'مادة/مواد',
      'po_supplier_colon': 'المورّد :',
      'po_type_colon': 'النوع :',
      'po_status_colon': 'الحالة :',
      'po_quantity_short': 'الكمية:',
      'po_price_estimate_short': 'السعر التقديري:',
      'po_designation': 'التسمية',
      'po_quantity': 'الكمية',
      'po_price_estimate': 'السعر التقديري',
      'po_supplier_optional': 'المورّد (اختياري)',
      'po_add_line': 'إضافة سطر',
      'po_created_title': 'تم الإنشاء',
      'po_created_prefix': 'أمر الشراء',
      'po_created_suffix': 'تم إنشاؤه',
      'pdf_stock_type_label': 'نوع المخزون :',
      'pdf_header_total': 'المجموع',
      'qr_print_page_title': 'رموز QR للطباعة',
      'qr_none_pending': 'لا يوجد رمز QR بانتظار الطباعة',
      'qr_lot_label': 'الدفعة:',
      'qr_location_label': 'الموقع:',
      'print_tooltip': 'طباعة',
      'remove_from_list_tooltip': 'إزالة من القائمة',
      'save_qr_dialog_title': 'حفظ رمز QR',
      'downloaded_title': 'تم التنزيل',
      'downloaded_msg_prefix': 'تم الحفظ في:',
      'download_button': 'تنزيل',
      'iot_zones_title': 'إنترنت الأشياء — المناطق',
      'iot_zone_label': 'المنطقة',
      'iot_all_zones': 'كل المناطق',
      'iot_no_data': 'لا توجد بيانات IoT مستلمة',
      'iot_level_critical': 'حرج',
      'iot_level_alert': 'تنبيه',
      'iot_level_manual': 'يدوي',
      'iot_level_normal': 'طبيعي',
      'iot_auto_resolved': '✓ تم الحل تلقائياً',
      'iot_needs_manual': '⚠ يتطلب تدخلاً يدوياً',
      'mark_all_read': 'تحديد الكل كمقروء',
      'th_title': 'العنوان',
      'th_message': 'الرسالة',
      'th_level': 'المستوى',
      'th_time': 'الوقت',
      'alert_level_warning': 'تحذير',
      'alert_level_info': 'معلومة',
      'read_label': 'مقروء',
      'new_label': 'جديد',
      'time_ago_minutes': 'قبل {n} د',
      'time_ago_hours': 'قبل {n} س',
      'approvals_page_title': 'تأكيد التغييرات',
      'approvals_gap_count': '{n} فارق (فوارق) في أمر الشراء بانتظار المصادقة',
      'examine_button': 'فحص',
      'approvals_no_pending': 'لا توجد طلبات بانتظار المعالجة',
      'gap_title_prefix': 'فارق — فاتورة #',
      'gap_detected_title': 'الفوارق المكتشفة',
      'gap_comment_title': 'التقرير',
      'reject_button': 'رفض',
      'approve_button': 'الموافقة',
      'rejected_title': 'مرفوضة',
      'rejected_msg': 'تم إلغاء الفاتورة',
      'approved_title': 'تمت الموافقة',
      'approved_msg': 'تستأنف الفاتورة مسارها الطبيعي',
      'invoice_hash_prefix': 'فاتورة #',
      'requested_by_prefix': 'طلب من',
      'gap_lock_notice': '🔒 قم أولاً بمعالجة فارق أمر الشراء لهذه الفاتورة (انظر أعلاه)',
      'view_invoice_button': 'عرض الفاتورة',
      'refuse_button': 'رفض',
      'refuse_reason_title': 'سبب الرفض',
      'refuse_reason_hint': 'لماذا ترفض هذا الطلب؟',
      'confirm_refuse_button': 'تأكيد الرفض',
      'ecart_fournisseur_different': '⚠ مورّد مختلف: مطلوب "{a}" ← مستلم "{b}"',
      'ecart_produit_non_commande': '⚠ تم استلام "{a}" دون طلبه (الكمية: {b})',
      'ecart_produit_manquant': '⚠ "{a}" مطلوب (الكمية: {b}) لكن لم يُستلم',
      'ecart_quantite_detail': 'الكمية المطلوبة {a} ← المستلمة {b}',
      'ecart_prix_detail': 'السعر التقديري {a} ← المستلم {b}',
      'ecart_generic_prefix': '⚠ "{a}" : {b}',
      'fab_page_title': 'التصنيع (وصفات الإنتاج والأوامر)',
      'fab_tab_recipes': 'وصفات الإنتاج (BOM)',
      'fab_tab_orders': 'أوامر التصنيع',
      'fab_new_recipe': 'وصفة جديدة',
      'fab_no_recipe': 'لا توجد وصفة معرّفة',
      'fab_product_hash_prefix': 'منتج #',
      'fab_per_unit_suffix': '(لكل وحدة)',
      'fab_loss_suffix': '— هدر',
      'fab_produce_from_recipe': 'إنتاج انطلاقاً من هذه الوصفة',
      'fab_new_recipe_dialog_title': 'وصفة جديدة (BOM)',
      'fab_finished_product_label': 'المنتج التام',
      'fab_component_label': 'المكوّن',
      'fab_qty_per_unit_label': 'الكمية / الوحدة',
      'fab_loss_percent_label': 'نسبة الهدر %',
      'fab_add_component': 'إضافة مكوّن',
      'fab_produce_dialog_title_prefix': 'إنتاج :',
      'fab_max_realisable_prefix': 'الكمية القصوى الممكن إنتاجها بالمخزون الحالي :',
      'fab_limited_by_prefix': 'محدود بـ :',
      'fab_qty_produced_label': 'الكمية المنتجة',
      'fab_location_optional_label': 'الموقع (اختياري)',
      'fab_lot_number_optional_label': 'رقم الدفعة (اختياري)',
      'fab_fabrication_date_label': 'تاريخ التصنيع',
      'fab_expiration_date_label': 'تاريخ انتهاء الصلاحية (موصى به)',
      'fab_not_defined_pick': 'غير محدد — اضغط للاختيار',
      'fab_confirm_production': 'تأكيد الإنتاج',
      'fab_production_recorded_title': 'تم تسجيل الإنتاج',
      'fab_lot_word': 'الدفعة',
      'fab_unit_cost_suffix': '— تكلفة الوحدة',
      'fab_no_orders': 'لا يوجد أمر تصنيع',
      'fab_quantity_colon': 'الكمية :',
      'fab_lot_colon': 'الدفعة :',
      'fab_per_unit_dzd_suffix': 'دج / وحدة',
      'report_stock_title': 'تقرير المخزون',
      'report_stock_desc': 'حالة كاملة للمخزون مع المستويات الحرجة وسجل التحركات.',
      'report_invoices_title': 'تقرير الفواتير',
      'report_invoices_desc': 'ملخص الفواتير المصادق عليها والمرفوضة والمعلقة خلال الفترة المحددة.',
      'report_alerts_title': 'تقرير التنبيهات',
      'report_alerts_desc': 'سجل كامل لتنبيهات النظام والمخزون الحرج والحالات الشاذة المكتشفة.',
      'generate_pdf_button': 'إنشاء PDF',
      'global_summary_title': 'الملخص العام',
      'stat_total_products': 'إجمالي المنتجات',
      'stat_critical_products': 'المنتجات الحرجة',
      'stat_validated_invoices': 'الفواتير المصادق عليها',
      'stat_system_availability': 'توفر النظام',
      'pdf_stock_report_title': 'SYNEXIA — تقرير المخزون',
      'pdf_generated_on_prefix': 'تم الإنشاء في',
      'pdf_header_product': 'المنتج',
      'pdf_header_stock_available': 'المخزون المتاح',
      'pdf_header_value_dzd': 'القيمة (دج)',
      'pdf_total_stock_value_prefix': 'إجمالي قيمة المخزون:',
      'pdf_invoices_report_title': 'SYNEXIA — تقرير الفواتير',
      'pdf_header_supplier': 'المورّد',
      'pdf_header_date': 'التاريخ',
      'pdf_status_validated': 'مصادق عليها',
      'pdf_status_rejected': 'مرفوضة',
      'pdf_status_pending': 'قيد الانتظار',
      'pdf_validated_count_prefix': 'المصادق عليها:',
      'pdf_pending_count_prefix': 'قيد الانتظار:',
      'pdf_rejected_count_prefix': 'المرفوضة:',
      'pdf_alerts_report_title': 'SYNEXIA — تقرير التنبيهات',
      'pdf_unread_label': 'غير مقروء',
      'hist_page_title': 'سجل المنتج',
      'hist_search_hint': 'ابحث عن منتج بالاسم أو SKU...',
      'hist_search_empty': 'ابحث عن منتج لعرض سجله',
      'hist_avg_purchase_price': 'متوسط سعر الشراء',
      'hist_avg_sale_price': 'متوسط سعر البيع',
      'hist_margin': 'الهامش',
      'hist_lot_distribution_title': 'توزيع المخزون حسب الدفعة',
      'hist_no_active_lot': 'لا توجد دفعة نشطة',
      'hist_units_suffix': 'وحدة',
      'hist_expires_prefix': 'ينتهي:',
      'hist_invoice_word': 'فاتورة',
      'hist_price_evolution_title': 'تطور سعر الشراء',
      'hist_all_invoices_title': 'كل الفواتير — هذا المنتج',
      'hist_no_invoice_yet': 'لا توجد فاتورة لهذا المنتج حالياً',
      'hist_no_validated_purchase': 'لا يوجد شراء مصادق عليه مسجّل لهذا المنتج',
      'hist_single_purchase_prefix': 'عملية شراء واحدة مصادق عليها',
      'hist_chart_appears_note': 'سيظهر الرسم البياني عند وجود عمليتي شراء أو أكثر.',
      'hist_status_accepted': 'مقبولة',
      'hist_type_sale': 'بيع',
      'hist_type_purchase': 'شراء',
      'sec_page_title': 'الأمان',
      'sec_access_control_title': 'مراقبة الدخول — التعرف على الوجه',
      'sec_th_person': 'الشخص',
      'sec_th_zone': 'المنطقة',
      'sec_th_confidence': 'الثقة',
      'sec_th_access': 'الدخول',
      'sec_no_face_event': 'لا يوجد حدث تعرف على الوجه',
      'sec_alerts_title': 'تنبيهات الأمان',
      'sec_no_security_alert': 'لا توجد تنبيهات أمنية',
      'sec_unknown_person': 'غير معروف',
      'sec_access_ok': '✓ مسموح',
      'sec_access_denied': '✗ مرفوض',
      'settings_appearance_title': 'المظهر',
      'settings_theme_label': 'السمة',
      'settings_language_label': 'اللغة',
      'settings_account_title': 'الحساب',
      'settings_connection_title': 'اتصال الخادم',
      'settings_connected_local': 'متصل بالخادم المحلي',
      'setup_fill_all_fields': 'يرجى ملء جميع الحقول',
      'setup_passwords_mismatch': 'كلمتا المرور غير متطابقتين',
      'setup_password_too_short': 'كلمة المرور قصيرة جداً (6 أحرف على الأقل)',
      'setup_already_done': 'تم الإعداد مسبقاً',
      'setup_password_too_short_server': 'كلمة المرور قصيرة جداً',
      'setup_server_error': 'خطأ في الخادم',
      'setup_initial_config_title': 'الإعداد الأولي',
      'setup_initial_config_desc': 'أنشئ حساب مسؤول المخزن.\nهذه الخطوة تظهر مرة واحدة فقط.',
      'setup_full_name_label': 'الاسم الكامل',
      'setup_confirm_password_label': 'تأكيد كلمة المرور',
      'setup_create_admin_button': 'إنشاء حساب المسؤول',
      'gate_connecting': 'جارٍ الاتصال بالخادم...',
      'setup_back_button': 'رجوع',
      'setup_server_config_title': 'إعداد الخادم',
      'setup_server_config_desc': 'أدخل عنوان الخادم المحلي لمخزنك',
      'setup_ip_label': 'عنوان IP',
      'setup_port_label': 'المنفذ',
      'setup_server_unreachable': 'تعذر الوصول إلى الخادم. تحقق من العنوان ومن تشغيل الخادم.',
      'sa_title': 'المشرف العام',
      'sa_zone_notice': 'منطقة مخصصة لمسؤول النظام.\nتتيح هذه المنطقة إدارة المستخدمين وصلاحيات الوصول.',
      'sa_system_password_label': 'كلمة مرور النظام',
      'sa_password_hint': 'أدخل كلمة مرور المشرف العام',
      'sa_wrong_password': 'كلمة المرور غير صحيحة',
      'sa_access_button': 'دخول',
      'sa_users_management_title': 'إدارة المستخدمين',
      'sa_add_user_title': 'إضافة مستخدم',
      'sa_username_exists': 'اسم المستخدم مستخدم من قبل',
      'sa_check_fields_error': 'خطأ — تحقق من الحقول',
      'sa_role_label': 'الدور',
      'sa_reset_password_title_prefix': 'إعادة تعيين كلمة المرور —',
      'sa_new_password_label': 'كلمة المرور الجديدة',
      'sa_role_admin_short': 'مشرف',
      'sa_th_name': 'الاسم',
      'sa_th_username': 'اسم المستخدم',
      'sa_th_role': 'الدور',
      'sa_deactivate_tooltip': 'تعطيل',
      'sa_activate_tooltip': 'تفعيل',
      'sa_reset_password_tooltip': 'إعادة تعيين كلمة المرور',
      'inv_page_actions_new_invoice': 'فاتورة جديدة',
      'inv_banner_mismatch_count': '{n} فاتورة (فواتير) لا تطابق أمر الشراء',
      'inv_view_and_report': 'عرض وإبلاغ',
      'inv_banner_ocr_count': '{n} فاتورة (فواتير) OCR بانتظار التحقق',
      'inv_verify_button': 'تحقق',
      'inv_banner_pending_mod_count': '{n} طلب (طلبات) تعديل بانتظار الموافقة',
      'inv_pending_admin': 'بانتظار المسؤول',
      'inv_banner_to_correct_count': '{n} فاتورة (فواتير) للتصحيح — تمت الموافقة على طلبك',
      'inv_correct_now': 'صحّح الآن',
      'th_authentication': 'التوثيق',
      'stamp_label': 'الختم',
      'signature_short_label': 'التوقيع',
      'inv_validate_button': 'مصادقة',
      'motif_rejet_title': 'سبب الرفض',
      'motif_rejet_hint': 'اشرح سبب رفض هذه الفاتورة...',
      'confirm_reject_button': 'تأكيد الرفض',
      'invoice_rejected_toast': 'تم رفض الفاتورة',
      'filter_all_types': 'كل الأنواع',
      'type_purchases': 'المشتريات',
      'type_sales': 'المبيعات',
      'status_validated_plural': 'مصادق عليها',
      'status_rejected_plural': 'مرفوضة',
      'new_manual_invoice_title': 'فاتورة يدوية جديدة',
      'manual_invoice_notice': 'الفاتورة المُنشأة يدوياً تبقى بانتظار التحقق من طرف مسؤول.',
      'type_label': 'النوع',
      'category_label': 'الفئة',
      'po_none': 'لا شيء',
      'po_reserved_by_you_prefix': 'أمر الشراء #',
      'po_reserved_by_you_suffix': '(محجوز من طرفك)',
      'po_optional_label': 'أمر الشراء (اختياري)',
      'supplier_client_label': 'المورّد / العميل',
      'nif_optional_label': 'NIF (اختياري)',
      'nis_optional_label': 'NIS (اختياري)',
      'rc_optional_label': 'RC (اختياري)',
      'invoice_date_label': 'تاريخ الفاتورة',
      'amount_ht_label': 'المبلغ دون الضريبة',
      'tva_label': 'الضريبة',
      'amount_ttc_label': 'المبلغ شامل الضريبة',
      'reason_required_label': 'السبب (إلزامي)',
      'reason_hint': 'لماذا الإدخال اليدوي؟',
      'articles_title': 'المواد',
      'add_article_button': 'إضافة مادة',
      'po_unavailable_title': 'غير متاح',
      'po_unavailable_msg': 'تم أخذ أمر الشراء هذا من طرف مستخدم آخر للتو',
      'problem_optional_label': 'المشكلة الملاحظة (اختياري)',
      'problem_hint': 'اترك الحقول المعنية فارغة، واشرح هنا بدقة ما هو ناقص أو غير صحيح.',
      'report_required_title': 'التقرير مطلوب',
      'report_required_msg': 'اشرح المشكلة قبل إرسال طلب التعديل',
      'reason_required_title': 'السبب مطلوب',
      'reason_required_msg': 'يجب ملء حقل "السبب (إلزامي)"',
      'supplier_required_title': 'المورّد مطلوب',
      'supplier_required_msg': 'يجب ملء حقل "المورّد / العميل"',
      'qty_missing_title': 'الكمية ناقصة',
      'qty_missing_msg': 'يجب أن تكون كمية كل مادة أكبر من 0',
      'send_modification_request_button': 'إرسال + طلب تعديل',
      'invoice_sent_title': 'تم إرسال الفاتورة',
      'invoice_sent_msg': 'في انتظار تأكيد التغيير — يجب على مسؤول المصادقة على طلبك',
      'send_failed_title': 'فشل الإرسال',
      'send_failed_msg': 'أعد المحاولة.',
      'send_button': 'إرسال',
      'invoice_created_title': 'تم إنشاء الفاتورة',
      'invoice_created_msg': 'بانتظار التحقق من طرف مسؤول',
      'new_product_switch_label': 'منتج غير موجود (جديد)',
      'search_existing_product_hint': 'ابحث عن منتج موجود...',
      'lot_location_prefilled_label': 'موقع هذه الدفعة (معبّأ مسبقاً، قابل للتعديل)',
      'new_product_name_label': 'اسم المنتج الجديد',
      'barcode_label': 'الباركود',
      'unit_label': 'الوحدة (كغ، لتر، قطعة...)',
      'critical_threshold_label': 'الحد الحرج',
      'location_label': 'الموقع',
      'designation_retained_label': 'التسمية المعتمدة',
      'qty_star_label': 'الكمية *',
      'required_label': 'مطلوب',
      'line_total_price_label': 'السعر الإجمالي (كما هو مكتوب على الفاتورة)',
      'unit_price_calc_label': 'سعر الوحدة (محسوب، قابل للتعديل)',
      'sale_price_optional_label': 'سعر البيع (اختياري)',
      'manufacturing_label': 'التصنيع',
      'expiration_label': 'انتهاء الصلاحية',
      'manufacturer_lot_label': 'رقم دفعة الصانع (إن كان مطبوعاً على المنتج)',
      'correct_invoice_title_prefix': 'تصحيح الفاتورة #',
      'corrected_articles_title': 'المواد المصححة',
      'send_correction_button': 'إرسال التصحيح',
      'invoice_corrected_title': 'تم تصحيح الفاتورة',
      'invoice_corrected_msg': 'الفاتورة أصبحت مرة أخرى بانتظار التحقق',
      'correction_failed_title': 'فشل',
      'correction_failed_msg': 'تعذر إرسال التصحيح. أعد المحاولة.',
      'verify_ocr_title_prefix': 'التحقق من فاتورة OCR #',
      'ocr_detected_articles_title': 'المواد المكتشفة بواسطة OCR (للقراءة فقط)',
      'pu_label': ' — سعر الوحدة:',
      'exp_inline_label': ' — الانتهاء:',
      'new_product_location_hint': 'الموقع (منتج جديد — غير موفر من OCR)',
      'report_error_button': 'الإبلاغ عن خطأ',
      'save_locations_button': 'حفظ المواقع',
      'locations_saved_title': 'تم حفظ المواقع',
      'locations_saved_msg': 'يمكنك الآن تأكيد الفاتورة',
      'confirm_button_word': 'تأكيد',
      'invoice_confirmed_title': 'تم تأكيد الفاتورة',
      'invoice_confirmed_msg': 'هي الآن بانتظار مصادقة المسؤول',
      'gaps_detected_title_prefix': 'فوارق مكتشفة — فاتورة #',
      'your_comment_label': 'تعليقك للمسؤول',
      'send_to_admin_button': 'إرسال إلى المسؤول',
      'sent_title': 'تم الإرسال',
      'sent_awaiting_admin_msg': 'بانتظار قرار المسؤول',
      'report_error_title': 'الإبلاغ عن خطأ',
      'describe_error_label': 'صف الخطأ الملاحظ',
      'send_request_button': 'إرسال الطلب',
      'request_sent_title': 'تم إرسال الطلب',
      'request_sent_msg': 'بانتظار موافقة المسؤول',
      'new_invoice_title': 'فاتورة جديدة',
      'from_phone_ocr_title': 'من هاتف (OCR)',
      'from_phone_ocr_subtitle': 'يتطلب تطبيق الهاتف المحمول',
      'manual_entry_title': 'إدخال يدوي',
      'manual_entry_subtitle': 'املأ الفاتورة مباشرة هنا',
      'invoice_category_title': 'فئة الفاتورة',
      'po_choice_title': 'أمر الشراء (اختياري)',
      'none_word': 'لا شيء',
      'receive_from_phone_title': 'الاستلام من هاتف',
      'code_expired_title': 'انتهت صلاحية الرمز',
      'generate_new_code_button': 'إنشاء رمز جديد',
      'server_connection_error': 'خطأ في الاتصال بالخادم',
      'expires_in_prefix': 'ينتهي خلال',
      'mobile_instructions': 'من تطبيق الهاتف: أدخل هذا الرمز أو امسح رمز QR.',
      'phone_connected_msg': 'تم توصيل الهاتف — بانتظار الصورة...',
      'invoice_received_msg': 'تم استلام الفاتورة!',
      'later_button': 'لاحقاً',
      'verify_invoice_button': 'التحقق من الفاتورة',
      'sale_word': 'بيع',
      'manual_adjustment_word': 'تعديل يدوي',
      'created_manually_label': 'أُنشئت يدوياً',
      'financial_summary_title': 'الملخص المالي',
      'ppa_label': 'PPA',
      'incoherence_detected_msg': 'تم اكتشاف تضارب بين المبلغ دون الضريبة ومجموع الأسطر.',
      'products_count_title': 'المنتجات',
      'add_short_button': '+ إضافة',
      'no_product_in_invoice': 'لم يُضف أي منتج لهذه الفاتورة',
      'existing_tag': '✅ موجود',
      'invoice_validated_success_msg': 'تمت مصادقة الفاتورة — تم تحديث المخزون',
      'add_product_to_invoice_title': 'إضافة منتج إلى الفاتورة',
      'quantity_word': 'الكمية',
      'line_total_invoice_label': 'السعر الإجمالي (الفاتورة)',
      'sale_price_optional_label2': 'سعر البيع (اختياري)',
      'manufacturing_date_ymd_label': 'تاريخ التصنيع (YYYY-MM-DD)',
      'expiration_date_ymd_label': 'تاريخ الانتهاء (YYYY-MM-DD)',
      'rejection_reason_title': 'سبب الرفض',
      'manual_creation_reason_label': 'السبب (إنشاء يدوي)',
      'invoice_cancelled': 'ملغاة',
      'invoice_amount_tva': 'مبلغ الضريبة',
      'invoices_empty': 'لا توجد فاتورة',
      'th_invoice_number': 'رقم الفاتورة',
      'th_supplier_upper': 'المورّد',
      'th_date_upper': 'التاريخ',
      'th_amount_ht_upper': 'المبلغ دون الضريبة',
      'th_amount_ttc_upper': 'المبلغ شامل الضريبة',
      'th_actions': 'الإجراءات',
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
      'nav_dashboard': 'Dashboard',
      'nav_manufacturing': 'Manufacturing',
      'nav_purchase_orders': 'Purchase Orders',
      'nav_qr_codes': 'QR Codes',
      'nav_approvals': 'Approvals',
      'nav_iot': 'IoT',
      'nav_security': 'Security',
      'nav_reports': 'Reports',
      'nav_admin': 'Admin',
      'nav_settings': 'Settings',
      'role_admin': 'Administrator',
      'role_agent_kiosk': 'Kiosk Agent',
      'logout': 'Logout',
      'login_subtitle': 'Access restricted to authorized users',
      'login_username_hint': 'Enter your username',
      'login_password_hint': 'Enter your password',
      'login_admin_access': 'System administrator access',
      'app_tagline': 'Warehouse Management System',
      'feature_stock_realtime': 'Real-time stock management',
      'feature_invoice_validation': 'Smart invoice validation',
      'feature_alerts_instant': 'Instant alerts',
      'feature_reports_analytics': 'Reports and analytics',
      'dashboard_refresh': 'Refresh',
      'kpi_entries_today': 'Entries / today',
      'kpi_exits_today': 'Exits / today',
      'kpi_active_alerts': 'Active alerts',
      'kpi_unread': 'unread',
      'kpi_pending_invoices': 'Pending invoices',
      'kpi_total_stock_value': 'Total stock value',
      'chart_movements_title': 'MOVEMENTS — LAST 7 DAYS',
      'chart_no_data': 'No data',
      'recent_alerts_title': 'RECENT ALERTS',
      'no_alerts': 'No alerts',
      'critical_stock_title': 'CRITICAL STOCK',
      'all_normal': 'Everything normal',
      'recent_movements_title': 'RECENT MOVEMENTS',
      'no_movements': 'No movements',
      'table_product': 'PRODUCT',
      'table_qty': 'QTY',
      'table_type': 'TYPE',
      'movement_entry': 'Entry',
      'movement_exit': 'Exit',
      'search_product_hint': 'SKU, name, reference...',
      'filter_all_status': 'All statuses',
      'add_button': 'Add',
      'th_sku': 'SKU',
      'th_category': 'CATEGORY',
      'th_stock_available': 'AVAILABLE STOCK',
      'th_value': 'VALUE',
      'th_status': 'STATUS',
      'no_product': 'No product',
      'status_low_short': 'Low',
      'filter_category_hint': 'Category',
      'filter_all_categories': 'All categories',
      'detail_stock_physical': 'Physical stock',
      'detail_stock_available': 'Available stock',
      'detail_stock_reserved': 'Reserved stock',
      'detail_critical_threshold': 'Critical threshold',
      'detail_purchase_price': 'Purchase price',
      'detail_sale_price': 'Sale price',
      'detail_pmp': 'WAC',
      'detail_stock_value': 'Stock value',
      'detail_tva': 'VAT',
      'detail_origin_country': 'Country of origin',
      'view_price_history': 'View price history',
      'lots_title': 'LOTS',
      'lot_available': 'available',
      'lot_expiry': 'Exp:',
      'print_lot_qr_tooltip': 'Print QR for this lot',
      'extra_fields_title': 'EXTRA FIELDS',
      'add_product_title': 'Add a product',
      'add_product_choose_mode': 'Choose the add mode:',
      'add_product_sheet_only': 'Product sheet only\n(no stock)',
      'add_product_with_stock': 'With initial stock\n(automatic invoice)',
      'form_sku': 'SKU *',
      'form_qr_code': 'QR Code *',
      'form_product_name': 'Product name *',
      'form_category': 'Category',
      'form_stock_type': 'Stock type',
      'form_purchase_price_ref': 'Reference purchase price',
      'form_sale_price_ref': 'Reference sale price',
      'cancel': 'Cancel',
      'create': 'Create',
      'error_sku_name_qr_required': 'SKU, Name and QR Code are required',
      'error_sku_qr_used': 'Error — SKU or QR Code already in use',
      'toast_success': 'Success',
      'toast_product_sheet_created': 'Product sheet created (stock at 0, awaiting invoice)',
      'product_full_title': 'Product with initial stock',
      'product_full_subtitle': 'An adjustment invoice will be created automatically to track this entry.',
      'form_supplier': 'Supplier',
      'form_origin_country': 'Country of origin',
      'form_supplier_nif': 'Supplier tax ID (NIF)',
      'form_supplier_nis': 'Supplier statistical ID (NIS)',
      'form_supplier_rc': 'Supplier trade register (RC)',
      'form_initial_qty': 'Initial quantity *',
      'toast_product_invoice_created': 'Product + adjustment invoice created',
      'qr_lot_title': 'QR — Lot',
      'qr_print_instruction': 'Print this window (Ctrl+P) and stick the QR on the lot boxes.',
      'error_title': 'Error',
      'filter_type_all': 'All',
      'filter_type_merchandise': 'Merchandise',
      'filter_type_raw_material': 'Raw material',
      'filter_type_finished_product': 'Finished product',
      'filter_type_consumable': 'Consumable',
      'po_new': 'New purchase order',
      'po_no_supplier': 'No supplier',
      'po_articles_suffix': 'item(s)',
      'po_supplier_colon': 'Supplier:',
      'po_type_colon': 'Type:',
      'po_status_colon': 'Status:',
      'po_quantity_short': 'Qty:',
      'po_price_estimate_short': 'Est. price:',
      'po_designation': 'Designation',
      'po_quantity': 'Quantity',
      'po_price_estimate': 'Estimated price',
      'po_supplier_optional': 'Supplier (optional)',
      'po_add_line': 'Add a line',
      'po_created_title': 'Created',
      'po_created_prefix': 'Purchase order',
      'po_created_suffix': 'created',
      'pdf_stock_type_label': 'Stock type:',
      'pdf_header_total': 'Total',
      'qr_print_page_title': 'QR codes to print',
      'qr_none_pending': 'No QR code pending printing',
      'qr_lot_label': 'Lot:',
      'qr_location_label': 'Location:',
      'print_tooltip': 'Print',
      'remove_from_list_tooltip': 'Remove from list',
      'save_qr_dialog_title': 'Save QR',
      'downloaded_title': 'Downloaded',
      'downloaded_msg_prefix': 'Saved:',
      'download_button': 'Download',
      'iot_zones_title': 'IoT — Zones',
      'iot_zone_label': 'Zone',
      'iot_all_zones': 'All zones',
      'iot_no_data': 'No IoT data received',
      'iot_level_critical': 'CRITICAL',
      'iot_level_alert': 'ALERT',
      'iot_level_manual': 'MANUAL',
      'iot_level_normal': 'NORMAL',
      'iot_auto_resolved': '✓ Automatically resolved',
      'iot_needs_manual': '⚠ Requires manual intervention',
      'mark_all_read': 'Mark all read',
      'th_title': 'TITLE',
      'th_message': 'MESSAGE',
      'th_level': 'LEVEL',
      'th_time': 'TIME',
      'alert_level_warning': 'Warning',
      'alert_level_info': 'Info',
      'read_label': 'Read',
      'new_label': 'New',
      'time_ago_minutes': '{n} min ago',
      'time_ago_hours': '{n}h ago',
      'approvals_page_title': 'Change confirmation',
      'approvals_gap_count': '{n} purchase order discrepancy(ies) to validate',
      'examine_button': 'Examine',
      'approvals_no_pending': 'No pending requests',
      'gap_title_prefix': 'Discrepancy — Invoice #',
      'gap_detected_title': 'DISCREPANCIES DETECTED',
      'gap_comment_title': 'COMMENT',
      'reject_button': 'Reject',
      'approve_button': 'Approve',
      'rejected_title': 'Rejected',
      'rejected_msg': 'The invoice has been cancelled',
      'approved_title': 'Approved',
      'approved_msg': 'The invoice resumes its normal course',
      'invoice_hash_prefix': 'Invoice #',
      'requested_by_prefix': 'Requested by',
      'gap_lock_notice': '🔒 First resolve the purchase order discrepancy for this invoice (see above)',
      'view_invoice_button': 'View invoice',
      'refuse_button': 'Decline',
      'refuse_reason_title': 'Reason for refusal',
      'refuse_reason_hint': 'Why decline this request?',
      'confirm_refuse_button': 'Confirm refusal',
      'ecart_fournisseur_different': '⚠ Different supplier: ordered "{a}" → received "{b}"',
      'ecart_produit_non_commande': '⚠ "{a}" received but not ordered (qty: {b})',
      'ecart_produit_manquant': '⚠ "{a}" ordered (qty: {b}) but not received',
      'ecart_quantite_detail': 'ordered quantity {a} → received {b}',
      'ecart_prix_detail': 'estimated price {a} → received {b}',
      'ecart_generic_prefix': '⚠ "{a}": {b}',
      'fab_page_title': 'Manufacturing (BOM & Orders)',
      'fab_tab_recipes': 'Recipes (BOM)',
      'fab_tab_orders': 'Manufacturing orders',
      'fab_new_recipe': 'New recipe',
      'fab_no_recipe': 'No recipe defined',
      'fab_product_hash_prefix': 'Product #',
      'fab_per_unit_suffix': '(per unit)',
      'fab_loss_suffix': '— loss',
      'fab_produce_from_recipe': 'Produce from this recipe',
      'fab_new_recipe_dialog_title': 'New recipe (BOM)',
      'fab_finished_product_label': 'Finished product',
      'fab_component_label': 'Component',
      'fab_qty_per_unit_label': 'Quantity / unit',
      'fab_loss_percent_label': '% loss',
      'fab_add_component': 'Add a component',
      'fab_produce_dialog_title_prefix': 'Produce:',
      'fab_max_realisable_prefix': 'Maximum quantity achievable with current stock:',
      'fab_limited_by_prefix': 'limited by:',
      'fab_qty_produced_label': 'Quantity produced',
      'fab_location_optional_label': 'Location (optional)',
      'fab_lot_number_optional_label': 'Lot number (optional)',
      'fab_fabrication_date_label': 'Manufacturing date',
      'fab_expiration_date_label': 'Expiration date (recommended)',
      'fab_not_defined_pick': 'Not set — tap to choose',
      'fab_confirm_production': 'Confirm production',
      'fab_production_recorded_title': 'Production recorded',
      'fab_lot_word': 'Lot',
      'fab_unit_cost_suffix': '— unit cost',
      'fab_no_orders': 'No manufacturing order',
      'fab_quantity_colon': 'Quantity:',
      'fab_lot_colon': 'Lot:',
      'fab_per_unit_dzd_suffix': 'DZD / unit',
      'report_stock_title': 'Stock report',
      'report_stock_desc': 'Complete inventory status with critical levels and movement history.',
      'report_invoices_title': 'Invoices report',
      'report_invoices_desc': 'Summary of validated, rejected and pending invoices over the selected period.',
      'report_alerts_title': 'Alerts report',
      'report_alerts_desc': 'Complete log of system alerts, critical stock and detected anomalies.',
      'generate_pdf_button': 'Generate PDF',
      'global_summary_title': 'GLOBAL SUMMARY',
      'stat_total_products': 'Total products',
      'stat_critical_products': 'Critical products',
      'stat_validated_invoices': 'Validated invoices',
      'stat_system_availability': 'System availability',
      'pdf_stock_report_title': 'SYNEXIA — Stock Report',
      'pdf_generated_on_prefix': 'Generated on',
      'pdf_header_product': 'Product',
      'pdf_header_stock_available': 'Available stock',
      'pdf_header_value_dzd': 'Value (DZD)',
      'pdf_total_stock_value_prefix': 'Total stock value:',
      'pdf_invoices_report_title': 'SYNEXIA — Invoices Report',
      'pdf_header_supplier': 'Supplier',
      'pdf_header_date': 'Date',
      'pdf_status_validated': 'Validated',
      'pdf_status_rejected': 'Rejected',
      'pdf_status_pending': 'Pending',
      'pdf_validated_count_prefix': 'Validated:',
      'pdf_pending_count_prefix': 'Pending:',
      'pdf_rejected_count_prefix': 'Rejected:',
      'pdf_alerts_report_title': 'SYNEXIA — Alerts Report',
      'pdf_unread_label': 'Unread',
      'hist_page_title': 'Product History',
      'hist_search_hint': 'Search a product by name or SKU...',
      'hist_search_empty': 'Search a product to see its history',
      'hist_avg_purchase_price': 'Average purchase price',
      'hist_avg_sale_price': 'Average sale price',
      'hist_margin': 'Margin',
      'hist_lot_distribution_title': 'STOCK DISTRIBUTION BY LOT',
      'hist_no_active_lot': 'No active lot',
      'hist_units_suffix': 'units',
      'hist_expires_prefix': 'Expires:',
      'hist_invoice_word': 'Invoice',
      'hist_price_evolution_title': 'PURCHASE PRICE EVOLUTION',
      'hist_all_invoices_title': 'ALL INVOICES — THIS PRODUCT',
      'hist_no_invoice_yet': 'No invoice for this product yet',
      'hist_no_validated_purchase': 'No validated purchase recorded for this product',
      'hist_single_purchase_prefix': 'One validated purchase',
      'hist_chart_appears_note': 'The chart will appear once there are 2 or more purchases.',
      'hist_status_accepted': 'Accepted',
      'hist_type_sale': 'Sale',
      'hist_type_purchase': 'Purchase',
      'sec_page_title': 'Security',
      'sec_access_control_title': 'ACCESS CONTROL — FACE ID',
      'sec_th_person': 'PERSON',
      'sec_th_zone': 'ZONE',
      'sec_th_confidence': 'CONFIDENCE',
      'sec_th_access': 'ACCESS',
      'sec_no_face_event': 'No Face ID event',
      'sec_alerts_title': 'SECURITY ALERTS',
      'sec_no_security_alert': 'No security alert',
      'sec_unknown_person': 'Unknown',
      'sec_access_ok': '✓ OK',
      'sec_access_denied': '✗ Denied',
      'settings_appearance_title': 'APPEARANCE',
      'settings_theme_label': 'Theme',
      'settings_language_label': 'Language',
      'settings_account_title': 'ACCOUNT',
      'settings_connection_title': 'SERVER CONNECTION',
      'settings_connected_local': 'Connected to local server',
      'setup_fill_all_fields': 'Please fill in all fields',
      'setup_passwords_mismatch': 'Passwords do not match',
      'setup_password_too_short': 'Password too short (minimum 6 characters)',
      'setup_already_done': 'Setup already done',
      'setup_password_too_short_server': 'Password too short',
      'setup_server_error': 'Server error',
      'setup_initial_config_title': 'Initial setup',
      'setup_initial_config_desc': 'Create the administrator account for your warehouse.\nThis step will only appear once.',
      'setup_full_name_label': 'Full name',
      'setup_confirm_password_label': 'Confirm password',
      'setup_create_admin_button': 'Create administrator account',
      'gate_connecting': 'Connecting to server...',
      'setup_back_button': 'Back',
      'setup_server_config_title': 'Server setup',
      'setup_server_config_desc': 'Enter your warehouse local server address',
      'setup_ip_label': 'IP address',
      'setup_port_label': 'Port',
      'setup_server_unreachable': 'Unable to reach the server. Check the address and that the server is running.',
      'sa_title': 'Super Admin',
      'sa_zone_notice': 'Zone reserved for the system administrator.\nThis zone allows managing users and access rights.',
      'sa_system_password_label': 'System password',
      'sa_password_hint': 'Enter the Super Admin password',
      'sa_wrong_password': 'Incorrect password',
      'sa_access_button': 'Access',
      'sa_users_management_title': 'User management',
      'sa_add_user_title': 'Add a user',
      'sa_username_exists': 'Username already in use',
      'sa_check_fields_error': 'Error — check the fields',
      'sa_role_label': 'Role',
      'sa_reset_password_title_prefix': 'Reset password —',
      'sa_new_password_label': 'New password',
      'sa_role_admin_short': 'Admin',
      'sa_th_name': 'NAME',
      'sa_th_username': 'USERNAME',
      'sa_th_role': 'ROLE',
      'sa_deactivate_tooltip': 'Deactivate',
      'sa_activate_tooltip': 'Activate',
      'sa_reset_password_tooltip': 'Reset password',
      'inv_page_actions_new_invoice': 'New invoice',
      'inv_banner_mismatch_count': '{n} invoice(s) do not match the purchase order',
      'inv_view_and_report': 'View and report',
      'inv_banner_ocr_count': '{n} OCR invoice(s) to verify',
      'inv_verify_button': 'Verify',
      'inv_banner_pending_mod_count': '{n} modification request(s) pending approval',
      'inv_pending_admin': 'Pending admin',
      'inv_banner_to_correct_count': '{n} invoice(s) to correct — your request was approved',
      'inv_correct_now': 'Correct now',
      'th_authentication': 'AUTHENTICATION',
      'stamp_label': 'Stamp',
      'signature_short_label': 'Sign.',
      'inv_validate_button': 'Validate',
      'motif_rejet_title': 'Reason for rejection',
      'motif_rejet_hint': 'Explain why this invoice is rejected...',
      'confirm_reject_button': 'Confirm rejection',
      'invoice_rejected_toast': 'Invoice rejected',
      'filter_all_types': 'All types',
      'type_purchases': 'Purchases',
      'type_sales': 'Sales',
      'status_validated_plural': 'Validated',
      'status_rejected_plural': 'Rejected',
      'new_manual_invoice_title': 'New manual invoice',
      'manual_invoice_notice': 'A manually created invoice stays pending until verified by an administrator.',
      'type_label': 'Type',
      'category_label': 'Category',
      'po_none': 'None',
      'po_reserved_by_you_prefix': 'Purchase order #',
      'po_reserved_by_you_suffix': '(reserved by you)',
      'po_optional_label': 'Purchase order (optional)',
      'supplier_client_label': 'Supplier / Customer',
      'nif_optional_label': 'NIF (optional)',
      'nis_optional_label': 'NIS (optional)',
      'rc_optional_label': 'RC (optional)',
      'invoice_date_label': 'Invoice date',
      'amount_ht_label': 'Amount excl. tax',
      'tva_label': 'VAT',
      'amount_ttc_label': 'Amount incl. tax',
      'reason_required_label': 'Reason (required)',
      'reason_hint': 'Why a manual entry?',
      'articles_title': 'ITEMS',
      'add_article_button': 'Add an item',
      'po_unavailable_title': 'Unavailable',
      'po_unavailable_msg': 'This purchase order was just taken by another user',
      'problem_optional_label': 'Problem noted (optional)',
      'problem_hint': 'Leave the relevant fields empty, and explain here precisely what is missing or incorrect.',
      'report_required_title': 'Report required',
      'report_required_msg': 'Explain the problem before sending a modification request',
      'reason_required_title': 'Reason required',
      'reason_required_msg': 'The "Reason (required)" field must be filled in',
      'supplier_required_title': 'Supplier required',
      'supplier_required_msg': 'The "Supplier / Customer" field must be filled in',
      'qty_missing_title': 'Missing quantity',
      'qty_missing_msg': 'Each item must have a quantity greater than 0',
      'send_modification_request_button': 'Send + modification request',
      'invoice_sent_title': 'Invoice sent',
      'invoice_sent_msg': 'Change confirmation — an administrator must validate your request',
      'send_failed_title': 'Sending failed',
      'send_failed_msg': 'Please try again.',
      'send_button': 'Send',
      'invoice_created_title': 'Invoice created',
      'invoice_created_msg': 'Pending verification by an administrator',
      'new_product_switch_label': 'Nonexistent product (new)',
      'search_existing_product_hint': 'Search an existing product...',
      'lot_location_prefilled_label': 'Location of this lot (prefilled, editable)',
      'new_product_name_label': 'New product name',
      'barcode_label': 'Barcode',
      'unit_label': 'Unit (kg, liter, piece...)',
      'critical_threshold_label': 'Critical threshold',
      'location_label': 'Location',
      'designation_retained_label': 'Retained designation',
      'qty_star_label': 'Qty *',
      'required_label': 'Required',
      'line_total_price_label': 'Total price (as written on the invoice)',
      'unit_price_calc_label': 'Unit price (calculated, editable)',
      'sale_price_optional_label': 'Sale price (optional)',
      'manufacturing_label': 'Manufacturing',
      'expiration_label': 'Expiration',
      'manufacturer_lot_label': 'Manufacturer lot number (if printed on the product)',
      'correct_invoice_title_prefix': 'Correct invoice #',
      'corrected_articles_title': 'CORRECTED ITEMS',
      'send_correction_button': 'Send correction',
      'invoice_corrected_title': 'Invoice corrected',
      'invoice_corrected_msg': 'The invoice is pending verification again',
      'correction_failed_title': 'Failed',
      'correction_failed_msg': 'The correction could not be sent. Please try again.',
      'verify_ocr_title_prefix': 'Verify OCR invoice #',
      'ocr_detected_articles_title': 'ITEMS DETECTED BY OCR (read-only)',
      'pu_label': ' — Unit price:',
      'exp_inline_label': ' — Exp:',
      'new_product_location_hint': 'Location (new product — not provided by OCR)',
      'report_error_button': 'Report an error',
      'save_locations_button': 'Save locations',
      'locations_saved_title': 'Locations saved',
      'locations_saved_msg': 'You can now confirm the invoice',
      'confirm_button_word': 'Confirm',
      'invoice_confirmed_title': 'Invoice confirmed',
      'invoice_confirmed_msg': 'It is now pending administrator validation',
      'gaps_detected_title_prefix': 'Discrepancies detected — Invoice #',
      'your_comment_label': 'Your comment for the administrator',
      'send_to_admin_button': 'Send to administrator',
      'sent_title': 'Sent',
      'sent_awaiting_admin_msg': 'Awaiting administrator decision',
      'report_error_title': 'Report an error',
      'describe_error_label': 'Describe the error found',
      'send_request_button': 'Send request',
      'request_sent_title': 'Request sent',
      'request_sent_msg': 'Pending administrator approval',
      'new_invoice_title': 'New invoice',
      'from_phone_ocr_title': 'From a phone (OCR)',
      'from_phone_ocr_subtitle': 'Requires the mobile app',
      'manual_entry_title': 'Manual entry',
      'manual_entry_subtitle': 'Fill in the invoice directly here',
      'invoice_category_title': 'Invoice category',
      'po_choice_title': 'Purchase order (optional)',
      'none_word': 'None',
      'receive_from_phone_title': 'Receive from a phone',
      'code_expired_title': 'Code expired',
      'generate_new_code_button': 'Generate a new code',
      'server_connection_error': 'Server connection error',
      'expires_in_prefix': 'Expires in',
      'mobile_instructions': 'From the mobile app: enter this code or scan the QR.',
      'phone_connected_msg': 'Phone connected — waiting for the photo...',
      'invoice_received_msg': 'Invoice received!',
      'later_button': 'Later',
      'verify_invoice_button': 'Verify invoice',
      'sale_word': 'Sale',
      'manual_adjustment_word': 'Manual adjustment',
      'created_manually_label': 'Created manually',
      'financial_summary_title': 'FINANCIAL SUMMARY',
      'ppa_label': 'PPA',
      'incoherence_detected_msg': 'Inconsistency detected between the amount excl. tax and the line total.',
      'products_count_title': 'PRODUCTS',
      'add_short_button': '+ Add',
      'no_product_in_invoice': 'No product added to this invoice',
      'existing_tag': '✅ Existing',
      'invoice_validated_success_msg': 'Invoice validated — stock updated',
      'add_product_to_invoice_title': 'Add a product to the invoice',
      'quantity_word': 'Quantity',
      'line_total_invoice_label': 'Total price (invoice)',
      'sale_price_optional_label2': 'Sale price (optional)',
      'manufacturing_date_ymd_label': 'Manufacturing date (YYYY-MM-DD)',
      'expiration_date_ymd_label': 'Expiration date (YYYY-MM-DD)',
      'rejection_reason_title': 'REJECTION REASON',
      'manual_creation_reason_label': 'Reason (manual creation)',
      'invoice_cancelled': 'Cancelled',
      'invoice_amount_tva': 'VAT amount',
      'invoices_empty': 'No invoice',
      'th_invoice_number': 'INVOICE N°',
      'th_supplier_upper': 'SUPPLIER',
      'th_date_upper': 'DATE',
      'th_amount_ht_upper': 'AMOUNT EXCL. TAX',
      'th_amount_ttc_upper': 'AMOUNT INCL. TAX',
      'th_actions': 'ACTIONS',
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
  String get navDashboard => get('nav_dashboard');
  String get navManufacturing => get('nav_manufacturing');
  String get navPurchaseOrders => get('nav_purchase_orders');
  String get navQrCodes => get('nav_qr_codes');
  String get navApprovals => get('nav_approvals');
  String get navIot => get('nav_iot');
  String get navSecurity => get('nav_security');
  String get navReports => get('nav_reports');
  String get navAdmin => get('nav_admin');
  String get navSettings => get('nav_settings');
  String get roleAdmin => get('role_admin');
  String get roleAgentKiosk => get('role_agent_kiosk');
  String get logout => get('logout');
  String get loginSubtitle => get('login_subtitle');
  String get loginUsernameHint => get('login_username_hint');
  String get loginPasswordHint => get('login_password_hint');
  String get loginAdminAccess => get('login_admin_access');
  String get appTagline => get('app_tagline');
  String get featureStockRealtime => get('feature_stock_realtime');
  String get featureInvoiceValidation => get('feature_invoice_validation');
  String get featureAlertsInstant => get('feature_alerts_instant');
  String get featureReportsAnalytics => get('feature_reports_analytics');
  String get dashboardRefresh => get('dashboard_refresh');
  String get kpiEntriesToday => get('kpi_entries_today');
  String get kpiExitsToday => get('kpi_exits_today');
  String get kpiActiveAlerts => get('kpi_active_alerts');
  String get kpiUnread => get('kpi_unread');
  String get kpiPendingInvoices => get('kpi_pending_invoices');
  String get kpiTotalStockValue => get('kpi_total_stock_value');
  String get chartMovementsTitle => get('chart_movements_title');
  String get chartNoData => get('chart_no_data');
  String get recentAlertsTitle => get('recent_alerts_title');
  String get noAlerts => get('no_alerts');
  String get criticalStockTitle => get('critical_stock_title');
  String get allNormal => get('all_normal');
  String get recentMovementsTitle => get('recent_movements_title');
  String get noMovements => get('no_movements');
  String get tableProduct => get('table_product');
  String get tableQty => get('table_qty');
  String get tableType => get('table_type');
  String get movementEntry => get('movement_entry');
  String get movementExit => get('movement_exit');
  String get searchProductHint => get('search_product_hint');
  String get filterAllStatus => get('filter_all_status');
  String get addButton => get('add_button');
  String get thSku => get('th_sku');
  String get thCategory => get('th_category');
  String get thStockAvailable => get('th_stock_available');
  String get thValue => get('th_value');
  String get thStatus => get('th_status');
  String get noProduct => get('no_product');
  String get statusLowShort => get('status_low_short');
  String get filterCategoryHint => get('filter_category_hint');
  String get filterAllCategories => get('filter_all_categories');
  String get detailStockPhysical => get('detail_stock_physical');
  String get detailStockAvailable => get('detail_stock_available');
  String get detailStockReserved => get('detail_stock_reserved');
  String get detailCriticalThreshold => get('detail_critical_threshold');
  String get detailPurchasePrice => get('detail_purchase_price');
  String get detailSalePrice => get('detail_sale_price');
  String get detailPmp => get('detail_pmp');
  String get detailStockValue => get('detail_stock_value');
  String get detailTva => get('detail_tva');
  String get detailOriginCountry => get('detail_origin_country');
  String get viewPriceHistory => get('view_price_history');
  String get lotsTitle => get('lots_title');
  String get lotAvailable => get('lot_available');
  String get lotExpiry => get('lot_expiry');
  String get printLotQrTooltip => get('print_lot_qr_tooltip');
  String get extraFieldsTitle => get('extra_fields_title');
  String get addProductTitle => get('add_product_title');
  String get addProductChooseMode => get('add_product_choose_mode');
  String get addProductSheetOnly => get('add_product_sheet_only');
  String get addProductWithStock => get('add_product_with_stock');
  String get formSku => get('form_sku');
  String get formQrCode => get('form_qr_code');
  String get formProductName => get('form_product_name');
  String get formCategory => get('form_category');
  String get formStockType => get('form_stock_type');
  String get formPurchasePriceRef => get('form_purchase_price_ref');
  String get formSalePriceRef => get('form_sale_price_ref');
  String get cancel => get('cancel');
  String get create => get('create');
  String get errorSkuNameQrRequired => get('error_sku_name_qr_required');
  String get errorSkuQrUsed => get('error_sku_qr_used');
  String get toastSuccess => get('toast_success');
  String get toastProductSheetCreated => get('toast_product_sheet_created');
  String get productFullTitle => get('product_full_title');
  String get productFullSubtitle => get('product_full_subtitle');
  String get formSupplier => get('form_supplier');
  String get formOriginCountry => get('form_origin_country');
  String get formSupplierNif => get('form_supplier_nif');
  String get formSupplierNis => get('form_supplier_nis');
  String get formSupplierRc => get('form_supplier_rc');
  String get formInitialQty => get('form_initial_qty');
  String get toastProductInvoiceCreated => get('toast_product_invoice_created');
  String get qrLotTitle => get('qr_lot_title');
  String get qrPrintInstruction => get('qr_print_instruction');
  String get errorTitle => get('error_title');
  String get filterTypeAll => get('filter_type_all');
  String get filterTypeMerchandise => get('filter_type_merchandise');
  String get filterTypeRawMaterial => get('filter_type_raw_material');
  String get filterTypeFinishedProduct => get('filter_type_finished_product');
  String get filterTypeConsumable => get('filter_type_consumable');
  String get poNew => get('po_new');
  String get poNoSupplier => get('po_no_supplier');
  String get poArticlesSuffix => get('po_articles_suffix');
  String get poSupplierColon => get('po_supplier_colon');
  String get poTypeColon => get('po_type_colon');
  String get poStatusColon => get('po_status_colon');
  String get poQuantityShort => get('po_quantity_short');
  String get poPriceEstimateShort => get('po_price_estimate_short');
  String get poDesignation => get('po_designation');
  String get poQuantity => get('po_quantity');
  String get poPriceEstimate => get('po_price_estimate');
  String get poSupplierOptional => get('po_supplier_optional');
  String get poAddLine => get('po_add_line');
  String get poCreatedTitle => get('po_created_title');
  String get poCreatedPrefix => get('po_created_prefix');
  String get poCreatedSuffix => get('po_created_suffix');
  String get pdfStockTypeLabel => get('pdf_stock_type_label');
  String get pdfHeaderTotal => get('pdf_header_total');
  String get qrPrintPageTitle => get('qr_print_page_title');
  String get qrNonePending => get('qr_none_pending');
  String get qrLotLabel => get('qr_lot_label');
  String get qrLocationLabel => get('qr_location_label');
  String get printTooltip => get('print_tooltip');
  String get removeFromListTooltip => get('remove_from_list_tooltip');
  String get saveQrDialogTitle => get('save_qr_dialog_title');
  String get downloadedTitle => get('downloaded_title');
  String get downloadedMsgPrefix => get('downloaded_msg_prefix');
  String get downloadButton => get('download_button');
  String get iotZonesTitle => get('iot_zones_title');
  String get iotZoneLabel => get('iot_zone_label');
  String get iotAllZones => get('iot_all_zones');
  String get iotNoData => get('iot_no_data');
  String get iotLevelCritical => get('iot_level_critical');
  String get iotLevelAlert => get('iot_level_alert');
  String get iotLevelManual => get('iot_level_manual');
  String get iotLevelNormal => get('iot_level_normal');
  String get iotAutoResolved => get('iot_auto_resolved');
  String get iotNeedsManual => get('iot_needs_manual');
  String get markAllRead => get('mark_all_read');
  String get thTitle => get('th_title');
  String get thMessage => get('th_message');
  String get thLevel => get('th_level');
  String get thTime => get('th_time');
  String get alertLevelWarning => get('alert_level_warning');
  String get alertLevelInfo => get('alert_level_info');
  String get readLabel => get('read_label');
  String get newLabel => get('new_label');
  String minutesAgo(int n) => get('time_ago_minutes').replaceAll('{n}', '$n');
  String hoursAgo(int n) => get('time_ago_hours').replaceAll('{n}', '$n');
  String get approvalsPageTitle => get('approvals_page_title');
  String gapCount(int n) => get('approvals_gap_count').replaceAll('{n}', '$n');
  String get examineButton => get('examine_button');
  String get approvalsNoPending => get('approvals_no_pending');
  String get gapTitlePrefix => get('gap_title_prefix');
  String get gapDetectedTitle => get('gap_detected_title');
  String get gapCommentTitle => get('gap_comment_title');
  String get rejectButton => get('reject_button');
  String get approveButton => get('approve_button');
  String get rejectedTitle => get('rejected_title');
  String get rejectedMsg => get('rejected_msg');
  String get approvedTitle => get('approved_title');
  String get approvedMsg => get('approved_msg');
  String get invoiceHashPrefix => get('invoice_hash_prefix');
  String get requestedByPrefix => get('requested_by_prefix');
  String get gapLockNotice => get('gap_lock_notice');
  String get viewInvoiceButton => get('view_invoice_button');
  String get refuseButton => get('refuse_button');
  String get refuseReasonTitle => get('refuse_reason_title');
  String get refuseReasonHint => get('refuse_reason_hint');
  String get confirmRefuseButton => get('confirm_refuse_button');
  String ecartFournisseurDifferent(String a, String b) => get('ecart_fournisseur_different').replaceAll('{a}', a).replaceAll('{b}', b);
  String ecartProduitNonCommande(String a, String b) => get('ecart_produit_non_commande').replaceAll('{a}', a).replaceAll('{b}', b);
  String ecartProduitManquant(String a, String b) => get('ecart_produit_manquant').replaceAll('{a}', a).replaceAll('{b}', b);
  String ecartQuantiteDetail(String a, String b) => get('ecart_quantite_detail').replaceAll('{a}', a).replaceAll('{b}', b);
  String ecartPrixDetail(String a, String b) => get('ecart_prix_detail').replaceAll('{a}', a).replaceAll('{b}', b);
  String ecartGenericPrefix(String a, String b) => get('ecart_generic_prefix').replaceAll('{a}', a).replaceAll('{b}', b);
  String get fabPageTitle => get('fab_page_title');
  String get fabTabRecipes => get('fab_tab_recipes');
  String get fabTabOrders => get('fab_tab_orders');
  String get fabNewRecipe => get('fab_new_recipe');
  String get fabNoRecipe => get('fab_no_recipe');
  String get fabProductHashPrefix => get('fab_product_hash_prefix');
  String get fabPerUnitSuffix => get('fab_per_unit_suffix');
  String get fabLossSuffix => get('fab_loss_suffix');
  String get fabProduceFromRecipe => get('fab_produce_from_recipe');
  String get fabNewRecipeDialogTitle => get('fab_new_recipe_dialog_title');
  String get fabFinishedProductLabel => get('fab_finished_product_label');
  String get fabComponentLabel => get('fab_component_label');
  String get fabQtyPerUnitLabel => get('fab_qty_per_unit_label');
  String get fabLossPercentLabel => get('fab_loss_percent_label');
  String get fabAddComponent => get('fab_add_component');
  String get fabProduceDialogTitlePrefix => get('fab_produce_dialog_title_prefix');
  String get fabMaxRealisablePrefix => get('fab_max_realisable_prefix');
  String get fabLimitedByPrefix => get('fab_limited_by_prefix');
  String get fabQtyProducedLabel => get('fab_qty_produced_label');
  String get fabLocationOptionalLabel => get('fab_location_optional_label');
  String get fabLotNumberOptionalLabel => get('fab_lot_number_optional_label');
  String get fabFabricationDateLabel => get('fab_fabrication_date_label');
  String get fabExpirationDateLabel => get('fab_expiration_date_label');
  String get fabNotDefinedPick => get('fab_not_defined_pick');
  String get fabConfirmProduction => get('fab_confirm_production');
  String get fabProductionRecordedTitle => get('fab_production_recorded_title');
  String get fabLotWord => get('fab_lot_word');
  String get fabUnitCostSuffix => get('fab_unit_cost_suffix');
  String get fabNoOrders => get('fab_no_orders');
  String get fabQuantityColon => get('fab_quantity_colon');
  String get fabLotColon => get('fab_lot_colon');
  String get fabPerUnitDzdSuffix => get('fab_per_unit_dzd_suffix');
  String get reportStockTitle => get('report_stock_title');
  String get reportStockDesc => get('report_stock_desc');
  String get reportInvoicesTitle => get('report_invoices_title');
  String get reportInvoicesDesc => get('report_invoices_desc');
  String get reportAlertsTitle => get('report_alerts_title');
  String get reportAlertsDesc => get('report_alerts_desc');
  String get generatePdfButton => get('generate_pdf_button');
  String get globalSummaryTitle => get('global_summary_title');
  String get statTotalProducts => get('stat_total_products');
  String get statCriticalProducts => get('stat_critical_products');
  String get statValidatedInvoices => get('stat_validated_invoices');
  String get statSystemAvailability => get('stat_system_availability');
  String get pdfStockReportTitle => get('pdf_stock_report_title');
  String get pdfGeneratedOnPrefix => get('pdf_generated_on_prefix');
  String get pdfHeaderProduct => get('pdf_header_product');
  String get pdfHeaderStockAvailable => get('pdf_header_stock_available');
  String get pdfHeaderValueDzd => get('pdf_header_value_dzd');
  String get pdfTotalStockValuePrefix => get('pdf_total_stock_value_prefix');
  String get pdfInvoicesReportTitle => get('pdf_invoices_report_title');
  String get pdfHeaderSupplier => get('pdf_header_supplier');
  String get pdfHeaderDate => get('pdf_header_date');
  String get pdfStatusValidated => get('pdf_status_validated');
  String get pdfStatusRejected => get('pdf_status_rejected');
  String get pdfStatusPending => get('pdf_status_pending');
  String get pdfValidatedCountPrefix => get('pdf_validated_count_prefix');
  String get pdfPendingCountPrefix => get('pdf_pending_count_prefix');
  String get pdfRejectedCountPrefix => get('pdf_rejected_count_prefix');
  String get pdfAlertsReportTitle => get('pdf_alerts_report_title');
  String get pdfUnreadLabel => get('pdf_unread_label');
  String get histPageTitle => get('hist_page_title');
  String get histSearchHint => get('hist_search_hint');
  String get histSearchEmpty => get('hist_search_empty');
  String get histAvgPurchasePrice => get('hist_avg_purchase_price');
  String get histAvgSalePrice => get('hist_avg_sale_price');
  String get histMargin => get('hist_margin');
  String get histLotDistributionTitle => get('hist_lot_distribution_title');
  String get histNoActiveLot => get('hist_no_active_lot');
  String get histUnitsSuffix => get('hist_units_suffix');
  String get histExpiresPrefix => get('hist_expires_prefix');
  String get histInvoiceWord => get('hist_invoice_word');
  String get histPriceEvolutionTitle => get('hist_price_evolution_title');
  String get histAllInvoicesTitle => get('hist_all_invoices_title');
  String get histNoInvoiceYet => get('hist_no_invoice_yet');
  String get histNoValidatedPurchase => get('hist_no_validated_purchase');
  String get histSinglePurchasePrefix => get('hist_single_purchase_prefix');
  String get histChartAppearsNote => get('hist_chart_appears_note');
  String get histStatusAccepted => get('hist_status_accepted');
  String get histTypeSale => get('hist_type_sale');
  String get histTypePurchase => get('hist_type_purchase');
  String get secPageTitle => get('sec_page_title');
  String get secAccessControlTitle => get('sec_access_control_title');
  String get secThPerson => get('sec_th_person');
  String get secThZone => get('sec_th_zone');
  String get secThConfidence => get('sec_th_confidence');
  String get secThAccess => get('sec_th_access');
  String get secNoFaceEvent => get('sec_no_face_event');
  String get secAlertsTitle => get('sec_alerts_title');
  String get secNoSecurityAlert => get('sec_no_security_alert');
  String get secUnknownPerson => get('sec_unknown_person');
  String get secAccessOk => get('sec_access_ok');
  String get secAccessDenied => get('sec_access_denied');
  String get settingsAppearanceTitle => get('settings_appearance_title');
  String get settingsThemeLabel => get('settings_theme_label');
  String get settingsLanguageLabel => get('settings_language_label');
  String get settingsAccountTitle => get('settings_account_title');
  String get settingsConnectionTitle => get('settings_connection_title');
  String get settingsConnectedLocal => get('settings_connected_local');
  String get setupFillAllFields => get('setup_fill_all_fields');
  String get setupPasswordsMismatch => get('setup_passwords_mismatch');
  String get setupPasswordTooShort => get('setup_password_too_short');
  String get setupAlreadyDone => get('setup_already_done');
  String get setupPasswordTooShortServer => get('setup_password_too_short_server');
  String get setupServerError => get('setup_server_error');
  String get setupInitialConfigTitle => get('setup_initial_config_title');
  String get setupInitialConfigDesc => get('setup_initial_config_desc');
  String get setupFullNameLabel => get('setup_full_name_label');
  String get setupConfirmPasswordLabel => get('setup_confirm_password_label');
  String get setupCreateAdminButton => get('setup_create_admin_button');
  String get gateConnecting => get('gate_connecting');
  String get setupBackButton => get('setup_back_button');
  String get setupServerConfigTitle => get('setup_server_config_title');
  String get setupServerConfigDesc => get('setup_server_config_desc');
  String get setupIpLabel => get('setup_ip_label');
  String get setupPortLabel => get('setup_port_label');
  String get setupServerUnreachable => get('setup_server_unreachable');
  String get saTitle => get('sa_title');
  String get saZoneNotice => get('sa_zone_notice');
  String get saSystemPasswordLabel => get('sa_system_password_label');
  String get saPasswordHint => get('sa_password_hint');
  String get saWrongPassword => get('sa_wrong_password');
  String get saAccessButton => get('sa_access_button');
  String get saUsersManagementTitle => get('sa_users_management_title');
  String get saAddUserTitle => get('sa_add_user_title');
  String get saUsernameExists => get('sa_username_exists');
  String get saCheckFieldsError => get('sa_check_fields_error');
  String get saRoleLabel => get('sa_role_label');
  String get saResetPasswordTitlePrefix => get('sa_reset_password_title_prefix');
  String get saNewPasswordLabel => get('sa_new_password_label');
  String get saRoleAdminShort => get('sa_role_admin_short');
  String get saThName => get('sa_th_name');
  String get saThUsername => get('sa_th_username');
  String get saThRole => get('sa_th_role');
  String get saDeactivateTooltip => get('sa_deactivate_tooltip');
  String get saActivateTooltip => get('sa_activate_tooltip');
  String get saResetPasswordTooltip => get('sa_reset_password_tooltip');
  String get invPageActionsNewInvoice => get('inv_page_actions_new_invoice');
  String invBannerMismatchCount(int n) => get('inv_banner_mismatch_count').replaceAll('{n}', '$n');
  String get invViewAndReport => get('inv_view_and_report');
  String invBannerOcrCount(int n) => get('inv_banner_ocr_count').replaceAll('{n}', '$n');
  String get invVerifyButton => get('inv_verify_button');
  String invBannerPendingModCount(int n) => get('inv_banner_pending_mod_count').replaceAll('{n}', '$n');
  String get invPendingAdmin => get('inv_pending_admin');
  String invBannerToCorrectCount(int n) => get('inv_banner_to_correct_count').replaceAll('{n}', '$n');
  String get invCorrectNow => get('inv_correct_now');
  String get thAuthentication => get('th_authentication');
  String get stampLabel => get('stamp_label');
  String get signatureShortLabel => get('signature_short_label');
  String get invValidateButton => get('inv_validate_button');
  String get motifRejetTitle => get('motif_rejet_title');
  String get motifRejetHint => get('motif_rejet_hint');
  String get confirmRejectButton => get('confirm_reject_button');
  String get invoiceRejectedToast => get('invoice_rejected_toast');
  String get filterAllTypes => get('filter_all_types');
  String get typePurchases => get('type_purchases');
  String get typeSales => get('type_sales');
  String get statusValidatedPlural => get('status_validated_plural');
  String get statusRejectedPlural => get('status_rejected_plural');
  String get newManualInvoiceTitle => get('new_manual_invoice_title');
  String get manualInvoiceNotice => get('manual_invoice_notice');
  String get typeLabel => get('type_label');
  String get categoryLabel => get('category_label');
  String get poNone => get('po_none');
  String get poReservedByYouPrefix => get('po_reserved_by_you_prefix');
  String get poReservedByYouSuffix => get('po_reserved_by_you_suffix');
  String get poOptionalLabel => get('po_optional_label');
  String get supplierClientLabel => get('supplier_client_label');
  String get nifOptionalLabel => get('nif_optional_label');
  String get nisOptionalLabel => get('nis_optional_label');
  String get rcOptionalLabel => get('rc_optional_label');
  String get invoiceDateLabel => get('invoice_date_label');
  String get amountHtLabel => get('amount_ht_label');
  String get tvaLabel => get('tva_label');
  String get amountTtcLabel => get('amount_ttc_label');
  String get reasonRequiredLabel => get('reason_required_label');
  String get reasonHint => get('reason_hint');
  String get articlesTitle => get('articles_title');
  String get addArticleButton => get('add_article_button');
  String get poUnavailableTitle => get('po_unavailable_title');
  String get poUnavailableMsg => get('po_unavailable_msg');
  String get problemOptionalLabel => get('problem_optional_label');
  String get problemHint => get('problem_hint');
  String get reportRequiredTitle => get('report_required_title');
  String get reportRequiredMsg => get('report_required_msg');
  String get reasonRequiredTitle => get('reason_required_title');
  String get reasonRequiredMsg => get('reason_required_msg');
  String get supplierRequiredTitle => get('supplier_required_title');
  String get supplierRequiredMsg => get('supplier_required_msg');
  String get qtyMissingTitle => get('qty_missing_title');
  String get qtyMissingMsg => get('qty_missing_msg');
  String get sendModificationRequestButton => get('send_modification_request_button');
  String get invoiceSentTitle => get('invoice_sent_title');
  String get invoiceSentMsg => get('invoice_sent_msg');
  String get sendFailedTitle => get('send_failed_title');
  String get sendFailedMsg => get('send_failed_msg');
  String get sendButton => get('send_button');
  String get invoiceCreatedTitle => get('invoice_created_title');
  String get invoiceCreatedMsg => get('invoice_created_msg');
  String get newProductSwitchLabel => get('new_product_switch_label');
  String get searchExistingProductHint => get('search_existing_product_hint');
  String get lotLocationPrefilledLabel => get('lot_location_prefilled_label');
  String get newProductNameLabel => get('new_product_name_label');
  String get barcodeLabel => get('barcode_label');
  String get unitLabel => get('unit_label');
  String get criticalThresholdLabel => get('critical_threshold_label');
  String get locationLabel => get('location_label');
  String get designationRetainedLabel => get('designation_retained_label');
  String get qtyStarLabel => get('qty_star_label');
  String get requiredLabel => get('required_label');
  String get lineTotalPriceLabel => get('line_total_price_label');
  String get unitPriceCalcLabel => get('unit_price_calc_label');
  String get salePriceOptionalLabel => get('sale_price_optional_label');
  String get manufacturingLabel => get('manufacturing_label');
  String get expirationLabel => get('expiration_label');
  String get manufacturerLotLabel => get('manufacturer_lot_label');
  String get correctInvoiceTitlePrefix => get('correct_invoice_title_prefix');
  String get correctedArticlesTitle => get('corrected_articles_title');
  String get sendCorrectionButton => get('send_correction_button');
  String get invoiceCorrectedTitle => get('invoice_corrected_title');
  String get invoiceCorrectedMsg => get('invoice_corrected_msg');
  String get correctionFailedTitle => get('correction_failed_title');
  String get correctionFailedMsg => get('correction_failed_msg');
  String get verifyOcrTitlePrefix => get('verify_ocr_title_prefix');
  String get ocrDetectedArticlesTitle => get('ocr_detected_articles_title');
  String get puLabel => get('pu_label');
  String get expInlineLabel => get('exp_inline_label');
  String get newProductLocationHint => get('new_product_location_hint');
  String get reportErrorButton => get('report_error_button');
  String get saveLocationsButton => get('save_locations_button');
  String get locationsSavedTitle => get('locations_saved_title');
  String get locationsSavedMsg => get('locations_saved_msg');
  String get confirmButtonWord => get('confirm_button_word');
  String get invoiceConfirmedTitle => get('invoice_confirmed_title');
  String get invoiceConfirmedMsg => get('invoice_confirmed_msg');
  String get gapsDetectedTitlePrefix => get('gaps_detected_title_prefix');
  String get yourCommentLabel => get('your_comment_label');
  String get sendToAdminButton => get('send_to_admin_button');
  String get sentTitle => get('sent_title');
  String get sentAwaitingAdminMsg => get('sent_awaiting_admin_msg');
  String get reportErrorTitle => get('report_error_title');
  String get describeErrorLabel => get('describe_error_label');
  String get sendRequestButton => get('send_request_button');
  String get requestSentTitle => get('request_sent_title');
  String get requestSentMsg => get('request_sent_msg');
  String get newInvoiceTitle => get('new_invoice_title');
  String get fromPhoneOcrTitle => get('from_phone_ocr_title');
  String get fromPhoneOcrSubtitle => get('from_phone_ocr_subtitle');
  String get manualEntryTitle => get('manual_entry_title');
  String get manualEntrySubtitle => get('manual_entry_subtitle');
  String get invoiceCategoryTitle => get('invoice_category_title');
  String get poChoiceTitle => get('po_choice_title');
  String get noneWord => get('none_word');
  String get receiveFromPhoneTitle => get('receive_from_phone_title');
  String get codeExpiredTitle => get('code_expired_title');
  String get generateNewCodeButton => get('generate_new_code_button');
  String get serverConnectionError => get('server_connection_error');
  String get expiresInPrefix => get('expires_in_prefix');
  String get mobileInstructions => get('mobile_instructions');
  String get phoneConnectedMsg => get('phone_connected_msg');
  String get invoiceReceivedMsg => get('invoice_received_msg');
  String get laterButton => get('later_button');
  String get verifyInvoiceButton => get('verify_invoice_button');
  String get saleWord => get('sale_word');
  String get manualAdjustmentWord => get('manual_adjustment_word');
  String get createdManuallyLabel => get('created_manually_label');
  String get financialSummaryTitle => get('financial_summary_title');
  String get ppaLabel => get('ppa_label');
  String get incoherenceDetectedMsg => get('incoherence_detected_msg');
  String get productsCountTitle => get('products_count_title');
  String get addShortButton => get('add_short_button');
  String get noProductInInvoice => get('no_product_in_invoice');
  String get existingTag => get('existing_tag');
  String get invoiceValidatedSuccessMsg => get('invoice_validated_success_msg');
  String get addProductToInvoiceTitle => get('add_product_to_invoice_title');
  String get quantityWord => get('quantity_word');
  String get lineTotalInvoiceLabel => get('line_total_invoice_label');
  String get salePriceOptionalLabel2 => get('sale_price_optional_label2');
  String get manufacturingDateYmdLabel => get('manufacturing_date_ymd_label');
  String get expirationDateYmdLabel => get('expiration_date_ymd_label');
  String get rejectionReasonTitle => get('rejection_reason_title');
  String get manualCreationReasonLabel => get('manual_creation_reason_label');
  String get invoiceCancelled => get('invoice_cancelled');
  String get invoiceAmountTva => get('invoice_amount_tva');
  String get invoicesEmpty => get('invoices_empty');
  String get thInvoiceNumber => get('th_invoice_number');
  String get thSupplierUpper => get('th_supplier_upper');
  String get thDateUpper => get('th_date_upper');
  String get thAmountHtUpper => get('th_amount_ht_upper');
  String get thAmountTtcUpper => get('th_amount_ttc_upper');
  String get thActions => get('th_actions');
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
