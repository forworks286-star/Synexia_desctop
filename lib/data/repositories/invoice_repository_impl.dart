import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/repositories.dart';
import '../services/api_client.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final _dio = ApiClient.instance.dio;

  @override
  Future<Either<String, List<Invoice>>> getInvoices() async {
    try {
      final response = await _dio.get(AppConfig.facturesAll);
      final invoices = (response.data['results'] as List)
          .map((e) => _parseInvoice(e as Map<String, dynamic>))
          .toList();
      return Right(invoices);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, Invoice>> getInvoice(int id) async {
    try {
      final url = AppConfig.factureDetail.replaceAll('{id}', '$id');
      final response = await _dio.get(url);
      return Right(_parseInvoice(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, Invoice>> submitOcrResult(Map<String, dynamic> ocrData) async {
    try {
      final response = await _dio.post(AppConfig.ocrReceive, data: ocrData);
      return Right(_parseInvoice(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, void>> validateInvoice(int id) async {
    try {
      final url = AppConfig.facturesValidate.replaceAll('{id}', '$id');
      await _dio.put(url);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, void>> rejectInvoice(int id, String motif) async {
    try {
      final url = AppConfig.facturesRejeter.replaceAll('{id}', '$id');
      await _dio.put(url, data: {'motif': motif});
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, List<LigneFacture>>> getLignes(int factureId) async {
    try {
      final url = AppConfig.factureLignes.replaceAll('{id}', '$factureId');
      final response = await _dio.get(url);
      final list = (response.data['results'] as List)
          .map((e) => _parseLigne(e as Map<String, dynamic>))
          .toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, LigneFacture>> addLigne(int factureId,
      {int? produitId, String? designation, String? typeStock,
      required double quantite, required double prixUnitaire,
      double? prixVente, String? dateFabrication, String? dateExpiration}) async {
    try {
      final url = AppConfig.factureLignes.replaceAll('{id}', '$factureId');
      final response = await _dio.post(url, data: {
        if (produitId != null) 'produit_id': produitId,
        if (designation != null) 'designation': designation,
        if (typeStock != null) 'type_stock': typeStock,
        'quantite': quantite, 'prix_unitaire': prixUnitaire,
        if (prixVente != null) 'prix_vente': prixVente,
        if (dateFabrication != null) 'date_fabrication': dateFabrication,
        if (dateExpiration != null) 'date_expiration': dateExpiration,
      });
      return Right(_parseLigne(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, Invoice>> creerFactureManuelle({
      required String fournisseurNom, required String date, required String typeFacture,
      required String typeStock, required double montantHt, required double montantTva,
      required double montantTtc, String? fournisseurNif, String? fournisseurNis, String? fournisseurRc,
      required String motifCreationManuelle,
      required List<Map<String, dynamic>> lignes, String? compteRenduDemande}) async {
    try {
      final response = await _dio.post(AppConfig.facturesManuelle, data: {
        'fournisseur_nom': fournisseurNom, 'date': date, 'type_facture': typeFacture,
        'type_stock': typeStock,
        'montant_ht': montantHt, 'montant_tva': montantTva, 'montant_ttc': montantTtc,
        'fournisseur_nif': fournisseurNif, 'fournisseur_nis': fournisseurNis, 'fournisseur_rc': fournisseurRc,
        'motif_creation_manuelle': motifCreationManuelle,
        'lignes': lignes,
        if (compteRenduDemande != null) 'compte_rendu_demande': compteRenduDemande,
      });
      return Right(_parseInvoice(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }


  @override
  Future<Either<String, List<DemandeModification>>> getDemandes({String statut = 'pending'}) async {
    try {
      final response = await _dio.get(AppConfig.demandesModification, queryParameters: {'statut': statut});
      final list = (response.data['results'] as List)
          .map((e) => _parseDemande(e as Map<String, dynamic>)).toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, void>> approuverDemande(int id) async {
    try {
      final url = AppConfig.demandeApprouver.replaceAll('{id}', '$id');
      await _dio.put(url);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, void>> refuserDemande(int id, String? motif) async {
    try {
      final url = AppConfig.demandeRefuser.replaceAll('{id}', '$id');
      await _dio.put(url, data: {'motif_refus': motif});
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, List<Invoice>>> getFacturesParStatut(String statut) async {
    try {
      final response = await _dio.get(AppConfig.facturesAll, queryParameters: {'statut': statut});
      final invoices = (response.data['results'] as List)
          .map((e) => _parseInvoice(e as Map<String, dynamic>))
          .toList();
      return Right(invoices);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, Invoice>> completerModification({
      required int factureId, required String fournisseurNom, required String date,
      required double montantHt, required double montantTva, required double montantTtc,
      required List<Map<String, dynamic>> lignes}) async {
    try {
      final url = AppConfig.factureCompleterModification.replaceAll('{id}', '$factureId');
      final response = await _dio.put(url, data: {
        'fournisseur_nom': fournisseurNom, 'date': date,
        'montant_ht': montantHt, 'montant_tva': montantTva, 'montant_ttc': montantTtc,
        'lignes': lignes,
      });
      return Right(_parseInvoice(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, void>> confirmerOcr(int factureId, List<Map<String, dynamic>> lignes) async {
    try {
      final url = AppConfig.factureConfirmerOcr.replaceAll('{id}', '$factureId');
      await _dio.put(url, data: {'lignes': lignes});
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }


  @override
  Future<Either<String, void>> enregistrerEmplacementsOcr(int factureId, List<Map<String, dynamic>> lignes) async {
    try {
      final url = AppConfig.factureEmplacementsOcr.replaceAll('{id}', '$factureId');
      await _dio.put(url, data: {'lignes': lignes});
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, void>> creerDemandeModification(int factureId, String compteRendu) async {
    try {
      await _dio.post(AppConfig.demandesModification, data: {'facture_id': factureId, 'compte_rendu': compteRendu});
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  DemandeModification _parseDemande(Map<String, dynamic> data) => DemandeModification(
    id: data['id'] as int, factureId: data['facture_id'] as int,
    demandeurId: data['demandeur_id'] as int, demandeurNom: data['demandeur_nom'] as String?,
    compteRendu: data['compte_rendu'] as String, statut: data['statut'] as String? ?? 'pending',
    traiteParId: data['traite_par_id'] as int?, motifRefus: data['motif_refus'] as String?,
    dateCreation: DateTime.tryParse(data['date_creation']?.toString() ?? '') ?? DateTime.now(),
    dateTraitement: data['date_traitement'] != null ? DateTime.tryParse(data['date_traitement'].toString()) : null,
    factureFournisseur: data['facture_fournisseur'] as String?,
    factureMontantTtc: (data['facture_montant_ttc'] as num?)?.toDouble(),
  );

  @override
  Future<Either<String, void>> deleteLigne(int ligneId) async {
    try {
      final url = AppConfig.ligneDelete.replaceAll('{id}', '$ligneId');
      await _dio.delete(url);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, HistoriquePrixProduit>> getHistoriquePrix(int produitId) async {
    try {
      final url = AppConfig.produitHistoriquePrix.replaceAll('{id}', '$produitId');
      final response = await _dio.get(url);
      final data = response.data as Map<String, dynamic>;
      return Right(HistoriquePrixProduit(
        produitId: data['produit_id'] as int,
        produitNom: data['produit_nom'] as String,
        historique: (data['historique'] as List).map((e) => _parseLigne(e as Map<String, dynamic>)).toList(),
        prixAchatMoyen: (data['prix_achat_moyen'] as num?)?.toDouble(),
        prixVenteMoyen: (data['prix_vente_moyen'] as num?)?.toDouble(),
        margePercent:   (data['marge_percent'] as num?)?.toDouble(),
      ));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  Invoice _parseInvoice(Map<String, dynamic> data) => Invoice(
    id: data['id'] as int,
    supplierName: data['supplier_name'] as String,
    date: DateTime.parse(data['date'] as String),
    amountHt: (data['amount_ht'] as num).toDouble(),
    amountTva: (data['amount_tva'] as num?)?.toDouble() ?? 0,
    amountTtc: (data['amount_ttc'] as num).toDouble(),
    tauxTva: (data['taux_tva'] as num?)?.toDouble() ?? 19.0,
    ppa: (data['ppa'] as num?)?.toDouble(),
    numeroFacture:    data['numero_facture'] as String?,
    fournisseurNif:   data['fournisseur_nif'] as String?,
    fournisseurNis:   data['fournisseur_nis'] as String?,
    fournisseurRc:    data['fournisseur_rc'] as String?,
    creeManuellement: (data['cree_manuellement'] as bool?) ?? false,
    motifRejet:       data['motif_rejet'] as String?,
    incoherenceDetectee: (data['incoherence_detectee'] as bool?) ?? false,
    stampDetected:      (data['stamp_detected'] as bool?) ?? true,
    signatureDetected:  (data['signature_detected'] as bool?) ?? true,
    status:             _parseStatus(data['status'] as String? ?? 'pending'),
    photoUrl:           data['photo_url'] as String?,
    typeFacture:        (data['type_facture'] as String?) ?? 'achat',
    creeParId:          data['cree_par_id'] as int?,
    motifCreationManuelle: data['motif_creation_manuelle'] as String?,
  );

  LigneFacture _parseLigne(Map<String, dynamic> data) => LigneFacture(
    id: data['id'] as int,
    factureId: data['facture_id'] as int,
    produitId: data['produit_id'] as int?,
    produitNom: data['produit_nom'] as String? ?? '—',
    typeStock: data['type_stock'] as String?,
    matched: (data['matched'] as bool?) ?? true,
    quantite: (data['quantite'] as num).toDouble(),
    prixUnitaire: (data['prix_unitaire'] as num).toDouble(),
    prixVente: (data['prix_vente'] as num?)?.toDouble(),
    montantLigne: (data['montant_ligne'] as num).toDouble(),
    source: data['source'] as String? ?? 'manuel',
    dateFabrication: data['date_fabrication'] as String?,
    dateExpiration: data['date_expiration'] as String?,
    dateExpirationManquante: (data['date_expiration_manquante'] as bool?) ?? false,
    factureDate: DateTime.parse(data['facture_date'] as String),
    fournisseurNom: data['fournisseur_nom'] as String,
    typeFacture: data['type_facture'] as String,
    numeroFacture: data['numero_facture'] as String?,
    factureStatus: data['facture_status'] as String? ?? 'validated',
    factureCreeParId: data['facture_cree_par_id'] as int?,
    numeroLotFournisseur: data['numero_lot_fournisseur'] as String?,
    nouveauCategorie: data['nouveau_categorie'] as String?,
    nouveauCodeBarre: data['nouveau_code_barre'] as String?,
    nouveauUniteMesure: data['nouveau_unite_mesure'] as String?,
    nouveauSeuilCritique: data['nouveau_seuil_critique'] as int?,
    nouveauEmplacement: data['nouveau_emplacement'] as String?,
  );

  InvoiceStatus _parseStatus(String status) {
    switch (status) {
      case 'validated': return InvoiceStatus.validated;
      case 'rejected': return InvoiceStatus.rejected;
      default: return InvoiceStatus.pending;
    }
  }

  String _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) return 'error_network';
    if (e.response?.statusCode == 401) return 'error_auth';
    final detail = e.response?.data?['detail'];
    if (detail is String) return detail;
    return 'error_server';
  }
}

