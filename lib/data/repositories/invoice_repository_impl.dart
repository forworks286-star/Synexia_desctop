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
      required double quantite, required double prixUnitaire}) async {
    try {
      final url = AppConfig.factureLignes.replaceAll('{id}', '$factureId');
      final response = await _dio.post(url, data: {
        if (produitId != null) 'produit_id': produitId,
        if (designation != null) 'designation': designation,
        if (typeStock != null) 'type_stock': typeStock,
        'quantite': quantite, 'prix_unitaire': prixUnitaire,
      });
      return Right(_parseLigne(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

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
    montantLigne: (data['montant_ligne'] as num).toDouble(),
    source: data['source'] as String? ?? 'manuel',
    factureDate: DateTime.parse(data['facture_date'] as String),
    fournisseurNom: data['fournisseur_nom'] as String,
    typeFacture: data['type_facture'] as String,
    numeroFacture: data['numero_facture'] as String?,
    factureStatus: data['facture_status'] as String? ?? 'validated',
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