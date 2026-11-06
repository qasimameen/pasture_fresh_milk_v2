import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/customer.dart';
import '../../../models/delivery.dart';
import '../../../widgets/empty_state.dart';
import 'share_delivery_report_screen.dart';
import 'delivery_card.dart';

/// Customer Delivery History Tab (plan.md C-M8 / Section 2.3).
///
/// Features:
/// - Delivery entries grouped by date header (EEE, dd MMM yyyy)
/// - Per-entry: shift badge (AM/PM), product name, quantity, rate, total,
///   status badge (Delivered / Skipped / Pending), and delivery time
/// - Infinite scroll pagination (20 per page)
/// - Empty state when no deliveries exist
class DeliveryHistoryTab extends ConsumerStatefulWidget {
  const DeliveryHistoryTab({
    super.key,
    required this.deliveries,
    required this.customer,
    this.pageSize = 20,
    this.scrollController,
  });

  /// The customer for whom the deliveries are being displayed.
  final Customer customer;

  /// All past deliveries for this customer, sorted descending by date.
  final List<Delivery> deliveries;

  /// Number of entries loaded per page (default 20 per plan.md).
  final int pageSize;

  /// Optional parent scroll controller for nested scroll views.
  final ScrollController? scrollController;

  @override
  ConsumerState<DeliveryHistoryTab> createState() => _DeliveryHistoryTabState();
}

class _DeliveryHistoryTabState extends ConsumerState<DeliveryHistoryTab> {
  late int _displayedCount;
  late ScrollController _internalController;
  bool _ownsController = false;

  String _filter = 'all'; // 'all', 'delivered', 'undelivered'
  String _searchQuery = '';
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _displayedCount = widget.pageSize;
    if (widget.scrollController != null) {
      _internalController = widget.scrollController!;
    } else {
      _internalController = ScrollController();
      _ownsController = true;
    }
    _internalController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _internalController.removeListener(_onScroll);
    if (_ownsController) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_internalController.hasClients) {
      final maxScroll = _internalController.position.maxScrollExtent;
      final currentScroll = _internalController.position.pixels;
      if (currentScroll >= maxScroll - 150) {
        _loadMore();
      }
    }
  }

  void _loadMore() {
    final total = widget.deliveries.length;
    if (_displayedCount < total) {
      setState(() {
        _displayedCount = (_displayedCount + widget.pageSize).clamp(0, total);
      });
    }
  }

  /// Sorts and filters deliveries descending by date (newest first).
  List<Delivery> get _sorted {
    var list = List<Delivery>.from(widget.deliveries);

    // Apply Status Filter
    if (_filter == 'delivered') {
      list = list.where((d) => d.status == 'delivered').toList();
    } else if (_filter == 'undelivered') {
      list = list.where((d) => d.status != 'delivered').toList();
    }

    // Apply Date Search
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      final dateFmt = DateFormat('EEE, dd MMM yyyy');
      final dateFmt2 = DateFormat('dd-MM-yyyy');
      final dateFmt3 = DateFormat('dd/MM/yyyy');
      list = list.where((d) {
        return dateFmt.format(d.date).toLowerCase().contains(q) ||
            dateFmt2.format(d.date).toLowerCase().contains(q) ||
            dateFmt3.format(d.date).toLowerCase().contains(q);
      }).toList();
    }

    list.sort((a, b) {
      final cmp = b.date.compareTo(a.date);
      if (cmp != 0) return cmp;
      return b.shift.compareTo(a.shift);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);

    if (widget.deliveries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceLg),
        child: EmptyState(
          icon: Symbols.local_shipping,
          title: l10n.noDeliveriesRecorded,
          subtitle: l10n.deliveryHistoryEmptySubtitle,
        ),
      );
    }

    final sorted = _sorted;
    final visible = sorted.take(_displayedCount).toList();
    final hasMore = _displayedCount < sorted.length;

    final grouped = <String, List<Delivery>>{};
    for (final d in visible) {
      final key = Delivery.dateKey(d.date);
      grouped.putIfAbsent(key, () => <Delivery>[]).add(d);
    }
    final dateKeys = grouped.keys.toList();
    final dateHeaderFmt = DateFormat('EEE, dd MMM yyyy');

    return ListView.builder(
      controller: _internalController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMd,
        vertical: AppSpacing.spaceMd,
      ),
      itemCount: dateKeys.length + 1 + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: AppSpacing.spaceSm,
              top: AppSpacing.spaceXs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        l10n.deliveryHistoryTitle,
                        style: typography.subhead.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutralTitle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceSm),
                    InkWell(
                      onTap: _showShareReportSheet,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.shareAction,
                              style: typography.caption.copyWith(
                                color: AppColors.brandPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Symbols.share,
                              size: 16,
                              color: AppColors.brandPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceMd),
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: l10n.searchByDateHint,
                    prefixIcon: const Icon(Symbols.search, size: 20, color: AppColors.neutralMuted),
                    filled: true,
                    fillColor: AppColors.scaffold,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spaceMd,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.neutralLine),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.neutralLine),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceMd),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'all', label: Text(l10n.filterAll)),
                    ButtonSegment(value: 'delivered', label: Text(l10n.deliveryStatusDelivered)),
                    ButtonSegment(value: 'undelivered', label: Text(l10n.filterUndelivered)),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (set) {
                    setState(() {
                      _filter = set.first;
                      _displayedCount = widget.pageSize; // Reset pagination on filter
                    });
                  },
                  style: ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.brandSoft;
                      }
                      return AppColors.card;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.brandPrimary;
                      }
                      return AppColors.neutralMuted;
                    }),
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceMd),
              ],
            ),
          );
        }

        if (hasMore && index == dateKeys.length + 1) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
            child: Center(
              child: TextButton.icon(
                onPressed: _loadMore,
                icon: const Icon(Symbols.expand_more, size: 18),
                label: Text(
                  l10n.loadMoreEntries,
                  style: typography.bodySm.copyWith(
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }

        final dayIndex = index - 1;
        final dayKey = dateKeys[dayIndex];
        final dayDeliveries = grouped[dayKey]!;
        final dayDate = DateTime.parse(dayKey);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.spaceSm,
                bottom: AppSpacing.spaceSm,
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Symbols.calendar_today,
                    size: 15,
                    color: AppColors.neutralMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateHeaderFmt.format(dayDate),
                    style: typography.labelSm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutralMuted,
                    ),
                  ),
                ],
              ),
            ),
            ...dayDeliveries.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
                child: DeliveryCard(delivery: d),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showShareReportSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShareDeliveryReportScreen(
          customerId: widget.customer.id,
          customerName: widget.customer.name,
          allDeliveries: widget.deliveries,
        ),
      ),
    );
  }
}

