import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Shimmer skeleton placeholder card (plan.md B-M15; Section 1.7 "Loading
/// States").
///
/// Renders [count] stacked placeholder cards, each a rounded rectangle
/// matching the shape of the card content it replaces: a "title" bar at 60%
/// width, a "subtitle" bar at 40% width and a "body" bar at 80% width,
/// stacked vertically (bars 20/12/16px tall — the plan fixes only their
/// width fractions; heights and the 16px `radiusXl` card shape are the
/// established card-convention fills). Cards are separated by 12px vertical
/// gaps ([AppSpacing.cardGap]) when [count] > 1.
///
/// Shimmer (Section 1.7 / B-M15): base `#E2E8F0`
/// ([AppColors.neutralLine]), highlight `#F8F9FA` ([AppColors.scaffold]),
/// continuous 1.5s linear sweep — delivered by the `shimmer` package's
/// [Shimmer.fromColors] (a repeating [ShaderMask] gradient). The card's
/// containers are painted with the white [AppColors.card] canvas color; the
/// shimmer shader replaces it entirely, so no color outside the B-M1 token
/// file is introduced.
///
/// Bar width fractions are relative to the card's inner width (card minus
/// its 16px [AppSpacing.spaceMd] padding).
///
/// ShimmerMetricGrid (the 2x2 grid variant) is a separate follow-up task.
///
/// Out of scope (B-M15): content-specific skeletons.
class ShimmerCard extends StatelessWidget {
  /// Creates the shimmer placeholder.
  ///
  /// [height] must fit the three placeholder bars: 2×16px padding + 48px of
  /// bars + 2×8px gaps = 96px minimum.
  const ShimmerCard({
    super.key,
    this.height = 120, // B-M15 default
    this.count = 3, // B-M15 default
  }) : assert(
         height >= 96,
         'ShimmerCard.height must fit the placeholder bars (minimum 96px)',
       );

  /// Height of each placeholder card (B-M15: default 120px).
  final double height;

  /// Number of stacked placeholder cards (B-M15: default 3).
  final int count;

  // Placeholder bar geometry — the plan fixes only the width fractions
  // (60% / 40% / 80%); heights are content-shape literals (heading-ish /
  // caption-ish / body-ish) since no token governs skeleton bar heights.
  static const double _kTitleWidthFactor = 0.60;
  static const double _kSubtitleWidthFactor = 0.40;
  static const double _kBodyWidthFactor = 0.80;
  static const double _kTitleBarHeight = 20;
  static const double _kSubtitleBarHeight = 12;
  static const double _kBodyBarHeight = 16;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      // Section 1.7 / B-M15: base #E2E8F0, highlight #F8F9FA, 1.5s linear
      // sweep, continuous.
      baseColor: AppColors.neutralLine,
      highlightColor: AppColors.scaffold,
      period: const Duration(milliseconds: 1500),
      child: Column(
        children: List<Widget>.generate(
          count,
          (int index) => Padding(
            // 12px vertical gap between stacked cards (B-M15; cardGap).
            padding: EdgeInsets.only(
              bottom: index == count - 1 ? 0 : AppSpacing.cardGap,
            ),
            child: _placeholderCard(),
          ),
        ),
      ),
    );
  }

  /// One skeleton card — rounded 16px (radiusXl, Section 1.4 "Cards") to
  /// match the card surface it replaces, full-width like a real card, 16px
  /// padding, bars top-aligned.
  Widget _placeholderCard() {
    return Container(
      height: height,
      width: double.infinity, // full-width card surface
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.card, // canvas — fully tinted by the shimmer shader
        borderRadius: BorderRadius.circular(16), // radiusXl (cards)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _bar(_kTitleWidthFactor, _kTitleBarHeight),
          const SizedBox(height: AppSpacing.spaceXs),
          _bar(_kSubtitleWidthFactor, _kSubtitleBarHeight),
          const SizedBox(height: AppSpacing.spaceXs),
          _bar(_kBodyWidthFactor, _kBodyBarHeight),
        ],
      ),
    );
  }

  /// One placeholder bar — [widthFactor] of the card's inner width.
  Widget _bar(double widthFactor, double barHeight) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(height: barHeight, color: AppColors.card),
    );
  }
}

/// Shimmer placeholder bar (canvas container sized to a width fraction) —
/// library-private helper shared by [ShimmerMetricGrid]'s bars. [ShimmerCard]
/// keeps its own identical helper untouched (its tested code must not change).
Widget _shimmerBar(double widthFactor, double barHeight) {
  return FractionallySizedBox(
    alignment: Alignment.centerLeft,
    widthFactor: widthFactor,
    child: Container(height: barHeight, color: AppColors.card),
  );
}

/// 2x2 shimmer skeleton grid matching the MetricCard bento grid (plan.md
/// B-M15; tile shape from B-M3 [MetricCard]).
///
/// Each tile approximates a [MetricCard] on its AppCard surface shape —
/// white canvas, 16px `radiusXl` radius (Section 1.4 cards), 16px
/// ([AppSpacing.spaceMd]) padding:
///
/// * top row — a flexible label bar (12px tall, 60% of the free row width)
///   on the start and a 32x32 ([AppSpacing.space2xl]) icon-container
///   placeholder with the 16px radius on the end, matching MetricCard's
///   label/icon row;
/// * 4px ([AppSpacing.space2xs]) gap — MetricCard's label→value gap;
/// * a 24px value bar at 60% width — 24px matches MetricCard's 24px metric
///   value (bar heights/width fractions are documented fills; the plan fixes
///   only the shape).
///
/// The sweep is the same mechanism/colors/timing as [ShimmerCard] (base
/// `#E2E8F0` [AppColors.neutralLine], highlight `#F8F9FA`
/// [AppColors.scaffold], 1500ms, continuous) — duplicated, not extracted,
/// because ShimmerCard's tested code must not change.
///
/// Gaps: 12px [AppSpacing.cardGap] between tiles horizontally and
/// vertically — the same bento card-gap token ShimmerCard uses (MetricCard's
/// own usage context, the Home bento grid, is defined at C-M1 and reuses the
/// 12px card gap).
class ShimmerMetricGrid extends StatelessWidget {
  /// Creates the 2x2 metric-grid skeleton.
  const ShimmerMetricGrid({super.key});

  // Tile bar geometry — documented fills (see class doc): label/value width
  // fractions and the 24px value bar matching MetricCard's 24px value.
  static const double _kLabelWidthFactor = 0.60;
  static const double _kValueWidthFactor = 0.60;
  static const double _kLabelBarHeight = 12;
  static const double _kValueBarHeight = 24;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      // Same sweep as ShimmerCard (Section 1.7 / B-M15): base #E2E8F0,
      // highlight #F8F9FA, 1.5s linear, continuous.
      baseColor: AppColors.neutralLine,
      highlightColor: AppColors.scaffold,
      period: const Duration(milliseconds: 1500),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: _tile()),
              const SizedBox(width: AppSpacing.cardGap),
              Expanded(child: _tile()),
            ],
          ),
          const SizedBox(height: AppSpacing.cardGap),
          Row(
            children: <Widget>[
              Expanded(child: _tile()),
              const SizedBox(width: AppSpacing.cardGap),
              Expanded(child: _tile()),
            ],
          ),
        ],
      ),
    );
  }

  /// One metric-tile skeleton (see class doc for the shape).
  Widget _tile() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.card, // canvas — fully tinted by the shimmer shader
        borderRadius: BorderRadius.circular(16), // radiusXl (cards)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Top row: label bar (start, flexible) + 32x32 icon-container
          // placeholder (end) — MetricCard's label/icon row.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _shimmerBar(_kLabelWidthFactor, _kLabelBarHeight),
              ),
              const SizedBox(width: AppSpacing.spaceXs),
              Container(
                width: AppSpacing.space2xl, // 32px icon container (B-M3)
                height: AppSpacing.space2xl,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16), // radiusXl
                ),
              ),
            ],
          ),
          // 4px label→value gap (MetricCard B-M3; space2xs).
          const SizedBox(height: AppSpacing.space2xs),
          // Value bar — 24px, matching MetricCard's 24px metric value.
          _shimmerBar(_kValueWidthFactor, _kValueBarHeight),
        ],
      ),
    );
  }
}
