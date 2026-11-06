import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/supplier.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';

/// Supplier card displaying khata status and operational actions.
class SupplierCard extends StatelessWidget {
  const SupplierCard({
    super.key,
    required this.supplier,
    this.onViewKhata,
    required this.onLogDelivery,
  });

  /// The supplier entity.
  final Supplier supplier;

  /// Callback when "View Khata" is tapped.
  final VoidCallback? onViewKhata;

  /// Callback when "Log Delivery" is tapped.
  final VoidCallback onLogDelivery;

  Future<void> _makePhoneCall(String? phone) async {
    if (phone == null || phone.trim().isEmpty) return;
    final uri = Uri.parse('tel:${phone.trim()}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  Future<void> _openWhatsApp(String? phone) async {
    if (phone == null || phone.trim().isEmpty) return;
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);

    final isPending = supplier.pendingKhata > 0.009;
    final isAdvance = supplier.pendingKhata < -0.009;

    return AppCard(
      key: Key('supplier_card_${supplier.id}'),
      onTap: onViewKhata,
      borderColor: AppColors.neutralLine,
      margin: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Header Row: Avatar, Name/Location, Call/WhatsApp ─
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Initials Avatar (44x44, 14px radius)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.brandSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Symbols.agriculture,
                  size: 22,
                  color: AppColors.brandPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),

              // Name & Location / Milk Type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      supplier.name,
                      style: typography.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutralTitle,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (supplier.location != null &&
                            supplier.location!.isNotEmpty)
                          supplier.location!,
                        if (supplier.milkType != null &&
                            supplier.milkType!.isNotEmpty)
                          supplier.milkType!,
                      ].join(' • '),
                      style: typography.caption.copyWith(
                        color: AppColors.neutralMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.spaceXs),

              // Action Buttons: Call & WhatsApp
              if (supplier.phone != null && supplier.phone!.isNotEmpty) ...<Widget>[
                _CircleIconButton(
                  key: Key('call_supplier_btn_${supplier.id}'),
                  icon: Symbols.call,
                  color: AppColors.brandPrimary,
                  bgColor: AppColors.brandSoft,
                  onTap: () => _makePhoneCall(supplier.phone),
                ),
                const SizedBox(width: 6),
                _CircleIconButton(
                  key: Key('chat_supplier_btn_${supplier.id}'),
                  icon: Symbols.chat,
                  color: AppColors.successText,
                  bgColor: AppColors.successLight,
                  onTap: () => _openWhatsApp(supplier.phone),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // ── Rate Line ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                l10n.localeName == 'ur' ? 'ریٹ' : 'Rate',
                style: typography.caption.copyWith(color: AppColors.neutralMuted),
              ),
              Text(
                supplier.ratePerLitre > 0
                    ? 'Rs. ${supplier.ratePerLitre == supplier.ratePerLitre.toInt() ? supplier.ratePerLitre.toInt() : supplier.ratePerLitre}/L'
                    : '—',
                style: typography.bodySm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutralTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // ── Khata Banner ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isPending
                  ? AppColors.warningLight.withValues(alpha: 0.6)
                  : AppColors.successLight.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  isPending ? Symbols.pending : Symbols.check_circle,
                  size: 16,
                  color: isPending
                      ? AppColors.warningDark
                      : AppColors.successText,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isPending
                        ? '${l10n.pendingKhataLabel}: Rs. ${supplier.pendingKhata.toStringAsFixed(0)}'
                        : (isAdvance
                            ? '${l10n.advanceLabel}: Rs. ${supplier.pendingKhata.abs().toStringAsFixed(0)}'
                            : l10n.allClearedKhataLabel),
                    style: typography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isPending
                          ? AppColors.warningDark
                          : AppColors.successText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _ActionPillButton(
                  key: Key('view_khata_btn_${supplier.id}'),
                  label: l10n.viewKhataAction,
                  filled: false,
                  bgColor: Colors.white,
                  textColor: AppColors.neutralTitle,
                  onTap: onViewKhata,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // ── Log Delivery Button ──
          AppButton(
            key: Key('log_delivery_btn_${supplier.id}'),
            label: l10n.logDropAction,
            icon: Symbols.local_shipping,
            isFullWidth: true,
            variant: AppButtonVariant.primary,
            onPressed: onLogDelivery,
          ),
        ],
      ),
    );
  }
}



class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

class _ActionPillButton extends StatelessWidget {
  const _ActionPillButton({
    super.key,
    required this.label,
    required this.filled,
    required this.bgColor,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final Color bgColor;
  final Color textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: filled ? null : Border.all(color: AppColors.neutralLine),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
