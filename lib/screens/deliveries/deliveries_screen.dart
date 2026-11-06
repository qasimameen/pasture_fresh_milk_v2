import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/delivery.dart';
import '../../models/customer.dart';
import '../../providers/customer_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/delivery_provider.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/date_selector.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_chip_bar.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/shift_selector.dart';
import 'widgets/delivery_card.dart';
import '../../widgets/temp_language_button.dart';

/// Today's Deliveries screen (plan.md Section 2.4 / Milestone D-M1).
///
/// Features:
/// - Screen header with count pill and Mark All bulk action
/// - Date navigation pill via [DateSelector]
/// - AM/PM shift selector via [ShiftSelector] with dynamic session counts
/// - Search bar with real-time filtering by customer name, phone, or address
/// - Status filter chips: All, Pending, Delivered, Skipped
/// - Delivery list area with shimmer loading and empty state
/// - Sticky operational summary banner displaying remaining deliveries count
///   and total volume left to deliver
class DeliveriesScreen extends ConsumerStatefulWidget {
  const DeliveriesScreen({
    super.key,
    this.initialDate,
    this.initialShift,
    this.onDeliveryTap,
    this.onMarkAllTap,
  });

  final DateTime? initialDate;
  final ShiftType? initialShift;

  /// Optional callback when a delivery item is tapped.
  final ValueChanged<Delivery>? onDeliveryTap;

  /// Optional callback for the Mark All action button.
  final VoidCallback? onMarkAllTap;

  @override
  ConsumerState<DeliveriesScreen> createState() => DeliveriesScreenState();
}

class DeliveriesScreenState extends ConsumerState<DeliveriesScreen> {
  late DateTime _selectedDate;
  late ShiftType _selectedShift;
  String _searchQuery = '';
  int _selectedFilterIndex = 0; // 0: All, 1: Pending, 2: Delivered, 3: Skipped
  final TextEditingController _searchController = TextEditingController();

  void resetFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedFilterIndex = 0;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = widget.initialDate ?? DateTime(now.year, now.month, now.day);
    if (widget.initialShift != null) {
      _selectedShift = widget.initialShift!;
    } else {
      _selectedShift = now.hour < 15 ? ShiftType.morning : ShiftType.evening;
    }
  }

  String get _shiftString =>
      _selectedShift == ShiftType.morning ? 'morning' : 'evening';

  void _handleDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = DateTime(newDate.year, newDate.month, newDate.day);
    });
  }

  void _handleShiftChanged(ShiftType newShift) {
    setState(() {
      _selectedShift = newShift;
    });
  }

  List<Delivery> _applyFilters(List<Delivery> deliveries, Map<String, Customer> customerMap) {
    var result = deliveries;

    // Filter by status chip
    switch (_selectedFilterIndex) {
      case 1:
        result = result.where((d) => d.status == 'pending').toList();
        break;
      case 2:
        result = result.where((d) => d.status == 'delivered').toList();
        break;
      case 3:
        result = result.where((d) => d.status == 'skipped').toList();
        break;
      default:
        break;
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((d) {
        final c = customerMap[d.customerId];
        final productName = d.productName.toLowerCase();
        final cName = c?.name.toLowerCase() ?? '';
        final cPhone = c?.phone.toLowerCase() ?? '';
        final cAddress = c?.address?.toLowerCase() ?? '';

        return productName.contains(q) ||
            cName.contains(q) ||
            cPhone.contains(q) ||
            cAddress.contains(q) ||
            d.customerId.toLowerCase().contains(q);
      }).toList();
    }

    // Sort logic: pending first, then by customer name ascending
    result = result.toList();
    result.sort((a, b) {
      final aPending = a.status == 'pending' ? 0 : 1;
      final bPending = b.status == 'pending' ? 0 : 1;
      final groupCompare = aPending.compareTo(bPending);
      if (groupCompare != 0) return groupCompare;

      final aName = (customerMap[a.customerId]?.name ?? '').trim().toLowerCase();
      final bName = (customerMap[b.customerId]?.name ?? '').trim().toLowerCase();
      return aName.compareTo(bName);
    });
    return result;
  }

  Future<void> _handleRefresh() async {
    ref.invalidate(deliveryListProvider);
    ref.invalidate(deliveryStatsProvider);
  }


  Future<void> _handleMarkAll(AppLocalizations l10n) async {
    if (widget.onMarkAllTap != null) {
      widget.onMarkAllTap!();
      return;
    }
    final deliveries = ref.read(deliveryListProvider(_selectedDate, _shiftString)).valueOrNull ?? [];
    final pending = deliveries.where((d) => d.status == 'pending').toList();
    if (pending.isEmpty) {
      AppSnackBar.show(context, message: l10n.markAllSuccess);
      return;
    }
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: l10n.markAllConfirmTitle,
      message: l10n.markAllConfirmBody(pending.length),
      cancelLabel: l10n.cancelAction,
      confirmLabel: l10n.confirmAction,
    );
    if (!confirmed || !mounted) return;

    final repo = ref.read(deliveryRepositoryProvider);
    int successCount = 0;
    for (final d in pending) {
      try {
        await repo.markDelivered(d.id, d.scheduledQuantity, 'auto', 0.0);
        successCount++;
        // Invalidate customer-specific providers for each successful delivery
        ref.invalidate(customerByIdProvider(d.customerId));
        ref.invalidate(customerDeliveryHistoryProvider(d.customerId));
        ref.invalidate(paymentListByCustomerProvider(d.customerId));
      } catch (e) {
        // Skip any individual failures silently, but they won't corrupt the DB anymore
      }
    }
    
    ref.invalidate(deliveryListProvider);
    ref.invalidate(deliveryStatsProvider);
    // Invalidate global dashboard since it tracks global metrics
    ref.invalidate(dashboardProvider);

    if (mounted) {
      if (successCount == pending.length) {
        AppSnackBar.show(context, message: l10n.markAllSuccess);
      } else {
        AppSnackBar.show(context, message: '$successCount/${pending.length} marked as delivered.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);

    final deliveriesAsync = ref.watch(
      deliveryListProvider(_selectedDate, _shiftString),
    );
    final statsAsync = ref.watch(
      deliveryStatsProvider(_selectedDate, _shiftString),
    );
    final customersAsync = ref.watch(customerListProvider);
    final Map<String, Customer> customerMap = {
      for (final c in customersAsync.valueOrNull ?? []) c.id: c
    };

    // Also fetch opposite shift stats for shift selector count pills
    final oppositeShiftString =
        _selectedShift == ShiftType.morning ? 'evening' : 'morning';
    final oppositeStatsAsync = ref.watch(
      deliveryStatsProvider(_selectedDate, oppositeShiftString),
    );

    final currentTotal = statsAsync.valueOrNull?.total ?? 0;
    final oppositeTotal = oppositeStatsAsync.valueOrNull?.total ?? 0;
    final morningCount = _selectedShift == ShiftType.morning ? currentTotal : oppositeTotal;
    final eveningCount = _selectedShift == ShiftType.evening ? currentTotal : oppositeTotal;

    final pendingCount = statsAsync.valueOrNull?.pending ?? 0;
    final deliveredCount = statsAsync.valueOrNull?.delivered ?? 0;
    final skippedCount = statsAsync.valueOrNull?.skipped ?? 0;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // ── Scrollable Upper Content (Header, Selectors, Filters, List) ──
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenGutter,
                          AppSpacing.spaceSm,
                          AppSpacing.screenGutter,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // ── Screen Title & Mark All Button ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      l10n.deliveriesTitle,
                                      style: typography.headlineLg.copyWith(
                                        color: AppColors.neutralTitle,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.spaceSm),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.brandSoft,
                                        borderRadius: BorderRadius.circular(9999),
                                      ),
                                      child: Text(
                                        '$currentTotal',
                                        key: const Key('deliveries_total_badge'),
                                        style: typography.labelSm.copyWith(
                                          color: AppColors.brandPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontFeatures: const [FontFeature.tabularFigures()],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton.icon(
                                  key: const Key('deliveries_mark_all_btn'),
                                  onPressed: () => _handleMarkAll(l10n),
                                  icon: const Icon(
                                    Symbols.done_all,
                                    size: 18,
                                    color: AppColors.brandPrimary,
                                  ),
                                  label: Text(
                                    l10n.markAllAction,
                                    style: typography.bodySm.copyWith(
                                      color: AppColors.brandPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const TempLanguageButton(),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.spaceSm),

                            // ── Date Selector ────────────────────────────────
                            Align(
                              alignment: Alignment.center,
                              heightFactor: 1,
                              child: DateSelector(
                                key: const Key('deliveries_date_selector'),
                                selectedDate: _selectedDate,
                                onDateChanged: _handleDateChanged,
                                showToday: true,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.spaceSm),

                            // ── Shift Selector ───────────────────────────────
                            ShiftSelector(
                              key: const Key('deliveries_shift_selector'),
                              selectedShift: _selectedShift,
                              onShiftChanged: _handleShiftChanged,
                              morningCount: morningCount,
                              eveningCount: eveningCount,
                            ),
                            const SizedBox(height: AppSpacing.spaceSm),

                            // ── Search Bar ───────────────────────────────────
                            AppSearchBar(
                              controller: _searchController,
                              key: const Key('deliveries_search_bar'),
                              hintText: l10n.searchDeliveriesHint,
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val.trim();
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.spaceSm),

                            // ── Filter Chips ─────────────────────────────────
                            FilterChipBar(
                              key: const Key('deliveries_filter_chips'),
                              selectedIndex: _selectedFilterIndex,
                              onSelected: (idx) {
                                setState(() {
                                  _selectedFilterIndex = idx;
                                });
                              },
                              chips: <FilterChipData>[
                                FilterChipData(
                                  label: l10n.filterAll,
                                  count: currentTotal,
                                ),
                                FilterChipData(
                                  label: l10n.deliveryStatusPending,
                                  count: pendingCount,
                                  dotColor: AppColors.warningMain,
                                ),
                                FilterChipData(
                                  label: l10n.deliveryStatusDelivered,
                                  count: deliveredCount,
                                  dotColor: AppColors.successMain,
                                ),
                                FilterChipData(
                                  label: l10n.deliveryStatusSkipped,
                                  count: skippedCount,
                                  dotColor: AppColors.errorMain,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.spaceSm),
                          ],
                        ),
                      ),
                    ),

                    // ── Deliveries List ───────────────────────────────────────
                    deliveriesAsync.when(
                      data: (deliveries) {
                        final filtered = _applyFilters(deliveries, customerMap);

                        if (filtered.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.spaceLg),
                                child: EmptyState(
                                  icon: Symbols.local_shipping,
                                  title: l10n.noDeliveriesFound,
                                  subtitle: l10n.noDeliveriesMatching,
                                ),
                              ),
                            ),
                          );
                        }

                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenGutter,
                            0,
                            AppSpacing.screenGutter,
                            AppSpacing.spaceMd,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final d = filtered[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.cardGap,
                                  ),
                                  child: DeliveryCard(
                                    key: Key('delivery_card_${d.id}'),
                                    delivery: d,
                                    selectedDate: _selectedDate,
                                    shiftString: _shiftString,
                                    onTap: widget.onDeliveryTap != null
                                        ? () => widget.onDeliveryTap!(d)
                                        : null,
                                  ),
                                );
                              },
                              childCount: filtered.length,
                            ),
                          ),
                        );
                      },
                      loading: () => const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenGutter,
                          ),
                          child: ShimmerCard(count: 3, height: 110),
                        ),
                      ),
                      error: (err, _) => SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            l10n.loadFailed,
                            style: typography.body.copyWith(
                              color: AppColors.errorText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
