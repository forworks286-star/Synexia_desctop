import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/models.dart';

class SynCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? borderLeft;

  const SynCard({super.key, required this.child, this.padding, this.onTap, this.borderLeft});

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      child: Container(
        decoration: borderLeft != null
            ? BoxDecoration(
                border: Border(left: BorderSide(color: borderLeft!, width: 3)),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );
    if (onTap != null) return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: card);
    return card;
  }
}

class KpiCard extends StatelessWidget {
  final String value;
  final String label;
  final String? trend;
  final bool trendUp;
  final Color? valueColor;
  final IconData icon;

  const KpiCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.trend,
    this.trendUp = true,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SynCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.darkTextMuted),
              const Spacer(),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (trendUp ? AppColors.success : AppColors.danger).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    trend!,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: trendUp ? AppColors.success : AppColors.danger),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: theme.textTheme.displayMedium?.copyWith(color: valueColor, fontSize: 26)),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final StockStatus status;
  final String label;

  const StatusChip({super.key, required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    Color c;
    switch (status) {
      case StockStatus.normal: c = AppColors.success; break;
      case StockStatus.low: c = AppColors.warning; break;
      case StockStatus.critical: c = AppColors.danger; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class InvoiceChip extends StatelessWidget {
  final InvoiceStatus status;
  final String label;

  const InvoiceChip({super.key, required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    Color c;
    switch (status) {
      case InvoiceStatus.validated: c = AppColors.success; break;
      case InvoiceStatus.rejected: c = AppColors.danger; break;
      case InvoiceStatus.pending: c = AppColors.warning; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class AlertDot extends StatelessWidget {
  final AlertLevel level;

  const AlertDot({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    Color c;
    switch (level) {
      case AlertLevel.danger: c = AppColors.danger; break;
      case AlertLevel.warning: c = AppColors.warning; break;
      case AlertLevel.success: c = AppColors.success; break;
      case AlertLevel.info: c = AppColors.secondary; break;
    }
    return Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle));
  }
}

class SynButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool outline;
  final Color? color;
  final IconData? icon;

  const SynButton({super.key, required this.label, this.onTap, this.isLoading = false, this.outline = false, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    final content = isLoading
        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 14), const SizedBox(width: 6)],
              Text(label),
            ],
          );

    if (outline) {
      return OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: c),
          foregroundColor: c,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(fontFamily: 'Syne', fontSize: 12, fontWeight: FontWeight.w700),
        ),
        child: content,
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(backgroundColor: c),
      child: content,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? action;

  const SectionTitle({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 14, color: AppColors.primary, margin: const EdgeInsets.only(right: 8)),
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.1)),
        if (action != null) ...[const Spacer(), action!],
      ],
    );
  }
}

class SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const SearchField({super.key, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search_rounded, size: 16, color: AppColors.darkTextMuted),
          isDense: true,
        ),
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  final String title;
  final List<Widget> actions;

  const PageHeader({super.key, required this.title, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        ...actions,
      ],
    );
  }
}
