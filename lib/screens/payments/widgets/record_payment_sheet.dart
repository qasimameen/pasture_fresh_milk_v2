import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/customer.dart';
import '../../../providers/customer_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../providers/refresh_helper.dart';
import '../../../widgets/app_bottom_sheet.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_snack_bar.dart';
import '../../../widgets/app_text_field.dart';

/// Supported payment modes in [RecordPaymentSheet].
enum PaymentMode {
  /// Paying off existing customer dues (cash_payment).
  dues,

  /// Adding advance prepaid credit (advance_topup).
  topup,
}

/// Modal bottom sheet to record a customer payment or advance topup (plan.md C-M12).
///
/// Features:
/// - Customer selector dropdown (when customer not pre-specified)
/// - Selected customer financial summary (Dues / Advance)
/// - Mode toggle: Pay Dues vs Advance Topup
/// - Amount field with quick-select chips (Pay Full, +Rs. 500, +Rs. 1,000, +Rs. 2,000)
/// - Method selection: Cash, Raast, Bank Transfer
/// - Optional Raast reference & notes
/// - Atomic balance updates via [PaymentRepository]
/// - Confirmation and Riverpod invalidation
class RecordPaymentSheet extends ConsumerStatefulWidget {
  const RecordPaymentSheet({
    super.key,
    this.customer,
    this.initialMode = PaymentMode.dues,
    this.onSuccess,
  });

  /// Optional initial customer. If null, a customer picker is presented.
  final Customer? customer;

  /// Initial mode displayed when sheet opens.
  final PaymentMode initialMode;

  /// Optional callback invoked upon successful recording.
  final VoidCallback? onSuccess;

  /// Shows the [RecordPaymentSheet] inside [AppBottomSheet].
  static Future<void> show(
    BuildContext context, {
    Customer? customer,
    PaymentMode initialMode = PaymentMode.dues,
    VoidCallback? onSuccess,
  }) {
    return AppBottomSheet.show(
      context: context,
      builder: (context) => RecordPaymentSheet(
        customer: customer,
        initialMode: initialMode,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  ConsumerState<RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends ConsumerState<RecordPaymentSheet> {
  Customer? _selectedCustomer;
  late PaymentMode _currentMode;
  String _selectedMethod = 'cash'; // 'cash' | 'raast' | 'bank_transfer'
  bool _isSubmitting = false;

  late final TextEditingController _amountController;
  late final TextEditingController _raastRefController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.customer;
    _currentMode = widget.initialMode;
    _amountController = TextEditingController();
    _raastRefController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _raastRefController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addAmount(double increment) {
    final current = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final updated = current + increment;
    _amountController.text = updated.toStringAsFixed(0);
    setState(() {});
  }

  void _setAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(0);
    setState(() {});
  }

  Future<void> _handleSubmit(AppLocalizations l10n) async {
    final customer = _selectedCustomer;
    if (customer == null) {
      AppSnackBar.show(context, message: l10n.errorNameRequired, error: true);
      return;
    }

    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      AppSnackBar.show(context, message: l10n.errorAmountRequired, error: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final paymentRepo = ref.read(paymentRepositoryProvider);
      final raastRef = _raastRefController.text.trim().isNotEmpty
          ? _raastRefController.text.trim()
          : null;
      final notes = _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null;

      if (_currentMode == PaymentMode.dues) {
        await paymentRepo.recordCashPayment(
          customer.id,
          amount,
          _selectedMethod,
          raastRef: raastRef,
          notes: notes,
        );
      } else {
        await paymentRepo.recordAdvanceTopup(
          customer.id,
          amount,
          _selectedMethod,
          raastRef: raastRef,
          notes: notes,
        );
      }

      // Refresh providers
      ref.invalidate(todayPaymentsProvider);
      ref.invalidate(todayCashTotalProvider);
      ref.invalidate(customerListProvider);
      ref.invalidate(allCustomersProvider);
      ref.invalidate(customerByIdProvider(customer.id));
      ref.invalidate(customerStatsProvider);
      ref.invalidate(paymentListByCustomerProvider(customer.id));
      ref.invalidate(dashboardProvider);
      invalidateAllGlobalData(ref);

      if (mounted) {
        final successMsg = _currentMode == PaymentMode.dues
            ? l10n.paymentRecordedSuccess(amount.toStringAsFixed(0))
            : l10n.topupRecordedSuccess(amount.toStringAsFixed(0));
        AppSnackBar.show(context, message: successMsg);

        widget.onSuccess?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
          error: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);
    final customersAsync = ref.watch(customerListProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: AppSpacing.spaceLg,
        right: AppSpacing.spaceLg,
        top: AppSpacing.spaceSm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.spaceXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // ── Header Title ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                _currentMode == PaymentMode.dues
                    ? l10n.recordPaymentModalTitle
                    : l10n.addTopupModalTitle,
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

          // ── Customer Picker (Dropdown if not pre-specified) ───────
          if (widget.customer == null)
            customersAsync.when(
              data: (customers) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.customerNameLabel,
                      style: typography.bodySm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutralTitle,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neutralLine),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Customer>(
                          isExpanded: true,
                          value: _selectedCustomer,
                          hint: Text(
                            l10n.customerNameLabel,
                            style: typography.bodySm.copyWith(
                              color: AppColors.neutralFaint,
                            ),
                          ),
                          items: customers.map((c) {
                            return DropdownMenuItem<Customer>(
                              value: c,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    c.name,
                                    style: typography.bodySm.copyWith(
                                      color: AppColors.neutralTitle,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (c.currentDue > 0)
                                    Text(
                                      'Due: Rs. ${c.currentDue.toStringAsFixed(0)}',
                                      style: typography.caption.copyWith(
                                        color: AppColors.errorText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (c) {
                            setState(() {
                              _selectedCustomer = c;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceSm),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),

          // ── Selected Customer Balance Card ────────────────────────
          if (_selectedCustomer != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.spaceMd),
              decoration: BoxDecoration(
                color: AppColors.brandSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.brandPrimary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        l10n.payableBalanceLabel,
                        style: typography.caption.copyWith(
                          color: AppColors.neutralMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Rs. ${(_selectedCustomer!.currentDue < 0 ? 0 : _selectedCustomer!.currentDue).toStringAsFixed(0)}',
                        style: typography.subhead.copyWith(
                          color: _selectedCustomer!.currentDue > 0
                              ? AppColors.errorText
                              : AppColors.neutralTitle,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: AppColors.neutralLine,
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        l10n.prepaidReserveLabel,
                        style: typography.caption.copyWith(
                          color: AppColors.neutralMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Rs. ${(_selectedCustomer!.advanceBalance < 0 ? 0 : _selectedCustomer!.advanceBalance).toStringAsFixed(0)}',
                        style: typography.subhead.copyWith(
                          color: AppColors.brandPrimary,
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
          ],

          // ── Mode Toggle: Pay Dues vs Advance Topup ─────────────────
          Container(
            decoration: BoxDecoration(
              color: AppColors.brandSubtle,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _ModePill(
                    label: l10n.paymentModeDues,
                    isSelected: _currentMode == PaymentMode.dues,
                    onTap: () => setState(() => _currentMode = PaymentMode.dues),
                  ),
                ),
                Expanded(
                  child: _ModePill(
                    label: l10n.paymentModeAdvance,
                    isSelected: _currentMode == PaymentMode.topup,
                    onTap: () => setState(() => _currentMode = PaymentMode.topup),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // ── Amount Input Field ────────────────────────────────────
          AppTextField(
            controller: _amountController,
            label: l10n.amountLabel,
            prefixIcon: Symbols.attach_money,
            suffixText: 'Rs.',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            hintText: '0',
          ),
          const SizedBox(height: AppSpacing.spaceXs),

          // ── Quick Increment Chips ─────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: <Widget>[
              if (_currentMode == PaymentMode.dues &&
                  _selectedCustomer != null &&
                  _selectedCustomer!.currentDue > 0)
                ActionChip(
                  label: Text(
                    l10n.payFullDueShortcut(_selectedCustomer!.currentDue.toStringAsFixed(0)),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: AppColors.brandSoft,
                  labelStyle: const TextStyle(color: AppColors.brandPrimary),
                  onPressed: () => _setAmount(_selectedCustomer!.currentDue),
                ),
              ActionChip(
                label: const Text('+500'),
                onPressed: () => _addAmount(500),
              ),
              ActionChip(
                label: const Text('+1,000'),
                onPressed: () => _addAmount(1000),
              ),
              ActionChip(
                label: const Text('+2,000'),
                onPressed: () => _addAmount(2000),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // ── Payment Method Chips ──────────────────────────────────
          Text(
            'Payment Method',
            style: typography.bodySm.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutralTitle,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              Expanded(
                child: _MethodOption(
                  label: l10n.paymentMethodCash,
                  icon: Symbols.payments,
                  isSelected: _selectedMethod == 'cash',
                  onTap: () => setState(() => _selectedMethod = 'cash'),
                ),
              ),
              const SizedBox(width: AppSpacing.spaceXs),
              Expanded(
                child: _MethodOption(
                  label: l10n.paymentMethodRaast,
                  icon: Symbols.bolt,
                  isSelected: _selectedMethod == 'raast',
                  onTap: () => setState(() => _selectedMethod = 'raast'),
                ),
              ),
              const SizedBox(width: AppSpacing.spaceXs),
              Expanded(
                child: _MethodOption(
                  label: l10n.paymentMethodBank,
                  icon: Symbols.account_balance,
                  isSelected: _selectedMethod == 'bank_transfer',
                  onTap: () => setState(() => _selectedMethod = 'bank_transfer'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // ── Raast Ref (if method is raast) ────────────────────────
          if (_selectedMethod == 'raast') ...[
            AppTextField(
              controller: _raastRefController,
              label: l10n.receiptRefLabel,
              hintText: 'e.g. #PK-RAAST-B92147',
            ),
            const SizedBox(height: AppSpacing.spaceMd),
          ],

          // ── Notes Field ───────────────────────────────────────────
          AppTextField(
            controller: _notesController,
            label: l10n.notesOptionalLabel,
            hintText: 'Optional notes...',
          ),
          const SizedBox(height: AppSpacing.spaceLg),

          // ── Submit Button ─────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: _isSubmitting ? null : () => _handleSubmit(l10n),
              label: _currentMode == PaymentMode.dues
                  ? l10n.recordPaymentCta
                  : l10n.addTopupCta,
              isLoading: _isSubmitting,
              variant: AppButtonVariant.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.card : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.brandPrimary : AppColors.neutralMuted,
          ),
        ),
      ),
    );
  }
}

class _MethodOption extends StatelessWidget {
  const _MethodOption({
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandSoft : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.brandPrimary : AppColors.neutralLine,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.brandPrimary
                  : AppColors.neutralMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.brandPrimary
                    : AppColors.neutralBody,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
