import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/product.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/local_sale_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/sales_analytics_provider.dart';
import '../../../providers/customer_provider.dart';
import '../../../repositories/local_sale_repository.dart';
import '../../../models/customer.dart';
import '../../../models/delivery.dart';
import '../../../providers/delivery_provider.dart';
import '../../../providers/refresh_helper.dart';

import '../../../core/utils/id_generator.dart';
import '../../../core/utils/unit_formatter.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_snack_bar.dart';
import '../../../widgets/app_text_field.dart';

/// Modal bottom sheet for recording custom walk-in counter sales (plan.md C-M3).
///
/// Fields:
///  1. Product selection (`Wrap` with `ChoiceChip`)
///  2. Quantity field (`AppTextField`, numeric, suffix unit)
///  3. Rate field (`AppTextField`, prefix "Rs.", auto-filled from product default rate, editable)
///  4. Total display (live auto-calculated: `quantity x rate`)
///  5. Save button (`AppButton.primary`)
///
/// Invariants & Behavior:
///  - Total recalculates live as user edits quantity or rate.
///  - Selecting a product auto-fills the default rate.
///  - Validation ensures quantity > 0 and rate > 0.
///  - On save, records the sale via [LocalSaleRepository.addQuickSale], dismisses,
///    invalidates dashboard/sales providers, and displays an [AppSnackBar] with Undo.
class QuickSaleScreen extends ConsumerStatefulWidget {
  const QuickSaleScreen({
    super.key,
    this.initialProduct,
  });

  final Product? initialProduct;

  /// Convenience helper to display the sheet modally.
  static Future<bool?> show(
    BuildContext context, {
    Product? initialProduct,
  }) async {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => QuickSaleScreen(
          initialProduct: initialProduct,
        ),
      ),
    );

    if (result == true && context.mounted) {
      final container = ProviderScope.containerOf(context, listen: false);
      final repository = container.read(localSaleRepositoryProvider);
      final now = DateTime.now();

      final String message = l10n?.saleRecorded ?? 'Sale recorded successfully';
      final String undoLabel = l10n?.undoAction ?? 'Undo';

      AppSnackBar.show(
        context,
        message: message,
        actionLabel: undoLabel,
        onAction: () async {
          await repository.deleteLastSale();
          container.invalidate(todayLocalSaleTotalsProvider(now));
          container.invalidate(lastLocalSaleProvider);
          container.invalidate(dashboardProvider);

          if (context.mounted) {
            AppSnackBar.show(
              context,
              message: l10n?.saleUndone ?? 'Sale undone',
            );
          }
        },
      );
    }

    return result;
  }

  @override
  ConsumerState<QuickSaleScreen> createState() => _QuickSaleScreenState();
}

class _QuickSaleScreenState extends ConsumerState<QuickSaleScreen> {
  final TextEditingController _quantityController =
      TextEditingController(text: '1');
  late final TextEditingController _amountController;

  Product? _selectedProduct;
  Customer? _selectedCustomer;
  String? _quantityError;
  String? _amountError;
  String? _productError;
  bool _isSubmitting = false;
  List<String> _recentCustomerIds = [];

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.initialProduct;
    final initialRate = widget.initialProduct?.defaultRate ?? 210.0;
    final initialAmount = initialRate * 1.0;
    _amountController = TextEditingController(
      text: initialAmount % 1 == 0
          ? initialAmount.toInt().toString()
          : initialAmount.toStringAsFixed(1),
    );
    _loadRecentCustomerIds();
  }

  Future<void> _loadRecentCustomerIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentIds = prefs.getStringList('recent_quick_sale_customers') ?? [];
      if (mounted) {
        setState(() {
          _recentCustomerIds = recentIds;
        });
      }
    } catch (_) {}
  }

  Future<void> _saveRecentCustomer(String customerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentIds = prefs.getStringList('recent_quick_sale_customers') ?? [];
      recentIds.remove(customerId);
      recentIds.insert(0, customerId);
      if (recentIds.length > 5) {
        recentIds.removeLast();
      }
      await prefs.setStringList('recent_quick_sale_customers', recentIds);
      if (mounted) {
        setState(() {
          _recentCustomerIds = recentIds;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double get _quantity => double.tryParse(_quantityController.text.trim()) ?? 0.0;

  double get _rate => _selectedProduct?.defaultRate ?? 0.0;

  double get _total => double.tryParse(_amountController.text.trim()) ?? 0.0;

  void _onProductChanged(Product product) {
    setState(() {
      _selectedProduct = product;
      _productError = null;
      _updateAmountFromQuantityAndRate();
    });
  }

  void _updateAmountFromQuantityAndRate() {
    final amount = _quantity * _rate;
    _amountController.text = amount % 1 == 0 ? amount.toInt().toString() : amount.toStringAsFixed(2);
    setState(() {});
  }

  void _updateQuantityFromAmount() {
    if (_rate > 0) {
      final double qty = _total / _rate;
      _quantityController.text = qty % 1 == 0 ? qty.toInt().toString() : qty.toStringAsFixed(2);
    }
    setState(() {});
  }

  void _setQuickQuantity(double q) {
    _quantityController.text = q % 1 == 0 ? q.toInt().toString() : q.toStringAsFixed(1);
    _updateAmountFromQuantityAndRate();
  }

  void _setQuickAmount(double amount) {
    _amountController.text = amount % 1 == 0 ? amount.toInt().toString() : amount.toStringAsFixed(2);
    _updateQuantityFromAmount();
  }

  bool _validate(AppLocalizations? l10n) {
    bool isValid = true;

    if (_selectedProduct == null) {
      _productError = l10n?.errorSelectProduct ?? 'Please select a product';
      isValid = false;
    } else {
      _productError = null;
    }

    if (_quantity <= 0) {
      _quantityError = l10n?.errorInvalidQuantity ??
          'Enter a valid quantity greater than 0';
      isValid = false;
    } else {
      _quantityError = null;
    }

    if (_amountController.text.trim().isEmpty) {
      _amountError = 'Enter a valid amount';
      isValid = false;
    } else {
      _amountError = null;
    }

    setState(() {});
    return isValid;
  }

  Future<void> _submit(AppLocalizations? l10n) async {
    if (!_validate(l10n)) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_selectedCustomer == null) {
        final repository = ref.read(localSaleRepositoryProvider);
        await repository.addQuickSale(
          _quantity,
          _selectedProduct!.name,
          _rate,
          productId: _selectedProduct!.id == '-1' ? null : _selectedProduct!.id,
        );

        // Invalidate relevant providers to update the dashboard & totals
        ref.invalidate(todayLocalSalesProvider);
        ref.invalidate(todayLocalSaleTotalsProvider);
        ref.invalidate(lastLocalSaleProvider);
        ref.invalidate(dashboardProvider);
        ref.invalidate(salesAnalyticsProvider);
        invalidateAllGlobalData(ref);
      } else {
        final deliveryRepo = ref.read(deliveryRepositoryProvider);
        final amount = double.tryParse(_amountController.text) ?? 0.0;
        final now = DateTime.now();

        final delivery = Delivery(
          id: IdGenerator.generate(),
          customerId: _selectedCustomer!.id,
          date: DateTime(now.year, now.month, now.day),
          shift: 'extra',
          productId: _selectedProduct!.id == '-1' ? null : _selectedProduct!.id,
          productName: _selectedProduct!.name,
          scheduledQuantity: _quantity,
          deliveredQuantity: _quantity,
          rate: _rate,
          totalAmount: amount,
          status: 'pending',
          paymentMethod: 'auto',
          amountCollected: 0.0,
          deliveryTime: now,
          sequenceNumber: 999,
          createdAt: now,
          updatedAt: now,
        );
        await deliveryRepo.insert(delivery);
        await deliveryRepo.markDelivered(
          delivery.id,
          _quantity,
          'auto',
          0.0,
        );

        ref.invalidate(customerDeliveryHistoryProvider);
        ref.invalidate(customerByIdProvider(_selectedCustomer!.id));
        ref.invalidate(allCustomersProvider);
        ref.invalidate(customerListProvider);
        ref.invalidate(customerStatsProvider);
        ref.invalidate(dashboardProvider);
        ref.invalidate(salesAnalyticsProvider);
        ref.invalidate(todayLocalSalesProvider);
        ref.invalidate(todayLocalSaleTotalsProvider);
        ref.invalidate(lastLocalSaleProvider);
        invalidateAllGlobalData(ref);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        AppSnackBar.show(context, message: e.toString(), error: true);
      }
    }
  }

  void _incrementQuantity() {
    final currentText = _quantityController.text;
    double val = double.tryParse(currentText) ?? 0.0;
    val += 1.0;
    _quantityController.text = (val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1));
    _updateAmountFromQuantityAndRate();
  }

  void _decrementQuantity() {
    final currentText = _quantityController.text;
    double val = double.tryParse(currentText) ?? 0.0;
    if (val > 0) {
      val -= 1.0;
      if (val < 0) val = 0;
      _quantityController.text = (val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1));
      _updateAmountFromQuantityAndRate();
    }
  }

  void _incrementAmount() {
    final currentText = _amountController.text;
    double val = double.tryParse(currentText) ?? 0.0;
    val += 10.0; // Increment step for amount
    _amountController.text = (val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(2));
    _updateQuantityFromAmount();
  }

  void _decrementAmount() {
    final currentText = _amountController.text;
    double val = double.tryParse(currentText) ?? 0.0;
    if (val > 0) {
      val -= 10.0;
      if (val < 0) val = 0;
      _amountController.text = (val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(2));
      _updateQuantityFromAmount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppTypography typography = AppTypography.of(context);
    final AppLocalizations? l10n =
        Localizations.of<AppLocalizations>(context, AppLocalizations);

    final productsAsync = ref.watch(productListProvider);

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
          l10n?.quickSaleTitle ?? 'Quick Counter Sale',
          style: typography.heading.copyWith(
            color: AppColors.neutralTitle,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenGutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // ── 1. Customer Search ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.spaceSm),
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border.all(color: AppColors.neutralLine),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Customer (Optional)',
                  style: typography.labelMd.copyWith(color: AppColors.neutralBody),
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                Consumer(
                  builder: (context, ref, child) {
                    final customersAsync = ref.watch(customerListProvider);
                    final allCustomers = customersAsync.valueOrNull ?? [];
                    return Autocomplete<Customer>(
                      displayStringForOption: (Customer option) => option.name,
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          if (_recentCustomerIds.isEmpty) {
                            return const Iterable<Customer>.empty();
                          }
                          return _recentCustomerIds.map((id) {
                            final matches = allCustomers.where((c) => c.id == id);
                            return matches.isNotEmpty ? matches.first : null;
                          }).where((c) => c != null).cast<Customer>();
                        }
                        return allCustomers.where((Customer customer) {
                          return customer.name.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                                 customer.phone.contains(textEditingValue.text);
                        });
                      },
                      onSelected: (Customer selection) {
                        setState(() {
                          _selectedCustomer = selection;
                        });
                        _saveRecentCustomer(selection.id);
                      },
                      fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                        return AppTextField(
                          controller: fieldTextEditingController,
                          focusNode: fieldFocusNode,
                          label: 'Search by Name or Phone',
                          prefixIcon: Symbols.search,
                          onChanged: (val) {
                            if (val.isEmpty && _selectedCustomer != null) {
                              setState(() {
                                _selectedCustomer = null;
                              });
                            }
                          },
                        );
                      },
                      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<Customer> onSelected, Iterable<Customer> options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width - (AppSpacing.screenGutter * 2) - AppSpacing.spaceSm * 2,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(8.0),
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final Customer option = options.elementAt(index);
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.brandTint,
                                      child: Text(
                                        option.name.substring(0, 1).toUpperCase(),
                                        style: typography.labelLg.copyWith(color: AppColors.brandPrimary),
                                      ),
                                    ),
                                    title: Text(option.name, style: typography.body),
                                    subtitle: Text(option.phone, style: typography.caption),
                                    onTap: () {
                                      onSelected(option);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spaceLg),

          // ── 2. Product Dropdown ──────────────────────────────────────────
          productsAsync.when(
            loading: () => const SizedBox(
              height: 48,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.brandPrimary,
                ),
              ),
            ),
            error: (_, __) => Text(
              l10n?.loadFailed ?? 'Failed to load products',
              style: typography.caption.copyWith(color: AppColors.errorText),
            ),
            data: (List<Product> allProducts) {
              final products = allProducts.where((p) => p.isActive).toList();
              
              if (_selectedProduct == null && products.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _selectedProduct == null) {
                    final defaultProduct = products.firstWhere(
                      (p) => p.name.toLowerCase() == 'milk',
                      orElse: () => products.first,
                    );
                    _onProductChanged(defaultProduct);
                  }
                });
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n?.localeName == 'ur' ? 'پروڈکٹ کی قسم' : 'Product Type',
                    style: typography.labelMd.copyWith(
                      color: AppColors.neutralBody,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spaceSm),
                  Builder(builder: (context) {
                    final List<String> order = ['milk', 'dahi', 'lassi', 'makhan', 'makhn', 'ghee'];
                    final sortedProducts = List<Product>.from(products);
                    sortedProducts.sort((a, b) {
                      final int indexA = order.indexOf(a.name.toLowerCase());
                      final int indexB = order.indexOf(b.name.toLowerCase());
                      if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);
                      if (indexA != -1) return -1;
                      if (indexB != -1) return 1;
                      return a.name.compareTo(b.name);
                    });

                    return Wrap(
                      spacing: 4.0,
                      runSpacing: 4.0,
                      children: sortedProducts.map((Product productOption) {
                      final bool isSelected = _selectedProduct?.name == productOption.name;
                      
                      String displayName = productOption.displayName(l10n?.localeName);

                      return ChoiceChip(
                        label: Text(displayName),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          if (selected) {
                            _onProductChanged(productOption);
                          }
                        },
                        selectedColor: AppColors.brandPrimaryLight.withValues(alpha: 0.15),
                        backgroundColor: AppColors.card,
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.brandPrimary : AppColors.neutralLine,
                          width: isSelected ? 2 : 1,
                        ),
                        labelStyle: typography.labelSm.copyWith(
                          color: isSelected ? AppColors.brandPrimary : AppColors.neutralTitle,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  );
                }),
                  if (_productError != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      _productError!,
                      style: typography.caption.copyWith(
                        color: AppColors.errorMain,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // ── 3. Quantity ────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.spaceSm),
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border.all(color: AppColors.neutralLine),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: _decrementQuantity,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brandSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Symbols.remove, size: 20, color: AppColors.brandPrimary),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2xs),
                    SizedBox(
                      width: 150,
                      child: AppTextField(
                        label: l10n?.localeName == 'ur' ? 'مقدار' : 'Quantity',
                        controller: _quantityController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        suffixText: _selectedProduct?.unit == 'Litre' ? 'L' : _selectedProduct?.unit ?? 'L',
                        errorText: _quantityError,
                        isRequired: true,
                        hasBorder: true,
                        isDense: true,
                        style: typography.bodyLg.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.neutralTitle,
                        ),
                        onChanged: (_) => _updateAmountFromQuantityAndRate(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2xs),
                    InkWell(
                      onTap: _incrementQuantity,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brandSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Symbols.add, size: 20, color: AppColors.brandPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceXs),
                Builder(
                  builder: (context) {
                    String unit = (_selectedProduct?.unit ?? 'Litre').localizeUnit(l10n?.localeName);
                    return Text(
                      l10n?.quickQuantity(unit) ?? 'Quick Quantity ($unit)',
                      style: typography.labelMd.copyWith(color: AppColors.neutralBody),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.spaceXs),
                Wrap(
                  spacing: AppSpacing.spaceSm,
                  runSpacing: AppSpacing.spaceSm,
                  children: <double>[0.5, 1, 1.5, 2, 3, 5].map((double q) {
                    return ActionChip(
                      label: Text(q % 1 == 0 ? q.toInt().toString() : q.toStringAsFixed(1)),
                      onPressed: () => _setQuickQuantity(q),
                      backgroundColor: AppColors.brandSoft,
                      side: const BorderSide(color: AppColors.brandTint),
                      labelStyle: typography.bodySm.copyWith(
                        color: AppColors.brandPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spaceLg),

          // ── 4. Amount ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.spaceSm),
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border.all(color: AppColors.neutralLine),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: _decrementAmount,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brandSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Symbols.remove, size: 20, color: AppColors.brandPrimary),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2xs),
                    SizedBox(
                      width: 150,
                      child: AppTextField(
                        label: l10n?.totalAmount ?? 'Total Amount',
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        suffixText: 'Rs',
                        errorText: _amountError,
                        isRequired: true,
                        hasBorder: true,
                        isDense: true,
                        style: typography.bodyLg.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.neutralTitle,
                        ),
                        onChanged: (_) => _updateQuantityFromAmount(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2xs),
                    InkWell(
                      onTap: _incrementAmount,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brandSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Symbols.add, size: 20, color: AppColors.brandPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceXs),
                Text(
                  l10n?.quickAmount ?? 'Quick Amount (Rs.)',
                  style: typography.labelMd.copyWith(color: AppColors.neutralBody),
                ),
                const SizedBox(height: AppSpacing.spaceXs),
                Wrap(
                  spacing: AppSpacing.spaceSm,
                  runSpacing: AppSpacing.spaceSm,
                  children: <double>[50, 100, 150, 200].map((double amt) {
                    return ActionChip(
                      label: Text(amt.toInt().toString()),
                      onPressed: () => _setQuickAmount(amt),
                      backgroundColor: AppColors.card,
                      side: const BorderSide(color: AppColors.neutralLine),
                      labelStyle: typography.bodySm.copyWith(
                        color: AppColors.neutralTitle,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spaceLg),

          // ── 5. Record Sale CTA ──────────────────────────────────────────
          AppButton(
            label: l10n?.recordSale ?? 'Record Sale',
            variant: AppButtonVariant.primary,
            icon: Symbols.check,
            isFullWidth: true,
            isLoading: _isSubmitting,
            onPressed: () => _submit(l10n),
          ),
        ],
      ),
      ),
    );
  }
}
