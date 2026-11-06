import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/id_generator.dart';
import '../../models/product.dart';
import '../../providers/customer_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/refresh_helper.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/status_badge.dart';

/// Products & Pricing management screen (plan.md C-M17; Section 2.7, 3.1).
///
/// Features:
/// 1. Product list with name, description, default rate, and active badge.
/// 2. FAB "+ Add Product" opens creation sheet.
/// 3. Tap to edit opens edit sheet with pre-populated values.
/// 4. Deactivate toggle with active customer reference validation and confirmation dialog.
/// 5. Reactivate toggle to restore previously deactivated products.
class ProductsPricingScreen extends ConsumerWidget {
  const ProductsPricingScreen({super.key});

  void _openProductSheet(BuildContext context, WidgetRef ref, [Product? product]) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final isEditing = product != null;

    AppBottomSheet.show(
      context: context,
      title: isEditing
          ? (l10n?.editProductModalTitle ?? 'Edit Product')
          : (l10n?.addProductModalTitle ?? 'Add Product'),
      builder: (sheetContext) => _ProductEditForm(
        product: product,
        onSaved: () {
          ref.invalidate(allProductListProvider);
          ref.invalidate(productListProvider);
          invalidateAllGlobalData(ref);
        },
      ),
    );
  }

  Future<void> _toggleProductStatus(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);

    if (product.isActive) {
      // Check if customers reference this product
      final customerRepo = ref.read(customerRepositoryProvider);
      final assignedCustomers =
          await customerRepo.getCustomersByProduct(product.id);
      final hasActiveCustomers =
          assignedCustomers.any((c) => c.status != 'inactive');

      if (!context.mounted) return;

      if (hasActiveCustomers) {
        AppSnackBar.show(
          context,
          message: l10n?.cannotDeactivateProduct ??
              'Cannot deactivate: Active customers are assigned to this product.',
          error: true,
        );
        return;
      }

      final confirmed = await AppDialog.showConfirmation(
        context,
        title: l10n?.deactivateProductTitle ?? 'Deactivate Product',
        message: l10n?.deactivateProductConfirm(product.name) ??
            'Are you sure you want to deactivate "${product.name}"?',
        cancelLabel: l10n?.cancelAction ?? 'Cancel',
        confirmLabel: l10n?.confirmAction ?? 'Confirm',
        isDestructive: true,
      );

      if (confirmed && context.mounted) {
        final updated = product.copyWith(isActive: false);
        await ref.read(productRepositoryProvider).update(updated);
        ref.invalidate(allProductListProvider);
        ref.invalidate(productListProvider);
        invalidateAllGlobalData(ref);
        if (context.mounted) {
          AppSnackBar.show(
            context,
            message: l10n?.productDeactivatedSuccess ?? 'Product deactivated',
          );
        }
      }
    } else {
      final updated = product.copyWith(isActive: true);
      await ref.read(productRepositoryProvider).update(updated);
      ref.invalidate(allProductListProvider);
      ref.invalidate(productListProvider);
      invalidateAllGlobalData(ref);
      if (context.mounted) {
        AppSnackBar.show(
          context,
          message: l10n?.productActivatedSuccess ?? 'Product activated',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppTypography typography = AppTypography.of(context);
    final AppLocalizations? l10n =
        Localizations.of<AppLocalizations>(context, AppLocalizations);

    final productsAsync = ref.watch(allProductListProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(
          bottom: BorderSide(color: AppColors.neutralLine, width: 1),
        ),
        leading: IconButton(
          icon: const Icon(
            Symbols.arrow_back,
            color: AppColors.neutralTitle,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n?.productsPricingTitle ?? 'Products & Pricing',
          style: typography.heading.copyWith(
            color: AppColors.neutralTitle,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'products_pricing_fab',
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Symbols.add, size: 28),
        label: Text(
          l10n?.addProductFab ?? 'Add Product',
          style: typography.body.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () => _openProductSheet(context, ref),
      ),
      body: productsAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenGutter),
          itemCount: 4,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.spaceMd),
          itemBuilder: (_, __) => const ShimmerCard(height: 100),
        ),
        error: (error, _) => Center(
          child: Text(
            error.toString(),
            style: typography.body.copyWith(color: AppColors.errorText),
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return EmptyState(
              icon: Symbols.inventory_2,
              title: l10n?.noProductsFound ?? 'No products found',
              subtitle: l10n?.noProductsSubtitle ??
                  'Add milk products and default pricing.',
              actionLabel: l10n?.addProductFab ?? '+ Add Product',
              onAction: () => _openProductSheet(context, ref),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenGutter,
              AppSpacing.screenGutter,
              AppSpacing.screenGutter,
              88,
            ),
            itemCount: products.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.spaceMd),
            itemBuilder: (context, index) {
              final product = products[index];
              return _ProductCard(
                product: product,
                onEdit: () => _openProductSheet(context, ref, product),
                onToggleStatus: () =>
                    _toggleProductStatus(context, ref, product),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onToggleStatus,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;

  @override
  Widget build(BuildContext context) {
    final AppTypography typography = AppTypography.of(context);
    final AppLocalizations? l10n =
        Localizations.of<AppLocalizations>(context, AppLocalizations);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.spaceLg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: product.isActive
                  ? AppColors.brandSoft
                  : AppColors.brandSubtle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: product.isActive
                    ? AppColors.brandTint
                    : AppColors.neutralLine,
                width: 1,
              ),
            ),
            child: Icon(
              Symbols.water_drop,
              size: 20,
              color: product.isActive
                  ? AppColors.brandPrimary
                  : AppColors.neutralMuted,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceMd),

          // Title and description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        product.displayName(l10n?.localeName),
                        style: typography.subhead.copyWith(
                          color: product.isActive
                              ? AppColors.neutralTitle
                              : AppColors.neutralMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2xs),
                    product.isActive
                        ? StatusBadge.active(
                            label: l10n?.activeStatus ?? 'Active',
                          )
                        : StatusBadge.paused(
                            label: l10n?.inactiveStatus ?? 'Inactive',
                          ),
                  ],
                ),
                if (product.description != null &&
                    product.description!.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    product.description!,
                    style: typography.caption.copyWith(
                      color: AppColors.neutralMuted,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.spaceXs),
                Text(
                  'Rs. ${product.defaultRate.toStringAsFixed(0)} / ${product.unit}',
                  style: typography.body.copyWith(
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: AppSpacing.spaceSm),

          // Trailing actions
          IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Symbols.edit, size: 16),
                  label: Text(
                    l10n?.localeName == 'ur' ? 'ترمیم' : 'Edit',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brandPrimary,
                    side: const BorderSide(color: AppColors.brandPrimary, width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    alignment: Alignment.centerLeft,
                  ),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: onToggleStatus,
                  icon: Icon(product.isActive ? Symbols.block : Symbols.check_circle, size: 16),
                  label: Text(
                    product.isActive 
                        ? (l10n?.localeName == 'ur' ? 'غیر فعال کریں' : 'Deactivate') 
                        : (l10n?.localeName == 'ur' ? 'فعال کریں' : 'Activate'),
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: product.isActive ? AppColors.errorMain : AppColors.successMain,
                    side: BorderSide(color: product.isActive ? AppColors.errorMain : AppColors.successMain, width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductEditForm extends ConsumerStatefulWidget {
  const _ProductEditForm({
    this.product,
    required this.onSaved,
  });

  final Product? product;
  final VoidCallback onSaved;

  @override
  ConsumerState<_ProductEditForm> createState() => _ProductEditFormState();
}

class _ProductEditFormState extends ConsumerState<_ProductEditForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _urduNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _rateController;
  String _selectedUnit = 'Litre';

  String? _nameError;
  String? _rateError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _urduNameController = TextEditingController(text: widget.product?.urduName ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _rateController = TextEditingController(
      text: widget.product != null
          ? widget.product!.defaultRate.toStringAsFixed(0)
          : '',
    );
    _selectedUnit = widget.product?.unit ?? 'Litre';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urduNameController.dispose();
    _descriptionController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final name = _nameController.text.trim();
    final urduName = _urduNameController.text.trim();
    final rateText = _rateController.text.trim();
    final rate = double.tryParse(rateText);

    bool hasError = false;
    if (name.isEmpty) {
      setState(() {
        _nameError = l10n?.errorNameRequired ?? 'Product name is required';
      });
      hasError = true;
    }

    if (rate == null || rate <= 0) {
      setState(() {
        _rateError = l10n?.errorInvalidRate ?? 'Enter a valid rate greater than 0';
      });
      hasError = true;
    }

    if (hasError) return;

    setState(() {
      _nameError = null;
      _rateError = null;
      _isSaving = true;
    });

    try {
      final repository = ref.read(productRepositoryProvider);
      final now = DateTime.now();

      if (widget.product != null) {
        final oldRate = widget.product!.defaultRate;
        final updated = widget.product!.copyWith(
          name: name,
          urduName: urduName.isNotEmpty ? urduName : null,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          unit: _selectedUnit,
          defaultRate: rate!,
          updatedAt: now,
        );
        await repository.update(updated);

        if (oldRate != rate && mounted) {
          final confirm = await AppDialog.showConfirmation(
            context,
            title: 'Update All Customers?',
            message:
                'Do you want to update EVERY customer assigned to this product to the new price of Rs. ${rate.toStringAsFixed(0)}? (This will overwrite any special concessions they had).',
            confirmLabel: 'Update Everyone',
            cancelLabel: 'No, skip',
          );
          if (confirm) {
            final customerRepo = ref.read(customerRepositoryProvider);
            final updatedCount = await customerRepo.updateAgreedRateForProduct(
                updated.id, rate);
            ref.invalidate(allCustomersProvider);
            ref.invalidate(customerListProvider);
            ref.invalidate(customerStatsProvider);
            invalidateAllGlobalData(ref);
            if (mounted) {
              AppSnackBar.show(
                context,
                message: 'Updated pricing for $updatedCount customers.',
              );
            }
          }
        }
      } else {
        final newProduct = Product(
          id: IdGenerator.generate(),
          name: name,
          urduName: urduName.isNotEmpty ? urduName : null,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          unit: _selectedUnit,
          defaultRate: rate!,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );
        await repository.insert(newProduct);
      }

      widget.onSaved();

      if (mounted) {
        AppSnackBar.show(
          context,
          message: l10n?.productSavedSuccess ?? 'Product saved successfully',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: e.toString(),
          error: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.spaceLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppTextField(
            label: l10n?.productNameInputLabel ?? 'Product Name',
            hintText: 'e.g. Buffalo Milk',
            controller: _nameController,
            isRequired: true,
            errorText: _nameError,
            onChanged: (_) {
              if (_nameError != null) {
                setState(() => _nameError = null);
              }
            },
          ),

          AppTextField(
            label: l10n?.productDefaultRateInputLabel ??
                'Default Rate (Rs.)',
            hintText: 'e.g. 210',
            controller: _rateController,
            prefixIcon: Symbols.payments,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            isRequired: true,
            errorText: _rateError,
            onChanged: (_) {
              if (_rateError != null) {
                setState(() => _rateError = null);
              }
            },
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          AppDropdown<String>(
            label: 'Unit',
            hintText: 'Select unit',
            value: _selectedUnit,
            items: const ['Litre', 'Kg', 'Glass', 'Piece'],
            itemLabelBuilder: (unit) => unit,
            onChanged: (val) {
              setState(() {
                _selectedUnit = val;
              });
            },
          ),
          const SizedBox(height: AppSpacing.spaceXl),
          AppButton(
            label: l10n?.saveChangesAction ?? 'Save Changes',
            isLoading: _isSaving,
            isFullWidth: true,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
