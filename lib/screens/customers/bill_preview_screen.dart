import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/services/receipt_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/app_snack_bar.dart';
import 'widgets/unified_bill_receipt.dart';

enum BillDateRange {
  thisMonth,
  lastMonth,
  last7Days,
  custom,
}

class BillPreviewScreen extends ConsumerStatefulWidget {
  final String customerId;

  const BillPreviewScreen({super.key, required this.customerId});

  @override
  ConsumerState<BillPreviewScreen> createState() => _BillPreviewScreenState();
}

class _BillPreviewScreenState extends ConsumerState<BillPreviewScreen> {
  BillDateRange _selectedRangeType = BillDateRange.thisMonth;
  late DateTime _startDate;
  late DateTime _endDate;
  final ReceiptService _receiptService = ReceiptService();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _setDatesForType(BillDateRange.thisMonth);
  }

  void _setDatesForType(BillDateRange type) {
    final now = DateTime.now();
    switch (type) {
      case BillDateRange.thisMonth:
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case BillDateRange.lastMonth:
        _startDate = DateTime(now.year, now.month - 1, 1);
        // The 0th day of the current month is the last day of the previous month
        _endDate = DateTime(now.year, now.month, 0, 23, 59, 59);
        break;
      case BillDateRange.last7Days:
        // Subtract 6 days to get exactly 7 days inclusive of today
        _startDate = now.subtract(const Duration(days: 6));
        _endDate = now;
        break;
      case BillDateRange.custom:
        // Do nothing here, handled by picker
        break;
    }
  }

  // _handleCustomDateRange removed as dates are picked inline

  Future<void> _handleShare(String customerName) async {
    if (_isGenerating) return;

    setState(() => _isGenerating = true);
    if (mounted) {
      AppSnackBar.show(context, message: 'Generating bill...');
    }

    try {
      await _receiptService.generateAndShareReceipt(
        context,
        UnifiedBillReceipt(
          customerId: widget.customerId,
          startDate: _startDate,
          endDate: _endDate,
        ),
        fileName: 'bill_${customerName.replaceAll(RegExp(r'\s+'), '_')}_${DateTime.now().millisecondsSinceEpoch}.png',
        locale: Localizations.localeOf(context),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    final customerAsync = ref.watch(customerByIdProvider(widget.customerId));
    final dateFormatter = DateFormat('dd MMM yyyy');

    final customerName = customerAsync.valueOrNull?.name ?? 'Customer';

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text('Preview Bill', style: typography.headlineLg.copyWith(color: AppColors.neutralTitle)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.neutralTitle),
        actions: [
          IconButton(
            icon: _isGenerating 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandPrimary)
                  )
                : const Icon(Symbols.share, color: AppColors.brandPrimary),
            onPressed: _isGenerating ? null : () => _handleShare(customerName),
            tooltip: 'Share Bill',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Area
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMd),
                  child: Row(
                    children: [
                      _buildChip('This Month', BillDateRange.thisMonth, typography),
                      const SizedBox(width: AppSpacing.spaceSm),
                      _buildChip('Last 7 Days', BillDateRange.last7Days, typography),
                      const SizedBox(width: AppSpacing.spaceSm),
                      _buildChip('Last Month', BillDateRange.lastMonth, typography),
                      const SizedBox(width: AppSpacing.spaceSm),
                      _buildChip('Custom', BillDateRange.custom, typography),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                if (_selectedRangeType == BillDateRange.custom)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg, vertical: AppSpacing.spaceXs),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildDateSelector(
                            label: 'Start Date',
                            date: _startDate,
                            typography: typography,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _startDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  _startDate = picked;
                                });
                              }
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.spaceSm),
                          child: Icon(Symbols.arrow_right_alt, color: AppColors.neutralMuted),
                        ),
                        Expanded(
                          child: _buildDateSelector(
                            label: 'End Date',
                            date: _endDate,
                            typography: typography,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _endDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    '${dateFormatter.format(_startDate)} - ${dateFormatter.format(_endDate)}',
                    style: typography.bodySm.copyWith(color: AppColors.neutralMuted),
                  ),
              ],
            ),
          ),
          
          // Preview Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.spaceLg),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    // Render the actual bill receipt
                    child: UnifiedBillReceipt(
                      customerId: widget.customerId,
                      startDate: _startDate,
                      endDate: _endDate,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime date,
    required AppTypography typography,
    required VoidCallback onTap,
  }) {
    final dateFormatter = DateFormat('dd MMM yyyy');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutralLine),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.scaffold,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: typography.caption.copyWith(color: AppColors.neutralMuted)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateFormatter.format(date), style: typography.bodySm.copyWith(fontWeight: FontWeight.w600)),
                const Icon(Symbols.calendar_month, size: 16, color: AppColors.brandPrimary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, BillDateRange type, AppTypography typography) {
    final isSelected = _selectedRangeType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      visualDensity: VisualDensity.compact,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedRangeType = type;
            if (type != BillDateRange.custom) {
              _setDatesForType(type);
            }
          });
        }
      },
      selectedColor: AppColors.brandPrimaryLight.withValues(alpha: 0.2),
      labelStyle: typography.bodySm.copyWith(
        color: isSelected ? AppColors.brandPrimary : AppColors.neutralTitle,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      backgroundColor: AppColors.scaffold,
      side: BorderSide(
        color: isSelected ? AppColors.brandPrimary : AppColors.neutralLine,
      ),
    );
  }
}
