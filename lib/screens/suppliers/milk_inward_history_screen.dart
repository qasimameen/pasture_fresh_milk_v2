import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasture_fresh_milk/core/utils/date_display.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/milk_collection.dart';
import '../../models/supplier.dart';
import '../../providers/milk_inward_history_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_chip_bar.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/status_badge.dart';

enum _HistoryDateFilter { today, thisWeek, thisMonth, custom }

final _allSuppliersProvider = FutureProvider.autoDispose<List<Supplier>>((ref) async {
  final repo = ref.watch(supplierRepositoryProvider);
  return repo.getAll();
});

class MilkInwardHistoryScreen extends ConsumerStatefulWidget {
  const MilkInwardHistoryScreen({super.key, this.initialSupplierId});

  final String? initialSupplierId;

  @override
  ConsumerState<MilkInwardHistoryScreen> createState() => _MilkInwardHistoryScreenState();
}

class _MilkInwardHistoryScreenState extends ConsumerState<MilkInwardHistoryScreen> {
  _HistoryDateFilter _selectedDateFilter = _HistoryDateFilter.thisMonth;
  late DateTime _startDate;
  late DateTime _endDate;
  DateTime? _customStart;
  DateTime? _customEnd;

  String? _selectedSupplierId;
  String? _selectedShift;
  int _selectedShiftIndex = 0; // 0=All, 1=Morning, 2=Evening

  @override
  void initState() {
    super.initState();
    _selectedSupplierId = widget.initialSupplierId;
    _applyPreset(_HistoryDateFilter.thisMonth);
  }

  void _applyPreset(_HistoryDateFilter filter) {
    _selectedDateFilter = filter;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (filter == _HistoryDateFilter.today) {
      _startDate = today;
      _endDate = today;
    } else if (filter == _HistoryDateFilter.thisWeek) {
      _startDate = today.subtract(Duration(days: now.weekday - 1));
      _endDate = today;
    } else if (filter == _HistoryDateFilter.thisMonth) {
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = today;
    } else if (filter == _HistoryDateFilter.custom) {
      _startDate = _customStart ?? DateTime(now.year, now.month, 1);
      _endDate = _customEnd ?? today;
    }
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2020),
      lastDate: today,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.brandPrimary,
              onPrimary: Colors.white,
              surface: AppColors.scaffold,
              onSurface: AppColors.neutralTitle,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateFilter = _HistoryDateFilter.custom;
        _customStart = picked.start;
        _customEnd = picked.end;
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Map<DateTime, List<MilkCollection>> _groupByDate(List<MilkCollection> collections) {
    final map = <DateTime, List<MilkCollection>>{};
    for (final c in collections) {
      final dDate = DateTime(c.date.year, c.date.month, c.date.day);
      map.putIfAbsent(dDate, () => []).add(c);
    }
    return map;
  }

  Widget _buildMetricColumn({
    required String label,
    required String value,
    required AppTypography typography,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          label,
          style: typography.caption.copyWith(color: AppColors.neutralMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: typography.body.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutralTitle,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);
    
    final filter = MilkInwardFilter(
      start: _startDate,
      end: _endDate,
      supplierId: _selectedSupplierId,
      shift: _selectedShift,
    );
    final historyAsync = ref.watch(milkInwardHistoryProvider(filter));
    final suppliersAsync = ref.watch(_allSuppliersProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.milkInwardHistoryTitle),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Range Chips
            const SizedBox(height: AppSpacing.spaceMd),
            FilterChipBar(
              chips: <FilterChipData>[
                FilterChipData(label: l10n.historyRangeToday),
                FilterChipData(label: l10n.shareReportThisWeek),
                FilterChipData(label: l10n.shareReportThisMonth),
                FilterChipData(label: l10n.shareReportCustom),
              ],
              selectedIndex: _selectedDateFilter.index,
              onSelected: (i) {
                if (i == 3) {
                  _pickCustomRange();
                } else {
                  setState(() {
                    _applyPreset(_HistoryDateFilter.values[i]);
                  });
                }
              },
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
              child: Row(
                children: <Widget>[
                  Text(
                    '${formatShortDate(_startDate)} - ${formatShortDate(_endDate)}',
                    style: typography.bodySm.copyWith(
                      color: AppColors.brandPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spaceMd),

            // Supplier Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
              child: suppliersAsync.when(
                data: (suppliers) {
                  return AppDropdown<String?>(
                    label: l10n.historySupplierLabel,
                    value: _selectedSupplierId,
                    items: <String?>[null, ...suppliers.map((s) => s.id)],
                    itemLabelBuilder: (String? id) {
                      if (id == null) return l10n.filterAll;
                      final s = suppliers.firstWhere((s) => s.id == id);
                      return s.isActive ? s.name : '${s.name} ${l10n.historyArchivedSuffix}';
                    },
                    onChanged: (String? val) {
                      setState(() {
                        _selectedSupplierId = val;
                      });
                    },
                  );
                },
                loading: () => AppDropdown<String?>(
                  label: l10n.historySupplierLabel,
                  value: null,
                  items: const <String?>[null],
                  itemLabelBuilder: (_) => '...',
                ),
                error: (_, __) => AppDropdown<String?>(
                  label: l10n.historySupplierLabel,
                  value: null,
                  items: const <String?>[null],
                  itemLabelBuilder: (_) => l10n.historyLoadError,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceMd),

            // Shift Chips
            FilterChipBar(
              chips: <FilterChipData>[
                FilterChipData(label: l10n.filterAll),
                FilterChipData(label: l10n.shiftMorning),
                FilterChipData(label: l10n.shiftEvening),
              ],
              selectedIndex: _selectedShiftIndex,
              onSelected: (i) {
                setState(() {
                  _selectedShiftIndex = i;
                  if (i == 0) {
                    _selectedShift = null;
                  } else if (i == 1) {
                    _selectedShift = 'morning';
                  } else if (i == 2) {
                    _selectedShift = 'evening';
                  }
                });
              },
            ),
            const SizedBox(height: AppSpacing.spaceMd),

            // List and Summary
            Expanded(
              child: historyAsync.when(
                data: (collections) {
                  if (collections.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.spaceLg),
                      child: EmptyState(
                        icon: Symbols.history,
                        title: l10n.historyNoDeliveries,
                        subtitle: l10n.historyNoDeliveriesSubtitle,
                      ),
                    );
                  }

                  final totals = computeMilkInwardTotals(collections);
                  final grouped = _groupByDate(collections);
                  final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
                  final allSuppliers = suppliersAsync.valueOrNull ?? <Supplier>[];

                  return CustomScrollView(
                    slivers: <Widget>[
                      // Summary metrics
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: MetricCard(
                                      label: l10n.totalMilkSupplied,
                                      value: totals.totalLitres.toStringAsFixed(1),
                                      valueSuffix: ' L',
                                      icon: Symbols.water_drop,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.spaceSm),
                                  Expanded(
                                    child: MetricCard(
                                      label: l10n.historyTotalAmount,
                                      value: totals.totalAmount.toStringAsFixed(0),
                                      valuePrefix: 'Rs. ',
                                      icon: Symbols.payments,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.spaceXs),
                              Text(
                                l10n.historyEntriesCount(totals.count.toString()),
                                style: typography.caption.copyWith(color: AppColors.neutralMuted),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.spaceMd),
                            ],
                          ),
                        ),
                      ),

                      // Grouped list
                      for (final date in dates) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(AppSpacing.screenGutter, AppSpacing.spaceLg, AppSpacing.screenGutter, AppSpacing.spaceSm),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  formatShortDate(date),
                                  style: typography.subhead.copyWith(color: AppColors.neutralTitle),
                                ),
                                Builder(
                                  builder: (context) {
                                    final dayList = grouped[date]!;
                                    final dayTotals = computeMilkInwardTotals(dayList);
                                    return Text(
                                      '${dayTotals.totalLitres.toStringAsFixed(1)}L \u2022 Rs. ${dayTotals.totalAmount.toStringAsFixed(0)}',
                                      style: typography.bodySm.copyWith(
                                        color: AppColors.neutralMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final collection = grouped[date]![index];
                              final isMorning = collection.shift == 'morning';
                              final s = allSuppliers.where((x) => x.id == collection.supplierId).firstOrNull;
                              final supplierName = s?.name ?? l10n.historyUnknownSupplier;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.screenGutter,
                                  vertical: 4, // half of spaceSm gap
                                ),
                                child: AppCard(
                                  padding: const EdgeInsets.all(AppSpacing.spaceMd),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      // Supplier Name & Shift Badge
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              supplierName,
                                              style: typography.bodySm.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.neutralTitle,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.spaceSm),
                                          StatusBadge(
                                            label: isMorning ? l10n.shiftMorning : l10n.shiftEvening,
                                            backgroundColor: isMorning ? AppColors.warningLight : AppColors.brandSoft,
                                            textColor: isMorning ? AppColors.warningText : AppColors.brandPrimary,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.spaceSm),

                                      // Quality Metrics Grid
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.spaceSm,
                                          vertical: AppSpacing.spaceXs,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.scaffold,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppColors.neutralLine),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            _buildMetricColumn(
                                              label: l10n.qtyLabel,
                                              value: collection.quantity.toStringAsFixed(1),
                                              typography: typography,
                                            ),
                                            Container(
                                              width: 1,
                                              height: 24,
                                              color: AppColors.neutralLine,
                                            ),
                                            _buildMetricColumn(
                                              label: l10n.ratePerLitreLabel,
                                              value: 'Rs. ${collection.rate.toStringAsFixed(0)}',
                                              typography: typography,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.spaceSm),

                                      // Batch Value Summary
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            l10n.batchValueLabel,
                                            style: typography.caption.copyWith(color: AppColors.neutralMuted),
                                          ),
                                          Text(
                                            'Rs. ${collection.batchValue.toStringAsFixed(0)}',
                                            style: typography.bodySm.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.brandPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: grouped[date]!.length,
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.screenGutter),
                  child: ShimmerCard(),
                ),
                error: (e, st) => Center(child: Padding(padding: const EdgeInsets.all(AppSpacing.spaceLg), child: Text(l10n.historyLoadError, textAlign: TextAlign.center))), // Error fallback
              ),
            ),
          ],
        ),
      ),
    );
  }
}
