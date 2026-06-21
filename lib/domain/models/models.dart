import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String fullName;
  final String username;
  final UserRole role;
  final List<String> permissions;
  final bool biometricEnabled;
  final DateTime? lastLogin;

  const User({
    required this.id,
    required this.fullName,
    required this.username,
    required this.role,
    this.permissions = const [],
    this.biometricEnabled = false,
    this.lastLogin,
  });

  @override
  List<Object?> get props => [id, username, role];
}

enum UserRole { admin, manager, stockiste, agentKiosk }

class Product extends Equatable {
  final int id;
  final String sku;
  final String name;
  final String? categorie;
  final String qrReference;
  final String? codeBarre;
  final String uniteMesure;
  final String? numeroSerie;
  final String? photoUrl;
  final String? paysOrigine;
  final String statutProduit;

  final int stockPhysique;
  final int stockDisponible;
  final int stockReserve;
  final int alertThreshold;
  final int stockSecurite;
  final int quantiteMinCommande;
  final int? quantiteMaxStock;

  final double prixAchat;
  final double prixMoyenPondere;
  final double prixVente;
  final double tauxTva;
  final String devise;
  final double valeurStock;

  final String? supplierName;
  final int? supplierId;
  final String? supplierSecondaireName;
  final int? delaiLivraisonJours;

  const Product({
    required this.id,
    required this.sku,
    required this.name,
    this.categorie,
    required this.qrReference,
    this.codeBarre,
    this.uniteMesure = 'piece',
    this.numeroSerie,
    this.photoUrl,
    this.paysOrigine,
    this.statutProduit = 'actif',
    required this.stockPhysique,
    required this.stockDisponible,
    required this.stockReserve,
    required this.alertThreshold,
    this.stockSecurite = 0,
    this.quantiteMinCommande = 1,
    this.quantiteMaxStock,
    this.prixAchat = 0,
    this.prixMoyenPondere = 0,
    this.prixVente = 0,
    this.tauxTva = 19,
    this.devise = 'DZD',
    this.valeurStock = 0,
    this.supplierName,
    this.supplierId,
    this.supplierSecondaireName,
    this.delaiLivraisonJours,
  });

  int get stockQuantity => stockDisponible;
  StockStatus get status {
    if (stockDisponible <= 0) return StockStatus.critical;
    if (stockDisponible <= alertThreshold) return StockStatus.low;
    return StockStatus.normal;
  }

  @override
  List<Object?> get props => [id, qrReference];
}

enum StockStatus { normal, low, critical }

class Lot extends Equatable {
  final int id;
  final String? numeroLot;
  final int quantitePhysique;
  final int quantiteDisponible;
  final String statut;
  final DateTime? dateFabrication;
  final DateTime? dateExpiration;
  final String? emplacement;

  const Lot({
    required this.id,
    this.numeroLot,
    required this.quantitePhysique,
    required this.quantiteDisponible,
    this.statut = 'disponible',
    this.dateFabrication,
    this.dateExpiration,
    this.emplacement,
  });

  @override
  List<Object?> get props => [id];
}

class Movement extends Equatable {
  final int id;
  final int productId;
  final String productName;
  final MovementType type;
  final int quantity;
  final String? numeroCommandeAchat;
  final String? numeroBl;
  final DateTime date;
  final String? userName;

  const Movement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    this.numeroCommandeAchat,
    this.numeroBl,
    required this.date,
    this.userName,
  });

  @override
  List<Object?> get props => [id];
}

enum MovementType { entry, exit, returnType }

class Invoice extends Equatable {
  final int id;
  final String supplierName;
  final DateTime date;
  final double amountHt;
  final double amountTtc;
  final bool stampDetected;
  final bool signatureDetected;
  final InvoiceStatus status;
  final String? photoUrl;

  const Invoice({
    required this.id,
    required this.supplierName,
    required this.date,
    required this.amountHt,
    required this.amountTtc,
    required this.stampDetected,
    required this.signatureDetected,
    required this.status,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id];
}

enum InvoiceStatus { pending, validated, rejected }

class Alert extends Equatable {
  final int id;
  final AlertLevel level;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  const Alert({
    required this.id,
    required this.level,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [id];
}

enum AlertLevel { info, warning, danger, success }

class DashboardStats extends Equatable {
  final int totalProducts;
  final int todayEntries;
  final int todayExits;
  final int activeAlerts;
  final int pendingInvoices;
  final double availability;

  const DashboardStats({
    required this.totalProducts,
    required this.todayEntries,
    required this.todayExits,
    required this.activeAlerts,
    required this.pendingInvoices,
    required this.availability,
  });

  @override
  List<Object?> get props => [totalProducts, activeAlerts];
}