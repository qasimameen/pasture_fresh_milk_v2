// B-M11 static layout verification for AppDialog (plan.md B-M11 —
// static part only).
//
// Confirms the dialog surface (white bg, 24px radius3xl radius, 24px
// padding, shadowMedium), the title in the Subhead token (16px/w600
// #0F172A), the message in the Body token (14px/w400 #334155), and the
// right-aligned button row: a plain text-only cancel TextButton and the
// confirm AppButton (Primary variant), with their tap callbacks.
//
// The showConfirmation() presentation — Future<bool> resolution, the
// barrierDismissible:false outside-tap block, back-button dismissal, and the
// isDestructive red-confirm swap — is asserted in the
// AppDialog.showConfirmation group below.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pasture_fresh_milk/core/theme/app_colors.dart';
import 'package:pasture_fresh_milk/core/theme/app_shadows.dart';
import 'package:pasture_fresh_milk/core/theme/app_spacing.dart';
import 'package:pasture_fresh_milk/widgets/app_button.dart';
import 'package:pasture_fresh_milk/widgets/app_dialog.dart';

const String _kTitle = 'Delete product?';
const String _kMessage = 'This action cannot be undone.';
const String _kCancel = 'Cancel';
const String _kConfirm = 'Delete';

Widget _app(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

AppDialog _dialog({VoidCallback? onCanceled, VoidCallback? onConfirmed}) =>
    AppDialog(
      title: _kTitle,
      message: _kMessage,
      cancelLabel: _kCancel,
      confirmLabel: _kConfirm,
      onCanceled: onCanceled,
      onConfirmed: onConfirmed,
    );

/// The dialog's surface Container — the only one tinted [AppColors.card]
/// (the confirm AppButton's inner surface is brandPrimary).
Container _surface(WidgetTester tester) => tester
    .widgetList<Container>(
      find.descendant(
        of: find.byType(AppDialog),
        matching: find.byType(Container),
      ),
    )
    .where(
      (Container c) => (c.decoration! as BoxDecoration).color == AppColors.card,
    )
    .single;

/// The button row — the Row that ancestors the cancel TextButton (the
/// confirm AppButton's internal label Row never contains it).
Finder _buttonRow() => find
    .ancestor(of: find.byType(TextButton), matching: find.byType(Row))
    .first;

void main() {
  group('AppDialog (static)', () {
    testWidgets('surface: white bg, 24px radius, 24px padding, shadowMedium', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_dialog()));
      await tester.pump();

      final Container surface = _surface(tester);
      final BoxDecoration deco = surface.decoration! as BoxDecoration;
      // card (#FFFFFF) — Section 1.1 "dialogs" surface.
      expect(deco.color, AppColors.card);
      // radius3xl — 24px (Section 1.4 "Dialogs: 24px (radius3xl)"; literal,
      // no radius token file).
      expect(deco.borderRadius, BorderRadius.circular(24));
      // shadowMedium — Section 1.5 "Shadow: shadowMedium" (the const token
      // list instance itself).
      expect(deco.boxShadow, same(AppShadows.shadowMedium));
      // 24px padding — Section 1.5 "Padding: 24px".
      expect(surface.padding, const EdgeInsets.all(AppSpacing.spaceXl));

      // Geometric: the title sits exactly 24px inside the surface's
      // top-left corner (padding is real, not just declared).
      final Rect dialogRect = tester.getRect(find.byType(AppDialog));
      final Rect titleRect = tester.getRect(find.text(_kTitle));
      expect(titleRect.left - dialogRect.left, AppSpacing.spaceXl);
      expect(titleRect.top - dialogRect.top, AppSpacing.spaceXl);
    });

    testWidgets('title renders the Subhead token in neutralTitle', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_dialog()));
      await tester.pump();

      final Text title = tester.widget<Text>(find.text(_kTitle));
      // Subhead: 16px/w600 (Section 1.2), tinted #0F172A.
      expect(title.style?.fontSize, 16);
      expect(title.style?.fontWeight, FontWeight.w600);
      expect(title.style?.color, AppColors.neutralTitle);
    });

    testWidgets('message renders the Body token in neutralBody', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_dialog()));
      await tester.pump();

      final Text message = tester.widget<Text>(find.text(_kMessage));
      // Body: 14px/w400 (Section 1.2), tinted #334155.
      expect(message.style?.fontSize, 14);
      expect(message.style?.fontWeight, FontWeight.w400);
      expect(message.style?.color, AppColors.neutralBody);
    });

    testWidgets(
      'button row is right-aligned: text-only cancel + confirm AppButton',
      (tester) async {
        // Fixed width so the stretched Row has free space on its left —
        // making the right-alignment geometrically observable.
        await tester.pumpWidget(_app(SizedBox(width: 320, child: _dialog())));
        await tester.pump();

        final Row row = tester.widget<Row>(_buttonRow());
        expect(row.mainAxisAlignment, MainAxisAlignment.end);

        final Rect dialogRect = tester.getRect(find.byType(AppDialog));
        final Rect confirmRect = tester.getRect(
          find.widgetWithText(AppButton, _kConfirm),
        );
        final Rect cancelRect = tester.getRect(
          find.widgetWithText(TextButton, _kCancel),
        );
        // Confirm flush against the right 24px padding edge...
        expect(dialogRect.right - confirmRect.right, AppSpacing.spaceXl);
        // ...cancel sits just left of the confirm (12px gap)...
        expect(confirmRect.left - cancelRect.right, AppSpacing.spaceSm);
        // ...leaving free space between it and the content's left edge.
        expect(
          cancelRect.left,
          greaterThan(dialogRect.left + AppSpacing.spaceXl),
        );

        // Cancel: exactly one plain TextButton, text-only (no icon), and
        // NOT built from AppButton.
        expect(find.byType(TextButton), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(TextButton),
            matching: find.byType(Icon),
          ),
          findsNothing,
        );
        expect(find.widgetWithText(AppButton, _kCancel), findsNothing);

        // Confirm: built with AppButton in the Primary variant —
        // brandPrimary (#1E40AF) surface (Section 6 "AppButton").
        final AppButton confirm = tester.widget<AppButton>(
          find.widgetWithText(AppButton, _kConfirm),
        );
        expect(confirm.variant, AppButtonVariant.primary);
        final Container confirmBox = tester.widget<Container>(
          find
              .descendant(
                of: find.widgetWithText(AppButton, _kConfirm),
                matching: find.byType(Container),
              )
              .first,
        );
        expect(
          (confirmBox.decoration! as BoxDecoration).color,
          AppColors.brandPrimary,
        );
      },
    );

    testWidgets('cancel tap fires onCanceled (and not onConfirmed)', (
      tester,
    ) async {
      int cancels = 0;
      int confirms = 0;
      await tester.pumpWidget(
        _app(
          _dialog(onCanceled: () => cancels++, onConfirmed: () => confirms++),
        ),
      );
      await tester.pump();

      await tester.tap(find.text(_kCancel));
      await tester.pump();
      expect(cancels, 1);
      expect(confirms, 0);
    });

    testWidgets('confirm tap fires onConfirmed', (tester) async {
      int confirms = 0;
      await tester.pumpWidget(_app(_dialog(onConfirmed: () => confirms++)));
      await tester.pump();

      await tester.tap(find.text(_kConfirm));
      await tester.pump();
      expect(confirms, 1);
    });
  });

  group('AppDialog.showConfirmation', () {
    /// Opens the dialog via a trigger button and returns the
    /// [AppDialog.showConfirmation] future.
    Future<Future<bool>> openDialog(
      WidgetTester tester, {
      bool isDestructive = false,
    }) async {
      Future<bool>? pending;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => pending = AppDialog.showConfirmation(
                    context,
                    title: _kTitle,
                    message: _kMessage,
                    cancelLabel: _kCancel,
                    confirmLabel: _kConfirm,
                    isDestructive: isDestructive,
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      return pending!;
    }

    testWidgets('presents the layout; confirm resolves true', (tester) async {
      final Future<bool> result = await openDialog(tester);
      expect(find.byType(AppDialog), findsOneWidget);
      expect(find.text(_kTitle), findsOneWidget);
      expect(find.text(_kMessage), findsOneWidget);

      await tester.tap(find.text(_kConfirm));
      await tester.pumpAndSettle();
      expect(find.byType(AppDialog), findsNothing);
      expect(await result, isTrue);
    });

    testWidgets('cancel resolves false', (tester) async {
      final Future<bool> result = await openDialog(tester);

      await tester.tap(find.text(_kCancel));
      await tester.pumpAndSettle();
      expect(find.byType(AppDialog), findsNothing);
      expect(await result, isFalse);
    });

    testWidgets('barrier tap does NOT dismiss (barrierDismissible: false)', (
      tester,
    ) async {
      final Future<bool> result = await openDialog(tester);

      await tester.tapAt(const Offset(10, 10)); // outside the dialog
      await tester.pumpAndSettle();
      // Still open — outside taps cannot dismiss it (B-M11).
      expect(find.byType(AppDialog), findsOneWidget);

      // And the future remains unresolved.
      bool resolved = false;
      unawaited(result.then((bool _) => resolved = true));
      await tester.pump();
      expect(resolved, isFalse);
    });

    testWidgets('back-button dismissal resolves false', (tester) async {
      final Future<bool> result = await openDialog(tester);

      // Simulate the system back button: the route pops with null.
      final NavigatorState navigator = tester.state<NavigatorState>(
        find.byType(Navigator),
      );
      unawaited(navigator.maybePop());
      await tester.pumpAndSettle();
      expect(find.byType(AppDialog), findsNothing);
      expect(await result, isFalse);
    });

    testWidgets(
      'isDestructive swaps the confirm button to the destructive variant',
      (tester) async {
        await openDialog(tester, isDestructive: true);

        final AppButton confirm = tester.widget<AppButton>(
          find.widgetWithText(AppButton, _kConfirm),
        );
        expect(confirm.variant, AppButtonVariant.destructive);

        final Container confirmBox = tester.widget<Container>(
          find
              .descendant(
                of: find.widgetWithText(AppButton, _kConfirm),
                matching: find.byType(Container),
              )
              .first,
        );
        // Destructive: #FEF2F2 bg / #DC2626 label (Section 6 "AppButton").
        expect(
          (confirmBox.decoration! as BoxDecoration).color,
          AppColors.errorLight,
        );
        expect(
          tester.widget<Text>(find.text(_kConfirm)).style?.color,
          AppColors.errorMain,
        );
      },
    );
  });
}
