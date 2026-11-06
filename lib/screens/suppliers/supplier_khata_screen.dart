import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pasture_fresh_milk/core/utils/date_display.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/milk_collection.dart';
import '../../models/supplier.dart';
import '../../models/supplier_payment.dart';
import '../../providers/milk_collection_provider.dart';
import '../../providers/supplier_payment_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/status_badge.dart';
import 'milk_inward_history_screen.dart';
import 'widgets/pay_supplier_sheet.dart';
import 'widgets/record_milk_sheet.dart';
import 'widgets/supplier_form_sheet.dart';
import '../../providers/refresh_helper.dart';
import '../../widgets/app_snack_bar.dart';

/// Supplier Khata Screen (plan.md C-M15 / Section 2.6).
/// Features:
/// - Custom AppBar with back navigation, supplier name, and direct phone call
/// - Supplier summary card with pending khata balance and "Pay Cash" CTA
/// - Aggregated metrics: Total Milk Supplied (L) and Total Payments Made (Rs.)
/// - Two tabs: Collections History & Payments History
/// - Detailed collection batch cards (QTY, RATE, Batch Value)
/// - Detailed payment cards (Date, Voucher, Amount, Notes)
/// - Empty states and pull-to-refresh
class SupplierKhataScreen extends ConsumerStatefulWidget {
  const SupplierKhataScreen({
    super.key,
    required this.supplierId,
    this.onCall,
  });

  /// The supplier UUID.
  final String supplierId;

  /// Optional override for phone call launcher (for testing).
  final VoidCallback? onCall;

  @override
  ConsumerState<SupplierKhataScreen> createState() => _SupplierKhataScreenState();
}

class _SupplierKhataScreenState extends ConsumerState<SupplierKhataScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(supplierByIdProvider(widget.supplierId));
    ref.invalidate(supplierCollectionsProvider(widget.supplierId));
    ref.invalidate(supplierPaymentListProvider(widget.supplierId));
  }

  Future<void> _handleCall(String? phone) async {
    if (widget.onCall != null) {
      widget.onCall!();
      return;
    }
    if (phone == null || phone.isEmpty) return;

    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri);
      }
    } catch (_) {
      // Gracefully ignore failures in test/unsupported environments
    }
  }

  Future<void> _confirmDelete({
    required BuildContext context,
    required String title,
    required String content,
    required Future<void> Function() onConfirm,
  }) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.actionDeleteEntry),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await onConfirm();
        invalidateSupplierData(ref, widget.supplierId);
        if (context.mounted) {
          AppSnackBar.show(context, message: l10n.entryDeletedSuccess);
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackBar.show(context, message: 'Error: $e', error: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);

    final supplierAsync = ref.watch(supplierByIdProvider(widget.supplierId));
    final collectionsAsync = ref.watch(supplierCollectionsProvider(widget.supplierId));
    final paymentsAsync = ref.watch(supplierPaymentListProvider(widget.supplierId));

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back, color: AppColors.neutralTitle),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: supplierAsync.when(
          data: (supplier) => Text(
            supplier?.name ?? l10n.supplierKhataTitle,
            style: typography.heading.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutralTitle,
            ),
          ),
          loading: () => Text(
            l10n.supplierKhataTitle,
            style: typography.heading.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutralTitle,
            ),
          ),
          error: (_, __) => Text(
            l10n.supplierKhataTitle,
            style: typography.heading.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutralTitle,
            ),
          ),
        ),
        actions: <Widget>[
          supplierAsync.when(
            data: (supplier) {
              if (supplier == null) {
                return const SizedBox.shrink();
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MilkInwardHistoryScreen(
                            initialSupplierId: supplier.id,
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Symbols.history,
                      semanticLabel: l10n.milkInwardHistoryTitle,
                    ),
                    tooltip: l10n.milkInwardHistoryTitle,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                  if (supplier.phone != null && supplier.phone!.isNotEmpty)
                    IconButton(
                      key: const Key('call_supplier_button'),
                      icon: const Icon(Symbols.call, color: AppColors.brandPrimary),
                      tooltip: l10n.callSupplierAction,
                      onPressed: () => _handleCall(supplier.phone),
                    ),
                  IconButton(
                    key: const Key('edit_supplier_btn'),
                    icon: const Icon(Symbols.edit, color: AppColors.brandPrimary),
                    tooltip: l10n.editSupplierTooltip,
                    onPressed: () async {
                      final archived = await SupplierFormSheet.show(context, supplier: supplier);
                      if (archived == true && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.brandPrimary,
          child: supplierAsync.when(
            data: (supplier) {
              if (supplier == null) {
                return Center(
                  child: Text(
                    'Supplier not found',
                    style: typography.body.copyWith(color: AppColors.neutralMuted),
                  ),
                );
              }

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return <Widget>[
                    // ── Supplier Summary Header ────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.spaceLg),
                        child: Column(
                          children: <Widget>[
                            _buildSupplierSummaryCard(
                              context,
                              supplier: supplier,
                              collections: collectionsAsync.valueOrNull ?? <MilkCollection>[],
                              payments: paymentsAsync.valueOrNull ?? <SupplierPayment>[],
                              l10n: l10n,
                              typography: typography,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Pinned Tab Bar ─────────────────────────────────
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _KhataTabBarDelegate(
                        TabBar(
                          controller: _tabController,
                          labelColor: AppColors.brandPrimary,
                          unselectedLabelColor: AppColors.neutralMuted,
                          indicatorColor: AppColors.brandPrimary,
                          indicatorWeight: 3,
                          labelStyle: typography.bodySm.copyWith(fontWeight: FontWeight.w700),
                          unselectedLabelStyle: typography.bodySm.copyWith(fontWeight: FontWeight.w500),
                          tabs: <Widget>[
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(l10n.collectionHistoryTab),
                                  const SizedBox(width: 6),
                                  _CountBadge(
                                    count: collectionsAsync.valueOrNull?.length ?? 0,
                                    isActive: _tabController.index == 0,
                                  ),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(l10n.paymentsMadeTab),
                                  const SizedBox(width: 6),
                                  _CountBadge(
                                    count: paymentsAsync.valueOrNull?.length ?? 0,
                                    isActive: _tabController.index == 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    // Tab 1: Collections
                    collectionsAsync.when(
                      data: (collections) => _buildCollectionsList(
                        context,
                        supplier: supplier,
                        collections: collections,
                        l10n: l10n,
                        typography: typography,
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(AppSpacing.spaceLg),
                        child: ShimmerCard(count: 3),
                      ),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),

                    // Tab 2: Payments
                    paymentsAsync.when(
                      data: (payments) => _buildPaymentsList(
                        context,
                        supplier: supplier,
                        payments: payments,
                        l10n: l10n,
                        typography: typography,
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(AppSpacing.spaceLg),
                        child: ShimmerCard(count: 3),
                      ),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.spaceLg),
              child: ShimmerCard(count: 4),
            ),
            error: (e, _) => Center(child: Text('Error loading supplier: $e')),
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierSummaryCard(
    BuildContext context, {
    required Supplier supplier,
    required List<MilkCollection> collections,
    required List<SupplierPayment> payments,
    required AppLocalizations l10n,
    required AppTypography typography,
  }) {
    final isPending = supplier.pendingKhata > 0.009;
    final isAdvance = supplier.pendingKhata < -0.009;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Supplier profile row
          Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.brandSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Symbols.agriculture,
                  size: 26,
                  color: AppColors.brandPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      supplier.name,
                      style: typography.heading.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutralTitle,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: <Widget>[
                        if (supplier.location != null && supplier.location!.isNotEmpty) ...<Widget>[
                          const Icon(
                            Symbols.location_on,
                            size: 14,
                            color: AppColors.neutralMuted,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            supplier.location!,
                            style: typography.caption.copyWith(color: AppColors.neutralMuted),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (supplier.milkType != null)
                          StatusBadge(
                            label: supplier.milkType!,
                            backgroundColor: AppColors.scaffold,
                            textColor: AppColors.neutralTitle,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceLg),

          // Pending Khata Banner Block
          Container(
            padding: const EdgeInsets.all(AppSpacing.spaceMd),
            decoration: BoxDecoration(
              color: isPending ? AppColors.warningLight : AppColors.successLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isPending
                    ? AppColors.warningMain.withValues(alpha: 0.3)
                    : AppColors.successMain.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isPending ? l10n.pendingKhataLabel.toUpperCase() : (isAdvance ? l10n.advanceLabel.toUpperCase() : l10n.allClearedKhataLabel.toUpperCase()),
                      style: typography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isPending ? AppColors.warningText : AppColors.successText,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rs. ${supplier.pendingKhata.abs().toStringAsFixed(0)}',
                      style: typography.heading.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: isPending ? AppColors.errorText : AppColors.successText,
                      ),
                    ),
                    if (isPending) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              l10n.unpaidMilkLabel,
                              style: typography.caption.copyWith(
                                color: isPending ? AppColors.warningText : AppColors.successText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_unpaidLitres(collections, supplier.pendingKhata).toStringAsFixed(1)} L',
                            style: typography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isPending ? AppColors.warningText : AppColors.successText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                if (isPending)
                  AppButton(
                    key: const Key('pay_cash_cta'),
                    label: l10n.payCashAction,
                    icon: Symbols.payments,
                    variant: AppButtonVariant.primary,
                    onPressed: () => PaySupplierSheet.show(
                      context,
                      supplier: supplier,
                      onSuccess: _refresh,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.successText,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Symbols.check, color: Colors.white, size: 20),
                  ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildCollectionsList(
    BuildContext context, {
    required Supplier supplier,
    required List<MilkCollection> collections,
    required AppLocalizations l10n,
    required AppTypography typography,
  }) {
    if (collections.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceXl),
        child: EmptyState(
          icon: Symbols.science,
          title: l10n.noCollectionsRecorded,
          subtitle: l10n.noCollectionsSubtitle,
        ),
      );
    }



    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.spaceLg),
      itemCount: collections.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.spaceSm),
      itemBuilder: (context, index) {
        final collection = collections[index];
        final isMorning = collection.shift == 'morning';

        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Top line: title/date + shift + actions
              Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Symbols.calendar_today,
                          size: 14,
                          color: AppColors.neutralMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            formatShortDate(collection.date),
                            style: typography.bodySm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.neutralTitle,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        StatusBadge(
                          label: isMorning ? l10n.shiftMorning : l10n.shiftEvening,
                          backgroundColor: isMorning ? AppColors.warningLight : AppColors.brandSoft,
                          textColor: isMorning ? AppColors.warningText : AppColors.brandPrimary,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Symbols.edit, size: 18, color: AppColors.neutralMuted),
                        tooltip: l10n.actionEditEntry,
                        onPressed: () => RecordMilkSheet.show(context, initialSupplier: supplier, existing: collection),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Symbols.delete, size: 18, color: AppColors.errorText),
                        tooltip: l10n.actionDeleteEntry,
                        onPressed: () => _confirmDelete(
                          context: context,
                          title: l10n.deleteConfirmTitle,
                          content: l10n.deleteConfirmMessage,
                          onConfirm: () async {
                            try {
                              await ref.read(milkCollectionRepositoryProvider).deleteCollection(collection.id);
                              invalidateSupplierData(ref, supplier.id);
                              if (context.mounted) {
                                AppSnackBar.show(context, message: l10n.entryDeletedSuccess);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                AppSnackBar.show(context, message: 'Error deleting entry', error: true);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceSm),

              // Second line: subtitle metrics grid (Expanded) + amount text
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        if (collection.notes != null && collection.notes!.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 4),
                          Text(
                            collection.notes!,
                            style: typography.caption.copyWith(
                              color: AppColors.neutralMuted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceMd),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentsList(
    BuildContext context, {
    required Supplier supplier,
    required List<SupplierPayment> payments,
    required AppLocalizations l10n,
    required AppTypography typography,
  }) {
    if (payments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceXl),
        child: EmptyState(
          icon: Symbols.payments,
          title: l10n.noSupplierPaymentsRecorded,
          subtitle: l10n.noSupplierPaymentsSubtitle,
        ),
      );
    }

    final timeFormat = DateFormat('hh:mm a');

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.spaceLg),
      itemCount: payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.spaceSm),
      itemBuilder: (context, index) {
        final payment = payments[index];

        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.spaceMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Symbols.payments,
                  size: 22,
                  color: AppColors.successText,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Top line
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${formatShortDate(payment.date)}, ${timeFormat.format(payment.date)}',
                            style: typography.caption.copyWith(color: AppColors.neutralMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Symbols.edit, size: 18, color: AppColors.neutralMuted),
                          tooltip: l10n.actionEditEntry,
                          onPressed: () => PaySupplierSheet.show(context, supplier: supplier, existing: payment),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Symbols.delete, size: 18, color: AppColors.errorText),
                          tooltip: l10n.actionDeleteEntry,
                          onPressed: () => _confirmDelete(
                            context: context,
                            title: l10n.deleteConfirmTitle,
                            content: l10n.deleteConfirmMessage,
                            onConfirm: () async {
                              try {
                                await ref.read(supplierPaymentRepositoryProvider).deletePayment(payment.id);
                                invalidateSupplierData(ref, supplier.id);
                                if (context.mounted) {
                                  AppSnackBar.show(context, message: l10n.entryDeletedSuccess);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  AppSnackBar.show(context, message: 'Error deleting entry', error: true);
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    // Second line
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (payment.voucherNumber != null && payment.voucherNumber!.isNotEmpty)
                                Text(
                                  'Voucher: ${payment.voucherNumber}',
                                  style: typography.caption.copyWith(
                                    color: AppColors.neutralTitle,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  payment.notes!,
                                  style: typography.caption.copyWith(
                                    color: AppColors.neutralMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              StatusBadge.cleared(
                                label: l10n.paymentMethodCash,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '- Rs. ${payment.amount.toStringAsFixed(0)}',
                          style: typography.subhead.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.successText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricColumn({
    required String label,
    required String value,
    required AppTypography typography,
  }) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: typography.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.neutralMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: typography.bodySm.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutralTitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.count,
    required this.isActive,
  });

  final int count;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? AppColors.brandPrimary : AppColors.neutralLine,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: isActive ? Colors.white : AppColors.neutralMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _KhataTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _KhataTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.card,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_KhataTabBarDelegate oldDelegate) {
    return false;
  }
}

double _unpaidLitres(List<MilkCollection> collections, double pending) {
  final sorted = [...collections]
    ..sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
    });
  var remaining = pending;
  var litres = 0.0;
  for (final c in sorted) {
    if (remaining <= 0.009) break;
    final value = c.batchValue;
    if (value <= 0) continue;
    if (value <= remaining) {
      litres += c.quantity;
      remaining -= value;
    } else {
      litres += c.quantity * (remaining / value);
      remaining = 0;
    }
  }
  return litres;
}

