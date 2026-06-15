import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String fullName;
  final String username;
  final UserRole role;
  final bool biometricEnabled;
  final DateTime? lastLogin;

  const User({
    required this.id,
    required this.fullName,
    required this.username,
    required this.role,
    this.biometricEnabled = false,
    this.lastLogin,
  });

  @override
  List<Object?> get props => [id, username, role];
}

enum UserRole { stockiste, manager }

class Product extends Equatable {
  final int id;
  final String name;
  final String qrReference;
  final int stockQuantity;
  final int alertThreshold;
  final String? supplierName;
  final int? supplierId;

  const Product({
    required this.id,
    required this.name,
    required this.qrReference,
    required this.stockQuantity,
    required this.alertThreshold,
    this.supplierName,
    this.supplierId,
  });

  StockStatus get status {
    if (stockQuantity <= 0) return StockStatus.critical;
    if (stockQuantity <= alertThreshold) return StockStatus.low;
    return StockStatus.normal;
  }

  @override
  List<Object?> get props => [id, qrReference];
}

enum StockStatus { normal, low, critical }

class Movement extends Equatable {
  final int id;
  final int productId;
  final String productName;
  final MovementType type;
  final int quantity;
  final DateTime date;
  final String? userName;

  const Movement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.date,
    this.userName,
  });

  @override
  List<Object?> get props => [id];
}

enum MovementType { entry, exit }

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
