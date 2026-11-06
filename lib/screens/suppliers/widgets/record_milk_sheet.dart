import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasture_fresh_milk/core/utils/date_display.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/id_generator.dart';
import '../../../models/milk_collection.dart';
import '../../../models/supplier.dart';
import '../../../providers/milk_collection_provider.dart';

import '../../../providers/refresh_helper.dart';
import '../../../widgets/app_bottom_sheet.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_snack_bar.dart';
import '../../../widgets/app_text_field.dart';

/// Modal bottom sheet to record inward milk from a supplier (plan.md C-M14).
class RecordMilkSheet extends ConsumerStatefulWidget {
  const RecordMilkSheet({
    super.key,
    required this.initialSupplier,
    this.initialDate,
    this.existing,
    this.onSuccess,
  });

  /// Pre-selected supplier.
  final Supplier initialSupplier;

  /// Initial collection date (defaults to today).
  final DateTime? initialDate;

  /// Optional existing collection to edit.
  final MilkCollection? existing;

  /// Optional callback upon successful save.
  final VoidCallback? onSuccess;

  /// Shows the [RecordMilkSheet] in an [AppBottomSheet].
  static Future<void> show(
    BuildContext context, {
    required Supplier initialSupplier,
    DateTime? initialDate,
    MilkCollection? existing,
    VoidCallback? onSuccess,
  }) {
    return AppBottomSheet.show(
      context: context,
      builder: (context) => RecordMilkSheet(
        initialSupplier: initialSupplier,
        initialDate: initialDate,
        existing: existing,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  ConsumerState<RecordMilkSheet> createState() => _RecordMilkSheetState();
}

class _RecordMilkSheetState extends ConsumerState<RecordMilkSheet> {
  late DateTime _selectedDate;
  late String _selectedShift;

  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (widget.existing != null) {
      _selectedDate = widget.existing!.date;
    } else {
      DateTime initial = widget.initialDate ?? now;
      DateTime initialDay = DateTime(initial.year, initial.month, initial.day);
      _selectedDate = initialDay.isAfter(today) ? today : initial;
    }
    _selectedShift = widget.existing?.shift ?? (now.hour < 15 ? 'morning' : 'evening');

    _quantityController = TextEditingController(text: widget.existing?.quantity.toStringAsFixed(1))
      ..addListener(_updateBatchValue);
    _notesController = TextEditingController(text: widget.existing?.notes);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateBatchValue() {
    setState(() {});
  }

  double get _supplierRate => widget.existing?.rate ?? widget.initialSupplier.ratePerLitre;

  double get _calculatedBatchValue {
    final qty = double.tryParse(_quantityController.text.trim()) ?? 0.0;
    final rate = _supplierRate;
    if (qty > 0 && rate > 0) {
      return qty * rate;
    }
    return 0.0;
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (_isSubmitting) return;

    final supplier = widget.initialSupplier;

    final qty = double.tryParse(_quantityController.text.trim());
    if (qty == null || qty <= 0) {
      AppSnackBar.show(
        context,
        message: l10n.errorQuantityRequired,
        error: true,
      );
      return;
    }

    final rate = widget.existing?.rate ?? supplier.ratePerLitre;
    if (rate <= 0) {
      AppSnackBar.show(
        context,
        message: l10n.errorSupplierRateNotSet,
        error: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final now = DateTime.now();
      final notesText = _notesController.text.trim();

      final repo = ref.read(milkCollectionRepositoryProvider);
      if (widget.existing != null) {
        final updated = widget.existing!.copyWith(
          date: _selectedDate,
          shift: _selectedShift,
          quantity: qty,
          batchValue: qty * rate,
          notes: notesText.isNotEmpty ? notesText : null,
          updatedAt: now,
        );
        await repo.updateCollection(updated);
      } else {
        final collection = MilkCollection(
          id: IdGenerator.generate(),
          supplierId: supplier.id,
          date: _selectedDate,
          shift: _selectedShift,
          quantity: qty,
          rate: rate,
          batchValue: qty * rate,
          status: 'recorded',
          loggedTime: now,
          notes: notesText.isNotEmpty ? notesText : null,
          createdAt: now,
          updatedAt: now,
        );
        await repo.recordCollection(collection);
      }

      // Invalidate relevant providers to update UI reactivity
      invalidateSupplierData(ref, supplier.id);

      if (mounted) {
        Navigator.of(context).pop();
        AppSnackBar.show(context, message: widget.existing != null ? l10n.entrySavedSuccess : l10n.batchRecordedSuccess);
        widget.onSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppSnackBar.show(
          context,
          message: l10n.errorRecordingMilk,
          error: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);

    final now = DateTime.now();
    final isNotToday = _selectedDate.year != now.year ||
        _selectedDate.month != now.month ||
        _selectedDate.day != now.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = _selectedDate.year == yesterday.year &&
        _selectedDate.month == yesterday.month &&
        _selectedDate.day == yesterday.day;
    final dateStr = formatShortDate(_selectedDate);

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
                widget.existing != null ? l10n.actionEditEntry : l10n.recordMilkModalTitle,
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

          // Date Display (Read-only)
          InkWell(
            onTap: () async {
              final nowDay = DateTime.now();
              final today = DateTime(nowDay.year, nowDay.month, nowDay.day);
              final firstDate = DateTime(2020);
              
              DateTime initDate = _selectedDate;
              DateTime selDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
              if (selDay.isAfter(today)) {
                initDate = today;
              }
              if (initDate.isBefore(firstDate)) {
                initDate = firstDate;
              }

              final picked = await showDatePicker(
                context: context,
                initialDate: initDate,
                firstDate: firstDate,
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _selectedDate = DateTime(picked.year, picked.month, picked.day));
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.spaceMd),
              decoration: BoxDecoration(
                color: AppColors.scaffold,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.neutralLine),
              ),
              child: Row(
                children: [
                  const Icon(
                    Symbols.calendar_today,
                    size: 20,
                    color: AppColors.brandPrimary,
                  ),
                  const SizedBox(width: AppSpacing.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.recordDateLabel,
                          style: typography.caption.copyWith(color: AppColors.neutralMuted),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                dateStr,
                                style: typography.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isNotToday ? AppColors.warningMain : AppColors.neutralTitle,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isNotToday) ...[
                              const SizedBox(width: AppSpacing.spaceSm),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.successLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  l10n.filterToday,
                                  style: typography.caption.copyWith(
                                    color: AppColors.successText,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  const Icon(
                    Symbols.expand_more,
                    size: 20,
                    color: AppColors.neutralMuted,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Row(
            children: [
              ChoiceChip(
                label: Text(l10n.filterToday),
                selected: !isNotToday,
                onSelected: (selected) {
                  if (selected) {
                    final now = DateTime.now();
                    setState(() => _selectedDate = DateTime(now.year, now.month, now.day));
                  }
                },
                selectedColor: AppColors.brandSoft,
                labelStyle: typography.bodySm.copyWith(
                  fontWeight: !isNotToday ? FontWeight.w700 : FontWeight.w500,
                  color: !isNotToday ? AppColors.brandPrimary : AppColors.neutralTitle,
                ),
                backgroundColor: AppColors.scaffold,
                side: BorderSide(
                  color: !isNotToday ? AppColors.brandPrimary : AppColors.neutralLine,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              ChoiceChip(
                label: Text(l10n.filterYesterday),
                selected: isYesterday,
                onSelected: (selected) {
                  if (selected) {
                    final yesterday = DateTime.now().subtract(const Duration(days: 1));
                    setState(() => _selectedDate = DateTime(yesterday.year, yesterday.month, yesterday.day));
                  }
                },
                selectedColor: AppColors.brandSoft,
                labelStyle: typography.bodySm.copyWith(
                  fontWeight: isYesterday ? FontWeight.w700 : FontWeight.w500,
                  color: isYesterday ? AppColors.brandPrimary : AppColors.neutralTitle,
                ),
                backgroundColor: AppColors.scaffold,
                side: BorderSide(
                  color: isYesterday ? AppColors.brandPrimary : AppColors.neutralLine,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // Supplier Selection (Read-only)
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
                        widget.initialSupplier.name,
                        style: typography.bodySm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutralTitle,
                        ),
                      ),
                      Text(
                        widget.initialSupplier.location ?? '',
                        style: typography.caption.copyWith(
                          color: AppColors.neutralMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Read-only rate display
          const SizedBox(height: AppSpacing.spaceSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                l10n.ratePerLitre,
                style: typography.bodySm.copyWith(
                  color: AppColors.neutralMuted,
                ),
              ),
              Text(
                _supplierRate > 0
                    ? 'Rs. ${_supplierRate % 1 == 0 ? _supplierRate.toInt() : _supplierRate} / L'
                    : '—',
                style: typography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutralTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // Shift Segmented Picker
          Row(
            children: <Widget>[
              Expanded(
                child: _ShiftButton(
                  label: l10n.shiftMorning,
                  icon: Symbols.wb_sunny,
                  isSelected: _selectedShift == 'morning',
                  onTap: () => setState(() => _selectedShift = 'morning'),
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: _ShiftButton(
                  label: l10n.shiftEvening,
                  icon: Symbols.nights_stay,
                  isSelected: _selectedShift == 'evening',
                  onTap: () => setState(() => _selectedShift = 'evening'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // Quantity Input
          AppTextField(
            key: const Key('record_milk_quantity_field'),
            label: l10n.quantityLitresLabel,
            hintText: '0.0',
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            isRequired: true,
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // Live Calculated Batch Value Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.spaceMd),
            decoration: BoxDecoration(
              color: AppColors.brandSubtle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.brandPrimary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.batchValueCalculatedLabel.toUpperCase(),
                      style: typography.caption.copyWith(
                        color: AppColors.brandPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rs. ${_calculatedBatchValue.toStringAsFixed(0)}',
                      style: typography.heading.copyWith(
                        color: AppColors.brandPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.brandSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Symbols.payments,
                    color: AppColors.brandPrimary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // Notes (Optional)
          AppTextField(
            key: const Key('record_milk_notes_field'),
            label: l10n.notesOptionalLabel,
            hintText: 'e.g. Clean transport crate, batch verified',
            controller: _notesController,
            prefixIcon: Symbols.edit_note,
          ),
          const SizedBox(height: AppSpacing.spaceLg),

          // Submit Button
          AppButton(
            key: const Key('record_milk_submit_button'),
            label: widget.existing != null ? 'Save' : l10n.recordBatchAction,
            icon: Symbols.check_circle,
            variant: AppButtonVariant.primary,
            isFullWidth: true,
            isLoading: _isSubmitting,
            onPressed: () => _submit(l10n),
          ),
        ],
      ),
    );
  }
}

class _ShiftButton extends StatelessWidget {
  const _ShiftButton({
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
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceSm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandSoft : AppColors.scaffold,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.brandPrimary : AppColors.neutralLine,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? AppColors.brandPrimary
                  : AppColors.neutralMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: typography.bodySm.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.brandPrimary
                    : AppColors.neutralTitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
