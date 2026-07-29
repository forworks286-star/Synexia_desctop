import 'package:get/get.dart';

/// Remplace Get.back() partout dans l'application.
/// Ferme d'abord un eventuel snackbar encore ouvert (meme si son
/// animation de sortie est en cours) AVANT de fermer le dialog/ecran.
/// Sans ca, Get.back() risque de fermer le snackbar au lieu du dialog
/// quand un snackbar de validation vient d'etre affiche juste avant.
void safeBack() {
  if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
  Get.back();
}