import 'dart:io';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

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

Future<void> _telechargerQr(Uint8List bytes, String numeroLot) async {
  final path = await FilePicker.platform.saveFile(
    dialogTitle: 'Enregistrer le QR',
    fileName: 'QR_$numeroLot.png',
    type: FileType.custom,
    allowedExtensions: ['png'],
  );
  if (path == null) return;
  final file = File(path.endsWith('.png') ? path : '$path.png');
  await file.writeAsBytes(bytes);
  Get.snackbar('Téléchargé', 'Enregistré : ${file.path}',
    backgroundColor: AppColors.success.withOpacity(0.1), colorText: AppColors.success);
}

Future<void> _imprimerQr(Uint8List bytes, String numeroLot) async {
  final image = pw.MemoryImage(bytes);
  final doc = pw.Document();
  doc.addPage(pw.Page(build: (context) => pw.Center(child: pw.Image(image, width: 220, height: 220))));
  await Printing.layoutPdf(onLayout: (format) async => doc.save(), name: 'QR_$numeroLot');
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
          content: SizedBox(width: 260, height: 260, child: Center(
            child: Image.memory(bytes, width: 220, height: 220),
          )),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Télécharger'),
              onPressed: () => _telechargerQr(bytes, numeroLot),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.print_rounded, size: 18),
              label: const Text('Imprimer'),
              onPressed: () => _imprimerQr(bytes, numeroLot),
            ),
            TextButton(onPressed: () => Get.back(), child: const Text('Fermer')),
          ],
        ),
      );
    },
  ));
}