import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/local_sale.dart';
import '../../../models/product.dart';

import '../../../providers/local_sale_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';

import 'daily_sales_bottom_sheet.dart';

/// Local counter walk-in sales section on the Home Dashboard (plan.md C-M2; Section 2.1 item 10).
///
/// Displays:
/// - Header with "Counter Sales" title and today's totals (Litres + Cash)
/// - Quick-tap volume buttons (+1L, +2L, +5L) with pre-computed prices
/// - Custom quick-sale CTA button
/// - Most recent sale display with undo capability
class LocalSalesSection extends ConsumerStatefulWidget {
  const LocalSalesSection({
    super.key,
    required this.now,
    required this.onOpenCustomSale,
  });

  /// The date reference for today's totals.
  final DateTime now;

  /// Callback when user wants to open the custom quick sale sheet (C-M3).
  final void Function(Product? defaultProduct) onOpenCustomSale;

  @override
  ConsumerState<LocalSalesSection> createState() => _LocalSalesSectionState();
}

class _LocalSalesSectionState extends ConsumerState<LocalSalesSection> {
  @override
  Widget build(BuildContext context) {
    final AppTypography typography = AppTypography.of(context);
    final AppLocalizations? l10n =
        Localizations.of<AppLocalizations>(context, AppLocalizations);

    final totalsAsync = ref.watch(todayLocalSaleTotalsProvider(widget.now));
    final lastSaleAsync = ref.watch(lastLocalSaleProvider);
    final productsAsync = ref.watch(productListProvider);

    final String title = l10n?.localSalesTitle ?? 'Counter Sales';

    // Determine current rate and unit based on selected product type
    final rawProducts = productsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => <Product>[],
    );
    
    final products = List<Product>.from(rawProducts).where((p) => p.isActive).toList();
    final List<String> order = ['milk', 'dahi', 'lassi'];
    products.sort((a, b) {
      final int indexA = order.indexOf(a.name.toLowerCase());
      final int indexB = order.indexOf(b.name.toLowerCase());
      if (indexA != -1 && indexB != -1) {
        return indexA.compareTo(indexB);
      } else if (indexA != -1) {
        return -1;
      } else if (indexB != -1) {
        return 1;
      } else {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
    });

    // Restrict to 3 products (excluding ghee/makhan)
    final filteredProducts = products.where((p) => order.contains(p.name.toLowerCase())).take(3).toList();

    final String totalsText = totalsAsync.maybeWhen(
      data: (totals) {
        final litres = totals.totalQuantity % 1 == 0
            ? totals.totalQuantity.toInt().toString()
            : totals.totalQuantity.toStringAsFixed(1);
        final amount = totals.totalAmount.toStringAsFixed(0);
        return l10n?.todayTotals(litres, amount) ??
            'Today: $litres • Rs. $amount';
      },
      orElse: () => l10n?.todayTotals('0', '0') ?? 'Today: 0 • Rs. 0',
    );

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header Row: Title and Today's Totals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: l10n?.localeName == 'ur'
                ? <Widget>[
                    Text(
                      totalsText,
                      style: typography.caption.copyWith(
                        color: AppColors.neutralMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      title,
                      style: typography.subhead.copyWith(
                        color: AppColors.neutralTitle,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ]
                : <Widget>[
                    Text(
                      title,
                      style: typography.subhead.copyWith(
                        color: AppColors.neutralTitle,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      totalsText,
                      style: typography.caption.copyWith(
                        color: AppColors.neutralMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
          ),
          const SizedBox(height: AppSpacing.space2xs),
          // POS-Style Product Grid
          if (filteredProducts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
              child: Text(
                'No products available. Please add some products in settings.',
                style: typography.body.copyWith(color: AppColors.neutralMuted),
              ),
            )
          else
            Wrap(
              spacing: AppSpacing.spaceSm,
              runSpacing: AppSpacing.spaceSm,
              children: filteredProducts.map((Product p) {
                return _POSProductTile(
                  product: p,
                  typography: typography,
                  l10n: l10n,
                  onTap: () => widget.onOpenCustomSale(p),
                );
              }).toList(),
            ),

          const SizedBox(height: AppSpacing.spaceSm),

          // "Add Quick Sale (Custom Quantity / Cash)" button for unlisted products
          AppButton(
            label: l10n?.quickSaleCustomCta ??
                'Add Quick Sale (Custom Quantity / Cash)',
            variant: AppButtonVariant.primary,
            isFullWidth: true,
            icon: Symbols.add,
            height: 40, // Reduced height to save space
            onPressed: () => widget.onOpenCustomSale(null),
          ),

          // Last sale entry display with undo capability
          lastSaleAsync.maybeWhen(
            data: (LocalSale? lastSale) {
              if (lastSale == null) return const SizedBox.shrink();
              final litres = lastSale.quantity % 1 == 0
                  ? lastSale.quantity.toInt().toString()
                  : lastSale.quantity.toStringAsFixed(1);
              final amount = lastSale.totalAmount.toStringAsFixed(0);
              final label = l10n?.lastSaleLabel(litres, amount) ??
                  'Last: $litres • Rs. $amount';

              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.spaceSm),
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => DailySalesBottomSheet(date: widget.now),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceSm,
                    vertical: AppSpacing.space2xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.scaffold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Symbols.history,
                        size: 16,
                        color: AppColors.neutralMuted,
                      ),
                      const SizedBox(width: AppSpacing.space2xs),
                      Expanded(
                        child: Text(
                          label,
                          style: typography.caption.copyWith(
                            color: AppColors.neutralBody,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _POSProductTile extends StatelessWidget {
  const _POSProductTile({
    required this.product,
    required this.typography,
    required this.l10n,
    required this.onTap,
  });

  final Product product;
  final AppTypography typography;
  final AppLocalizations? l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String displayName = product.displayName(l10n?.localeName);


    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 100, // Fixed width for uniform grid
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.spaceSm,
            horizontal: AppSpacing.space2xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.brandSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.brandTint,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                displayName,
                style: typography.body.copyWith(
                  color: AppColors.brandPrimary,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

