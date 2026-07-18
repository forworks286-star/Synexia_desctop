
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../models/models.dart';

abstract class AuthRepository {
  Future<Either<String, User>> login(String username, String password);
  Future<Either<String, User>> loginBiometric();
  Future<Either<String, void>> logout();
  Future<User?> getCurrentUser();
}

abstract class StockRepository {
  Future<Either<String, List<Product>>> getProducts();
  Future<Either<String, Product>> getProductByQr(String qrCode);
  Future<Either<String, void>> registerMovement({
    required int produitId,
    required int lotId,
    required MovementType type,
    required int quantite,
  });
  Future<Either<String, List<Movement>>> getMovements({int? limit});
  Future<Either<String, DashboardStats>> getDashboardStats();
  Future<Either<String, List<ChartPoint>>> getMovementsChart({int days = 7});
  Future<Either<String, List<CommandeAuto>>> getCommandesAuto();
  Future<Either<String, void>> validerCommande(int id);
  Future<Either<String, void>> rejeterCommande(int id);
  Future<Either<String, List<IoTZone>>> getIoTDashboard();
  Future<Either<String, List<FaceEvent>>> getFaceEvents();
  Future<Either<String, void>> ajoutManuelComplet(Map<String, dynamic> data);
  Future<Either<String, Uint8List>> getLotQr(int lotId);
}
abstract class AlertRepository {
  Future<Either<String, List<Alert>>> getAlerts();
  Stream<Alert> alertStream();
  Future<Either<String, void>> markAsRead(int alertId);
  Future<Either<String, void>> markAllRead();
}

abstract class InvoiceRepository {
  Future<Either<String, List<Invoice>>> getInvoices();
  Future<Either<String, Invoice>> getInvoice(int id);
  Future<Either<String, Invoice>> submitOcrResult(Map<String, dynamic> ocrData);
  Future<Either<String, void>> validateInvoice(int id);
  Future<Either<String, void>> rejectInvoice(int id, String motif);
  Future<Either<String, List<LigneFacture>>> getLignes(int factureId);
  Future<Either<String, LigneFacture>> addLigne(int factureId, {int? produitId, String? designation, String? typeStock, required double quantite, required double prixUnitaire, double? prixVente, String? dateFabrication, String? dateExpiration});
  Future<Either<String, void>> deleteLigne(int ligneId);
  Future<Either<String, HistoriquePrixProduit>> getHistoriquePrix(int produitId);
  Future<Either<String, Invoice>> creerFactureManuelle({required String fournisseurNom, required String date, required String typeFacture, required double montantHt, required double montantTva, required double montantTtc, required String motifCreationManuelle});
  Future<Either<String, DemandeModification>> creerDemande({required int factureId, required String champConcerne, required String valeurProposee, required String compteRendu});
  Future<Either<String, List<DemandeModification>>> getDemandes({String statut = 'pending'});
  Future<Either<String, void>> approuverDemande(int id);
  Future<Either<String, void>> refuserDemande(int id, String? motif);
}

abstract class ManufacturingRepository {
  Future<Either<String, List<BomModel>>> getBoms();
  Future<Either<String, BomModel>> getBomDuProduit(int produitFiniId);
  Future<Either<String, BomModel>> creerBom({required int produitFiniId, String? nom, required List<Map<String, dynamic>> lignes});
  Future<Either<String, Map<String, dynamic>>> creerOrdreFabrication({required int bomId, required double quantiteProduite, String? emplacement});
  Future<Either<String, List<OrdreFabrication>>> getOrdresFabrication();
}
