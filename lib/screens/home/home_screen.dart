import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/product.dart';
import '../../providers/customer_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/local_sale_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/store_profile_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/metric_card.dart';
import 'widgets/collections_bottom_sheet.dart';
import 'widgets/local_sales_section.dart';
import 'widgets/shift_banner.dart';
import 'quick_sale_screen.dart';
import '../../widgets/temp_language_button.dart';

/// Complete Home Dashboard Screen (plan.md C-M2; Section 2.1).
///
/// Features:
/// 1. Store Header with store name, active status badge, current date,
///    settings gear button, and language toggle (EN/UR).
/// 2. Active Shift Banner with delivery progress, count badges, and tab jump link.
/// 3. Bento KPI Metric Grid (2x3) with 6 MetricCards.
/// 4. Monthly Collection Total banner with target progress.
/// 5. Local Counter Sales section with +1L, +2L, +5L quick-tap buttons and undo.
/// 6. Delivery Schedule Overview with Morning & Evening shift cards.
/// 7. Pull-to-refresh with shimmer loading and graceful error state.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
    required this.onNavigateToTab,
  });

  /// Callback to switch tabs in [AppShell] (e.g. index 2 = Deliveries).
  final ValueChanged<int> onNavigateToTab;

  Future<void> _refreshData(WidgetRef ref) async {
    final DateTime now = DateTime.now();
    ref.invalidate(dashboardProvider);
    ref.invalidate(todayLocalSaleTotalsProvider(now));
    ref.invalidate(lastLocalSaleProvider);
    ref.invalidate(storeProfileProvider);
    ref.invalidate(productListProvider);
    try {
      await ref.read(dashboardProvider.future);
    } catch (_) {
      // Gracefully handled by AsyncValue UI
    }
  }

  void _openCustomSaleSheet(BuildContext context, {Product? defaultProduct}) {
    QuickSaleScreen.show(context, initialProduct: defaultProduct);
  }

  void _showCollections(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CollectionsBottomSheet(type: type),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppTypography typography = AppTypography.of(context);
    final AppLocalizations? l10n =
        Localizations.of<AppLocalizations>(context, AppLocalizations);

    final dashboardAsync = ref.watch(dashboardProvider);
    final storeProfileAsync = ref.watch(storeProfileProvider);
    final productsAsync = ref.watch(productListProvider);

    final String storeName = storeProfileAsync.maybeWhen(
      data: (profile) => profile?.name.isNotEmpty == true
          ? profile!.name
          : (l10n?.storeDefaultName ?? 'Al-Madina Dairy'),
      orElse: () => l10n?.storeDefaultName ?? 'Al-Madina Dairy',
    );

    final String defaultUnit = productsAsync.maybeWhen(
      data: (products) {
        if (products.isEmpty) return 'Litre';
        final String unit = products.first.unit.trim();
        return unit.isEmpty ? 'Litre' : unit;
      },
      orElse: () => 'Litre',
    );

    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat.yMMMMEEEEd().format(now);

    return Material(
      color: AppColors.scaffold,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refreshData(ref),
          color: AppColors.brandPrimary,
          backgroundColor: AppColors.card,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenGutter,
              vertical: AppSpacing.spaceSm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // ── 1. Store Identity Header ──────────────────────────────
                _buildHeader(
                  context,
                  storeName: storeName,
                  formattedDate: formattedDate,
                  typography: typography,
                  l10n: l10n,
                ),
                const SizedBox(height: AppSpacing.spaceMd),

                // ── 2. Async Dashboard Content ────────────────────────────
                dashboardAsync.when(
                  loading: () => _buildLoadingSkeleton(),
                  error: (error, _) => _buildErrorCard(
                    context,
                    ref: ref,
                    typography: typography,
                    l10n: l10n,
                  ),
                  data: (DashboardData data) => _buildDashboardBody(
                    context,
                    ref: ref,
                    data: data,
                    now: now,
                    defaultUnit: defaultUnit,
                    typography: typography,
                    l10n: l10n,
                  ),
                ),

                // Spacing to clear the glass bottom nav bar comfortably
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required String storeName,
    required String formattedDate,
    required AppTypography typography,
    required AppLocalizations? l10n,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    storeName,
                    style: typography.headlineLg.copyWith(
                      color: AppColors.neutralTitle,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedDate,
                    style: typography.caption.copyWith(
                      color: AppColors.neutralMuted,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Settings gear icon button
            IconButton(
              icon: const Icon(
                Symbols.settings,
                size: 22,
                color: AppColors.neutralTitle,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.settings);
              },
            ),
            const TempLanguageButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardBody(
    BuildContext context, {
    required WidgetRef ref,
    required DashboardData data,
    required DateTime now,
    required String defaultUnit,
    required AppTypography typography,
    required AppLocalizations? l10n,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Local Counter Sales Section
        LocalSalesSection(
          now: now,
          onOpenCustomSale: (Product? product) => _openCustomSaleSheet(context, defaultProduct: product),
        ),
        const SizedBox(height: AppSpacing.spaceMd),

        // Active Shifts Banner (Morning & Evening combined)
        ShiftBanner(
          data: data,
          onNavigateToDeliveries: () => onNavigateToTab(2),
        ),
        const SizedBox(height: AppSpacing.spaceSm), // Reduced from spaceMd

        // Bento KPI Metric Grid (2x3)
        _buildBentoKpiGrid(context, ref, data, defaultUnit, typography, l10n, onNavigateToTab),
        const SizedBox(height: AppSpacing.spaceSm), // Reduced from spaceMd


        // Advance Held Banner
        _buildAdvanceHeldBanner(data, typography, l10n, ref, onNavigateToTab),
      ],
    );
  }

  Widget _buildBentoKpiGrid(
    BuildContext context,
    WidgetRef ref,
    DashboardData data,
    String defaultUnit,
    AppTypography typography,
    AppLocalizations? l10n,
    ValueChanged<int> onNavigateToTab,
  ) {
    return Column(
      children: <Widget>[
        // Row 1: Total Customers & Total Dues
        Row(
          children: <Widget>[
            Expanded(
              child: MetricCard(
                label: l10n?.kpiTotalCustomers ?? 'Total Customers',
                value: '${data.totalCustomers}',
                icon: Symbols.group,
                iconBgColor: AppColors.brandSoft,
                iconColor: AppColors.brandPrimary,
                onTap: () {
                  ref.read(customerFilterIndexProvider.notifier).state = 0;
                  onNavigateToTab(1);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.cardGap),
            Expanded(
              child: MetricCard(
                label: l10n?.kpiTotalDues ?? 'Total Dues',
                value: data.totalDues.toStringAsFixed(0),
                valuePrefix: 'Rs. ',
                onTap: () {
                  ref.read(customerFilterIndexProvider.notifier).state = 1;
                  onNavigateToTab(1);
                },
                valueTrailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Symbols.person,
                      size: 16,
                      color: data.totalDues > 0 ? AppColors.errorText : AppColors.neutralMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${data.overdueCount}',
                      style: typography.bodySm.copyWith(
                        color: data.totalDues > 0 ? AppColors.errorText : AppColors.neutralMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                icon: Symbols.payments,
                iconBgColor: data.totalDues > 0
                    ? AppColors.errorLight
                    : AppColors.brandSoft,
                iconColor: data.totalDues > 0
                    ? AppColors.errorMain
                    : AppColors.brandPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.cardGap),

        // Row 2: Daily Sell & Monthly Sell
        Row(
          children: <Widget>[
            Expanded(
              child: MetricCard(
                label: l10n?.kpiDailySell ?? 'Daily Sell',
                value: data.dailySellQuantity.toStringAsFixed(1),
                valueSuffix: ' $defaultUnit',
                icon: Symbols.local_shipping,
                iconBgColor: AppColors.brandSoft,
                iconColor: AppColors.brandPrimary,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.salesAnalyticsPath('daily')),
              ),
            ),
            const SizedBox(width: AppSpacing.cardGap),
            Expanded(
              child: MetricCard(
                label: l10n?.kpiMonthlySell ?? 'Monthly Sell',
                value: data.monthlySellQuantity.toStringAsFixed(0),
                valueSuffix: ' $defaultUnit',
                icon: Symbols.trending_up,
                iconBgColor: AppColors.successLight,
                iconColor: AppColors.successMain,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.salesAnalyticsPath('monthly')),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.cardGap),

        // Row 3: Today's Cash & Monthly Collection
        Row(
          children: <Widget>[
            Expanded(
              child: MetricCard(
                label: l10n?.kpiTodayCash ?? "Today's Cash",
                value: data.todayCash.toStringAsFixed(0),
                valuePrefix: 'Rs. ',
                icon: Symbols.account_balance_wallet,
                iconBgColor: AppColors.brandSoft,
                iconColor: AppColors.brandPrimary,
                onTap: () => _showCollections(context, 'today'),
              ),
            ),
            const SizedBox(width: AppSpacing.cardGap),
            Expanded(
              child: MetricCard(
                label: l10n?.monthlyCollection ?? 'Monthly Collection',
                value: data.monthlyCollectionTotal.toStringAsFixed(0),
                valuePrefix: 'Rs. ',
                icon: Symbols.account_balance,
                iconBgColor: AppColors.brandSoft,
                iconColor: AppColors.brandPrimary,
                onTap: () => _showCollections(context, 'month'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdvanceHeldBanner(
    DashboardData data,
    AppTypography typography,
    AppLocalizations? l10n,
    WidgetRef ref,
    ValueChanged<int> onNavigateToTab,
  ) {
    return MetricCard(
      label: l10n?.kpiAdvanceHeld ?? 'Advance Held',
      value: data.advanceHeld.toStringAsFixed(0),
      valuePrefix: 'Rs. ',
      onTap: () {
        ref.read(customerFilterIndexProvider.notifier).state = 2;
        onNavigateToTab(1);
      },
      valueTrailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Symbols.person,
            size: 16,
            color: AppColors.neutralMuted,
          ),
          const SizedBox(width: 4),
          Text(
            '${data.prepaidCount}',
            style: typography.bodySm.copyWith(
              color: AppColors.neutralMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      icon: Symbols.savings,
      iconBgColor: AppColors.successLight,
      iconColor: AppColors.successMain,
    );
  }

  Widget _buildLoadingSkeleton() {
    return const Column(
      children: <Widget>[
        ShimmerCard(count: 1, height: 110),
        SizedBox(height: AppSpacing.spaceMd),
        ShimmerMetricGrid(),
        SizedBox(height: AppSpacing.spaceMd),
        ShimmerCard(count: 2, height: 120),
      ],
    );
  }

  Widget _buildErrorCard(
    BuildContext context, {
    required WidgetRef ref,
    required AppTypography typography,
    required AppLocalizations? l10n,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.spaceLg),
      child: Center(
        child: Column(
          children: <Widget>[
            const Icon(
              Symbols.error,
              size: 40,
              color: AppColors.errorMain,
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            Text(
              l10n?.loadFailed ?? 'Failed to load dashboard data',
              style: typography.body.copyWith(
                color: AppColors.neutralTitle,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.spaceMd),
            AppButton(
              label: l10n?.retry ?? 'Retry',
              variant: AppButtonVariant.primary,
              icon: Symbols.refresh,
              onPressed: () => ref.invalidate(dashboardProvider),
            ),
          ],
        ),
      ),
    );
  }
}
