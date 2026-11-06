import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/customer.dart';
import '../../../providers/customer_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../providers/refresh_helper.dart';
import '../../../widgets/app_bottom_sheet.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_snack_bar.dart';
import '../../../widgets/app_text_field.dart';



/// Modal bottom sheet to record a customer payment or advance topup (plan.md C-M10).
///
/// Features:
/// - Header with customer name and financial summary pill
/// - Mode toggle: Pay Dues vs Advance Topup
/// - Amount field with quick-select chips (Pay Full, +Rs. 500, +Rs. 1,000, +Rs. 2,000)
/// - Method selection: Cash, Raast, Bank Transfer
/// - Optional receipt / Raast reference & notes
/// - Atomic balance updates via [PaymentRepository]
/// - Success callback and SnackBar confirmation
class RecordPaymentSheet extends ConsumerStatefulWidget {
  const RecordPaymentSheet({
    super.key,
    required this.customer,
    this.onSuccess,
  });

  /// The customer receiving the payment or topup.
  final Customer customer;

  /// Optional callback invoked upon successful recording.
  final VoidCallback? onSuccess;

  /// Shows the [RecordPaymentSheet] inside [AppBottomSheet].
  static Future<void> show(
    BuildContext context, {
    required Customer customer,
    VoidCallback? onSuccess,
  }) {
    return AppBottomSheet.show(
      context: context,
      builder: (context) => RecordPaymentSheet(
        customer: customer,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  ConsumerState<RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends ConsumerState<RecordPaymentSheet> {
  late TextEditingController _amountController;
  late TextEditingController _refController;
  late TextEditingController _notesController;

  String _selectedMethod = 'cash'; // 'cash', 'raast', 'bank_transfer'
  bool _isSubmitting = false;
  String? _amountError;

  @override
  void initState() {
    super.initState();

    // Default amount: prefill currentDue if greater than zero
    final defaultAmount = widget.customer.currentDue > 0
        ? widget.customer.currentDue.toStringAsFixed(0)
        : '';

    _amountController = TextEditingController(text: defaultAmount);
    _refController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    _notesController.dispose();
    super.dispose();
  }



  void _setAmount(double amount) {
    setState(() {
      _amountController.text = amount.toStringAsFixed(0);
      _amountError = null;
    });
  }

  void _addAmount(double increment) {
    final current = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final updated = current + increment;
    _setAmount(updated);
  }

  Future<void> _handleSubmit() async {
    final l10n = AppLocalizations.of(context);
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      setState(() {
        _amountError = l10n.errorAmountRequired;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _amountError = null;
    });

    final paymentRepo = ref.read(paymentRepositoryProvider);
    final refText = _refController.text.trim();
    final notesText = _notesController.text.trim();

    try {
      if (amount <= widget.customer.currentDue) {
        await paymentRepo.recordCashPayment(
          widget.customer.id,
          amount,
          _selectedMethod,
          receiptNumber: refText.isNotEmpty ? refText : null,
          raastRef: _selectedMethod == 'raast' && refText.isNotEmpty ? refText : null,
          notes: notesText.isNotEmpty ? notesText : null,
        );
      } else {
        if (widget.customer.currentDue > 0) {
          await paymentRepo.recordCashPayment(
            widget.customer.id,
            widget.customer.currentDue,
            _selectedMethod,
            receiptNumber: refText.isNotEmpty ? refText : null,
            raastRef: _selectedMethod == 'raast' && refText.isNotEmpty ? refText : null,
            notes: notesText.isNotEmpty ? notesText : null,
          );
        }
        final topupAmount = amount - widget.customer.currentDue;
        await paymentRepo.recordAdvanceTopup(
          widget.customer.id,
          topupAmount,
          _selectedMethod,
          receiptNumber: refText.isNotEmpty ? refText : null,
          raastRef: _selectedMethod == 'raast' && refText.isNotEmpty ? refText : null,
          notes: notesText.isNotEmpty ? notesText : null,
        );
      }

      // Invalidate customer & payment providers
      ref.invalidate(customerByIdProvider(widget.customer.id));
      ref.invalidate(allCustomersProvider);
      ref.invalidate(customerListProvider);
      ref.invalidate(customerStatsProvider);
      ref.invalidate(paymentListByCustomerProvider(widget.customer.id));
      ref.invalidate(todayCashTotalProvider);
      invalidateAllGlobalData(ref);

      if (!mounted) return;

      final successMsg = l10n.paymentRecordedSuccess(amount.toStringAsFixed(0));

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        AppSnackBar.show(context, message: successMsg);
      }
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      widget.onSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _amountError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: AppSpacing.spaceMd,
        right: AppSpacing.spaceMd,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.spaceLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ── Sheet Title & Customer Summary ──────────────────────
          Text(
            l10n.recordPaymentModalTitle,
            style: typography.heading.copyWith(
              color: AppColors.neutralTitle,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),

          // Customer balance strip
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceMd,
              vertical: AppSpacing.spaceSm,
            ),
            decoration: BoxDecoration(
              color: AppColors.scaffold,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.neutralLine),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.customer.name,
                        style: typography.bodySm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutralTitle,
                        ),
                      ),
                      Text(
                        widget.customer.phone,
                        style: typography.caption.copyWith(
                          color: AppColors.neutralMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      l10n.payableBalanceLabel,
                      style: typography.caption.copyWith(
                        color: AppColors.neutralMuted,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      'Rs. ${(widget.customer.currentDue < 0 ? 0 : widget.customer.currentDue).toStringAsFixed(0)}',
                      style: typography.labelMd.copyWith(
                        color: AppColors.errorText,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMd),


          // ── Amount Field ────────────────────────────────────────
          AppTextField(
            key: const Key('payment_amount_input'),
            controller: _amountController,
            label: l10n.amountLabel,
            hintText: '0',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffixText: 'Rs.',
            errorText: _amountError,
            isRequired: true,
            prefixIcon: Symbols.attach_money,
          ),
          const SizedBox(height: AppSpacing.spaceXs),

          // Quick Amount Shortcuts
          Wrap(
            spacing: AppSpacing.spaceXs,
            runSpacing: AppSpacing.spaceXs,
            children: <Widget>[
              if (widget.customer.currentDue > 0)
                _QuickAmountChip(
                  key: const Key('quick_chip_full_due'),
                  label: l10n.payFullDueShortcut(widget.customer.currentDue.toStringAsFixed(0)),
                  color: AppColors.errorLight,
                  textColor: AppColors.errorText,
                  onTap: () => _setAmount(widget.customer.currentDue),
                ),
              _QuickAmountChip(
                key: const Key('quick_chip_500'),
                label: '+500',
                onTap: () => _addAmount(500),
              ),
              _QuickAmountChip(
                key: const Key('quick_chip_1000'),
                label: '+1,000',
                onTap: () => _addAmount(1000),
              ),
              _QuickAmountChip(
                key: const Key('quick_chip_2000'),
                label: '+2,000',
                onTap: () => _addAmount(2000),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // ── Payment Method Selector ─────────────────────────────
          Text(
            'Payment Method',
            style: typography.caption.copyWith(
              color: AppColors.neutralMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              Expanded(
                child: _MethodCard(
                  key: const Key('method_cash_btn'),
                  label: l10n.paymentMethodCash,
                  icon: Symbols.payments,
                  isSelected: _selectedMethod == 'cash',
                  onTap: () => setState(() => _selectedMethod = 'cash'),
                ),
              ),
              const SizedBox(width: AppSpacing.spaceXs),
              Expanded(
                child: _MethodCard(
                  key: const Key('method_raast_btn'),
                  label: l10n.paymentMethodRaast,
                  icon: Symbols.qr_code_2,
                  isSelected: _selectedMethod == 'raast',
                  onTap: () => setState(() => _selectedMethod = 'raast'),
                ),
              ),
              const SizedBox(width: AppSpacing.spaceXs),
              Expanded(
                child: _MethodCard(
                  key: const Key('method_bank_btn'),
                  label: l10n.paymentMethodBank,
                  icon: Symbols.account_balance,
                  isSelected: _selectedMethod == 'bank_transfer',
                  onTap: () => setState(() => _selectedMethod = 'bank_transfer'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // ── Reference / Receipt Input ───────────────────────────
          AppTextField(
            key: const Key('payment_ref_input'),
            controller: _refController,
            label: l10n.receiptRefLabel,
            hintText: _selectedMethod == 'raast' ? 'Raast ID / Ref' : 'Receipt #',
            prefixIcon: Symbols.tag,
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // ── Optional Notes ──────────────────────────────────────
          AppTextField(
            key: const Key('payment_notes_input'),
            controller: _notesController,
            label: l10n.notesOptionalLabel,
            hintText: 'Any remark or note...',
            maxLines: 2,
            prefixIcon: Symbols.edit_note,
          ),
          const SizedBox(height: AppSpacing.spaceLg),

          // ── Submit Button ───────────────────────────────────────
          AppButton(
            key: const Key('submit_payment_btn'),
            label: l10n.recordPaymentCta,
            icon: Symbols.check,
            variant: AppButtonVariant.primary,
            isLoading: _isSubmitting,
            onPressed: _handleSubmit,
          ),
        ],
      ),
    );
  }
}

// ─── Subcomponents ────────────────────────────────────────────────────────────

class _QuickAmountChip extends StatelessWidget {
  const _QuickAmountChip({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.textColor,
  });

  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color ?? AppColors.brandSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color != null
                ? (textColor ?? AppColors.brandPrimary).withValues(alpha: 0.2)
                : AppColors.brandPrimary.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          label,
          style: typography.caption.copyWith(
            color: textColor ?? AppColors.brandPrimary,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandSoft : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.brandPrimary : AppColors.neutralLine,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.brandPrimary : AppColors.neutralMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: typography.caption.copyWith(
                color: isSelected ? AppColors.brandPrimary : AppColors.neutralBody,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
