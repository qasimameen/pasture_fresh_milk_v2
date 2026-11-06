// B-M9 static rendering verification for AppButton (plan.md B-M9 —
// static part only).
//
// Confirms the 3 variants render their Section 1.1 color pairs with the
// labelLg token (14px/w600), 16px radius, 48px height, the optional leading
// icon with the 4px gap, and isFullWidth stretching vs content sizing.
//
// Loading state, disabled opacity, press animation, and AppIconButton are
// follow-up tasks and are intentionally NOT asserted here.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:pasture_fresh_milk/core/theme/app_colors.dart';
import 'package:pasture_fresh_milk/core/theme/app_spacing.dart';
import 'package:pasture_fresh_milk/widgets/app_button.dart';

Widget _app(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

Size _buttonSize(WidgetTester tester, String label) => tester.getSize(
  find.ancestor(of: find.text(label), matching: find.byType(AppButton)).first,
);

/// The button surface's *rendered* decoration (nearest DecoratedBox above
/// the label) — reflects the pressed-background swap.
BoxDecoration _renderedDeco(WidgetTester tester, String label) =>
    tester.widget<DecoratedBox>(
      find
          .ancestor(
            of: find.text(label),
            matching: find.byType(DecoratedBox),
          )
          .first,
    ).decoration as BoxDecoration;

void main() {
  group('AppButton (static)', () {
    testWidgets('variants use their Section 1.1 color pairs', (tester) async {
      await tester.pumpWidget(
        _app(
          Column(
            children: <Widget>[
              AppButton(label: 'Save', onPressed: () {}),
              AppButton(
                label: 'Save',
                onPressed: () {},
                variant: AppButtonVariant.secondary,
              ),
              AppButton(
                label: 'Delete',
                onPressed: () {},
                variant: AppButtonVariant.destructive,
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      final Iterable<Container> buttons = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.byType(Container),
        ),
      );

      final List<(Color, Color)> expected = <(Color, Color)>[
        (AppColors.brandPrimary, AppColors.card), // primary
        (AppColors.brandSoft, AppColors.brandPrimary), // secondary
        (AppColors.errorLight, AppColors.errorMain), // destructive
      ];
      expect(buttons.length, expected.length);

      int i = 0;
      for (final Container button in buttons) {
        final BoxDecoration deco = button.decoration! as BoxDecoration;
        expect(deco.color, expected[i].$1, reason: 'variant $i bg');
        expect(
          deco.borderRadius,
          BorderRadius.circular(16),
          reason: 'variant $i radius',
        );
        i++;
      }

      expect(
        tester.widget<Text>(find.text('Save').first).style?.color,
        AppColors.card,
      );
      expect(
        tester.widget<Text>(find.text('Save').at(1)).style?.color,
        AppColors.brandPrimary,
      );
      expect(
        tester.widget<Text>(find.text('Delete')).style?.color,
        AppColors.errorMain,
      );

      // labelLg token: 14px/w600.
      final TextStyle labelStyle =
          tester.widget<Text>(find.text('Save').first).style!;
      expect(labelStyle.fontSize, 14);
      expect(labelStyle.fontWeight, FontWeight.w600);
    });

    testWidgets('optional icon renders before the label with a 4px gap', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Column(
            children: <Widget>[
              AppButton(label: 'Add', onPressed: () {}, icon: Symbols.add),
              AppButton(label: 'Add', onPressed: () {}),
            ],
          ),
        ),
      );
      await tester.pump();

      // With icon: 20px, tinted the text color (white on primary).
      expect(find.byIcon(Symbols.add), findsOneWidget);
      final Icon icon = tester.widget<Icon>(find.byIcon(Symbols.add));
      expect(icon.size, 20);
      expect(icon.color, AppColors.card);

      final Rect iconRect = tester.getRect(find.byIcon(Symbols.add));
      final Rect labelRect = tester.getRect(find.text('Add').first);
      expect(labelRect.left, greaterThan(iconRect.right));
      expect(
        labelRect.left - iconRect.right,
        moreOrLessEquals(AppSpacing.space2xs, epsilon: 0.5),
      );

      // Without icon: only the first button has one.
      expect(find.text('Add'), findsNWidgets(2));
      expect(find.byIcon(Symbols.add), findsOneWidget);
    });

    testWidgets('isFullWidth stretches; default hugs content', (tester) async {
      await tester.pumpWidget(
        _app(
          Column(
            children: <Widget>[
              AppButton(label: 'Full', onPressed: () {}, isFullWidth: true),
              AppButton(label: 'Compact', onPressed: () {}),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(_buttonSize(tester, 'Full').width, 800); // test surface width
      final double compactWidth = _buttonSize(tester, 'Compact').width;
      expect(compactWidth, lessThan(800));
      expect(compactWidth, greaterThanOrEqualTo(AppSpacing.targetMin));
    });

    testWidgets('height defaults to 48px and accepts an override', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Column(
            children: <Widget>[
              AppButton(label: 'A', onPressed: () {}),
              AppButton(label: 'B', onPressed: () {}, height: 56),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(_buttonSize(tester, 'A').height, AppSpacing.targetMin);
      expect(_buttonSize(tester, 'B').height, 56);
    });

    testWidgets('isLoading: spinner only, inert, full opacity', (tester) async {
      int calls = 0;
      await tester.pumpWidget(
        _app(
          AppButton(
            label: 'Pay',
            onPressed: () => calls++,
            icon: Symbols.payments,
            isLoading: true,
          ),
        ),
      );
      await tester.pump();

      // Label and icon are NOT rendered (not hidden-but-laid-out, not shown
      // alongside the spinner).
      expect(find.text('Pay'), findsNothing);
      expect(find.byIcon(Symbols.payments), findsNothing);

      // Spinner: present, 20px box, tinted the variant's text color.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final CircularProgressIndicator spinner =
          tester.widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          );
      expect(spinner.color, AppColors.card); // primary text color
      expect(
        tester.getSize(
          find
              .ancestor(
                of: find.byType(CircularProgressIndicator),
                matching: find.byType(SizedBox),
              )
              .first,
        ),
        const Size(20, 20),
      );

      // Full opacity — visually distinct from the disabled state (which is
      // wrapped in Opacity 0.5).
      expect(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(Opacity),
        ),
        findsNothing,
      );

      // Non-interactive: no press machinery, tap does not fire onPressed.
      expect(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.byType(InkWell),
        ),
        findsNothing,
      );
      await tester.tap(find.byType(AppButton));
      await tester.pump(const Duration(milliseconds: 100));
      expect(calls, 0);

      // Variant bg and height unchanged while loading.
      final DecoratedBox surface =
          tester.widget<DecoratedBox>(
            find
                .ancestor(
                  of: find.byType(CircularProgressIndicator),
                  matching: find.byType(DecoratedBox),
                )
                .first,
          );
      expect((surface.decoration as BoxDecoration).color, AppColors.brandPrimary);
      expect(
        tester.getRect(
          find
              .ancestor(
                of: find.byType(CircularProgressIndicator),
                matching: find.byType(DecoratedBox),
              )
              .first,
        ).height,
        AppSpacing.targetMin,
      );
    });

    testWidgets('tap fires onPressed', (tester) async {
      int calls = 0;
      await tester.pumpWidget(
        _app(AppButton(label: 'Go', onPressed: () => calls++)),
      );
      await tester.pump();

      await tester.tap(find.text('Go'));
      await tester.pump();
      expect(calls, 1);
    });

    testWidgets('press scales to 0.97 and primary shows pressed bg', (
      tester,
    ) async {
      await tester.pumpWidget(_app(AppButton(label: 'Go', onPressed: () {})));
      await tester.pump();

      // Measure the DecoratedBox surface — its localToGlobal path crosses
      // the AnimatedScale's transform, so the rect reflects the scale (the
      // RenderTransform itself reports its unscaled layout box).
      Finder surfaceOf(String label) => find
          .ancestor(of: find.text(label), matching: find.byType(DecoratedBox))
          .first;
      expect(tester.getRect(surfaceOf('Go')).height, AppSpacing.targetMin);

      // Press and hold: AnimatedScale settles at 0.97, primary darkens to
      // its pressed color (B-M9). Two pumps: the first processes the press
      // and starts the 100ms scale animation, the second advances it.
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.text('Go')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester.getRect(surfaceOf('Go')).height,
        moreOrLessEquals(AppSpacing.targetMin * 0.97, epsilon: 0.5),
      );
      expect(_renderedDeco(tester, 'Go').color, AppColors.brandPrimaryDark);

      // Release: back to 1.0 and the resting background.
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.getRect(surfaceOf('Go')).height, AppSpacing.targetMin);
      expect(_renderedDeco(tester, 'Go').color, AppColors.brandPrimary);
    });

    testWidgets('secondary/destructive keep resting bg while pressed', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Column(
            children: <Widget>[
              AppButton(
                label: 'S',
                onPressed: () {},
                variant: AppButtonVariant.secondary,
              ),
              AppButton(
                label: 'D',
                onPressed: () {},
                variant: AppButtonVariant.destructive,
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      // No pressed tokens exist for these variants — scale-only feedback.
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.text('S')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(_renderedDeco(tester, 'S').color, AppColors.brandSoft);
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 100));

      final TestGesture gesture2 = await tester.startGesture(
        tester.getCenter(find.text('D')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(_renderedDeco(tester, 'D').color, AppColors.errorLight);
      await gesture2.up();
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('disabled: null onPressed is inert and 0.5 opacity', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const AppButton(label: 'Off')));
      await tester.pump();

      expect(
        tester.widget<Opacity>(
          find.ancestor(
            of: find.text('Off'),
            matching: find.byType(Opacity),
          ),
        ).opacity,
        0.5,
      );
      // Inert: no press machinery in the disabled subtree.
      expect(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.byType(InkWell),
        ),
        findsNothing,
      );
      // Tapping does nothing — no scale change, no crash.
      await tester.tap(find.text('Off'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester
            .getRect(
              find
                  .ancestor(
                    of: find.text('Off'),
                    matching: find.byType(AppButton),
                  )
                  .first,
            )
            .height,
        AppSpacing.targetMin,
      );
    });
  });

  group('AppIconButton', () {
    const AppIconButton enabledButton = AppIconButton(
      icon: Symbols.add,
      backgroundColor: AppColors.brandSoft,
      iconColor: AppColors.brandPrimary,
      onPressed: _noop,
    );

    testWidgets('renders square size with bg, tint, and radius', (
      tester,
    ) async {
      await tester.pumpWidget(_app(enabledButton));
      await tester.pump();

      expect(tester.getSize(find.byType(AppIconButton)), const Size(40, 40));
      final Icon icon = tester.widget<Icon>(find.byIcon(Symbols.add));
      expect(icon.size, 20);
      expect(icon.color, AppColors.brandPrimary);

      final Container box = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppIconButton),
          matching: find.byType(Container),
        ),
      );
      final BoxDecoration deco = box.decoration! as BoxDecoration;
      expect(deco.color, AppColors.brandSoft);
      expect(deco.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('tap fires onPressed; press scales to 0.97', (tester) async {
      int calls = 0;
      await tester.pumpWidget(
        _app(
          AppIconButton(
            icon: Symbols.add,
            backgroundColor: AppColors.brandSoft,
            iconColor: AppColors.brandPrimary,
            onPressed: () => calls++,
          ),
        ),
      );
      await tester.pump();

      Finder surfaceOf() => find
          .ancestor(of: find.byIcon(Symbols.add), matching: find.byType(DecoratedBox))
          .first;

      // Full tap fires onPressed.
      await tester.tap(find.byIcon(Symbols.add));
      await tester.pump();
      expect(calls, 1);

      // Press-and-hold: 0.97 scale, back to 1.0 on release.
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(Symbols.add)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester.getRect(surfaceOf()).height,
        moreOrLessEquals(40 * 0.97, epsilon: 0.5),
      );

      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.getRect(surfaceOf()).height, 40);
    });

    testWidgets('disabled: inert and 0.5 opacity', (tester) async {
      await tester.pumpWidget(
        _app(
          const AppIconButton(
            icon: Symbols.add,
            backgroundColor: AppColors.brandSoft,
            iconColor: AppColors.brandPrimary,
          ),
        ),
      );
      await tester.pump();

      expect(
        tester
            .widget<Opacity>(
              find
                  .ancestor(
                    of: find.byIcon(Symbols.add),
                    matching: find.byType(Opacity),
                  )
                  .first,
            )
            .opacity,
        0.5,
      );
      // Inert: no press machinery; tapping changes nothing.
      expect(find.byType(InkWell), findsNothing);
      await tester.tap(find.byIcon(Symbols.add));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.getSize(find.byType(AppIconButton)), const Size(40, 40));
    });
  });
}

void _noop() {}

