import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/id_generator.dart';
import '../../../models/supplier.dart';
import '../../../models/supplier_payment.dart';
import '../../../providers/supplier_payment_provider.dart';
import '../../../providers/refresh_helper.dart';
import '../../../widgets/app_bottom_sheet.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_snack_bar.dart';
import '../../../widgets/app_text_field.dart';

/// Modal bottom sheet to record a cash payment to a supplier (plan.md C-M13).
class PaySupplierSheet extends ConsumerStatefulWidget {
  const PaySupplierSheet({
    super.key,
    required this.supplier,
    this.existing,
    this.onSuccess,
  });

  /// The supplier receiving payment.
  final Supplier supplier;

  /// Optional existing payment to edit.
  final SupplierPayment? existing;

  /// Optional callback upon successful payment.
  final VoidCallback? onSuccess;

  /// Shows the [PaySupplierSheet] in an [AppBottomSheet].
  static Future<void> show(
    BuildContext context, {
    required Supplier supplier,
    SupplierPayment? existing,
    VoidCallback? onSuccess,
  }) {
    return AppBottomSheet.show(
      context: context,
      builder: (context) => PaySupplierSheet(
        supplier: supplier,
        existing: existing,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  ConsumerState<PaySupplierSheet> createState() => _PaySupplierSheetState();
}

class _PaySupplierSheetState extends ConsumerState<PaySupplierSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _voucherController;
  late final TextEditingController _notesController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.existing != null ? widget.existing!.amount.toStringAsFixed(0) : '',
    );
    _voucherController = TextEditingController(text: widget.existing?.voucherNumber);
    _notesController = TextEditingController(text: widget.existing?.notes);

    if (widget.existing == null && widget.supplier.pendingKhata > 0) {
      _amountController.text = widget.supplier.pendingKhata.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _voucherController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _setAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(0);
    setState(() {});
  }

  void _addAmount(double increment) {
    final current = double.tryParse(_amountController.text.trim()) ?? 0.0;
    _amountController.text = (current + increment).toStringAsFixed(0);
    setState(() {});
  }

  Future<void> _submitPayment(AppLocalizations l10n) async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      AppSnackBar.show(context, message: l10n.errorAmountRequired, error: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final now = DateTime.now();
      final voucherText = _voucherController.text.trim();
      final notesText = _notesController.text.trim();

      final payment = SupplierPayment(
        id: IdGenerator.generate(),
        supplierId: widget.supplier.id,
        date: now,
        amount: amount,
        type: 'cash_payment',
        voucherNumber: voucherText.isNotEmpty ? voucherText : null,
        notes: notesText.isNotEmpty ? notesText : null,
        createdAt: now,
        updatedAt: now,
      );

      final repo = ref.read(supplierPaymentRepositoryProvider);
      
      if (widget.existing != null) {
        final updated = widget.existing!.copyWith(
          amount: amount,
          type: widget.existing!.type,
          voucherNumber: voucherText.isNotEmpty ? voucherText : null,
          notes: notesText.isNotEmpty ? notesText : null,
          updatedAt: now,
        );
        await repo.updatePayment(updated);
      } else {
        await repo.recordPayment(payment);
      }

      invalidateSupplierData(ref, widget.supplier.id);

      if (mounted) {
        Navigator.of(context).pop();
        AppSnackBar.show(
          context,
          message: widget.existing != null 
            ? l10n.entrySavedSuccess 
            : 'Payment of Rs. ${amount.toStringAsFixed(0)} recorded for ${widget.supplier.name}',
        );
        widget.onSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppSnackBar.show(context, message: 'Error: $e', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);

    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.only(
        start: AppSpacing.spaceLg,
        end: AppSpacing.spaceLg,
        top: AppSpacing.spaceSm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.spaceXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                widget.existing != null ? l10n.actionEditEntry : l10n.paySupplierModalTitle,
                style: typography.heading.copyWith(
                  color: AppColors.neutralTitle,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Symbols.close, color: AppColors.neutralMuted),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // Supplier strip
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceMd,
              vertical: AppSpacing.spaceSm,
            ),
            decoration: BoxDecoration(
              color: AppColors.brandSubtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.neutralLine),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.brandSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Symbols.agriculture,
                    size: 20,
                    color: AppColors.brandPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.supplier.name,
                        style: typography.bodySm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutralTitle,
                        ),
                      ),
                      Text(
                        '${l10n.amountOwedLabel}: Rs. ${widget.supplier.pendingKhata.toStringAsFixed(0)}',
                        style: typography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: widget.supplier.hasKhataPending
                              ? AppColors.errorText
                              : AppColors.successText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // Amount field
          AppTextField(
            label: l10n.amountLabel,
            hintText: '0',
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Symbols.payments,
            isRequired: true,
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // Quick selection chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                if (widget.supplier.pendingKhata > 0) ...<Widget>[
                  ActionChip(
                    label: Text('Full Khata (Rs. ${widget.supplier.pendingKhata.toStringAsFixed(0)})'),
                    onPressed: () => _setAmount(widget.supplier.pendingKhata),
                    backgroundColor: AppColors.brandSoft,
                    labelStyle: typography.caption.copyWith(
                      color: AppColors.brandPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                ActionChip(
                  label: const Text('+Rs. 1,000'),
                  onPressed: () => _addAmount(1000),
                  backgroundColor: AppColors.card,
                  labelStyle: typography.caption.copyWith(
                    color: AppColors.neutralTitle,
                  ),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('+Rs. 5,000'),
                  onPressed: () => _addAmount(5000),
                  backgroundColor: AppColors.card,
                  labelStyle: typography.caption.copyWith(
                    color: AppColors.neutralTitle,
                  ),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('+Rs. 10,000'),
                  onPressed: () => _addAmount(10000),
                  backgroundColor: AppColors.card,
                  labelStyle: typography.caption.copyWith(
                    color: AppColors.neutralTitle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // Voucher input
          AppTextField(
            label: 'VOUCHER NUMBER (OPTIONAL)',
            hintText: 'e.g. VCH-001',
            controller: _voucherController,
            prefixIcon: Symbols.receipt_long,
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // Notes input
          AppTextField(
            label: 'NOTES (OPTIONAL)',
            hintText: 'e.g. Morning batch payment',
            controller: _notesController,
            prefixIcon: Symbols.edit_note,
          ),
          const SizedBox(height: AppSpacing.spaceLg),

          // Submit button
          AppButton(
            label: widget.existing != null ? 'Save' : l10n.payCashAction,
            icon: Symbols.payments,
            variant: AppButtonVariant.primary,
            isFullWidth: true,
            isLoading: _isSubmitting,
            onPressed: () => _submitPayment(l10n),
          ),
        ],
      ),
    );
  }
}
