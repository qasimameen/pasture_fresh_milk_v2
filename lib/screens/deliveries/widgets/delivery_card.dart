import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/customer.dart';
import '../../../models/delivery.dart';
import '../../../models/product.dart';
import '../../../providers/customer_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/delivery_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/refresh_helper.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_snack_bar.dart';
import '../../../widgets/delivery_note_text.dart';
import '../../../widgets/quantity_stepper.dart';
import '../../../widgets/status_badge.dart';
import '../../../core/utils/unit_formatter.dart';

/// Interactive delivery card with four visual/interaction states (plan.md C-M11).
///
/// * **Pending** — [QuantityStepper], payment method chips,
///   "Deliver" primary button, "Skip" text button.
/// * **Delivered** — dimmed, strikethrough name, green badge, Undo chip.
/// * **Skipped** — rose-tinted, skip reason, Undo chip.
class DeliveryCard extends ConsumerStatefulWidget {
  const DeliveryCard({
    super.key,
    required this.delivery,
    required this.selectedDate,
    required this.shiftString,
    this.onTap,
  });

  final Delivery delivery;
  final DateTime selectedDate;
  final String shiftString;
  final VoidCallback? onTap;

  @override
  ConsumerState<DeliveryCard> createState() => _DeliveryCardState();
}

class _DeliveryCardState extends ConsumerState<DeliveryCard> {
  late double _qty;
  bool _isBusy = false;
  String? _receiverNote;

  @override
  void initState() {
    super.initState();
    _qty = widget.delivery.scheduledQuantity;
  }

  @override
  void didUpdateWidget(DeliveryCard old) {
    super.didUpdateWidget(old);
    if (old.delivery.id != widget.delivery.id ||
        old.delivery.status != widget.delivery.status) {
      _qty = widget.delivery.scheduledQuantity;
    }
  }

  void _invalidate() {
    ref.invalidate(deliveryListProvider);
    ref.invalidate(deliveryStatsProvider);
    ref.invalidate(customerByIdProvider(widget.delivery.customerId));
    ref.invalidate(allCustomersProvider);
    ref.invalidate(customerListProvider);
    ref.invalidate(customerStatsProvider);
    ref.invalidate(todayCashTotalProvider);
    ref.invalidate(todayPaymentsProvider);
    ref.invalidate(dashboardProvider);
    invalidateAllGlobalData(ref);
  }

  Future<void> _handleDeliver(AppLocalizations l10n) async {
    if (_isBusy) return;
    final amount = _qty * widget.delivery.rate;
    final confirmed = await _showDeliverDialog(l10n, _qty, amount);
    if (!confirmed || !mounted) return;

    setState(() => _isBusy = true);
    try {
      await ref
          .read(deliveryRepositoryProvider)
          .markDelivered(
            widget.delivery.id,
            _qty,
            'auto',
            0.0,
            receiverNote: _receiverNote,
          );
      _invalidate();
      if (mounted) AppSnackBar.show(context, message: l10n.deliveredSuccess);
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: e.toString(), error: true);
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _handleSkip(AppLocalizations l10n) async {
    if (_isBusy) return;
    final reason = await _showSkipDialog(l10n);
    if (reason == null || !mounted) return;

    setState(() => _isBusy = true);
    try {
      await ref
          .read(deliveryRepositoryProvider)
          .markSkipped(widget.delivery.id, reason);
      _invalidate();
      if (mounted) AppSnackBar.show(context, message: l10n.skippedSuccess);
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: e.toString(), error: true);
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _handleUndo(AppLocalizations l10n) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      final repo = ref.read(deliveryRepositoryProvider);
      if (widget.delivery.isDelivered) {
        await repo.undoDeliver(widget.delivery.id);
      } else {
        await repo.undoSkip(widget.delivery.id);
      }
      _invalidate();
      if (mounted) {
        AppSnackBar.show(context, message: l10n.deliveryResetSuccess);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: e.toString(), error: true);
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _handleDeleteExtra(AppLocalizations l10n) async {
    if (_isBusy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Extra Sale?'),
        content: const Text(
          'This will remove the charge from the customer and strike out this record.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelAction),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.errorMain),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isBusy = true);
    try {
      final repo = ref.read(deliveryRepositoryProvider);
      if (widget.delivery.isDelivered) {
        await repo.undoDeliver(widget.delivery.id);
      }
      await repo.markSkipped(widget.delivery.id, 'deleted');
      _invalidate();
      if (mounted) {
        AppSnackBar.show(context, message: 'Extra sale deleted');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: e.toString(), error: true);
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<bool> _showDeliverDialog(
    AppLocalizations l10n,
    double qty,
    double amount,
  ) async {
    String noteText = _receiverNote ?? '';
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Material(
          type: MaterialType.transparency,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceLg,
                ),
                padding: const EdgeInsets.all(AppSpacing.spaceXl),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.confirmDeliverTitle,
                      style: AppTypography.of(ctx).subhead.copyWith(
                        color: AppColors.neutralTitle,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceSm),
                    Text(
                      l10n.confirmDeliverBody(
                        qty.toStringAsFixed(1),
                        amount.toStringAsFixed(0),
                      ),
                      style: AppTypography.of(
                        ctx,
                      ).body.copyWith(color: AppColors.neutralBody),
                    ),
                    const SizedBox(height: AppSpacing.spaceLg),
                    TextFormField(
                      initialValue: noteText,
                      onChanged: (v) => noteText = v,
                      maxLines: 3,
                      minLines: 1,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: l10n.addNoteHint,
                        labelText: l10n.receiverNamePrefix
                            .replaceAll(':', '')
                            .trim(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceXl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text(
                            l10n.cancelAction,
                            style: AppTypography.of(
                              ctx,
                            ).labelLg.copyWith(color: AppColors.neutralMuted),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.spaceSm),
                        AppButton(
                          label: l10n.confirmAction,
                          height: 40,
                          onPressed: () {
                            final trimmed = noteText.trim();
                            if (mounted) {
                              setState(() {
                                _receiverNote = trimmed.isEmpty
                                    ? null
                                    : trimmed;
                              });
                            }
                            Navigator.of(ctx).pop(true);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return confirmed ?? false;
  }

  Future<String?> _showSkipDialog(AppLocalizations l10n) async {
    final controller = TextEditingController();
    String? error;
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceLg,
              ),
              padding: const EdgeInsets.all(AppSpacing.spaceXl),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.skipDeliveryTitle,
                    style: AppTypography.of(ctx).subhead.copyWith(
                      color: AppColors.neutralTitle,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spaceMd),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: l10n.skipReasonHint,
                      errorText: error,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) {
                      if (error != null) setModalState(() => error = null);
                    },
                  ),
                  const SizedBox(height: AppSpacing.spaceXl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(null),
                        child: Text(
                          l10n.cancelAction,
                          style: AppTypography.of(
                            ctx,
                          ).labelLg.copyWith(color: AppColors.neutralMuted),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spaceSm),
                      AppButton(
                        label: l10n.skipAction,
                        variant: AppButtonVariant.destructive,
                        height: 40,
                        onPressed: () {
                          final reason = controller.text.trim();
                          if (reason.isEmpty) {
                            setModalState(
                              () => error = l10n.errorSkipReasonRequired,
                            );
                            return;
                          }
                          Navigator.of(ctx).pop(reason);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  String _buildAddress(Customer customer) {
    final parts = <String>[];
    if (customer.address != null && customer.address!.trim().isNotEmpty) {
      parts.add(customer.address!.trim());
    }
    if (customer.area != null && customer.area!.trim().isNotEmpty) {
      parts.add(customer.area!.trim());
    }
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);
    final d = widget.delivery;
    final customerAsync = ref.watch(
      customerByIdProvider(widget.delivery.customerId),
    );
    final customer = customerAsync.valueOrNull;

    final productAsync = widget.delivery.productId != null
        ? ref.watch(productByIdProvider(widget.delivery.productId!))
        : null;
    final product = productAsync?.valueOrNull;
    final unitString = (product?.unit ?? 'Litre').localizeUnit(l10n.localeName);

    return AppCard(
      elevation: 1,
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                      if (customer != null) ...<Widget>[
                        Text(
                          customer.name,
                          style: typography.subhead.copyWith(
                            color: (d.isDelivered || d.isDeleted)
                                ? AppColors.neutralMuted
                                : AppColors.neutralTitle,
                            fontWeight: FontWeight.w600,
                            decoration: (d.isDelivered || d.isDeleted)
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_buildAddress(customer).isNotEmpty) ...<Widget>[
                          const SizedBox(height: 2),
                          Row(
                            children: <Widget>[
                              const Icon(
                                Symbols.location_on,
                                size: 13,
                                color: AppColors.neutralMuted,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  _buildAddress(customer),
                                  style: typography.caption.copyWith(
                                    color: AppColors.neutralMuted,
                                    decoration: d.isDeleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceSm),
                _buildBadge(d, l10n),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.spaceXs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(
                        d.productName.localized(l10n.localeName),
                        style: typography.bodySm.copyWith(
                          color: (d.isDelivered || d.isDeleted)
                              ? AppColors.neutralMuted
                              : AppColors.neutralTitle,
                          fontWeight: FontWeight.w600,
                          decoration: (d.isDelivered || d.isDeleted)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${d.scheduledQuantity.toStringAsFixed(1)} $unitString • Rs. ${d.rate.toStringAsFixed(0)}',
                        style: typography.caption.copyWith(
                          color: AppColors.neutralMuted,
                          decoration: d.isDeleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                if (d.isPending) ...<Widget>[
                  const SizedBox(width: AppSpacing.spaceSm),
                  QuantityStepper(
                    key: Key('stepper_${d.id}'),
                    value: _qty,
                    min: 0.5,
                    max: 20.0,
                    step: 0.5,
                    onChanged: (v) => setState(() => _qty = v),
                  ),
                ],
              ],
            ),

          if (d.isDelivered) ...<Widget>[
            const SizedBox(height: AppSpacing.spaceSm),
            const Divider(color: AppColors.neutralLineFaint, height: 1),
            const SizedBox(height: AppSpacing.spaceSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  l10n.deliveryFooterDelivered(
                    d.deliveredQuantity.toStringAsFixed(1),
                    unitString,
                    d.totalAmount.toStringAsFixed(0),
                  ),
                  style: typography.caption.copyWith(
                    color: AppColors.successText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    if (d.shift == 'extra') ...[
                      IconButton(
                        icon: const Icon(
                          Symbols.delete,
                          size: 20,
                          color: AppColors.errorMain,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: _isBusy
                            ? null
                            : () => _handleDeleteExtra(l10n),
                      ),
                      const SizedBox(width: AppSpacing.spaceSm),
                    ],
                    _UndoChip(
                      onTap: _isBusy ? null : () => _handleUndo(l10n),
                      l10n: l10n,
                    ),
                  ],
                ),
              ],
            ),
            if (d.receiverNote != null &&
                d.receiverNote!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.spaceXs),
              DeliveryNoteText(note: d.receiverNote),
            ],
          ],

          if (d.isDeleted) ...<Widget>[
            const SizedBox(height: AppSpacing.spaceSm),
            const Divider(color: AppColors.neutralLineFaint, height: 1),
            const SizedBox(height: AppSpacing.spaceSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Deleted',
                  style: typography.caption.copyWith(
                    color: AppColors.errorText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          if (d.isSkipped) ...<Widget>[
            const SizedBox(height: AppSpacing.spaceSm),
            const Divider(color: AppColors.neutralLineFaint, height: 1),
            const SizedBox(height: AppSpacing.spaceSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    d.skipReason != null
                        ? 'Skipped: ${d.skipReason}'
                        : 'Skipped',
                    style: typography.caption.copyWith(
                      color: AppColors.errorText,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _UndoChip(
                  onTap: _isBusy ? null : () => _handleUndo(l10n),
                  l10n: l10n,
                ),
              ],
            ),
          ],

          if (d.isPending) ...<Widget>[
            const SizedBox(height: AppSpacing.spaceSm),
            Row(
              children: <Widget>[
                Expanded(
                  child: AppButton(
                    key: Key('deliver_btn_${d.id}'),
                    label: l10n.deliverAction,
                    icon: Symbols.check_circle,
                    isLoading: _isBusy,
                    onPressed: _isBusy ? null : () => _handleDeliver(l10n),
                    height: 40,
                  ),
                ),

                TextButton(
                  key: Key('skip_btn_${d.id}'),
                  onPressed: _isBusy ? null : () => _handleSkip(l10n),
                  child: Text(
                    l10n.skipAction,
                    style: typography.labelLg.copyWith(
                      color: AppColors.errorMain,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  StatusBadge _buildBadge(Delivery d, AppLocalizations l10n) {
    if (d.isDelivered) {
      return StatusBadge.delivered(label: l10n.deliveryStatusDelivered);
    }
    if (d.isDeleted) {
      return const StatusBadge.skipped(label: 'Deleted');
    }
    if (d.isSkipped) {
      return StatusBadge.skipped(label: l10n.deliveryStatusSkipped);
    }
    return StatusBadge.pending(label: l10n.deliveryStatusPending);
  }
}

class _UndoChip extends StatelessWidget {
  const _UndoChip({required this.onTap, required this.l10n});
  final VoidCallback? onTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.neutralLineFaint,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          l10n.undoAction,
          style: AppTypography.of(context).caption.copyWith(
            color: AppColors.neutralMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
