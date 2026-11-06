import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/customer.dart';
import '../../models/product.dart';
import '../../providers/customer_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_chip_bar.dart';
import '../../widgets/loading_state.dart';
import 'widgets/add_customer_sheet.dart';
import 'widgets/customer_card.dart';
import 'widgets/record_payment_sheet.dart';
import '../../widgets/temp_language_button.dart';

/// Customers Directory Screen (plan.md Section 2.2 & C-M4).
///
/// Features:
/// - Header with customer count and summary statistics bar
/// - Real-time search bar with 300ms debounce
/// - 5 filter chips (All, Has Dues, On Advance, Morning, Evening)
/// - Customer cards list with quotas, rates, financial statuses, and contextual actions
/// - Paused-customer visual treatment with "Resume Supply" action
/// - FAB "+ Add Customer"
/// - Pull-to-refresh and shimmer skeleton loading
/// - Empty state with filter reset action
class CustomersScreen extends ConsumerStatefulWidget {
  /// Creates the [CustomersScreen].
  const CustomersScreen({
    super.key,
    this.onAddCustomer,
    this.onCustomerTap,
  });

  /// Optional callback invoked when tapping the "+ Add Customer" FAB.
  final VoidCallback? onAddCustomer;

  /// Optional callback invoked when tapping a customer card.
  final ValueChanged<Customer>? onCustomerTap;

  @override
  ConsumerState<CustomersScreen> createState() => CustomersScreenState();
}

class CustomersScreenState extends ConsumerState<CustomersScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  void resetFilters() {
    ref.read(customerFilterIndexProvider.notifier).state = 0;
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    ref.invalidate(allCustomersProvider);
    ref.invalidate(customerStatsProvider);
    await ref.read(allCustomersProvider.future);
  }

  Future<void> _resumeSupply(Customer customer, AppLocalizations l10n) async {
    final updated = customer.copyWith(status: 'active');
    final repo = ref.read(customerRepositoryProvider);
    await repo.update(updated);

    ref.invalidate(allCustomersProvider);
    ref.invalidate(customerListProvider);
    ref.invalidate(customerStatsProvider);
    ref.invalidate(dashboardProvider);

    if (!mounted) return;
    AppSnackBar.show(
      context,
      message: l10n.supplyResumedMessage(customer.name),
    );
  }

  List<Customer> _applyFilters(List<Customer> customers) {
    final selectedFilterIndex = ref.read(customerFilterIndexProvider);
    final filtered = customers.where((c) {
      // 1. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatches = c.name.toLowerCase().contains(q);
        final phoneMatches = c.phone.toLowerCase().contains(q);
        final areaMatches = c.area?.toLowerCase().contains(q) ?? false;
        final addressMatches = c.address?.toLowerCase().contains(q) ?? false;
        if (!nameMatches && !phoneMatches && !areaMatches && !addressMatches) {
          return false;
        }
      }

      // 2. Chip Filter (0: All, 1: Has Dues, 2: On Advance, 3: Morning, 4: Evening)
      switch (selectedFilterIndex) {
        case 1:
          return c.currentDue > 0;
        case 2:
          return c.advanceBalance > 0;
        case 3:
          return c.dailyQuotaAm > 0;
        case 4:
          return c.dailyQuotaPm > 0;
        default:
          return true;
      }
    }).toList();

    if (selectedFilterIndex == 1) {
      filtered.sort((a, b) {
        final dueCmp = b.currentDue.compareTo(a.currentDue);
        if (dueCmp != 0) return dueCmp;
        return a.name.compareTo(b.name);
      });
    } else if (selectedFilterIndex == 2) {
      filtered.sort((a, b) {
        final advCmp = b.advanceBalance.compareTo(a.advanceBalance);
        if (advCmp != 0) return advCmp;
        return a.name.compareTo(b.name);
      });
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);
    final customersAsync = ref.watch(allCustomersProvider);
    final statsAsync = ref.watch(customerStatsProvider);
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_customer_fab'),
        heroTag: 'customers_screen_fab',
        onPressed: widget.onAddCustomer ??
            () async {
              final added = await AddCustomerSheet.show(context);
              if (added == true && context.mounted) {
                ref.invalidate(allCustomersProvider);
                ref.invalidate(customerStatsProvider);
                ref.invalidate(customerListProvider);
                ref.invalidate(dashboardProvider);
              }
            },
        backgroundColor: AppColors.brandPrimary,
        elevation: 2,
        icon: const Icon(Symbols.person_add, size: 20, color: AppColors.card),
        label: Text(
          l10n.addCustomerFab,
          style: typography.labelLg.copyWith(
            color: AppColors.card,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.brandPrimary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              // Top Header & Statistics Surface
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenGutter,
                    AppSpacing.spaceMd,
                    AppSpacing.screenGutter,
                    AppSpacing.spaceXs,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Screen Title & Count Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            l10n.customersTitle,
                            style: typography.headlineLg.copyWith(
                              color: AppColors.neutralTitle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.spaceSm),
                          statsAsync.when(
                            data: (stats) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.brandSoft,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                '${stats.total}',
                                style: typography.labelSm.copyWith(
                                  color: AppColors.brandPrimary,
                                  fontFeatures: const <FontFeature>[
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                          const Spacer(),
                          const TempLanguageButton(),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.spaceSm),

                      // Statistics Summary Bar
                      _buildSummaryBar(statsAsync, l10n, typography),
                      const SizedBox(height: AppSpacing.spaceSm),

                      // Search Bar
                      AppSearchBar(
                        controller: _searchController,
                        hintText: l10n.searchCustomersHint,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim();
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.spaceXs),
                    ],
                  ),
                ),
              ),

              // Horizontal Filter Chips
              SliverToBoxAdapter(
                child: customersAsync.when(
                  data: (allCustomers) => _buildFilterChipBar(
                    allCustomers,
                    statsAsync,
                    l10n,
                  ),
                  loading: () => const SizedBox(height: 48),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.spaceSm),
              ),

              // Customers List or Shimmer / Empty State
              customersAsync.when(
                data: (allCustomers) {
                  final filtered = _applyFilters(allCustomers);

                  if (filtered.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: EmptyState(
                          icon: Symbols.person_search,
                          title: l10n.noCustomersFound,
                          subtitle: l10n.noCustomersMatching,
                          actionLabel: l10n.clearFiltersAction,
                          onAction: () {
                            setState(() {
                              _searchQuery = '';
                            });
                            ref.read(customerFilterIndexProvider.notifier).state = 0;
                          },
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenGutter,
                      0,
                      AppSpacing.screenGutter,
                      88, // Space for FAB
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final customer = filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.cardGap,
                            ),
                            child: CustomerCard(
                              customer: customer,
                              product: productsAsync.valueOrNull?.cast<Product?>().firstWhere(
                                (p) => p?.id == customer.productId,
                                orElse: () => null,
                              ),
                              onTap: () {
                                if (widget.onCustomerTap != null) {
                                  widget.onCustomerTap!(customer);
                                } else {
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.customerPath(customer.id),
                                  );
                                }
                              },
                              onResumeSupply: () => _resumeSupply(customer, l10n),
                              onRecordPayment: () => RecordPaymentSheet.show(
                                context,
                                customer: customer,
                              ),
                              onAddRecharge: () => RecordPaymentSheet.show(
                                context,
                                customer: customer,
                              ),
                            ),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  );
                },
                loading: () => SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenGutter,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.cardGap),
                        child: ShimmerCard(height: 148),
                      ),
                      childCount: 4,
                    ),
                  ),
                ),
                error: (err, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          l10n.loadFailed,
                          style: typography.body.copyWith(
                            color: AppColors.errorMain,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spaceSm),
                        TextButton(
                          onPressed: _handleRefresh,
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBar(
    AsyncValue<({int active, int onAdvance, int total, double totalDues, int withDues})>
        statsAsync,
    AppLocalizations l10n,
    AppTypography typography,
  ) {
    return AppCard(
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: 12,
      borderColor: AppColors.neutralLine,
      child: statsAsync.when(
        data: (stats) => Row(
          children: <Widget>[
            // Total Stat
            Expanded(
              child: _buildSummaryStatItem(
                typography: typography,
                label: l10n.totalStatLabel,
                value: '${stats.total}',
                valueColor: AppColors.neutralTitle,
              ),
            ),
            Container(width: 1, height: 28, color: AppColors.neutralLine),

            // With Dues Stat
            Expanded(
              flex: 2,
              child: _buildSummaryStatItem(
                typography: typography,
                label: l10n.withDuesStatLabel,
                value:
                    '${stats.withDues} (Rs. ${stats.totalDues.toStringAsFixed(0)})',
                valueColor: stats.withDues > 0
                    ? AppColors.errorText
                    : AppColors.neutralTitle,
              ),
            ),
            Container(width: 1, height: 28, color: AppColors.neutralLine),

            // On Advance Stat
            Expanded(
              child: _buildSummaryStatItem(
                typography: typography,
                label: l10n.onAdvanceStatLabel,
                value: '${stats.onAdvance}',
                valueColor: stats.onAdvance > 0
                    ? AppColors.successText
                    : AppColors.neutralTitle,
              ),
            ),
          ],
        ),
        loading: () => const SizedBox(
          height: 28,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        error: (_, __) => const SizedBox(height: 28),
      ),
    );
  }

  Widget _buildSummaryStatItem({
    required AppTypography typography,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: typography.caption.copyWith(
            color: AppColors.neutralMuted,
            fontSize: 10,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: typography.labelMd.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFilterChipBar(
    List<Customer> allCustomers,
    AsyncValue<({int active, int onAdvance, int total, double totalDues, int withDues})>
        statsAsync,
    AppLocalizations l10n,
  ) {
    final morningCount = allCustomers.where((c) {
      return c.dailyQuotaAm > 0;
    }).length;

    final eveningCount = allCustomers.where((c) {
      return c.dailyQuotaPm > 0;
    }).length;

    final withDuesCount = allCustomers.where((c) => c.currentDue > 0).length;
    final onAdvanceCount = allCustomers.where((c) => c.advanceBalance > 0).length;

    return FilterChipBar(
      chips: <FilterChipData>[
        FilterChipData(label: l10n.filterAll, count: allCustomers.length),
        FilterChipData(
          label: l10n.filterHasDues,
          count: withDuesCount,
          dotColor: AppColors.errorMain,
        ),
        FilterChipData(
          label: l10n.filterOnAdvance,
          count: onAdvanceCount,
          dotColor: AppColors.successMain,
        ),
        FilterChipData(label: l10n.filterMorning, count: morningCount),
        FilterChipData(label: l10n.filterEvening, count: eveningCount),
      ],
      selectedIndex: ref.watch(customerFilterIndexProvider),
      onSelected: (index) {
        ref.read(customerFilterIndexProvider.notifier).state = index;
      },
    );
  }
}
