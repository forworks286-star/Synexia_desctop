import 'package:flutter/material.dart';
import '../../core/design/theme_extension.dart';
import '../../core/design/radii.dart';
import '../../core/design/shadows.dart';
import '../../domain/models/models.dart';

class SynCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? borderLeft;

  const SynCard({super.key, required this.child, this.padding, this.onTap, this.borderLeft});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Padding(padding: padding ?? const EdgeInsets.all(20), child: child);

    final body = borderLeft == null
        ? content
        : Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: borderLeft,
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(AppRadii.xl)),
                ),
              ),
              Expanded(child: content),
            ],
          );

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadii.rXl,
        border: Border.all(color: colors.border, width: 1),
        boxShadow: AppShadows.card(isDark),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? body
          : InkWell(onTap: onTap, hoverColor: colors.hover, child: body),
    );
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
    final colors = context.colors;
    final accent = valueColor ?? colors.primary;

    return SynCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: accent.withOpacity(0.12), borderRadius: AppRadii.rMd),
              child: Icon(icon, size: 17, color: accent),
            ),
            const Spacer(),
            if (trend != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: (trendUp ? colors.success : colors.danger).withOpacity(0.12),
                  borderRadius: AppRadii.rSm,
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(trendUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      size: 10, color: trendUp ? colors.success : colors.danger),
                  const SizedBox(width: 2),
                  Text(trend!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: trendUp ? colors.success : colors.danger)),
                ]),
              ),
          ]),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontFamily: 'Syne', fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: colors.text)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textMuted, letterSpacing: 0.2)),
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
    final colors = context.colors;
    late final Color c;
    switch (status) {
      case StockStatus.normal: c = colors.success; break;
      case StockStatus.low: c = colors.warning; break;
      case StockStatus.critical: c = colors.danger; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: AppRadii.rSm),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 5, height: 5, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class InvoiceChip extends StatelessWidget {
  final InvoiceStatus status;
  final String label;

  const InvoiceChip({super.key, required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    late final Color c;
    switch (status) {
      case InvoiceStatus.validated: c = colors.success; break;
      case InvoiceStatus.rejected: c = colors.danger; break;
      case InvoiceStatus.pending: c = colors.warning; break;
      case InvoiceStatus.annulee: c = colors.textMuted; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: AppRadii.rSm),
      child: Text(label, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class AlertDot extends StatelessWidget {
  final AlertLevel level;

  const AlertDot({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    late final Color c;
    switch (level) {
      case AlertLevel.danger: c = colors.danger; break;
      case AlertLevel.warning: c = colors.warning; break;
      case AlertLevel.success: c = colors.success; break;
      case AlertLevel.info: c = colors.secondary; break;
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
    final colors = context.colors;
    final c = color ?? colors.primary;

    final content = isLoading
        ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: outline ? c : Colors.white))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 15), const SizedBox(width: 7)],
              Text(label),
            ],
          );

    if (outline) {
      return OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color != null ? c : colors.border),
          foregroundColor: c,
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
    final colors = context.colors;
    return Row(
      children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(color: colors.primary, borderRadius: AppRadii.rXs), margin: const EdgeInsets.only(right: 8)),
        Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: colors.text)),
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
    final colors = context.colors;
    return SizedBox(
      width: 260,
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(fontSize: 13, color: colors.text),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(Icons.search_rounded, size: 17, color: colors.textMuted),
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
    final colors = context.colors;
    return Row(
      children: [
        Text(title, style: TextStyle(fontFamily: 'Syne', fontSize: 20, fontWeight: FontWeight.w700, color: colors.text, letterSpacing: -0.3)),
        const Spacer(),
        ...actions,
      ],
    );
  }
}