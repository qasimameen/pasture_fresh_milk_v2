import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/string_utils.dart';
import '../../../models/supplier.dart';
import '../../../providers/supplier_provider.dart';
import '../../../providers/refresh_helper.dart';
import '../../../widgets/app_bottom_sheet.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_snack_bar.dart';
import '../../../widgets/app_text_field.dart';

/// Modal bottom sheet to add or edit a supplier.
class SupplierFormSheet extends ConsumerStatefulWidget {
  const SupplierFormSheet({super.key, this.supplier});

  final Supplier? supplier;

  /// Shows the [SupplierFormSheet] in an [AppBottomSheet].
  /// Returns [true] if the supplier was archived.
  static Future<bool?> show(BuildContext context, {Supplier? supplier}) {
    return AppBottomSheet.show<bool>(
      context: context,
      builder: (context) => SupplierFormSheet(supplier: supplier),
    );
  }

  @override
  ConsumerState<SupplierFormSheet> createState() => _SupplierFormSheetState();
}

class _SupplierFormSheetState extends ConsumerState<SupplierFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;
  late final TextEditingController _milkTypeController;
  late final TextEditingController _rateController;

  bool _isSubmitting = false;

  bool get _isEditMode => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier?.name);
    _phoneController = TextEditingController(text: widget.supplier?.phone);
    _locationController = TextEditingController(text: widget.supplier?.location);
    _milkTypeController = TextEditingController(text: widget.supplier?.milkType);
    _rateController = TextEditingController(
      text: widget.supplier?.ratePerLitre != null && widget.supplier!.ratePerLitre > 0
          ? (widget.supplier!.ratePerLitre % 1 == 0
              ? widget.supplier!.ratePerLitre.toInt().toString()
              : widget.supplier!.ratePerLitre.toString())
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _milkTypeController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (_isSubmitting) return;

    final name = StringUtils.capitalizeWords(_nameController.text);
    if (name.isEmpty) {
      AppSnackBar.show(context, message: l10n.errorSupplierNameRequired, error: true);
      return;
    }

    final rateStr = _rateController.text.trim();
    final rate = double.tryParse(rateStr) ?? 0.0;
    if (rate <= 0) {
      AppSnackBar.show(context, message: l10n.errorInvalidRate, error: true);
      return;
    }

    final phoneStr = _phoneController.text.trim();
    if (phoneStr.isNotEmpty && phoneStr.replaceAll(RegExp(r'\D'), '').length > 11) {
      AppSnackBar.show(context, message: l10n.errorPhoneTooLong, error: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final now = DateTime.now();
      final repo = ref.read(supplierRepositoryProvider);

      if (_isEditMode) {
        final supplier = widget.supplier!.copyWith(
          name: name,
          phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
          milkType: _milkTypeController.text.trim().isNotEmpty ? _milkTypeController.text.trim() : null,
          ratePerLitre: rate,
          updatedAt: now,
        );
        await repo.update(supplier);
      } else {
        final supplier = Supplier(
          id: IdGenerator.generate(),
          name: name,
          phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
          milkType: _milkTypeController.text.trim().isNotEmpty ? _milkTypeController.text.trim() : null,
          ratePerLitre: rate,
          isActive: true,
          pendingKhata: 0.0,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insert(supplier);
      }

      invalidateAllGlobalData(ref);

      if (mounted) {
        Navigator.of(context).pop();
        AppSnackBar.show(
          context,
          message: _isEditMode ? l10n.supplierUpdatedSuccess : l10n.supplierSavedSuccess,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppSnackBar.show(context, message: l10n.errorSavingSupplier, error: true);
      }
    }
  }

  Future<void> _archiveSupplier(AppLocalizations l10n) async {
    if (_isSubmitting) return;
    if (widget.supplier == null) return;

    if (widget.supplier!.pendingKhata.abs() > 0.009) {
      AppSnackBar.show(context, message: l10n.errorKhataMustBeCleared, error: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.archiveSupplierConfirmTitle),
        content: Text(l10n.archiveSupplierConfirmBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorMain),
            child: Text(l10n.actionConfirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(supplierRepositoryProvider);
      final supplier = widget.supplier!.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );
      await repo.update(supplier);
      
      invalidateAllGlobalData(ref);

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate archived
        AppSnackBar.show(context, message: l10n.supplierArchivedSuccess);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppSnackBar.show(context, message: l10n.errorSavingSupplier, error: true);
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
                _isEditMode ? l10n.editSupplierTitle : l10n.addSupplierTitle,
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
          const SizedBox(height: AppSpacing.spaceMd),

          AppTextField(
            key: const Key('supplier_name_field'),
            label: l10n.supplierNameLabel,
            hintText: l10n.supplierNameHint,
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            isRequired: true,
            prefixIcon: Symbols.storefront,
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          AppTextField(
            key: const Key('supplier_phone_field'),
            label: l10n.supplierPhoneLabel,
            hintText: '03XX XXXXXXX',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            prefixIcon: Symbols.call,
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          AppTextField(
            key: const Key('supplier_location_field'),
            label: l10n.supplierLocationLabel,
            hintText: l10n.supplierLocationHint,
            controller: _locationController,
            prefixIcon: Symbols.location_on,
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: AppTextField(
                  key: const Key('supplier_milk_type_field'),
                  label: l10n.supplierMilkTypeLabel,
                  hintText: l10n.supplierMilkTypeHint,
                  controller: _milkTypeController,
                  prefixIcon: Symbols.water_drop,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: AppTextField(
                  key: const Key('supplier_rate_field'),
                  label: l10n.supplierRateLabel,
                  hintText: l10n.supplierRateHint,
                  controller: _rateController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Symbols.payments,
                  suffixText: 'Rs/L',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceLg),

          // Submit Button
          AppButton(
            key: const Key('supplier_submit_button'),
            label: _isEditMode ? l10n.saveChangesAction : l10n.saveSupplierAction,
            icon: Symbols.check_circle,
            variant: AppButtonVariant.primary,
            isFullWidth: true,
            isLoading: _isSubmitting,
            onPressed: () => _submit(l10n),
          ),
          
          if (_isEditMode) ...<Widget>[
            const SizedBox(height: AppSpacing.spaceSm),
            TextButton(
              onPressed: () => _archiveSupplier(l10n),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.errorMain,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              child: Text(
                l10n.archiveSupplierAction,
                style: typography.labelLg,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
