// B-M14 verification for EmptyState (plan.md B-M14; Section 1.7 "Empty
// States").
//
// Confirms the centered column: the 48px neutralFaint icon, the Subhead
// (16px/w600 #0F172A) title 8px below it, the Body (14px/w400 #64748B)
// subtitle 4px below that, and the optional CTA — the B-M9 AppButton
// secondary variant reused directly — 16px below the subtitle, rendered only
// when actionLabel and onAction are both provided (asserted as a pair).
//
// Also confirms the 280px content-column cap (declared + measured), the tap
// callback, and that the widget centers within a constrained parent
// (SizedBox) instead of forcing its own screen-filling size.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:pasture_fresh_milk/core/theme/app_colors.dart';
import 'package:pasture_fresh_milk/core/theme/app_spacing.dart';
import 'package:pasture_fresh_milk/widgets/app_button.dart';
import 'package:pasture_fresh_milk/widgets/empty_state.dart';

const String _kTitle = 'No customers yet';
const String _kSubtitle = 'Add a customer to start planning deliveries.';
const String _kAction = 'Add customer';
const Key _kBoxKey = Key('empty-state-box');

Widget _app(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

EmptyState _state({VoidCallback? onAction}) {
  return EmptyState(
    icon: Symbols.inbox,
    title: _kTitle,
    subtitle: _kSubtitle,
    // The pair is provided (or withheld) together per the widget's assert.
    actionLabel: onAction == null ? null : _kAction,
    onAction: onAction,
  );
}

/// The 48px empty-state icon — the only Icon in the widget (the reused
/// AppButton gets no icon prop).
Finder _icon() => find
    .descendant(of: find.byType(EmptyState), matching: find.byType(Icon))
    .first;

/// The content column — the only Column in the widget (AppButton uses a Row).
Finder _column() => find
    .descendant(of: find.byType(EmptyState), matching: find.byType(Column))
    .first;

/// The action button, found through its label.
Finder _button() => find
    .ancestor(of: find.text(_kAction), matching: find.byType(AppButton))
    .first;

void main() {
  group('EmptyState (content & styling)', () {
    testWidgets('icon/title/subtitle render with the token styles', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_state()));
      await tester.pump();

      // Icon: 48px, outlined style (caller passes the outlined symbol),
      // color #94A3B8 — Section 1.7.
      final Icon icon = tester.widget<Icon>(_icon());
      expect(icon.size, 48);
      expect(icon.color, AppColors.neutralFaint);

      // Title: Subhead token (16px/w600) in #0F172A — Section 1.7.
      final Text title = tester.widget<Text>(find.text(_kTitle));
      expect(title.style?.fontSize, 16);
      expect(title.style?.fontWeight, FontWeight.w600);
      expect(title.style?.color, AppColors.neutralTitle);

      // Subtitle: Body token (14px/w400) in #64748B — Section 1.7.
      final Text subtitle = tester.widget<Text>(find.text(_kSubtitle));
      expect(subtitle.style?.fontSize, 14);
      expect(subtitle.style?.fontWeight, FontWeight.w400);
      expect(subtitle.style?.color, AppColors.neutralMuted);
    });

    testWidgets('vertical rhythm: 8px icon→title, 4px title→subtitle, '
        '16px subtitle→button', (tester) async {
      await tester.pumpWidget(_app(_state(onAction: () {})));
      await tester.pump();

      final Rect iconRect = tester.getRect(_icon());
      final Rect titleRect = tester.getRect(find.text(_kTitle));
      final Rect subtitleRect = tester.getRect(find.text(_kSubtitle));
      final Rect buttonRect = tester.getRect(_button());

      // Section 1.7 gaps, all on the AppSpacing token scale.
      expect(titleRect.top - iconRect.bottom, AppSpacing.spaceXs);
      expect(subtitleRect.top - titleRect.bottom, AppSpacing.space2xs);
      expect(buttonRect.top - subtitleRect.bottom, AppSpacing.spaceMd);
    });

    testWidgets('no action button when actionLabel/onAction are absent', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_state()));
      await tester.pump();

      expect(find.byType(AppButton), findsNothing);
      expect(find.text(_kAction), findsNothing);
      expect(find.text(_kTitle), findsOneWidget);
      expect(find.text(_kSubtitle), findsOneWidget);
    });

    testWidgets(
      'action renders as the reused AppButton secondary variant when '
      'both props are given',
      (tester) async {
        await tester.pumpWidget(_app(_state(onAction: () {})));
        await tester.pump();

        final AppButton button = tester.widget<AppButton>(_button());
        expect(button.variant, AppButtonVariant.secondary);
        expect(button.label, _kAction);

        // The secondary surface comes from the reused AppButton itself:
        // brandSoft bg, 16px radius, label tinted brandPrimary (B-M9).
        final Container surface = tester.widget<Container>(
          find
              .descendant(of: _button(), matching: find.byType(Container))
              .first,
        );
        final BoxDecoration deco = surface.decoration! as BoxDecoration;
        expect(deco.color, AppColors.brandSoft);
        expect(deco.borderRadius, BorderRadius.circular(16));
        expect(
          tester.widget<Text>(find.text(_kAction)).style?.color,
          AppColors.brandPrimary,
        );
      },
    );

    testWidgets(
      'actionLabel without onAction is rejected (paired-args assert)',
      (tester) async {
        // The constructor asserts both-or-neither (user-confirmed resolution,
        // same convention as AppSnackBar).
        expect(
          () => EmptyState(
            icon: Symbols.inbox,
            title: _kTitle,
            subtitle: _kSubtitle,
            actionLabel: _kAction, // onAction missing
          ),
          throwsA(isA<AssertionError>()),
        );
        await tester.pumpWidget(_app(_state()));
        await tester.pump();
      },
    );

    testWidgets('action callback fires when the button is tapped', (
      tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(_app(_state(onAction: () => taps++)));
      await tester.pump();

      expect(taps, 0);
      await tester.tap(find.text(_kAction));
      await tester.pumpAndSettle(); // flush the 100ms press feedback
      expect(taps, 1);
    });
  });

  group('EmptyState (column cap & centering)', () {
    testWidgets('content column respects the 280px max width', (tester) async {
      // Long enough that single-line rendering would far exceed 280px on
      // the 800px test surface — the cap must bind and wrap the text.
      const String longTitle =
          'No customers match the current route and shift filters today';
      const String longSubtitle =
          'Try clearing the filters or add a new customer to this route to '
          'see them listed here.';

      await tester.pumpWidget(
        _app(
          const EmptyState(
            icon: Symbols.inbox,
            title: longTitle,
            subtitle: longSubtitle,
          ),
        ),
      );
      await tester.pump();

      // Declared cap: the column is constrained to maxWidth 280.
      final ConstrainedBox cap = tester.widget<ConstrainedBox>(
        find
            .descendant(
              of: find.byType(EmptyState),
              matching: find.byType(ConstrainedBox),
            )
            .first,
      );
      expect(cap.constraints.maxWidth, 280);

      // Measured cap: no content element exceeds 280px on the 800px surface.
      expect(
        tester.getRect(find.text(longTitle)).width,
        lessThanOrEqualTo(280),
      );
      expect(
        tester.getRect(find.text(longSubtitle)).width,
        lessThanOrEqualTo(280),
      );
      expect(tester.getRect(_column()).width, lessThanOrEqualTo(280));

      // The capped column stays horizontally centered on the surface.
      expect(
        tester.getRect(_column()).center.dx,
        moreOrLessEquals(400, epsilon: 0.5),
      );
    });

    testWidgets('centers within a constrained parent (SizedBox)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SizedBox(
            key: _kBoxKey,
            height: 400,
            width: double.infinity,
            child: _state(onAction: () {}),
          ),
        ),
      );
      await tester.pump();

      final Rect boxRect = tester.getRect(find.byKey(_kBoxKey));
      final Rect columnRect = tester.getRect(_column());

      // The column hugs its content (not stretched to the 400px box) and is
      // vertically centered inside it — Section 1.7 "Centered vertically in
      // available space".
      expect(columnRect.height, lessThan(boxRect.height));
      expect(
        columnRect.center.dy,
        moreOrLessEquals(boxRect.center.dy, epsilon: 0.5),
      );
      // Horizontally centered too.
      expect(
        columnRect.center.dx,
        moreOrLessEquals(boxRect.center.dx, epsilon: 0.5),
      );
    });
  });
}
