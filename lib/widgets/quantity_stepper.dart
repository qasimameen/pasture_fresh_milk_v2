import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// Quantity adjustment stepper (- / value / +) (plan.md B-M7; Section 6
/// "QuantityStepper").
///
/// Renders a `#F8F9FA` ([AppColors.scaffold]) pill bar with a 16px radius
/// (`radiusXl`, Section 1.4 — no radius token file, same convention as
/// [AppCard]-style widgets) holding, in order:
///
///   1. a 32x32 decrement button — white ([AppColors.card]) bg,
///      [AppShadows.shadowSoft], 12px radius, 18px `remove` icon;
///   2. the value label — 13px/w500 `#0F172A` ([AppColors.neutralTitle])
///      with tabular figures (Section 1.2 numeric formatting rule; the
///      `bodySm` token), 40px fixed width, centered text;
///   3. a 32x32 increment button — identical to the decrement button with
///      an 18px `add` icon.
///
/// Behavior (plan.md B-M7):
/// * Tapping a button steps the value by [step] (default 0.5), clamped to
///   [min] / [max] — the reported value never overshoots either bound.
/// * [HapticFeedback.selectionClick] fires on every step that actually
///   changes the value.
/// * Long-press-and-hold repeats the step every 200ms until release.
///
/// The value is owned by the parent via [value] (with [onChanged] reporting
/// the new one); the widget keeps an internal working copy so consecutive
/// long-press repeats compose from the latest reported value. Clamping
/// snaps overshooting steps exactly onto [min] / [max].
///
/// Out of scope (B-M7): price calculation, card integration.
class QuantityStepper extends StatefulWidget {
  /// Creates a quantity stepper.
  ///
  /// [value] and [onChanged] are required; [step], [min] and [max] must
  /// satisfy `min <= max` (asserted).
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.step = 0.5,
    this.min = 0.0,
    this.max = 99.0,
  }) : assert(min <= max, 'min must be <= max.');

  /// The current quantity, owned by the parent (default display "0.5").
  final double value;

  /// Amount added/removed per step (default 0.5).
  final double step;

  /// Lower bound — stepping never reports a value below this (default 0.0).
  final double min;

  /// Upper bound — stepping never reports a value above this (default 99.0).
  final double max;

  /// Called with the stepped, clamped value on every change.
  final ValueChanged<double> onChanged;

  @override
  State<QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<QuantityStepper> {
  /// Timer driving the repeating step while held (see [_stepRepeat]).
  Timer? _stepRepeat;

  /// Internal working copy of the value so consecutive long-press repeats
  /// compose from the latest reported value (see [widget.value]).
  double _workingValue = 0.5;

  @override
  void initState() {
    super.initState();
    _workingValue = widget.value;
  }

  @override
  void didUpdateWidget(QuantityStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _workingValue = widget.value;
    }
  }

  @override
  void dispose() {
    _stepRepeat?.cancel();
    super.dispose();
  }

  /// One stepped, clamped value change: `value` clamped to [widget.min] /
  /// [widget.max], then reported to [widget.onChanged].
  void _step(double value) {
    final double clamped = value.clamp(widget.min, widget.max);
    if (clamped == _workingValue) {
      return;
    }
    setState(() {
      _workingValue = clamped;
    });
    HapticFeedback.selectionClick();
    widget.onChanged(clamped);
  }

  /// Amount added per increment (one [widget.step], +).
  void _increment() {
    _step(_workingValue + widget.step);
  }

  /// Amount removed per decrement (one [widget.step], -).
  void _decrement() {
    _step(_workingValue - widget.step);
  }

  /// Long-press start: steps once, then repeats the step every 200ms until
  /// release (see [_longPressEnd]).
  void _longPressStart(LongPressStartDetails details) {
    _increment();
    _stepRepeat = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => _increment(),
    );
  }

  /// Long-press end/release: cancels the repeating step (see
  /// [_longPressStart]).
  void _longPressEnd(LongPressEndDetails details) {
    _stepRepeat?.cancel();
    _stepRepeat = null;
  }
  @override
  Widget build(BuildContext context) {
    final AppTypography typography = AppTypography.of(context);

    // 13px/w500 tabular — bodySm, tinted with neutral-title (#0F172A) for the
    // quantity value.
    final TextStyle valueStyle = typography.bodySm.copyWith(
      color: AppColors.neutralTitle,
    );

    // The decrement/increment buttons are 32x32 white containers with a 12px
    // radius and shadowSoft — no radius token file, same convention as
    // AppCard.borderRadius.
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      boxShadow: AppShadows.shadowSoft,
    );

    final Widget decrementButton = GestureDetector(
      onTap: _decrement,
      onLongPressStart: _longPressStart,
      onLongPressEnd: _longPressEnd,
      child: Container(
        width: AppSpacing.space2xl,
        height: AppSpacing.space2xl,
        decoration: buttonDecoration,
        alignment: Alignment.center,
        child: const Icon(
          Symbols.remove,
          size: 18,
          color: AppColors.neutralMuted,
        ),
      ),
    );

    final Widget incrementButton = GestureDetector(
      onTap: _increment,
      onLongPressStart: _longPressStart,
      onLongPressEnd: _longPressEnd,
      child: Container(
        width: AppSpacing.space2xl,
        height: AppSpacing.space2xl,
        decoration: buttonDecoration,
        alignment: Alignment.center,
        child: const Icon(
          Symbols.add,
          size: 18,
          color: AppColors.neutralMuted,
        ),
      ),
    );

    // The #F8F9FA pill bar: 16px radius, decrement | value | increment.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceXs),
      decoration: BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          decrementButton,
          SizedBox(
            width: 40, // 40px fixed value width (B-M7)
            child: Text(
              '$_workingValue',
              style: valueStyle,
              textAlign: TextAlign.center,
            ),
          ),
          incrementButton,
        ],
      ),
    );
  }
}

