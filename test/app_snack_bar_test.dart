// B-M13 verification for AppSnackBar (plan.md B-M13).
//
// Group 1 — static rendering: the toast container (normal #0F172A /
// error #DC2626 bg, 12px radiusLg radius, 16px screen-gutter margin), the
// message text in the Body token (14px/w400 #FFFFFF), and the optional
// action label in the labelLg token (14px/w600 #60A5FA) — rendered when
// provided, absent when not — with its tap callback.
//
// Group 2 — presentation layer (AppSnackBar.show/dismiss): the OverlayEntry
// presentation, auto-dismiss at 3s (normal) / 5s (with action) using the
// tester's fake-async time control (tester.pump durations — no real waits),
// single-instance replace (a second show() drops the first immediately, one
// snackbar in the tree), and the 200ms slide-up entry animation.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pasture_fresh_milk/core/theme/app_colors.dart';
import 'package:pasture_fresh_milk/core/theme/app_spacing.dart';
import 'package:pasture_fresh_milk/widgets/app_snack_bar.dart';

const String _kMessage = 'Sale recorded';
const String _kAction = 'Undo';

Widget _app(Widget child) {
  return MaterialApp(home: Scaffold(body: Center(child: child)));
}

Finder _container() => find.descendant(
  of: find.byType(AppSnackBar),
  matching: find.byType(Container),
).first;

BoxDecoration _deco(WidgetTester tester) =>
    tester.widget<Container>(_container()).decoration! as BoxDecoration;

void main() {
  group('AppSnackBar (static rendering)', () {
    testWidgets('normal variant: #0F172A bg, 12px radius, 16px margin', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const AppSnackBar(message: _kMessage)));
      await tester.pump();

      final BoxDecoration deco = _deco(tester);
      // neutral.title (#0F172A) — Section 1.5 "Background: #0F172A".
      expect(deco.color, AppColors.neutralTitle);
      // radiusLg — 12px (Section 1.5 "Corner radius: 12px"; literal, no
      // radius token file).
      expect(deco.borderRadius, BorderRadius.circular(12));

      // 16px margin from edges — Section 1.5 "Margin: 16px from edges".
      final Container container = tester.widget<Container>(_container());
      expect(container.margin, const EdgeInsets.all(AppSpacing.screenGutter));
      // Geometric: the decorated surface sits exactly 16px inside each
      // screen edge (the margin is real, not just declared — the widget's
      // own rect includes the margin padding, so measure the DecoratedBox).
      final Rect screen = tester.getRect(find.byType(MaterialApp));
      final Rect rect = tester.getRect(
        find.descendant(
          of: find.byType(AppSnackBar),
          matching: find.byType(DecoratedBox),
        ).first,
      );
      expect(rect.left, screen.left + AppSpacing.screenGutter);
      expect(rect.right, screen.right - AppSpacing.screenGutter);

      // No action button when none is provided.
      expect(find.text(_kAction), findsNothing);
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('error variant: #DC2626 bg', (tester) async {
      await tester.pumpWidget(
        _app(const AppSnackBar(message: _kMessage, error: true)),
      );
      await tester.pump();

      // error.main (#DC2626) — Section 1.5 / B-M13 "or #DC2626 if error".
      expect(_deco(tester).color, AppColors.errorMain);
    });

    testWidgets('message: Body token (14px/w400) in white', (tester) async {
      await tester.pumpWidget(_app(const AppSnackBar(message: _kMessage)));
      await tester.pump();

      final Text text = tester.widget<Text>(find.text(_kMessage));
      // AppTypography.of(context).body is the Body token (EN: 14px/w400);
      // the widget copies white onto it.
      expect(text.style?.fontSize, 14);
      expect(text.style?.fontWeight, FontWeight.w400);
      expect(text.style?.color, AppColors.card); // #FFFFFF
    });

    testWidgets(
      'action renders when provided: labelLg (14px/w600) #60A5FA, tappable',
      (tester) async {
        int taps = 0;
        await tester.pumpWidget(
          _app(
            AppSnackBar(
              message: _kMessage,
              actionLabel: _kAction,
              onAction: () => taps++,
            ),
          ),
        );
        await tester.pump();

        final Text action = tester.widget<Text>(find.text(_kAction));
        // labelLg token (EN: 14px/w600) with brand.primaryLight (#60A5FA).
        expect(action.style?.fontSize, 14);
        expect(action.style?.fontWeight, FontWeight.w600);
        expect(action.style?.color, AppColors.brandPrimaryLight);

        // The callback fires on tap (tappable, not inert).
        expect(taps, 0);
        await tester.tap(find.text(_kAction));
        await tester.pump();
        expect(taps, 1);
      },
    );

    testWidgets(
      'action label without a callback is rejected (paired-args assert)',
      (tester) async {
        // The constructor asserts actionLabel and onAction are provided
        // together — this documents that guard.
        expect(
          () => AppSnackBar(message: _kMessage, actionLabel: _kAction),
          throwsA(isA<AssertionError>()),
        );
        await tester.pumpWidget(_app(const AppSnackBar(message: _kMessage)));
        await tester.pump();
      },
    );
  });

  group('AppSnackBar (presentation: show/dismiss)', () {
    const String kFirstToast = 'First toast';
    const String kSecondToast = 'Second toast';

    /// Builds an app whose "Show" button calls [AppSnackBar.show] with the
    /// given args (closure so each test picks its parameters).
    Widget showingApp({
      required String message,
      String? actionLabel,
      VoidCallback? onAction,
      bool error = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => TextButton(
              onPressed: () => AppSnackBar.show(
                context,
                message: message,
                actionLabel: actionLabel,
                onAction: onAction,
                error: error,
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      );
    }

    Future<void> trigger(WidgetTester tester) async {
      await tester.tap(find.text('Show'));
      // Frame that inserts the OverlayEntry and mounts _AnimatedSnackBar.
      await tester.pump();
    }

    testWidgets('show() displays the snackbar with the correct content', (
      tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        showingApp(
          message: _kMessage,
          actionLabel: _kAction,
          onAction: () => taps++,
        ),
      );
      await trigger(tester);

      // The visual widget (not a re-implementation) is in the tree.
      expect(find.byType(AppSnackBar), findsOneWidget);
      expect(find.text(_kMessage), findsOneWidget);
      expect(find.text(_kAction), findsOneWidget);
      // Normal variant bg (not error) — Section 1.5.
      expect(_deco(tester).color, AppColors.neutralTitle);

      // The action stays tappable through the presentation layer — first
      // let the 200ms slide-up finish so the label is on-screen.
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text(_kAction));
      await tester.pump();
      expect(taps, 1);

      AppSnackBar.dismiss();
      await tester.pump();
    });

    testWidgets('show(error: true) presents the error variant', (tester) async {
      await tester.pumpWidget(showingApp(message: _kMessage, error: true));
      await trigger(tester);

      expect(find.byType(AppSnackBar), findsOneWidget);
      // error.main (#DC2626) — B-M13 "or #DC2626 if error".
      expect(_deco(tester).color, AppColors.errorMain);

      AppSnackBar.dismiss();
      await tester.pump();
    });

    testWidgets('auto-dismiss: gone after 3s (normal)', (tester) async {
      await tester.pumpWidget(showingApp(message: _kMessage));
      await trigger(tester);
      expect(find.byType(AppSnackBar), findsOneWidget);

      // Just under the 3s mark: still visible.
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 999));
      expect(find.byType(AppSnackBar), findsOneWidget);

      // Cross 3s (B-M13: "Auto-dismiss 3s") and flush the removal frame.
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      expect(find.byType(AppSnackBar), findsNothing);
    });

    testWidgets('auto-dismiss: 5s when an action is provided', (tester) async {
      await tester.pumpWidget(
        showingApp(message: _kMessage, actionLabel: _kAction, onAction: () {}),
      );
      await trigger(tester);
      expect(find.byType(AppSnackBar), findsOneWidget);

      // At the normal 3s mark it must STILL be visible (5s rule).
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      expect(find.byType(AppSnackBar), findsOneWidget);

      // Cross 5s total and it dismisses (B-M13: "(5s with action)").
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(find.byType(AppSnackBar), findsNothing);
    });

    testWidgets('show() replaces the visible one instead of stacking', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => TextButton(
                onPressed: () {
                  AppSnackBar.show(context, message: kFirstToast);
                  // Second call in the same run — must replace, not queue.
                  AppSnackBar.show(context, message: kSecondToast);
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump();

      // Exactly one snackbar, showing the SECOND message; the first was
      // dropped immediately (B-M13: "one at a time").
      expect(find.byType(AppSnackBar), findsOneWidget);
      expect(find.text(kSecondToast), findsOneWidget);
      expect(find.text(kFirstToast), findsNothing);

      // The replacement runs its own full lifetime: dismissed at 3s.
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      expect(find.byType(AppSnackBar), findsNothing);
    });

    testWidgets('entry: slides up from the bottom over 200ms', (tester) async {
      await tester.pumpWidget(showingApp(message: _kMessage));
      await trigger(tester);

      SlideTransition slide = tester.widget<SlideTransition>(
        find.byType(SlideTransition),
      );
      // First entry frame: fully below its resting spot (slide-UP start).
      expect(slide.position.value, const Offset(0, 1));

      // Halfway through the 200ms window: strictly mid-flight and rising
      // (asserted between the exact endpoints so the check is
      // curve-implementation independent — easeOut, easeOutCubic, etc. all
      // pass; the endpoints pin the tween itself).
      await tester.pump(const Duration(milliseconds: 100));
      slide = tester.widget<SlideTransition>(find.byType(SlideTransition));
      expect(slide.position.value.dy, greaterThan(0.0));
      expect(slide.position.value.dy, lessThan(1.0));
      expect(slide.position.value.dx, 0.0);

      // 200ms total (B-M13: "slide-up entry 200ms"): settled at offset zero.
      await tester.pump(const Duration(milliseconds: 100));
      slide = tester.widget<SlideTransition>(find.byType(SlideTransition));
      expect(slide.position.value, Offset.zero);
      // Resting spot: exactly 16px above the screen bottom (margin) — the
      // widget's own rect includes the margin, so measure the DecoratedBox.
      final Rect screen = tester.getRect(find.byType(MaterialApp));
      final Rect rect = tester.getRect(
        find
            .descendant(
              of: find.byType(AppSnackBar),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(rect.bottom, screen.bottom - AppSpacing.screenGutter);

      // Re-showing restarts the entry from the bottom (a replacement is a
      // fresh presentation, not a continued animation).
      await tester.tap(find.text('Show'));
      await tester.pump();
      slide = tester.widget<SlideTransition>(find.byType(SlideTransition));
      expect(slide.position.value, const Offset(0, 1));

      AppSnackBar.dismiss();
      await tester.pump();
    });
  });
}
