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
import '../../../models/customer.dart';
import '../../../models/product.dart';

import '../../../providers/customer_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/product_provider.dart';

import '../../../providers/refresh_helper.dart';
import '../../../widgets/app_bottom_sheet.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dropdown.dart';
import '../../../widgets/app_snack_bar.dart';
import '../../../widgets/app_text_field.dart';

/// Modal bottom sheet for creating or editing customer profiles (plan.md C-M5).
///
/// Features:
/// - Add and Edit mode support (pre-populates existing customer when editing)
/// - Name & Phone inputs (required)
/// - Delivery sequence order
/// - Preferred Shift dropdown (Morning / Evening / Both)
/// - Morning and Evening quotas (at least one > 0)
/// - Product selection with automatic agreed rate auto-fill
/// - Agreed rate input with validation (> 0)
/// - Free-form notes
/// - SQLite persistence via [CustomerRepository]
class AddCustomerSheet extends ConsumerStatefulWidget {
  /// Creates the [AddCustomerSheet].
  const AddCustomerSheet({
    super.key,
    this.customerToEdit,
  });

  /// The customer profile being edited, or null when creating a new customer.
  final Customer? customerToEdit;

  /// Shows the customer creation/editing bottom sheet modal.
  ///
  /// Returns `true` if a customer was successfully created or updated.
  static Future<bool?> show(
    BuildContext context, {
    Customer? customerToEdit,
  }) async {
    final result = await AppBottomSheet.show<bool>(
      context: context,
      builder: (context) => AddCustomerSheet(customerToEdit: customerToEdit),
    );

    if (result == true && context.mounted) {
      final l10n = AppLocalizations.of(context);
      AppSnackBar.show(
        context,
        message: customerToEdit != null
            ? l10n.customerUpdatedMessage
            : l10n.customerAddedMessage,
      );
    }
    return result;
  }

  @override
  ConsumerState<AddCustomerSheet> createState() => _AddCustomerSheetState();
}

class _AddCustomerSheetState extends ConsumerState<AddCustomerSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
    late final TextEditingController _addressController;
  late final TextEditingController _quotaAmController;
  late final TextEditingController _quotaPmController;
  late final TextEditingController _rateController;
  late final TextEditingController _notesController;

  Product? _selectedProduct;
  bool _initializedDropdowns = false;
  String _selectedStatus = 'active';

  String? _nameError;
  String? _phoneError;
  String? _rateError;
  String? _quotaError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.customerToEdit;
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _addressController = TextEditingController(text: c?.address ?? '');
    _quotaAmController = TextEditingController(
      text: c != null ? (c.dailyQuotaAm > 0 ? '${c.dailyQuotaAm}' : '') : '',
    );
    _quotaPmController = TextEditingController(
      text: c != null ? (c.dailyQuotaPm > 0 ? '${c.dailyQuotaPm}' : '') : '',
    );
    _rateController = TextEditingController(
      text: c != null ? c.agreedRate.toStringAsFixed(0) : '',
    );
    _notesController = TextEditingController(text: c?.notes ?? '');
    _selectedStatus = c?.status ?? 'active';
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _quotaAmController.dispose();
    _quotaPmController.dispose();
    _rateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onProductSelected(Product product) {
    setState(() {
      _selectedProduct = product;
      // Auto-fill agreed rate from product default if empty or adding new customer
      if (widget.customerToEdit == null || _rateController.text.trim().isEmpty) {
        _rateController.text = product.defaultRate.toStringAsFixed(0);
        _rateError = null;
      }
    });
  }

  Future<void> _handleSave() async {
    final l10n = AppLocalizations.of(context);
    final name = StringUtils.capitalizeWords(_nameController.text);
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final quotaAm = double.tryParse(_quotaAmController.text.trim()) ?? 0.0;
    final quotaPm = double.tryParse(_quotaPmController.text.trim()) ?? 0.0;
    final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
    final notes = _notesController.text.trim();

    bool hasError = false;

    if (name.isEmpty) {
      _nameError = l10n.errorNameRequired;
      hasError = true;
    } else {
      _nameError = null;
    }

    if (phone.isEmpty) {
      _phoneError = l10n.errorPhoneRequired;
      hasError = true;
    } else if (phone.replaceAll(RegExp(r'\D'), '').length > 11) {
      _phoneError = l10n.errorPhoneTooLong;
      hasError = true;
    } else {
      _phoneError = null;
    }

    if (rate <= 0) {
      _rateError = l10n.errorInvalidRate;
      hasError = true;
    } else {
      _rateError = null;
    }

    if (quotaAm <= 0 && quotaPm <= 0) {
      _quotaError = l10n.errorQuotaRequired;
      hasError = true;
    } else {
      _quotaError = null;
    }

    if (hasError) {
      setState(() {});
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final repo = ref.read(customerRepositoryProvider);
    final now = DateTime.now();

    try {
      if (widget.customerToEdit == null) {
        // Create mode
        final newCustomer = Customer(
          id: IdGenerator.generate(),
          name: name,
          phone: phone,
          address: address.isNotEmpty ? address : null,
          dailyQuotaAm: quotaAm,
          dailyQuotaPm: quotaPm,
          preferredShift: 'morning',
          productId: _selectedProduct?.id,
          agreedRate: rate,
          status: 'active',
          notes: notes.isNotEmpty ? notes : null,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insert(newCustomer);
      } else {
        // Edit mode
        final updatedCustomer = widget.customerToEdit!.copyWith(
          name: name,
          phone: phone,
          address: address.isNotEmpty ? address : null,
          dailyQuotaAm: quotaAm,
          dailyQuotaPm: quotaPm,
          preferredShift: widget.customerToEdit?.preferredShift ?? 'morning',
          productId: _selectedProduct?.id,
          agreedRate: rate,
          status: _selectedStatus,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          updatedAt: now,
        );
        await repo.update(updatedCustomer);
        ref.invalidate(customerByIdProvider(widget.customerToEdit!.id));
      }

      ref.invalidate(allCustomersProvider);
      ref.invalidate(customerListProvider);
      ref.invalidate(customerStatsProvider);
      ref.invalidate(dashboardProvider);
      invalidateAllGlobalData(ref);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e, stack) {
      debugPrint('Failed to save customer: $e\n$stack');
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        AppSnackBar.show(context, message: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);

    final productsAsync = ref.watch(productListProvider);
    final isEdit = widget.customerToEdit != null;

    // Initialize product selections once provider data is available
    if (!_initializedDropdowns) {
      if (productsAsync.hasValue &&
          productsAsync.value != null &&
          _selectedProduct == null) {
        final products = productsAsync.value!;
        if (widget.customerToEdit?.productId != null) {
          _selectedProduct = products.cast<Product?>().firstWhere(
                (p) => p?.id == widget.customerToEdit!.productId,
                orElse: () => null,
              );
        } else if (products.isNotEmpty) {
          _selectedProduct = products.first;
          if (_rateController.text.trim().isEmpty) {
            _rateController.text =
                _selectedProduct!.defaultRate.toStringAsFixed(0);
          }
        }
      }

      if (productsAsync.hasValue) {
        _initializedDropdowns = true;
      }
    }

    return SingleChildScrollView(
      controller: _scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Title Header
            Text(
              isEdit ? l10n.editCustomerTitle : l10n.addCustomerTitle,
              style: typography.heading.copyWith(
                color: AppColors.neutralTitle,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceLg),

            // Profile Section: Name & Phone
            AppTextField(
              key: const Key('customer_name_field'),
              controller: _nameController,
              label: l10n.customerNameLabel,
              prefixIcon: Symbols.person,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              isRequired: true,
              errorText: _nameError,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
            const SizedBox(height: AppSpacing.spaceSm),

            AppTextField(
              key: const Key('customer_phone_field'),
              controller: _phoneController,
              label: l10n.customerPhoneLabel,
              prefixIcon: Symbols.phone,
              textInputAction: TextInputAction.next,
              isRequired: true,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              errorText: _phoneError,
              onChanged: (_) {
                if (_phoneError != null) setState(() => _phoneError = null);
              },
            ),
            const SizedBox(height: AppSpacing.spaceSm),

            AppTextField(
              key: const Key('customer_address_field'),
              controller: _addressController,
              label: l10n.customerAddressLabel,
              prefixIcon: Symbols.home_pin,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.spaceSm),

            // Quotas
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: AppTextField(
                    key: const Key('customer_quota_am_field'),
                    controller: _quotaAmController,
                    label: l10n.dailyQuotaAmLabel,
                    prefixIcon: Symbols.wb_sunny,
                    suffixText: _selectedProduct?.unit ?? 'Litre',
                    textInputAction: TextInputAction.next,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) {
                      if (_quotaError != null) {
                        setState(() => _quotaError = null);
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceSm),
                Expanded(
                  child: AppTextField(
                    key: const Key('customer_quota_pm_field'),
                    controller: _quotaPmController,
                    label: l10n.dailyQuotaPmLabel,
                    prefixIcon: Symbols.nightlight,
                    suffixText: _selectedProduct?.unit ?? 'Litre',
                    textInputAction: TextInputAction.next,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) {
                      if (_quotaError != null) {
                        setState(() => _quotaError = null);
                      }
                    },
                  ),
                ),
              ],
            ),
            if (_quotaError != null) ...[
              const SizedBox(height: AppSpacing.space2xs),
              Text(
                _quotaError!,
                style: typography.caption.copyWith(color: AppColors.errorText),
              ),
            ],
            const SizedBox(height: AppSpacing.spaceSm),

            // Product & Agreed Rate
            productsAsync.when(
              data: (products) => AppDropdown<Product>(
                key: const Key('customer_product_dropdown'),
                label: l10n.milkType,
                items: products,
                value: _selectedProduct,
                itemLabelBuilder: (p) => p.displayName(l10n.localeName),
                itemBuilder: (p) {
                  final bool isSelected = p == _selectedProduct;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          p.displayName(l10n.localeName),
                          style: typography.body.copyWith(
                            color: isSelected
                                ? AppColors.brandPrimary
                                : AppColors.neutralTitle,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rs. ${p.defaultRate.toStringAsFixed(0)}',
                        style: typography.caption.copyWith(
                          color: isSelected
                              ? AppColors.brandPrimary
                              : AppColors.neutralMuted,
                        ),
                      ),
                    ],
                  );
                },
                onChanged: _onProductSelected,
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppSpacing.spaceSm),

            AppTextField(
              key: const Key('customer_rate_field'),
              controller: _rateController,
              label: l10n.agreedRateLabel,
              prefixIcon: Symbols.payments,
              suffixText: 'Rs',
              textInputAction: TextInputAction.next,
              isRequired: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              errorText: _rateError,
              onChanged: (_) {
                if (_rateError != null) setState(() => _rateError = null);
              },
            ),
            const SizedBox(height: AppSpacing.spaceSm),

            if (isEdit) ...[
              AppDropdown<String>(
                key: const Key('customer_status_dropdown'),
                label: 'Status',
                items: const ['active', 'paused', 'inactive'],
                value: _selectedStatus,
                itemLabelBuilder: (s) => s[0].toUpperCase() + s.substring(1),
                onChanged: (val) => setState(() => _selectedStatus = val),
              ),
              const SizedBox(height: AppSpacing.spaceSm),
            ],

            // Notes
            AppTextField(
              key: const Key('customer_notes_field'),
              controller: _notesController,
              label: l10n.notesLabel,
              prefixIcon: Symbols.notes,
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.spaceLg),

            // Submit Button
            AppButton(
              key: const Key('save_customer_button'),
              label: isEdit ? l10n.saveChangesAction : l10n.addCustomerFab,
              icon: Symbols.check,
              variant: AppButtonVariant.primary,
              isFullWidth: true,
              isLoading: _isSaving,
              onPressed: _handleSave,
            ),
          ],
      ),
    );
  }
}
