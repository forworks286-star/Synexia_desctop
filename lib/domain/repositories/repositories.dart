import 'package:dartz/dartz.dart';
import '../models/models.dart';

abstract class AuthRepository {
  Future<Either<String, User>> login(String username, String password);
  Future<Either<String, User>> loginBiometric();
  Future<Either<String, void>> logout();
  Future<User?> getCurrentUser();
  Future<bool> refreshToken();
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
  Future<Either<String, void>> rejectInvoice(int id);
}


