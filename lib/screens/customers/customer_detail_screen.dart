import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/customer.dart';
import '../../models/delivery.dart';
import '../../models/payment.dart';
import '../../models/product.dart';
import '../../core/utils/unit_formatter.dart';

import '../../providers/customer_provider.dart';
import '../../providers/delivery_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/status_badge.dart';
import 'widgets/add_customer_sheet.dart';
import 'widgets/delivery_history_tab.dart';

import 'widgets/payment_history_tab.dart';
import 'widgets/record_payment_sheet.dart';
import '../../core/routes/app_routes.dart';

/// Customer Detail & Ledger Profile Screen (plan.md C-M6 / Section 2.3).
///
/// Features:
/// - Top bar with Back button, customer name, Direct Call, and Edit Profile
/// - Customer profile card with initials avatar, status badge, and contact info
/// - Delivery preferences card (AM/PM quotas, rate per litre, preferred shift)
/// - Financial summary grid: Current Due (Payable Balance) & Advance (Prepaid Reserve)
/// - Action buttons: Record Payment, Add Topup, Share Bill
/// - 3-tab navigation: Advance Ledger, Delivery History, Payment History
/// - Sticky bottom bar when customer has outstanding dues
class CustomerDetailScreen extends ConsumerStatefulWidget {
  /// Creates a [CustomerDetailScreen].
  const CustomerDetailScreen({
    super.key,
    required this.customerId,
    this.onCall,
    this.onEditProfile,
  });

  /// The customer UUID.
  final String customerId;

  /// Optional override for the phone call action (for testing).
  final VoidCallback? onCall;

  /// Optional override for the edit profile action (for testing).
  final VoidCallback? onEditProfile;

  @override
  ConsumerState<CustomerDetailScreen> createState() =>
      _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleCall(String phone) async {
    if (widget.onCall != null) {
      widget.onCall!();
      return;
    }
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      final launched = await launchUrl(uri);
      if (!launched && mounted) {
        AppSnackBar.show(
          context,
          message: 'Could not open dialer for $cleanPhone',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: 'Error: Cannot launch dialer');
      }
    }
  }

  Future<void> _handleSms(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('sms:$cleanPhone');
    try {
      final launched = await launchUrl(uri);
      if (!launched && mounted) {
        AppSnackBar.show(
          context,
          message: 'Could not open messages for $cleanPhone',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: 'Error: Cannot launch messages');
      }
    }
  }

  Future<void> _handleWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        AppSnackBar.show(
          context,
          message: 'Could not open WhatsApp for $cleanPhone',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: 'Error: Cannot launch WhatsApp');
      }
    }
  }

  Future<void> _handleEdit(Customer customer) async {
    if (widget.onEditProfile != null) {
      widget.onEditProfile!();
      return;
    }
    await AddCustomerSheet.show(context, customerToEdit: customer);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);

    final customerAsync = ref.watch(customerByIdProvider(widget.customerId));
    final productsAsync = ref.watch(productListProvider);
    final deliveriesAsync = ref.watch(
      customerDeliveryHistoryProvider(widget.customerId),
    );
    final paymentsAsync = ref.watch(
      paymentListByCustomerProvider(widget.customerId),
    );

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          key: const Key('detail_back_button'),
          icon: const Icon(Symbols.arrow_back, color: AppColors.neutralTitle),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: customerAsync.when(
          data: (customer) => Text(
            customer?.name ?? l10n.customerDetailTitle,
            style: typography.subhead.copyWith(
              color: AppColors.neutralTitle,
              fontWeight: FontWeight.w700,
            ),
          ),
          loading: () => Text(
            l10n.customerDetailTitle,
            style: typography.subhead.copyWith(color: AppColors.neutralTitle),
          ),
          error: (_, __) => Text(
            l10n.customerDetailTitle,
            style: typography.subhead.copyWith(color: AppColors.neutralTitle),
          ),
        ),
        actions: <Widget>[
          if (customerAsync.hasValue && customerAsync.value != null) ...[
            IconButton(
              key: const Key('detail_call_button'),
              icon: const Icon(Symbols.call, color: AppColors.successMain),
              tooltip: l10n.callAction,
              onPressed: () => _handleCall(customerAsync.value!.phone),
            ),
            IconButton(
              key: const Key('detail_edit_button'),
              icon: const Icon(Symbols.edit, color: AppColors.brandPrimary),
              tooltip: l10n.editProfileAction,
              onPressed: () => _handleEdit(customerAsync.value!),
            ),
            const SizedBox(width: AppSpacing.spaceXs),
          ],
        ],
      ),
      body: customerAsync.when(
        data: (customer) {
          if (customer == null) {
            return Center(
              child: Text(
                l10n.customerNotFound,
                style: typography.body.copyWith(color: AppColors.neutralMuted),
              ),
            );
          }
          final products = productsAsync.asData?.value ?? <Product>[];
          final allDeliveries = deliveriesAsync.asData?.value ?? <Delivery>[];
          final payments = paymentsAsync.asData?.value ?? <Payment>[];
          final product = customer.productId != null
              ? products.cast<Product?>().firstWhere(
                  (p) => p?.id == customer.productId,
                  orElse: () => null,
                )
              : null;

          return Column(
            children: [
              Container(
                color: AppColors.card,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.brandPrimary,
                  unselectedLabelColor: AppColors.neutralMuted,
                  indicatorColor: AppColors.brandPrimary,
                  indicatorWeight: 3,
                  labelStyle: typography.labelLg,
                  unselectedLabelStyle: typography.bodySm,
                  tabs: [
                    Tab(
                      key: const Key('tab_summary'),
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Center(child: Text(l10n.tabSummary)),
                          Positioned(
                            right: -16, // Adjust based on tab spacing
                            child: Container(
                              width: 2,
                              height: 24,
                              color: AppColors.neutralLine,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      key: const Key('tab_delivery_history'),
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Center(child: Text(l10n.tabDeliveryHistory)),
                          Positioned(
                            right: -16,
                            child: Container(
                              width: 2,
                              height: 24,
                              color: AppColors.neutralLine,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      key: const Key('tab_payment_history'),
                      text: l10n.tabPaymentHistory,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    // Tab 1: Summary
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.spaceMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // Profile Header Card
                          _buildProfileCard(
                            customer,
                            product,
                            l10n,
                            typography,
                          ),
                          const SizedBox(height: AppSpacing.spaceSm),
                          // Financial Summary & Actions Card
                          _buildFinancialCard(customer, l10n, typography),
                          const SizedBox(height: AppSpacing.spaceSm),
                          // Contact Actions
                          _buildContactActionsCard(customer, typography),
                        ],
                      ),
                    ),
                    // Tab 2: Delivery History (C-M8)
                    DeliveryHistoryTab(
                      deliveries: allDeliveries,
                      customer: customer,
                    ),
                    // Tab 3: Payment History (C-M9)
                    PaymentHistoryTab(payments: payments, customer: customer),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.spaceMd),
          child: ShimmerCard(count: 3, height: 120),
        ),
        error: (err, _) => Center(
          child: Text(
            l10n.loadFailed,
            style: typography.body.copyWith(color: AppColors.errorText),
          ),
        ),
      ),
      bottomNavigationBar:
          customerAsync.hasValue &&
              customerAsync.value != null &&
              customerAsync.value!.currentDue > 0
          ? _buildStickyDuesBottomBar(customerAsync.value!, l10n, typography)
          : null,
    );
  }

  Widget _buildProfileCard(
    Customer customer,
    Product? product,
    AppLocalizations l10n,
    AppTypography typography,
  ) {
    final displayRate = customer.agreedRate > 0
        ? customer.agreedRate
        : (product?.defaultRate ?? 0.0);

    return AppCard(
      elevation: 1,
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Name and Phone (Start side)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      customer.name,
                      style: typography.subhead.copyWith(
                        color: AppColors.neutralTitle,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Symbols.phone,
                          size: 16,
                          color: AppColors.neutralMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          customer.phone,
                          style: typography.bodySm.copyWith(
                            color: AppColors.neutralBody,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              // Status Badge (End side: Right in English, Left in Urdu)
              _buildStatusBadge(customer.status, l10n),
            ],
          ),
          if (customer.address != null && customer.address!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.spaceSm),
            const Divider(height: 1, color: AppColors.neutralLineFaint),
            const SizedBox(height: AppSpacing.spaceSm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  Symbols.location_on,
                  size: 16,
                  color: AppColors.neutralMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    customer.address!,
                    style: typography.bodySm.copyWith(
                      color: AppColors.neutralBody,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.spaceSm),
          const Divider(height: 1, color: AppColors.neutralLineFaint),
          const SizedBox(height: AppSpacing.spaceSm),
          Text(
            l10n.deliveryPreferencesTitle,
            style: typography.subhead.copyWith(
              color: AppColors.neutralTitle,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.scaffold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Type
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Symbols.inventory_2,
                          size: 16,
                          color: AppColors.brandPrimaryDark,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          product?.displayName(l10n.localeName) ?? l10n.product,
                          style: typography.bodySm.copyWith(
                            color: AppColors.neutralBody,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    // Rate (Using Global Product Price if available)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Symbols.sell,
                          size: 16,
                          color: AppColors.successMain,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Rs. ${displayRate.toStringAsFixed(0)}/${product?.unit.displayUnit(l10n.localeName) ?? 'L'}',
                          style: typography.bodySm.copyWith(
                            color: AppColors.neutralBody,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.spaceSm),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.scaffold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Symbols.wb_sunny,
                            size: 16,
                            color: AppColors.warningMain,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'AM: ${customer.dailyQuotaAm} L',
                            style: typography.bodySm.copyWith(
                              color: AppColors.neutralBody,
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceMd),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.scaffold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Symbols.nights_stay,
                            size: 16,
                            color: AppColors.brandPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'PM: ${customer.dailyQuotaPm} L',
                            style: typography.bodySm.copyWith(
                              color: AppColors.neutralBody,
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(
    Customer customer,
    AppLocalizations l10n,
    AppTypography typography,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Payable Balance
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.payableBalanceLabel,
                      style: typography.caption.copyWith(
                        color: AppColors.neutralMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs. ${(customer.currentDue < 0 ? 0 : customer.currentDue).toStringAsFixed(0)}',
                      key: const Key('detail_due_amount'),
                      style: typography.headlineLg.copyWith(
                        color: AppColors.errorText,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Container(
                width: 1,
                height: 40,
                color: AppColors.neutralLine,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceSm,
                ),
              ),
              // Advance Balance
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      l10n.prepaidReserveLabel,
                      style: typography.caption.copyWith(
                        color: AppColors.neutralMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs. ${(customer.advanceBalance < 0 ? 0 : customer.advanceBalance).toStringAsFixed(0)}',
                      key: const Key('detail_advance_amount'),
                      style: typography.headlineLg.copyWith(
                        color: AppColors.successText,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          Row(
            children: <Widget>[
              Expanded(
                child: AppButton(
                  key: const Key('add_payment_action_btn'),
                  label: l10n.recordPaymentCta, // Or 'Add Payment'
                  icon: Symbols.payments,
                  variant: AppButtonVariant.primary,
                  onPressed: () {
                    RecordPaymentSheet.show(context, customer: customer);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.spaceXs),
              Expanded(
                child: AppButton(
                  key: const Key('share_bill_action_btn'),
                  label: l10n.shareDetailsAction,
                  icon: Symbols.share,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => _handleShareBill(customer, l10n),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactActionsCard(Customer customer, AppTypography typography) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.space3xl,
        bottom: AppSpacing.spaceMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildContactIcon(
            icon: Symbols.call,
            label: 'Call',
            onPressed: () => _handleCall(customer.phone),
            typography: typography,
          ),
          _buildContactIcon(
            icon: Symbols.sms,
            label: 'Message',
            onPressed: () => _handleSms(customer.phone),
            typography: typography,
          ),
          _buildContactIcon(
            icon: Symbols.chat,
            label: 'WhatsApp',
            onPressed: () => _handleWhatsApp(customer.phone),
            typography: typography,
          ),
        ],
      ),
    );
  }

  Widget _buildContactIcon({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required AppTypography typography,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.neutralTitle, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: typography.caption.copyWith(
                  color: AppColors.neutralTitle,
                  fontWeight: FontWeight.w400,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleShareBill(
    Customer customer,
    AppLocalizations l10n,
  ) async {
    Navigator.of(context).pushNamed(AppRoutes.billPreviewPath(customer.id));
  }

  Widget _buildStatusBadge(String status, AppLocalizations l10n) {
    switch (status) {
      case 'active':
        return StatusBadge.active(label: l10n.statusActive);
      case 'paused':
        return StatusBadge.paused(label: l10n.statusInactive);
      default:
        return StatusBadge.paused(label: l10n.statusInactive);
    }
  }

  Widget _buildStickyDuesBottomBar(
    Customer customer,
    AppLocalizations l10n,
    AppTypography typography,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMd,
        vertical: AppSpacing.spaceXs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        boxShadow: AppShadows.shadowMedium,
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: SizedBox(
            width: 220,
            child: AppButton(
              key: const Key('collect_payment_bottom_btn'),
              label: l10n.collectPaymentBottomBar,
              icon: Symbols.payments,
              isFullWidth: true,
            height: 40,
            textStyle: typography.labelMd,
            variant: AppButtonVariant.primary,
            onPressed: () {
              RecordPaymentSheet.show(context, customer: customer);
            },
          ),
        ),
      ),
      ),
    );
  }
}
