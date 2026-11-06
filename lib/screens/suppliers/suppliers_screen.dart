import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/supplier.dart';
import '../../providers/milk_collection_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/date_selector.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_chip_bar.dart';

import '../../widgets/loading_state.dart';
import '../../widgets/metric_card.dart';
import 'widgets/record_milk_sheet.dart';
import 'widgets/supplier_card.dart';
import 'widgets/supplier_form_sheet.dart';
import '../../widgets/temp_language_button.dart';
/// Suppliers & Procurement Screen (plan.md C-M13; Section 2.6).
///
/// Features:
/// - Screen Header with LanguageToggle
/// - DateSelector
/// - One row of two KPI cards (Total Milk Inward, Today's Payable)
/// - Suppliers section header with farm count badge
/// - FilterChipBar (All, Pending Khata)
/// - Supplier cards
/// - Pull-to-refresh & EmptyState
/// - FAB "Add Supplier"
class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({
    super.key,
    this.initialDate,
  });

  /// Optional initial date (defaults to today).
  final DateTime? initialDate;

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  late DateTime _selectedDate;
  int _selectedFilterIndex = 0; // 0 = All, 1 = Pending Khata
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    final now = DateTime.now();
    _selectedDate = widget.initialDate ?? DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(supplierListProvider);
    ref.invalidate(milkCollectionStatsProvider(_selectedDate));
  }

  void _openRecordMilkSheet(BuildContext context, {required Supplier initialSupplier}) {
    RecordMilkSheet.show(
      context,
      initialSupplier: initialSupplier,
      initialDate: _selectedDate,
      onSuccess: _refresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);

    final suppliersAsync = ref.watch(supplierListProvider);
    final statsAsync = ref.watch(milkCollectionStatsProvider(_selectedDate));
    final suppliers = ref.watch(supplierListProvider).valueOrNull ?? const <Supplier>[];
    final totalOwed = suppliers.fold<double>(0.0, (sum, s) => sum + (s.pendingKhata > 0 ? s.pendingKhata : 0.0));

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_supplier_fab'),
        onPressed: () => SupplierFormSheet.show(context),
        backgroundColor: AppColors.brandPrimary,
        icon: const Icon(Symbols.add, color: Colors.white),
        label: Text(
          l10n.addSupplierFab,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.brandPrimary,
          child: CustomScrollView(
            slivers: <Widget>[
              // ── Top Bar / Header ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.spaceLg,
                    AppSpacing.spaceMd,
                    AppSpacing.spaceLg,
                    AppSpacing.spaceSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          l10n.suppliersScreenTitle,
                          style: typography.heading.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutralTitle,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spaceSm),
                      const TempLanguageButton(),
                    ],
                  ),
                ),
              ),

              // ── Date Selector ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
                  child: Align(
                    alignment: Alignment.center,
                    heightFactor: 1,
                    child: DateSelector(
                      selectedDate: _selectedDate,
                      onDateChanged: (newDate) {
                        setState(() {
                          _selectedDate = newDate;
                        });
                      },
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.spaceMd)),

              // ── One row of two KPI cards ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
                  child: statsAsync.when(
                    data: (stats) => Row(
                      children: <Widget>[
                        Expanded(
                          child: MetricCard(
                            label: l10n.totalMilkInwardKpi,
                            value: stats.totalQuantity.toStringAsFixed(1),
                            icon: Symbols.local_shipping,
                            iconBgColor: AppColors.successLight,
                            iconColor: AppColors.successText,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.spaceSm),
                        Expanded(
                          child: MetricCard(
                            label: l10n.dairyPayablesKpi,
                            value: 'Rs. ${totalOwed.toStringAsFixed(0)}',
                            icon: Symbols.payments,
                            iconBgColor: AppColors.errorLight,
                            iconColor: AppColors.errorText,
                          ),
                        ),
                      ],
                    ),
                    loading: () => const ShimmerMetricGrid(),
                    error: (e, _) => Center(child: Text('Error loading stats: $e')),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.spaceMd)),



              // ── Search Bar ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
                  child: AppSearchBar(
                    controller: _searchController,
                    hintText: l10n.searchSuppliersHint,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.spaceMd)),

              // ── Suppliers List with FilterChipBar ────────────────────
              suppliersAsync.when(
                data: (suppliers) {
                  return _buildSuppliersContent(
                    context,
                    l10n: l10n,
                    suppliers: suppliers,
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
                    child: ShimmerCard(count: 2),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Center(child: Text('Error: $e')),
                ),
              ),

              // Bottom spacing so FAB does not obscure content
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuppliersContent(
    BuildContext context, {
    required AppLocalizations l10n,
    required List<Supplier> suppliers,
  }) {
    // Counts for filter chips
    final pendingKhataCount = suppliers.where((s) => s.hasKhataPending).length;

    // Filter suppliers
    final List<Supplier> filteredSuppliers = suppliers.where((s) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatches = s.name.toLowerCase().contains(q);
        final phoneMatches = s.phone?.toLowerCase().contains(q) ?? false;
        if (!nameMatches && !phoneMatches) {
          return false;
        }
      }

      switch (_selectedFilterIndex) {
        case 1: // Pending Khata
          return s.hasKhataPending;
        case 0: // All
        default:
          return true;
      }
    }).toList();

    return SliverList(
      delegate: SliverChildListDelegate(
        <Widget>[
          // Section Header with farm count badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  l10n.suppliersSectionTitle,
                  style: AppTypography.of(context).subhead.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutralTitle,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.brandSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.farmsCountBadge(suppliers.length),
                    style: AppTypography.of(context).caption.copyWith(
                          color: AppColors.brandPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.spaceSm),

          // FilterChipBar
          FilterChipBar(
            selectedIndex: _selectedFilterIndex,
            onSelected: (index) {
              setState(() {
                _selectedFilterIndex = index;
              });
            },
            chips: [
              FilterChipData(
                label: l10n.filterAll,
                count: suppliers.length,
              ),
              FilterChipData(
                label: l10n.filterPendingKhata,
                count: pendingKhataCount,
                dotColor: AppColors.warningDark,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.spaceMd),

          // Supplier Cards List or EmptyState
          if (filteredSuppliers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceLg,
                vertical: AppSpacing.spaceXl,
              ),
              child: EmptyState(
                icon: Symbols.agriculture,
                title: l10n.noSuppliersFound,
                subtitle: l10n.noSuppliersSubtitle,
                actionLabel: l10n.addSupplierFab,
                onAction: () => SupplierFormSheet.show(context),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
              child: Column(
                children: filteredSuppliers.map((supplier) {
                  return SupplierCard(
                    supplier: supplier,
                    onViewKhata: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.supplierKhataPath(supplier.id),
                      );
                    },
                    onLogDelivery: () => _openRecordMilkSheet(
                      context,
                      initialSupplier: supplier,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
