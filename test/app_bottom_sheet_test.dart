// B-M10 static layout verification for AppBottomSheet (plan.md B-M10 —
// static part only).
//
// Confirms the white surface with 20px top-only radius, the 40x4 drag
// handle (#E2E8F0, 9999px radius, centered, 12px top margin), the optional
// title (Subhead 16px/w600 #0F172A) with its divider, and the content
// wrapper (16px horizontal + 16px bottom padding, bottom safe area).
//
// The static show() method, barrier styling, and dismiss behavior are
// follow-up tasks and are intentionally NOT asserted here.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pasture_fresh_milk/core/theme/app_colors.dart';
import 'package:pasture_fresh_milk/core/theme/app_spacing.dart';
import 'package:pasture_fresh_milk/widgets/app_bottom_sheet.dart';

Widget _app(Widget sheet, {double bottomInset = 0}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(padding: EdgeInsets.only(bottom: bottomInset)),
      child: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: sheet,
        ),
      ),
    ),
  );
}

/// The drag-handle Container (the only one tinted neutralLine).
Container _handle(WidgetTester tester) =>
    tester
        .widgetList<Container>(find.byType(Container))
        .where(
          (Container c) =>
              (c.decoration! as BoxDecoration).color == AppColors.neutralLine,
        )
        .single;

/// The handle's visual 4px box — the Container's own render box includes its
/// margins, so measure the inner DecoratedBox.
Finder _handleVisual(WidgetTester tester) => find
    .descendant(of: find.byWidget(_handle(tester)), matching: find.byType(DecoratedBox))
    .first;

void main() {
  group('AppBottomSheet (static)', () {
    testWidgets('with title: subhead title + divider between title and body', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const AppBottomSheet(
            title: 'Choose amount',
            child: Text('Body'),
          ),
        ),
      );
      await tester.pump();

      final Text title = tester.widget<Text>(find.text('Choose amount'));
      // Subhead token: 16px/w600, tinted neutralTitle (#0F172A).
      expect(title.style?.fontSize, 16);
      expect(title.style?.fontWeight, FontWeight.w600);
      expect(title.style?.color, AppColors.neutralTitle);

      // Divider sits between the title and the content.
      final Divider divider = tester.widget<Divider>(find.byType(Divider));
      expect(divider.color, AppColors.neutralLine);
      expect(divider.thickness, 1);
      final Rect titleRect = tester.getRect(find.text('Choose amount'));
      final Rect dividerRect = tester.getRect(find.byType(Divider));
      final Rect bodyRect = tester.getRect(find.text('Body'));
      expect(dividerRect.top, greaterThan(titleRect.bottom));
      expect(bodyRect.top, greaterThanOrEqualTo(dividerRect.bottom));
    });

    testWidgets('without title: no title, no divider, handle still present', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const AppBottomSheet(child: Text('Body'))));
      await tester.pump();

      expect(find.byType(Divider), findsNothing);
      expect(tester.widgetList<Container>(find.byType(Container)).length, 2);
      final Rect bodyRect = tester.getRect(find.text('Body'));
      final Rect handleRect = tester.getRect(_handleVisual(tester));
      // Content starts below the handle (with its bottom margin between).
      expect(bodyRect.top, greaterThan(handleRect.bottom));
    });

    testWidgets('drag handle: 40x4, centered, 12px top margin', (tester) async {
      await tester.pumpWidget(_app(const AppBottomSheet(child: Text('Body'))));
      await tester.pump();

      final Container handle = _handle(tester);
      final BoxDecoration deco = handle.decoration! as BoxDecoration;
      expect(deco.color, AppColors.neutralLine);
      expect(deco.borderRadius, BorderRadius.circular(9999)); // radiusFull

      final Rect sheetRect = tester.getRect(find.byType(AppBottomSheet));
      final Rect handleRect = tester.getRect(_handleVisual(tester));
      expect(handleRect.width, 40);
      expect(handleRect.height, 4);
      // 12px top margin from the sheet surface (B-M10).
      expect(handleRect.top - sheetRect.top, AppSpacing.spaceSm);
      // Horizontally centered.
      expect(
        handleRect.center.dx,
        moreOrLessEquals(sheetRect.center.dx, epsilon: 0.5),
      );
    });

    testWidgets('surface: white bg, 20px top radius only, flat bottom', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const AppBottomSheet(child: Text('Body'))));
      await tester.pump();

      final Container surface = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(AppBottomSheet),
              matching: find.byType(Container),
            )
            .first,
      );
      final BoxDecoration deco = surface.decoration! as BoxDecoration;
      expect(deco.color, AppColors.card);
      final BorderRadius radius = deco.borderRadius! as BorderRadius;
      expect(radius.topLeft, const Radius.circular(20)); // radius2xl
      expect(radius.topRight, const Radius.circular(20));
      expect(radius.bottomLeft, Radius.zero);
      expect(radius.bottomRight, Radius.zero);
    });

    testWidgets('content: 16px h-padding + 16px bottom + bottom safe area', (
      tester,
    ) async {
      const double inset = 34;
      await tester.pumpWidget(
        _app(const AppBottomSheet(child: Text('Body')), bottomInset: inset),
      );
      await tester.pump();

      final Rect sheetRect = tester.getRect(find.byType(AppBottomSheet));
      final Rect bodyRect = tester.getRect(find.text('Body'));
      expect(bodyRect.left - sheetRect.left, AppSpacing.spaceMd);
      expect(sheetRect.right - bodyRect.right, AppSpacing.spaceMd);
      // 16px bottom padding, then the safe-area inset below it.
      expect(
        sheetRect.bottom - bodyRect.bottom,
        AppSpacing.spaceMd + inset,
      );
    });
  });

  group('AppBottomSheet.show', () {
    Future<void> openSheet(
      WidgetTester tester, {
      String? title = 'Choose amount',
      required Widget child,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => AppBottomSheet.show<void>(
                    context: context,
                    title: title,
                    builder: (BuildContext _) => child,
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
    }

    testWidgets('opens the layout inside the modal route', (tester) async {
      await openSheet(tester, child: const Text('Body'));
      expect(find.text('Choose amount'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('applies the 90% max-height constraint (B-M10)', (
      tester,
    ) async {
      // 600px test surface → 90% cap = 540px.
      await openSheet(
        tester,
        title: null,
        child: const SizedBox(height: 496), // fills exactly to the cap
      );

      final BuildContext sheetContext = tester.element(
        find.byType(AppBottomSheet),
      );
      final ModalBottomSheetRoute<dynamic> route =
          ModalRoute.of(sheetContext)! as ModalBottomSheetRoute<dynamic>;
      expect(
        route.constraints!.maxHeight,
        moreOrLessEquals(600 * 0.9, epsilon: 0.5),
      );

      // Behaviorally: content that fills the cap yields exactly 540px.
      expect(
        tester.getRect(find.byType(AppBottomSheet)).height,
        moreOrLessEquals(540, epsilon: 0.5),
      );
    });

    testWidgets('barrier is black at 30% opacity (B-M10)', (tester) async {
      await openSheet(tester, child: const Text('Body'));

      final Color expected = Colors.black.withValues(alpha: 0.3);
      final Iterable<ModalBarrier> barriers = tester.widgetList<ModalBarrier>(
        find.byType(ModalBarrier),
      );
      expect(
        barriers.where((ModalBarrier b) => b.color == expected),
        isNotEmpty,
      );
    });

    testWidgets('dismisses via barrier tap (B-M10)', (tester) async {
      await openSheet(tester, child: const Text('Body'));

      await tester.tapAt(const Offset(10, 10)); // above the sheet
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomSheet), findsNothing);
    });

    testWidgets('dismisses via drag down (B-M10)', (tester) async {
      await openSheet(tester, child: const Text('Body'));

      await tester.fling(find.text('Body'), const Offset(0, 300), 800);
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomSheet), findsNothing);
    });
  });
}
