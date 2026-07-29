import 'package:get/get.dart';

/// Remplace Get.back() partout dans l'application.
/// Attend la fermeture COMPLETE d'un eventuel snackbar (animation incluse)
/// AVANT de fermer le dialog/ecran. Sans le "await", Get.back() s'execute
/// pendant que le snackbar est encore en train de se fermer, ce qui cree
/// un conflit d'overlay et bloque l'ecran.
Future<void> safeBack() async {
  if (Get.isSnackbarOpen) {
    await Get.closeCurrentSnackbar();
  }
  Get.back();
}