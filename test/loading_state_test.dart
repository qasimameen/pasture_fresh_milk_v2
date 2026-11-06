// B-M15 verification for ShimmerCard (plan.md B-M15 — static part +
// sweep animation; Section 1.7 "Loading States").
//
// Confirms the placeholder shapes: each card is a 16px-radius rectangle with
// title (60%), subtitle (40%) and body (80%) bars stacked with 8px gaps
// inside 16px padding; count produces that many cards separated by 12px
// cardGap gaps; the shimmer sweep uses base #E2E8F0 / highlight #F8F9FA with
// a 1.5s period, actually animates (the gradient slides over time) and keeps
// running continuously.
//
// ShimmerMetricGrid (2x2 grid) is a follow-up task and is not asserted here.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pasture_fresh_milk/core/theme/app_colors.dart';
import 'package:pasture_fresh_milk/core/theme/app_spacing.dart';
import 'package:pasture_fresh_milk/widgets/loading_state.dart';

Widget _app(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

/// The placeholder cards — Containers WITH a BoxDecoration (the bars are
/// color-only containers, see [_bars]).
List<Container> _cards(WidgetTester tester) =>
    tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(ShimmerCard),
            matching: find.byType(Container),
          ),
        )
        .where((Container container) => container.decoration != null)
        .toList();

/// The three placeholder bars of each card — Containers with no decoration
/// (color-only canvas for the shimmer shader).
List<Container> _bars(WidgetTester tester) =>
    tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(ShimmerCard),
            matching: find.byType(Container),
          ),
        )
        .where((Container container) => container.decoration == null)
        .toList();

Rect _rectOf(WidgetTester tester, Container container) =>
    tester.getRect(find.byWidget(container));

/// The shimmer sweep's live progress (0..1). The `shimmer` package drives it
/// with a repeating controller on its (private) `_Shimmer` render widget,
/// whose `percent` field is public — read via dynamic dispatch.
double _shimmerPercent(WidgetTester tester) {
  final Widget renderWidget = tester.widget(
    find.byWidgetPredicate(
      (Widget widget) => widget.runtimeType.toString() == '_Shimmer',
    ),
  );
  return (renderWidget as dynamic).percent as double;
}

void main() {
  group('ShimmerCard (placeholder shapes)', () {
    testWidgets('defaults: 3 cards, 120px tall, 12px gaps, radiusXl', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const ShimmerCard()));
      await tester.pump();

      final List<Container> cards = _cards(tester);
      expect(cards.length, 3); // B-M15 count default

      final List<Rect> rects = <Rect>[
        for (final Container card in cards) _rectOf(tester, card),
      ];
      for (final Rect rect in rects) {
        expect(rect.height, 120); // B-M15 height default
        expect(rect.width, 800); // fills the test surface width
      }
      // 12px vertical gaps between stacked cards (B-M15; cardGap).
      expect(rects[1].top - rects[0].bottom, AppSpacing.cardGap);
      expect(rects[2].top - rects[1].bottom, AppSpacing.cardGap);

      // Card surface: white canvas + 16px radiusXl (Section 1.4 cards).
      final BoxDecoration deco = cards.first.decoration! as BoxDecoration;
      expect(deco.color, AppColors.card);
      expect(deco.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('height/count props override the defaults', (tester) async {
      await tester.pumpWidget(
        _app(
          const SingleChildScrollView(child: ShimmerCard(height: 200, count: 5)),
        ),
      );
      await tester.pump();

      final List<Container> cards = _cards(tester);
      expect(cards.length, 5);
      final List<Rect> rects = <Rect>[
        for (final Container card in cards) _rectOf(tester, card),
      ];
      for (final Rect rect in rects) {
        expect(rect.height, 200);
      }
      // 4 gaps of 12px between the 5 stacked cards.
      for (int i = 1; i < rects.length; i++) {
        expect(rects[i].top - rects[i - 1].bottom, AppSpacing.cardGap);
      }
    });

    testWidgets('bars: 60%/40%/80% of inner width, stacked with 8px gaps', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const ShimmerCard(height: 200, count: 1)));
      await tester.pump();

      final Rect cardRect = _rectOf(tester, _cards(tester).single);
      final List<Container> bars = _bars(tester);
      expect(bars.length, 3);

      final List<Rect> rects = <Rect>[
        for (final Container bar in bars) _rectOf(tester, bar),
      ];
      // Sort narrowest → widest: subtitle (40%), title (60%), body (80%).
      rects.sort((Rect a, Rect b) => a.width.compareTo(b.width));

      // Width fractions are relative to the card's inner width (card minus
      // the 16px padding on each side).
      final double innerWidth =
          cardRect.width - 2 * AppSpacing.spaceMd;
      expect(rects[0].width, moreOrLessEquals(innerWidth * 0.40, epsilon: 0.5));
      expect(rects[1].width, moreOrLessEquals(innerWidth * 0.60, epsilon: 0.5));
      expect(rects[2].width, moreOrLessEquals(innerWidth * 0.80, epsilon: 0.5));

      // Bar heights (title 20 / subtitle 12 / body 16).
      expect(rects[0].height, 12);
      expect(rects[1].height, 20);
      expect(rects[2].height, 16);

      // Left-aligned at the card's inner-left edge; stacked top-down with
      // 8px (spaceXs) gaps, starting at the card's inner-top edge.
      for (final Rect rect in rects) {
        expect(rect.left, cardRect.left + AppSpacing.spaceMd);
      }
      // Order by vertical position: title, subtitle, body.
      final List<Rect> vertical = <Rect>[...rects]
        ..sort((Rect a, Rect b) => a.top.compareTo(b.top));
      expect(vertical[0].top, cardRect.top + AppSpacing.spaceMd);
      expect(vertical[1].top - vertical[0].bottom, AppSpacing.spaceXs);
      expect(vertical[2].top - vertical[1].bottom, AppSpacing.spaceXs);
    });
  });

  group('ShimmerCard (shimmer sweep)', () {
    testWidgets('token colors and 1.5s period', (tester) async {
      await tester.pumpWidget(_app(const ShimmerCard()));
      await tester.pump();

      final Shimmer shimmer = tester.widget<Shimmer>(
        find.descendant(
          of: find.byType(ShimmerCard),
          matching: find.byType(Shimmer),
        ),
      );
      // Section 1.7 / B-M15: base #E2E8F0, highlight #F8F9FA, 1.5s sweep.
      // fromColors folds the colors into the gradient: [base, base,
      // highlight, base, base].
      expect(shimmer.period, const Duration(milliseconds: 1500));
      expect(shimmer.direction, ShimmerDirection.ltr);
      final LinearGradient gradient = shimmer.gradient as LinearGradient;
      expect(gradient.colors.length, 5);
      expect(gradient.colors[0], AppColors.neutralLine);
      expect(gradient.colors[2], AppColors.scaffold);
      expect(gradient.colors[4], AppColors.neutralLine);
    });

    testWidgets('sweep animates and runs continuously', (tester) async {
      await tester.pumpWidget(_app(const ShimmerCard()));
      await tester.pump();

      final double start = _shimmerPercent(tester);
      await tester.pump(const Duration(milliseconds: 750));
      final double mid = _shimmerPercent(tester);
      expect(mid, isNot(moreOrLessEquals(start, epsilon: 0.01)));

      // Continuous: still sweeping after several full periods — the percent
      // wraps around the 1.5s loop and a new frame keeps being scheduled.
      await tester.pump(const Duration(seconds: 5));
      final double later = _shimmerPercent(tester);
      expect(later, isNot(moreOrLessEquals(mid, epsilon: 0.01)));
      expect(tester.binding.hasScheduledFrame, isTrue);
      expect(find.byType(ShimmerCard), findsOneWidget);
    });
  });

  group('ShimmerMetricGrid (2x2 grid)', () {
    /// The grid tiles — decorated Containers with the 16px spaceMd padding
    /// (distinguishes them from the 32x32 icon boxes, which have no padding).
    List<Container> gridTiles(WidgetTester tester) =>
        tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(ShimmerMetricGrid),
                matching: find.byType(Container),
              ),
            )
            .where(
              (Container container) =>
                  container.padding ==
                  const EdgeInsets.all(AppSpacing.spaceMd),
            )
            .toList();

    /// The 32x32 icon-container placeholders (decorated, no padding).
    List<Container> iconBoxes(WidgetTester tester) =>
        tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(ShimmerMetricGrid),
                matching: find.byType(Container),
              ),
            )
            .where(
              (Container container) =>
                  container.decoration != null && container.padding == null,
            )
            .toList();

    /// The placeholder bars (color-only Containers).
    List<Container> gridBars(WidgetTester tester) =>
        tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(ShimmerMetricGrid),
                matching: find.byType(Container),
              ),
            )
            .where((Container container) => container.decoration == null)
            .toList();

    testWidgets('renders 4 equal tiles in a 2x2 layout with cardGap gaps', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const ShimmerMetricGrid()));
      await tester.pump();

      final List<Container> tiles = gridTiles(tester);
      expect(tiles.length, 4);

      // Sort by (top, left) → top-left, top-right, bottom-left, bottom-right.
      final List<Rect> rects = <Rect>[
        for (final Container tile in tiles) _rectOf(tester, tile),
      ]..sort((Rect a, Rect b) {
        final int byTop = a.top.compareTo(b.top);
        return byTop != 0 ? byTop : a.left.compareTo(b.left);
      });

      // 2x2: two tiles share each row; row 2 sits below row 1.
      expect(rects[0].top, rects[1].top);
      expect(rects[2].top, rects[3].top);
      expect(rects[0].top, lessThan(rects[2].top));
      expect(rects[0].left, lessThan(rects[1].left));

      // 12px horizontal gap inside each row (cardGap).
      expect(rects[1].left - rects[0].right, AppSpacing.cardGap);
      expect(rects[3].left - rects[2].right, AppSpacing.cardGap);
      // 12px vertical gap between rows (cardGap).
      expect(rects[2].top - rects[0].bottom, AppSpacing.cardGap);

      // Equal tile sizes: equal columns and equal rows.
      final double tileWidth = rects[0].width;
      for (final Rect rect in rects) {
        expect(rect.width, moreOrLessEquals(tileWidth, epsilon: 0.5));
      }
      expect(rects[0].height, rects[2].height);
      expect(rects[1].height, rects[3].height);
      expect(
        tileWidth,
        moreOrLessEquals((800 - AppSpacing.cardGap) / 2, epsilon: 0.5),
      );
    });

    testWidgets('tiles match the MetricCard shape (icon box, label, value)', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const ShimmerMetricGrid()));
      await tester.pump();

      final Rect tileRect = _rectOf(tester, gridTiles(tester).first);
      final Rect iconRect = _rectOf(tester, iconBoxes(tester).first);
      final List<Rect> barRects = <Rect>[
        for (final Container bar in gridBars(tester)) _rectOf(tester, bar),
      ];

      // Icon container: 32x32 (space2xl), 16px radius, at the tile's
      // inner-top-end — MetricCard's icon container shape.
      expect(iconRect.width, AppSpacing.space2xl);
      expect(iconRect.height, AppSpacing.space2xl);
      expect(
        (iconBoxes(tester).first.decoration! as BoxDecoration).borderRadius,
        BorderRadius.circular(16),
      );
      expect(iconRect.right, tileRect.right - AppSpacing.spaceMd);
      expect(iconRect.top, tileRect.top + AppSpacing.spaceMd);

      // Label bar (12px) shares the icon row's top, at the tile's inner
      // start; 60% of the free row width (inner width minus the icon box
      // and its 8px spaceXs gap).
      final Rect labelBar = barRects
          .firstWhere((Rect rect) => rect.height == 12);
      expect(labelBar.top, iconRect.top);
      expect(labelBar.left, tileRect.left + AppSpacing.spaceMd);
      final double freeRow =
          innerWidthOf(tileRect) - AppSpacing.space2xl - AppSpacing.spaceXs;
      expect(
        labelBar.width,
        moreOrLessEquals(freeRow * 0.60, epsilon: 0.5),
      );

      // Value bar: 24px (MetricCard's 24px value), 60% of the inner width,
      // 4px (space2xs) below the icon row, ending at the tile's inner-bottom.
      final Rect valueBar = barRects
          .firstWhere((Rect rect) => rect.height == 24);
      expect(valueBar.top - iconRect.bottom, AppSpacing.space2xs);
      expect(
        valueBar.width,
        moreOrLessEquals(innerWidthOf(tileRect) * 0.60, epsilon: 0.5),
      );
      expect(valueBar.left, tileRect.left + AppSpacing.spaceMd);
      expect(valueBar.bottom, tileRect.bottom - AppSpacing.spaceMd);
    });

    testWidgets('same shimmer sweep as ShimmerCard (tokens, 1500ms, run)', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const ShimmerMetricGrid()));
      await tester.pump();

      final Shimmer shimmer = tester.widget<Shimmer>(
        find.descendant(
          of: find.byType(ShimmerMetricGrid),
          matching: find.byType(Shimmer),
        ),
      );
      expect(shimmer.period, const Duration(milliseconds: 1500));
      expect(shimmer.direction, ShimmerDirection.ltr);
      final LinearGradient gradient = shimmer.gradient as LinearGradient;
      expect(gradient.colors[0], AppColors.neutralLine);
      expect(gradient.colors[2], AppColors.scaffold);
      expect(gradient.colors[4], AppColors.neutralLine);

      // The sweep animates and runs continuously (one repeating controller
      // drives the whole grid — same mechanism as ShimmerCard).
      final double start = _shimmerPercent(tester);
      await tester.pump(const Duration(milliseconds: 750));
      expect(
        _shimmerPercent(tester),
        isNot(moreOrLessEquals(start, epsilon: 0.01)),
      );
      await tester.pump(const Duration(seconds: 5));
      expect(tester.binding.hasScheduledFrame, isTrue);
      expect(find.byType(ShimmerMetricGrid), findsOneWidget);
    });
  });
}

/// The tile's inner width (tile width minus the 16px padding on each side).
double innerWidthOf(Rect tileRect) => tileRect.width - 2 * AppSpacing.spaceMd;
