import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/delivery.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/empty_state.dart';
import '../delivery_report_preview_screen.dart';
import 'delivery_card.dart';

enum DateFilter {
  today,
  yesterday,
  thisWeek,
  last15Days,
  lastMonth,
  currentMonth,
  custom,
}

class ShareDeliveryReportScreen extends ConsumerStatefulWidget {
  final String customerId;
  final String customerName;
  final List<Delivery> allDeliveries;

  const ShareDeliveryReportScreen({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.allDeliveries,
  });

  @override
  ConsumerState<ShareDeliveryReportScreen> createState() => _ShareDeliveryReportScreenState();
}

class _ShareDeliveryReportScreenState extends ConsumerState<ShareDeliveryReportScreen> {
  DateFilter _selectedFilter = DateFilter.currentMonth;
  DateTime? _customStart;
  DateTime? _customEnd;

  (DateTime, DateTime) _getDateRange() {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case DateFilter.today:
        return (
          DateTime(now.year, now.month, now.day),
          DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      case DateFilter.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        return (
          DateTime(yesterday.year, yesterday.month, yesterday.day),
          DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
        );
      case DateFilter.thisWeek:
        final start = now.subtract(Duration(days: now.weekday - 1));
        return (
          DateTime(start.year, start.month, start.day),
          DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      case DateFilter.last15Days:
        final start = now.subtract(const Duration(days: 14));
        return (
          DateTime(start.year, start.month, start.day),
          DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      case DateFilter.lastMonth:
        final start = DateTime(now.year, now.month - 1, 1);
        final end = DateTime(now.year, now.month, 0, 23, 59, 59);
        return (start, end);
      case DateFilter.currentMonth:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return (start, end);
      case DateFilter.custom:
        final start = _customStart ?? DateTime(now.year, now.month, 1);
        final end = _customEnd ?? now;
        return (
          DateTime(start.year, start.month, start.day),
          DateTime(end.year, end.month, end.day, 23, 59, 59),
        );
    }
  }

  List<Delivery> _getFilteredDeliveries((DateTime, DateTime) range) {
    final start = range.$1;
    final end = range.$2;

    final filtered = widget.allDeliveries.where((d) {
      if (d.status != 'delivered') return false;
      final dDate = DateTime(d.date.year, d.date.month, d.date.day);
      final sDate = DateTime(start.year, start.month, start.day);
      final eDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
      return dDate.isAfter(sDate.subtract(const Duration(days: 1))) &&
          dDate.isBefore(eDate.add(const Duration(days: 1)));
    }).toList();

    filtered.sort((a, b) {
      final cmp = b.date.compareTo(a.date);
      if (cmp != 0) return cmp;
      return b.shift.compareTo(a.shift);
    });

    return filtered;
  }

  Future<void> _pickCustomDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_customStart ?? now) : (_customEnd ?? now),
      firstDate: DateTime(2020),
      lastDate: now,
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
        if (isStart) {
          _customStart = picked;
        } else {
          _customEnd = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);
    final range = _getDateRange();
    final filteredDeliveries = _getFilteredDeliveries(range);
    final dateFmt = DateFormat('dd MMM yyyy');

    final bool hasError = _selectedFilter == DateFilter.custom &&
        _customStart != null &&
        _customEnd != null &&
        _customStart!.isAfter(_customEnd!);

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.shareDeliveryReportScreenTitle),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.spaceMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
              child: Wrap(
                spacing: AppSpacing.spaceXs,
                runSpacing: AppSpacing.spaceXs,
                children: [
                  _buildFilterChip(l10n.filterToday, DateFilter.today, typography),
                  _buildFilterChip(l10n.filterYesterday, DateFilter.yesterday, typography),
                  _buildFilterChip(l10n.filterThisWeek, DateFilter.thisWeek, typography),
                  _buildFilterChip(l10n.filterLast15Days, DateFilter.last15Days, typography),
                  _buildFilterChip(l10n.filterLastMonth, DateFilter.lastMonth, typography),
                  _buildFilterChip(l10n.filterCurrentMonth, DateFilter.currentMonth, typography),
                  _buildFilterChip(l10n.filterCustom, DateFilter.custom, typography),
                ],
              ),
            ),
            if (_selectedFilter == DateFilter.custom) ...[
              const SizedBox(height: AppSpacing.spaceMd),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickCustomDate(true),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.spaceSm),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.neutralLine),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.filterFrom, style: typography.caption.copyWith(color: AppColors.neutralMuted)),
                              const SizedBox(height: 4),
                              Text(
                                _customStart != null ? dateFmt.format(_customStart!) : '-',
                                style: typography.body.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceMd),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickCustomDate(false),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.spaceSm),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.neutralLine),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.filterTo, style: typography.caption.copyWith(color: AppColors.neutralMuted)),
                              const SizedBox(height: 4),
                              Text(
                                _customEnd != null ? dateFmt.format(_customEnd!) : '-',
                                style: typography.body.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter).copyWith(top: AppSpacing.spaceXs),
                  child: Text(
                    l10n.errorFromAfterTo,
                    style: typography.caption.copyWith(color: AppColors.errorText),
                  ),
                ),
            ],
            const SizedBox(height: AppSpacing.spaceMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
              child: Text(
                '${dateFmt.format(range.$1)} - ${dateFmt.format(range.$2)}',
                style: typography.bodySm.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w600),
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceMd),
            Expanded(
              child: filteredDeliveries.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.spaceLg),
                      child: EmptyState(
                        icon: Symbols.local_shipping,
                        title: l10n.emptyDeliveriesInRange,
                        subtitle: '',
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter, vertical: AppSpacing.spaceSm),
                      itemCount: filteredDeliveries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.spaceSm),
                      itemBuilder: (context, index) {
                        return DeliveryCard(delivery: filteredDeliveries[index]);
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenGutter),
              child: AppButton(
                label: l10n.shareDeliveryReportScreenTitle,
                icon: Symbols.share,
                variant: AppButtonVariant.primary,
                onPressed: (hasError || filteredDeliveries.isEmpty) ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DeliveryReportPreviewScreen(
                        customerName: widget.customerName,
                        deliveries: filteredDeliveries,
                        startDate: range.$1,
                        endDate: range.$2,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, DateFilter filter, AppTypography typography) {
    final isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = filter;
          });
        }
      },
      labelStyle: typography.bodySm.copyWith(
        color: isSelected ? Colors.white : AppColors.neutralTitle,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      selectedColor: AppColors.brandPrimary,
      backgroundColor: AppColors.card,
      side: BorderSide(
        color: isSelected ? AppColors.brandPrimary : AppColors.neutralLine,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
    );
  }
}
