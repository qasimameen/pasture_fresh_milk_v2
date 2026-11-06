import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/unit_formatter.dart';
import '../../../models/delivery.dart';
import '../../../models/product.dart';
import '../../../providers/product_provider.dart';
import '../../../widgets/delivery_note_text.dart';
import '../../../widgets/status_badge.dart';

class DeliveryCard extends ConsumerWidget {
  const DeliveryCard({super.key, required this.delivery});
  final Delivery delivery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);
    final d = delivery;

    final isMorning = d.shift.toLowerCase() == 'morning';
    final isExtra = d.shift.toLowerCase() == 'extra';
    final isSkipped = d.status == 'skipped';

    final q = d.isDelivered ? d.deliveredQuantity : d.scheduledQuantity;
    final qtyFormat = NumberFormat.decimalPattern(l10n.localeName)..maximumFractionDigits = 2;
    final qtyStr = qtyFormat.format(q);

    final products = ref.watch(productListProvider).valueOrNull ?? <Product>[];
    String? unit;
    if (d.productId != null) {
      for (final p in products) {
        if (p.id == d.productId) {
          unit = p.unit.localizeUnit(l10n.localeName);
          break;
        }
      }
    }

    final iconBg = isSkipped
        ? AppColors.errorLight
        : (isExtra ? AppColors.successLight : (isMorning ? AppColors.warningLight : AppColors.brandSoft));
    final iconColor = isSkipped
        ? AppColors.errorText
        : (isExtra ? AppColors.successMain : (isMorning ? AppColors.warningText : AppColors.brandPrimary));

    final timeFmt = DateFormat('hh:mm a');
    final timeStr = d.deliveryTime != null
        ? timeFmt.format(d.deliveryTime!)
        : null;
    final dateFmt = DateFormat('dd MMM, yyyy');
    final dateStr = dateFmt.format(d.date);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutralLine),
      ),
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Leading column: icon + amount ──────────────────────────────
          SizedBox(
            width: 56,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    isExtra
                        ? Symbols.local_shipping
                        : (isMorning ? Symbols.wb_sunny : Symbols.nights_stay),
                    size: 22,
                    color: iconColor,
                  ),
                ),
                if (!isSkipped) ...<Widget>[
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Rs. ${d.totalAmount.toStringAsFixed(0)}',
                      style: typography.bodySm.copyWith(
                        color: AppColors.neutralTitle,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.spaceMd),
          // ── Content column ─────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // ROW 1: product name | date+time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        d.productName.localized(l10n.localeName),
                        style: typography.bodySm.copyWith(
                          color: AppColors.neutralTitle,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceXs),
                    Text(
                      timeStr != null ? '$dateStr · $timeStr' : dateStr,
                      style: typography.caption.copyWith(
                        color: AppColors.neutralFaint,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceXs),
                // ROW 2: quantity + unit | status badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          if (unit != null && unit.isNotEmpty && l10n.localeName == 'ur') ...<Widget>[
                            Text(
                              unit,
                              style: typography.bodySm.copyWith(
                                color: AppColors.neutralBody,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.spaceXs),
                          ],
                          Text(
                            qtyStr,
                            style: typography.bodySm.copyWith(
                              color: AppColors.neutralBody,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (unit != null && unit.isNotEmpty && l10n.localeName != 'ur') ...<Widget>[
                            const SizedBox(width: AppSpacing.spaceXs),
                            Text(
                              unit,
                              style: typography.bodySm.copyWith(
                                color: AppColors.neutralBody,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceXs),
                    _StatusPill(
                      status: d.status,
                      l10n: l10n,
                      typography: typography,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceXs),
                // ROW 3: shift badge alone
                _ShiftBadge(
                  label: isExtra
                      ? 'Extra'
                      : (isMorning ? l10n.shiftMorning : l10n.shiftEvening),
                  isMorning: isMorning,
                  isExtra: isExtra,
                  typography: typography,
                ),
                // Conditional: skip reason
                if (isSkipped && d.skipReason != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.spaceXs),
                  Text(
                    d.skipReason!,
                    style: typography.caption.copyWith(
                      color: AppColors.errorText,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                // Conditional: delivery note
                if (d.isDelivered &&
                    d.receiverNote != null &&
                    d.receiverNote!.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.spaceXs),
                  DeliveryNoteText(note: d.receiverNote),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _ShiftBadge extends StatelessWidget {
  const _ShiftBadge({
    required this.label,
    required this.isMorning,
    this.isExtra = false,
    required this.typography,
  });
  final String label;
  final bool isMorning;
  final bool isExtra;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isExtra ? AppColors.successLight : (isMorning ? AppColors.warningLight : AppColors.brandSoft),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: typography.caption.copyWith(
          color: isExtra ? AppColors.successMain : (isMorning ? AppColors.warningText : AppColors.brandPrimary),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.status,
    required this.l10n,
    required this.typography,
  });
  final String status;
  final AppLocalizations l10n;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'delivered':
        return StatusBadge.active(label: l10n.deliveryStatusDelivered);
      case 'skipped':
        return StatusBadge.paused(label: l10n.deliveryStatusSkipped);
      default:
        return StatusBadge.paused(label: l10n.deliveryStatusPending);
    }
  }
}
