import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';
import '../../../data/repositories/stock_repository_impl.dart';

class QrAImprimerScreen extends StatelessWidget {
  const QrAImprimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stock = Get.find<StockController>();
    stock.loadQrAImprimer();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PageHeader(title: 'Codes QR à imprimer', actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: stock.loadQrAImprimer),
        ]),
        const SizedBox(height: 20),
        Expanded(child: Obx(() {
          final items = stock.qrAImprimer;
          if (items.isEmpty) {
            return const Center(child: Text('Aucun code QR en attente d\'impression',
              style: TextStyle(color: AppColors.darkTextMuted)));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final item = items[i];
              return SynCard(child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.produitNom, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Lot: ${item.numeroLot ?? '—'}  ·  Emplacement: ${item.emplacement ?? '—'}',
                    style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted)),
                ])),
                IconButton(
                  icon: const Icon(Icons.qr_code_2_rounded, color: AppColors.primary),
                  tooltip: 'Imprimer',
                  onPressed: () => showLotQrDialog(item.lotId, item.numeroLot ?? '#${item.lotId}'),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.danger),
                  tooltip: 'Retirer de la liste',
                  onPressed: () => stock.supprimerQrAImprimer(item.id),
                ),
              ]));
            },
          );
        })),
      ]),
    );
  }
}

void showLotQrDialog(int lotId, String numeroLot) {
  Get.dialog(FutureBuilder<Either<String, Uint8List>>(
    future: StockRepositoryImpl().getLotQr(lotId),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const AlertDialog(content: SizedBox(height: 120,
          child: Center(child: CircularProgressIndicator())));
      }
      return snapshot.data!.fold(
        (e) => AlertDialog(title: const Text('Erreur'), content: Text(e)),
        (bytes) => AlertDialog(
          title: Text('QR — Lot $numeroLot'),
          content: SizedBox(width: 260, height: 300, child: Column(children: [
            Image.memory(bytes, width: 220, height: 220),
            const SizedBox(height: 10),
            const Text('Imprimez cette fenêtre (Ctrl+P) et collez le QR sur les cartons du lot.',
              style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted), textAlign: TextAlign.center),
          ])),
          actions: [TextButton(onPressed: () => Get.back(), child: const Text('Fermer'))],
        ),
      );
    },
  ));
}