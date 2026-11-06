import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/customer_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/local_sale_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/supplier_payment_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/date_selector.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_chip_bar.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/metric_card.dart';
import 'widgets/record_payment_sheet.dart';
import 'widgets/transaction_card.dart';
import 'widgets/whatsapp_reminder_card.dart';
import '../../widgets/temp_language_button.dart';

/// Payments & Accounts screen (plan.md Section 2.5 / Milestone C-M12).
///
/// Features:
/// - Header with store info, date selector, live sync badge, language toggle
/// - 2x2 KPI Bento Grid: Today's Inflow, Cash in Hand, Customer Dues, Dairy Payables
/// - Full-width "+ Record Payment In / Out" CTA button
/// - WhatsApp Reminders carousel for overdue customers with Send Reminder and Log Cash
/// - FilterChipBar: All, Collections, Payables
/// - Unified transaction feed (Customer Payments, Advance Deposits, Counter Retail, Supplier Outflows)
/// - Pull-to-refresh
class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({
    super.key,
    this.initialDate,
  });

  /// Optional initial date (defaults to DateTime.now()).
  final DateTime? initialDate;

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  late DateTime _selectedDate;
  int _selectedFilterIndex = 0; // 0: All, 1: Collections, 2: Payables
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = widget.initialDate ?? DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
    });
  }

  Future<void> _handleRefresh() async {
    ref.invalidate(todayPaymentsProvider);
    ref.invalidate(todaySupplierPaymentsProvider);
    ref.invalidate(todayLocalSalesProvider);
    ref.invalidate(customerListProvider);
    ref.invalidate(allCustomersProvider);
    ref.invalidate(supplierListProvider);
    ref.invalidate(dashboardProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);

    final paymentsAsync = ref.watch(todayPaymentsProvider(_selectedDate));
    final supplierPaymentsAsync =
        ref.watch(todaySupplierPaymentsProvider(_selectedDate));
    final localSalesAsync = ref.watch(todayLocalSalesProvider(_selectedDate));
    final customersAsync = ref.watch(customerListProvider);
    final suppliersAsync = ref.watch(supplierListProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.brandPrimary,
          child: CustomScrollView(
            slivers: <Widget>[
              // ── Header Bar ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceLg,
                    vertical: AppSpacing.spaceSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Title & Live Sync indicator
                      Row(
                        children: <Widget>[
                          Text(
                            l10n.paymentsTitle,
                            style: typography.heading.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.neutralTitle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.spaceSm),
                          _buildLiveSyncBadge(l10n),
                        ],
                      ),
                      const TempLanguageButton(),
                    ],
                  ),
                ),
              ),

              // ── Date Selector ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceLg,
                    vertical: AppSpacing.spaceXs,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    heightFactor: 1,
                    child: DateSelector(
                      selectedDate: _selectedDate,
                      onDateChanged: _onDateSelected,
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.spaceSm),
              ),

              // ── Main Content based on loaded data ──────────────────
              () {
                final hasError = customersAsync.hasError ||
                    suppliersAsync.hasError ||
                    paymentsAsync.hasError ||
                    supplierPaymentsAsync.hasError ||
                    localSalesAsync.hasError;

                if (hasError && (!customersAsync.hasValue && !suppliersAsync.hasValue)) {
                  final err = customersAsync.error ??
                      suppliersAsync.error ??
                      paymentsAsync.error ??
                      supplierPaymentsAsync.error ??
                      localSalesAsync.error;
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.spaceLg),
                      child: EmptyState(
                        icon: Symbols.error_outline,
                        title: l10n.noTransactionsFound,
                        subtitle: err.toString(),
                        actionLabel: l10n.retry,
                        onAction: _handleRefresh,
                      ),
                    ),
                  );
                }

                final isLoading = customersAsync.isLoading ||
                    suppliersAsync.isLoading ||
                    paymentsAsync.isLoading ||
                    supplierPaymentsAsync.isLoading ||
                    localSalesAsync.isLoading;

                if (isLoading &&
                    (!customersAsync.hasValue || !suppliersAsync.hasValue)) {
                  return const SliverFillRemaining(
                    child: ShimmerCard(count: 3),
                  );
                }

                return _buildLoadedContent(
                  context,
                  l10n: l10n,
                  customers: customersAsync.valueOrNull ?? [],
                  suppliers: suppliersAsync.valueOrNull ?? [],
                  payments: paymentsAsync.valueOrNull ?? [],
                  supplierPayments: supplierPaymentsAsync.valueOrNull ?? [],
                  localSales: localSalesAsync.valueOrNull ?? [],
                );
              }(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedContent(
    BuildContext context, {
    required AppLocalizations l10n,
    required List<dynamic> customers,
    required List<dynamic> suppliers,
    required List<dynamic> payments,
    required List<dynamic> supplierPayments,
    required List<dynamic> localSales,
  }) {
    final customerMap = {for (final c in customers) c.id: (c.name as String?) ?? ''};
    final supplierMap = {for (final s in suppliers) s.id: (s.name as String?) ?? ''};

    // ── Build Unified Transactions Feed ──────────────────────────────
    final List<TransactionFeedItem> allItems = [];

    // 1. Customer payments
    for (final p in payments) {
      if (p.type == 'cash_payment' || p.type == 'advance_topup') {
        allItems.add(
          TransactionFeedItem.fromPayment(
            p,
            customerName: customerMap[p.customerId],
            l10n: l10n,
          ),
        );
      }
    }

    // 2. Supplier payments
    for (final sp in supplierPayments) {
      allItems.add(
        TransactionFeedItem.fromSupplierPayment(
          sp,
          supplierName: supplierMap[sp.supplierId],
          l10n: l10n,
        ),
      );
    }

    // 3. Counter retail sales
    for (final ls in localSales) {
      allItems.add(
        TransactionFeedItem.fromLocalSale(ls, l10n: l10n),
      );
    }

    // Sort newest first
    allItems.sort((a, b) => b.date.compareTo(a.date));

    // Filter items
    List<TransactionFeedItem> filteredItems = switch (_selectedFilterIndex) {
      1 => allItems.where((item) => item.isInflow).toList(),
      2 => allItems.where((item) => !item.isInflow).toList(),
      _ => allItems,
    };

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filteredItems = filteredItems.where((item) {
        if (item.title.toLowerCase().contains(q)) return true;

        String note = '';
        if (item.type == TransactionType.customerCollection || item.type == TransactionType.advanceDeposit) {
          for (final p in payments) {
            if (p.id == item.id) {
              note = p.notes ?? '';
              break;
            }
          }
        } else if (item.type == TransactionType.supplierOutflow) {
          for (final sp in supplierPayments) {
            if (sp.id == item.id) {
              note = sp.notes ?? '';
              break;
            }
          }
        }
        return note.toLowerCase().contains(q);
      }).toList();
    }

    // Counts for filter chips
    final inflowCount = allItems.where((i) => i.isInflow).length;
    final outflowCount = allItems.where((i) => !i.isInflow).length;

    // ── Compute KPIs ─────────────────────────────────────────────────
    final totalInflow = allItems
        .where((i) => i.isInflow)
        .fold<double>(0.0, (sum, i) => sum + i.amount);

    final cashInflow = allItems
        .where((i) => i.isInflow && (i.method == 'cash' || i.type == TransactionType.counterRetail))
        .fold<double>(0.0, (sum, i) => sum + i.amount);

    final cashOutflow = allItems
        .where((i) => !i.isInflow && i.method == 'cash_payment')
        .fold<double>(0.0, (sum, i) => sum + i.amount);

    final cashInHand = (cashInflow - cashOutflow).clamp(0.0, double.infinity);

    final customerDues = customers.fold<double>(
      0.0,
      (sum, c) => sum + (((c.currentDue as num?)?.toDouble() ?? 0.0) < 0 ? 0 : ((c.currentDue as num?)?.toDouble() ?? 0.0)),
    );

    final dairyPayables = suppliers.fold<double>(
      0.0,
      (sum, s) => sum + (((s.pendingKhata as num?)?.toDouble() ?? 0.0) < 0 ? 0 : ((s.pendingKhata as num?)?.toDouble() ?? 0.0)),
    );

    // Overdue customers
    final overdueCustomers = customers
        .where((c) => ((c.currentDue as num?)?.toDouble() ?? 0.0) > 0)
        .toList()
      ..sort((a, b) => ((b.currentDue as num?)?.toDouble() ?? 0.0).compareTo((a.currentDue as num?)?.toDouble() ?? 0.0));

    return SliverList(
      delegate: SliverChildListDelegate(
        <Widget>[
          // ── KPI Bento Grid 2x2 ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: MetricCard(
                        label: l10n.todayInflowKpi,
                        value: 'Rs. ${totalInflow.toStringAsFixed(0)}',
                        icon: Symbols.trending_up,
                        iconBgColor: AppColors.successLight,
                        iconColor: AppColors.successText,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceSm),
                    Expanded(
                      child: MetricCard(
                        label: l10n.cashInHandKpi,
                        value: 'Rs. ${cashInHand.toStringAsFixed(0)}',
                        subtitle: l10n.counterVerifiedNote,
                        icon: Symbols.account_balance_wallet,
                        iconBgColor: AppColors.brandSoft,
                        iconColor: AppColors.brandPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: MetricCard(
                        label: l10n.customerDuesKpi,
                        value: 'Rs. ${customerDues.toStringAsFixed(0)}',
                        icon: Symbols.group,
                        iconBgColor: AppColors.errorLight,
                        iconColor: AppColors.errorText,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceSm),
                    Expanded(
                      child: MetricCard(
                        label: l10n.dairyPayablesKpi,
                        value: 'Rs. ${dairyPayables.toStringAsFixed(0)}',
                        icon: Symbols.inventory_2,
                        iconBgColor: const Color(0xFFFFFBEB),
                        iconColor: const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.spaceMd),

          // ── "+ Record Payment In / Out" CTA Button ─────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
            child: AppButton(
              onPressed: () => RecordPaymentSheet.show(context),
              label: l10n.recordPaymentInOutCta,
              icon: Symbols.add_circle,
              isFullWidth: true,
              variant: AppButtonVariant.primary,
            ),
          ),

          const SizedBox(height: AppSpacing.spaceLg),

          // ── WhatsApp Reminders Section ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  l10n.whatsappRemindersTitle,
                  style: AppTypography.of(context).subhead.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutralTitle,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: overdueCustomers.isNotEmpty
                        ? AppColors.errorLight
                        : AppColors.successLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${overdueCustomers.length}',
                    style: AppTypography.of(context).caption.copyWith(
                          color: overdueCustomers.isNotEmpty
                              ? AppColors.errorText
                              : AppColors.successText,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.spaceSm),

          // Horizontal Overdue Carousel
          if (overdueCustomers.isNotEmpty)
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
                itemCount: overdueCustomers.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.spaceSm),
                itemBuilder: (context, index) {
                  final customer = overdueCustomers[index];
                  return WhatsAppReminderCard(
                    customer: customer,
                    onLogCash: () => RecordPaymentSheet.show(
                      context,
                      customer: customer,
                    ),
                  );
                },
              ),
            )
          else
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.spaceMd),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.neutralLine),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Symbols.check_circle,
                      color: AppColors.successText,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.spaceSm),
                    Text(
                      l10n.noOverdueCustomers,
                      style: AppTypography.of(context).bodySm.copyWith(
                            color: AppColors.neutralMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.spaceLg),

          // ── FilterChipBar ──────────────────────────────────────────
          FilterChipBar(
            selectedIndex: _selectedFilterIndex,
            onSelected: (index) {
              setState(() {
                _selectedFilterIndex = index;
              });
            },
            chips: [
              FilterChipData(
                label: 'All',
                count: allItems.length,
              ),
              FilterChipData(
                label: l10n.filterCollections,
                count: inflowCount,
                dotColor: AppColors.successText,
              ),
              FilterChipData(
                label: l10n.filterPayables,
                count: outflowCount,
                dotColor: AppColors.errorText,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.spaceSm),

          // ── Search Bar ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
            child: AppSearchBar(
              controller: _searchController,
              hintText: l10n.searchTransactionsHint,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
            ),
          ),

          const SizedBox(height: AppSpacing.spaceSm),

          // ── Transactions Section Header ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceLg,
              vertical: AppSpacing.spaceXs,
            ),
            child: Text(
              l10n.transactionsHeader,
              style: AppTypography.of(context).subhead.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutralTitle,
                  ),
            ),
          ),

          const SizedBox(height: AppSpacing.spaceXs),

          // ── Transactions Feed List ─────────────────────────────────
          if (filteredItems.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space2xl),
              child: EmptyState(
                icon: Symbols.receipt_long,
                title: l10n.noTransactionsFound,
                subtitle: l10n.noTransactionsSubtitle,
              ),
            )
          else
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredItems.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.spaceSm),
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return TransactionCard(item: item);
                },
              ),
            ),

          const SizedBox(height: AppSpacing.space2xl),
        ],
      ),
    );
  }

  Widget _buildLiveSyncBadge(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.successText,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            l10n.liveSyncLabel,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.successText,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

}
