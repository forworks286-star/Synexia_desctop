import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ToastType { success, error, warning, info }

class _ToastData {
  final String id;
  final String title;
  final String? message;
  final ToastType type;
  _ToastData(this.id, this.title, this.message, this.type);
}

/// Système de notifications totalement indépendant de GetX.
/// Ne partage aucun mécanisme avec Get.dialog / Navigator / Overlay —
/// ne peut donc jamais bloquer, retarder, ou entrer en conflit avec
/// la fermeture d'un écran ou d'un dialogue.
class AppToastHost extends StatefulWidget {
  final Widget child;
  const AppToastHost({super.key, required this.child});

  static final GlobalKey<_AppToastHostState> _hostKey = GlobalKey<_AppToastHostState>();

  static Widget wrap(Widget child) => AppToastHost(key: _hostKey, child: child);

  static void _show(String title, String? message, ToastType type) {
    _hostKey.currentState?._addToast(title, message, type);
  }

  @override
  State<AppToastHost> createState() => _AppToastHostState();
}

class _AppToastHostState extends State<AppToastHost> {
  final List<_ToastData> _toasts = [];
  int _counter = 0;

  void _addToast(String title, String? message, ToastType type) {
    final id = 't${_counter++}';
    if (!mounted) return;
    setState(() => _toasts.add(_ToastData(id, title, message, type)));
    Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _toasts.removeWhere((t) => t.id == id));
    });
  }

  Color _bg(ToastType t) {
    switch (t) {
      case ToastType.success: return AppColors.success;
      case ToastType.error: return AppColors.danger;
      case ToastType.warning: return AppColors.warning;
      case ToastType.info: return AppColors.darkCard;
    }
  }

  IconData _icon(ToastType t) {
    switch (t) {
      case ToastType.success: return Icons.check_circle_outline_rounded;
      case ToastType.error: return Icons.error_outline_rounded;
      case ToastType.warning: return Icons.warning_amber_rounded;
      case ToastType.info: return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      widget.child,
      Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        child: IgnorePointer(
          child: Column(
            children: _toasts.map((t) => Padding(
              key: ValueKey(t.id),
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _bg(t.type),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Row(children: [
                    Icon(_icon(t.type), color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Text(t.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      if (t.message != null && t.message!.isNotEmpty)
                        Text(t.message!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ])),
                  ]),
                ),
              ),
            )).toList(),
          ),
        ),
      ),
    ]);
  }
}

class AppToast {
  static void success(String title, [String? message]) => AppToastHost._show(title, message, ToastType.success);
  static void error(String title, [String? message]) => AppToastHost._show(title, message, ToastType.error);
  static void warning(String title, [String? message]) => AppToastHost._show(title, message, ToastType.warning);
  static void info(String title, [String? message]) => AppToastHost._show(title, message, ToastType.info);
}