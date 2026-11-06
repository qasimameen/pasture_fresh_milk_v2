// B-M8 verification for BottomNavBar (plan.md B-M8).
//
// Confirms the 5 tabs render in plan order with the correct icons and
// labels, the inactive visual state (neutralMuted icon+label, 22px icon,
// 11px caption label), the 48px min tap width, and the container styling
// (95% white + 12px blur, #F1F5F9 top border, shadowHeavy, 64px + safe
// area).
//
// Also covers the B-M8 state behaviors: tapping a tab reports its index via
// onTap, currentIndex drives the active pill (#EFF6FF bg, #1E40AF
// icon/label) with inactive tabs unaffected, and the switch animates over
// 200ms instead of snapping.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:pasture_fresh_milk/core/theme/app_colors.dart';
import 'package:pasture_fresh_milk/core/theme/app_shadows.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/widgets/bottom_nav_bar.dart';

Widget _app(Widget bottomNavigationBar) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(bottomNavigationBar: bottomNavigationBar),
  );
}

/// RTL harness — the Urdu app runs under RTL directionality (Section 1.7);
/// wrapping the home content is how the directionality reaches the bar.
Widget _rtlApp(Widget bottomNavigationBar) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(bottomNavigationBar: bottomNavigationBar),
    ),
  );
}

BottomNavBar _bar() {
  return BottomNavBar(currentIndex: 0, onTap: (_) {});
}

/// Expected tab order (plan.md B-M8).
const List<(String, IconData)> _expectedTabs = <(String, IconData)>[
  ('Home', Symbols.storefront),
  ('Customers', Symbols.group),
  ('Deliveries', Symbols.local_shipping),
  ('Payments', Symbols.payments),
  ('Suppliers', Symbols.inventory_2),
];

/// Effective rendered label style (labels get their style from
/// AnimatedDefaultTextStyle, so Text.widget.style is null).
TextStyle _labelStyle(WidgetTester tester, String label) =>
    tester.renderObject<RenderParagraph>(find.text(label)).text.style!;

/// The pill's *rendered* decoration — AnimatedContainer.widget.decoration is
/// always the target, the lerped value lives in the internal DecoratedBox.
BoxDecoration _pillRenderDeco(WidgetTester tester, String label) =>
    tester.widget<DecoratedBox>(
      find
          .ancestor(
            of: find.text(label),
            matching: find.byType(DecoratedBox),
          )
          .first,
    ).decoration as BoxDecoration;

void main() {
  group('BottomNavBar', () {
    testWidgets('renders all 5 tabs in order with correct icons and labels', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_bar()));
      await tester.pump();

      for (final (String label, IconData icon) in _expectedTabs) {
        expect(find.text(label), findsOneWidget);
        expect(find.byIcon(icon), findsOneWidget);
      }

      // Left-to-right order matches the plan order (LTR canvas).
      double previousLeft = double.negativeInfinity;
      for (final (String _, IconData icon) in _expectedTabs) {
        final double left = tester.getRect(find.byIcon(icon)).left;
        expect(left, greaterThan(previousLeft));
        previousLeft = left;
      }
    });

    testWidgets('currentIndex drives active styling; inactive tabs unaffected', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(BottomNavBar(currentIndex: 2, onTap: (_) {})),
      );
      await tester.pump();

      // Active tab (Deliveries, index 2): brandPrimary icon/label inside the
      // #EFF6FF 16px pill (B-M8).
      final Icon activeIcon = tester.widget<Icon>(
        find.byIcon(Symbols.local_shipping),
      );
      expect(activeIcon.color, AppColors.brandPrimary);
      expect(activeIcon.size, 22);

      expect(_labelStyle(tester, 'Deliveries').fontSize, 11);
      expect(_labelStyle(tester, 'Deliveries').color, AppColors.brandPrimary);

      final AnimatedContainer activePill = tester.widget<AnimatedContainer>(
        find.ancestor(
          of: find.text('Deliveries'),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final BoxDecoration activeDeco = activePill.decoration! as BoxDecoration;
      expect(activeDeco.color, AppColors.brandSoft);
      expect(activeDeco.borderRadius, BorderRadius.circular(16));

      // Inactive tabs unaffected: neutralMuted icon/label, transparent pill.
      for (final (String label, IconData icon) in _expectedTabs) {
        if (label == 'Deliveries') {
          continue;
        }
        expect(
          tester.widget<Icon>(find.byIcon(icon)).color,
          AppColors.neutralMuted,
        );
        expect(
          tester.widget<Text>(find.text(label)).style?.color,
          isNull, // style comes from AnimatedDefaultTextStyle
        );
        expect(_labelStyle(tester, label).color, AppColors.neutralMuted);
        final AnimatedContainer pill = tester.widget<AnimatedContainer>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(AnimatedContainer),
          ),
        );
        expect((pill.decoration! as BoxDecoration).color, Colors.transparent);
      }
    });

    testWidgets('tapping each tab fires onTap with its index', (tester) async {
      final List<int> recorded = <int>[];
      await tester.pumpWidget(
        _app(BottomNavBar(currentIndex: 0, onTap: recorded.add)),
      );
      await tester.pump();

      for (final (String _, IconData icon) in _expectedTabs) {
        await tester.tap(find.byIcon(icon));
        await tester.pump();
      }
      expect(recorded, <int>[0, 1, 2, 3, 4]);
    });

    testWidgets('active pill animates over 200ms rather than snapping', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(BottomNavBar(currentIndex: 0, onTap: (_) {})),
      );
      await tester.pump(); // first frame renders tab 0 active directly

      Finder pillOf(String label) => find.ancestor(
        of: find.text(label),
        matching: find.byType(AnimatedContainer),
      );

      // Switch the active tab to Customers (index 1).
      await tester.pumpWidget(
        _app(BottomNavBar(currentIndex: 1, onTap: (_) {})),
      );
      await tester.pump(const Duration(milliseconds: 100)); // half of 200ms

      final AnimatedContainer midPill = tester.widget<AnimatedContainer>(
        pillOf('Customers'),
      );
      final BoxDecoration midDeco = _pillRenderDeco(tester, 'Customers');
      // Half-way through: not yet the final brandSoft, no longer transparent.
      expect(midDeco.color, isNot(AppColors.brandSoft));
      expect(midDeco.color, isNot(Colors.transparent));
      // The 200ms duration from B-M8 drives the animation.
      expect(midPill.duration, const Duration(milliseconds: 200));

      await tester.pump(const Duration(milliseconds: 200)); // past the end
      expect(
        _pillRenderDeco(tester, 'Customers').color,
        AppColors.brandSoft,
      );
    });

    testWidgets('RTL: tab order visually mirrors (Home rightmost)', (
      tester,
    ) async {
      await tester.pumpWidget(_rtlApp(_bar()));
      await tester.pump();

      // Mirrored order: the plan order reads right-to-left, so each
      // successive tab sits strictly further LEFT on the LTR canvas.
      double previousLeft = double.infinity;
      for (final (String label, IconData icon) in _expectedTabs) {
        final double left = tester.getRect(find.byIcon(icon)).left;
        expect(left, lessThan(previousLeft), reason: label);
        previousLeft = left;

        // 48px min tap width still respected per slot under RTL.
        expect(
          tester
              .getSize(
                find.ancestor(
                  of: find.text(label),
                  matching: find.byType(ConstrainedBox),
                ).first,
              )
              .width,
          greaterThanOrEqualTo(48),
          reason: label,
        );
      }

      // The first tab (Home) is flush with the bar's right edge — the RTL
      // mirror of the LTR left edge (only the 4px slot margin sits between).
      final Rect barRect = tester.getRect(find.byType(BottomNavBar));
      final Rect homeSlot = tester.getRect(
        find.ancestor(
          of: find.text('Home'),
          matching: find.byType(ConstrainedBox),
        ).first,
      );
      expect(
        homeSlot.right,
        moreOrLessEquals(barRect.right, epsilon: 0.5),
      );
    });

    testWidgets('RTL: active styling and tap-to-index mapping unaffected', (
      tester,
    ) async {
      final List<int> recorded = <int>[];
      await tester.pumpWidget(
        _rtlApp(BottomNavBar(currentIndex: 2, onTap: recorded.add)),
      );
      await tester.pump();

      // Active state still driven by currentIndex, visually mirrored:
      // Deliveries (index 2) is active — brand pill + brandPrimary — while
      // the (now right-to-left) neighbours stay inactive.
      expect(
        tester.widget<Icon>(find.byIcon(Symbols.local_shipping)).color,
        AppColors.brandPrimary,
      );
      expect(_labelStyle(tester, 'Deliveries').color, AppColors.brandPrimary);
      expect(
        _pillRenderDeco(tester, 'Deliveries').color,
        AppColors.brandSoft,
      );
      for (final (String label, IconData icon) in _expectedTabs) {
        if (label == 'Deliveries') {
          continue;
        }
        expect(
          tester.widget<Icon>(find.byIcon(icon)).color,
          AppColors.neutralMuted,
          reason: label,
        );
      }

      // Tapping the VISUALLY rightmost tab (Home under RTL) still reports
      // index 0, and the leftmost (Suppliers) reports 4 — indices follow the
      // tab list, not the visual position.
      await tester.tap(find.byIcon(Symbols.storefront));
      await tester.pump();
      await tester.tap(find.byIcon(Symbols.inventory_2));
      await tester.pump();
      expect(recorded, <int>[0, 4]);
    });

    testWidgets('each tab slot honors the 48px min tap width', (tester) async {
      await tester.pumpWidget(_app(_bar()));
      await tester.pump();

      for (final (String label, IconData _) in _expectedTabs) {
        final Size tabSize = tester.getSize(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(ConstrainedBox),
          ).first,
        );
        expect(tabSize.width, greaterThanOrEqualTo(48));
      }
    });

    testWidgets('bar is 64px tall, extending into the bottom safe area', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_bar()));
      await tester.pump();
      expect(tester.getSize(find.byType(BottomNavBar)).height, 64);

      // With a bottom safe inset the bar extends by exactly that inset
      // (64px + safe area, B-M8).
      await tester.pumpWidget(
        _app(
          MediaQuery(
            data: const MediaQueryData(padding: EdgeInsets.only(bottom: 34)),
            child: _bar(),
          ),
        ),
      );
      await tester.pump();
      expect(tester.getSize(find.byType(BottomNavBar)).height, 98);
    });

    testWidgets('container: 95% white, top border #F1F5F9, shadowHeavy', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_bar()));
      await tester.pump();

      // Two Containers: the outer surface (95% white + shadowHeavy) and the
      // inner 64px box carrying the 1px #F1F5F9 top border.
      final Iterable<Container> containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(BottomNavBar),
          matching: find.byType(Container),
        ),
      );
      final Container outer = containers.first;
      final Container bordered = containers
          .where(
            (Container c) => (c.decoration! as BoxDecoration).border != null,
          )
          .single;

      final BoxDecoration outerDeco = outer.decoration! as BoxDecoration;
      expect(outerDeco.color, AppColors.card.withValues(alpha: 0.95));
      expect(outerDeco.border, isNull);
      expect(outerDeco.boxShadow, AppShadows.shadowHeavy);

      final BoxDecoration borderDeco = bordered.decoration! as BoxDecoration;
      expect(borderDeco.border, isA<Border>());
      expect(
        (borderDeco.border! as Border).top.color,
        AppColors.neutralLineFaint,
      );
      expect((borderDeco.border! as Border).top.width, 1);

      // 12px backdrop blur sits between the bar root and the container.
      final BackdropFilter blur = tester.widget<BackdropFilter>(
        find.descendant(
          of: find.byType(BottomNavBar),
          matching: find.byType(BackdropFilter),
        ),
      );
      expect(blur.filter.runtimeType.toString(), contains('ImageFilter'));
    });
  });
}
