import 'package:get/get.dart';

Future<void> safeBack() async {
  if (Get.isSnackbarOpen) {
    await Get.closeCurrentSnackbar();
  }
  Get.back();
}