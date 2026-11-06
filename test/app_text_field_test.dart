// B-M12 static rendering verification for AppTextField (plan.md B-M12 —
// AppTextField only; AppDropdown is a follow-up task).
//
// Confirms the label (Caption-derived 11px/w700 #64748B, uppercase, 0.04em,
// red asterisk when isRequired), the field surface (#F8F9FA, 16px radius,
// 48px single-line height, 16px h-padding), input/hint styles, the focus
// ring (2px #1E40AF when focused, none at rest), the error state (2px
// #DC2626 + caption message below in error.text), prefix/suffix icons and
// suffixText, maxLines growth, and the controller/onChanged wiring.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pasture_fresh_milk/core/theme/app_colors.dart';
import 'package:pasture_fresh_milk/core/theme/app_spacing.dart';
import 'package:pasture_fresh_milk/widgets/app_text_field.dart';

Widget _app(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

/// The field's *rendered* border — painted by the InputDecorator's
/// foreground CustomPaint (Flutter 3.32 draws outline borders there, not in
/// a DecoratedBox), evaluated at its current animation value.
InputBorder _renderedBorder(WidgetTester tester) {
  final CustomPainter painter = tester
      .widgetList<CustomPaint>(
        find.descendant(
          of: find.byType(TextField),
          matching: find.byType(CustomPaint),
        ),
      )
      .firstWhere((CustomPaint p) => p.foregroundPainter != null)
      .foregroundPainter!;
  // The painter/tween types are framework-private; resolve dynamically.
  final dynamic dynamicPainter = painter;
  final Animation<double> animation =
      dynamicPainter.borderAnimation as Animation<double>;
  return dynamicPainter.border.evaluate(animation) as InputBorder;
}

/// The label Text — the only Text widget in label-only builds.
Text _label(WidgetTester tester) => tester.widget<Text>(find.byType(Text));
void main() {
  group('AppTextField (static)', () {
    testWidgets('label: Caption-derived, uppercase, muted, 0.04em', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const AppTextField(label: 'Amount')));
      await tester.pump();

      final Text label = _label(tester);
      final TextSpan span = label.textSpan! as TextSpan;
      // The style lives on the span (Text.rich).
      expect(span.style!.fontSize, 11);
      expect(span.style!.fontWeight, FontWeight.w700);
      expect(span.style!.color, AppColors.neutralMuted);
      expect(span.style!.letterSpacing, closeTo(0.04 * 11, 0.001));
      expect(span.style!.letterSpacing, isNot(closeTo(0.06 * 11, 0.001)));

      // Not required: plain uppercase label, no asterisk.
      expect(span.toPlainText(), 'AMOUNT');
      expect(span.children, isNull);
    });

    testWidgets('isRequired: red asterisk appended to the label', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const AppTextField(label: 'Amount', isRequired: true)),
      );
      await tester.pump();

      final TextSpan span = _label(tester).textSpan! as TextSpan;
      expect(span.toPlainText(), 'AMOUNT *');
      // The asterisk span itself is tinted error.main (#DC2626).
      final TextSpan star = span.children!.last as TextSpan;
      expect(star.text, '*');
      expect(star.style!.color, AppColors.errorMain);
    });

    testWidgets('field: scaffold bg, 16px radius, 48px height, 16px h-pad', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const AppTextField()));
      await tester.pump();

      final InputDecoration deco = tester
          .widget<TextField>(find.byType(TextField))
          .decoration!;
      expect(deco.filled, isTrue);
      expect(deco.fillColor, AppColors.scaffold);
      expect(
        (deco.enabledBorder! as OutlineInputBorder).borderRadius,
        BorderRadius.circular(16), // radiusXl
      );
      expect(
        (deco.focusedBorder! as OutlineInputBorder).borderRadius,
        BorderRadius.circular(16),
      );
      final EdgeInsets padding = deco.contentPadding! as EdgeInsets;
      expect(padding.left, AppSpacing.spaceMd);
      expect(padding.right, AppSpacing.spaceMd);

      // Single-line field is exactly the 48px targetMin tall.
      expect(
        tester.getSize(find.byType(TextField)).height,
        AppSpacing.targetMin,
      );

      // Rest state: no visible border (transparent 2px keeps layout stable).
      expect(_renderedBorder(tester).borderSide.color, Colors.transparent);
    });

    testWidgets('input text Body token #0F172A; hint Body token #94A3B8', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const AppTextField(hintText: 'Enter amount')),
      );
      await tester.pump();

      final TextField field = tester.widget<TextField>(find.byType(TextField));
      // Input: Body (14px/w400) in neutral.title.
      expect(field.style!.fontSize, 14);
      expect(field.style!.fontWeight, FontWeight.w400);
      expect(field.style!.color, AppColors.neutralTitle);

      // Placeholder: Body (14px/w400) in neutral.faint.
      final InputDecoration deco = field.decoration!;
      expect(deco.hintStyle!.fontSize, 14);
      expect(deco.hintStyle!.fontWeight, FontWeight.w400);
      expect(deco.hintStyle!.color, AppColors.neutralFaint);
      expect(find.text('Enter amount'), findsOneWidget);
    });

    testWidgets('focus ring: 2px brandPrimary when focused, none at rest', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const AppTextField()));
      await tester.pump();
      // Rest: transparent border.
      expect(_renderedBorder(tester).borderSide.color, Colors.transparent);

      // Focus the field; the border transitions over the theme animation
      // (the cursor keeps scheduling, so fixed pumps instead of settle).
      // First pump applies the focus, second completes the 200ms border
      // transition.
      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Rendered focus ring: 2px in brandPrimary (#1E40AF).
      final InputBorder focused = _renderedBorder(tester);
      expect(focused.borderSide.color, AppColors.brandPrimary);
      expect(focused.borderSide.width, 2);
    });

    testWidgets('error state: 2px #DC2626 border + caption message below', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const AppTextField(errorText: 'Required')));
      await tester.pump();

      final InputDecoration deco = tester
          .widget<TextField>(find.byType(TextField))
          .decoration!;
      // Error border wins in both focus states (2px, error.main).
      expect(
        (deco.errorBorder! as OutlineInputBorder).borderSide.color,
        AppColors.errorMain,
      );
      expect((deco.errorBorder! as OutlineInputBorder).borderSide.width, 2);
      expect(
        (deco.focusedErrorBorder! as OutlineInputBorder).borderSide.color,
        AppColors.errorMain,
      );
      // Rendered border shows the error color even unfocused.
      expect(_renderedBorder(tester).borderSide.color, AppColors.errorMain);

      // Message rendered below the input line (but inside the field's
      // overall box — the decorator reserves space for it), in the Caption
      // token tinted error.text (#B91C1C).
      final Rect inputRect = tester.getRect(
        find
            .descendant(
              of: find.byType(TextField),
              matching: find.byType(EditableText),
            )
            .first,
      );
      final Text errorMessage = tester.widget<Text>(find.text('Required'));
      expect(errorMessage.style!.fontSize, 11);
      expect(errorMessage.style!.fontWeight, FontWeight.w700);
      expect(errorMessage.style!.color, AppColors.errorText);
      final Rect errorRect = tester.getRect(find.text('Required'));
      expect(errorRect.top, greaterThanOrEqualTo(inputRect.bottom));
      expect(
        errorRect.bottom,
        lessThanOrEqualTo(tester.getRect(find.byType(TextField)).bottom),
      );
    });

    testWidgets('prefix/suffix icons (20px, muted) and suffixText render', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const AppTextField(
            prefixIcon: Icons.search,
            suffixIcon: Icons.info_outline,
            suffixText: 'L',
          ),
        ),
      );
      await tester.pump();

      final Icon prefix = tester.widget<Icon>(find.byIcon(Icons.search));
      expect(prefix.size, 20);
      expect(prefix.color, AppColors.neutralMuted);

      final Icon suffix = tester.widget<Icon>(find.byIcon(Icons.info_outline));
      expect(suffix.size, 20);
      expect(suffix.color, AppColors.neutralMuted);

      final InputDecoration deco = tester
          .widget<TextField>(find.byType(TextField))
          .decoration!;
      expect(deco.suffixText, 'L');
      expect(deco.suffixStyle!.fontSize, 14);
      expect(deco.suffixStyle!.color, AppColors.neutralMuted);
    });

    testWidgets('onChanged fires and the controller receives input', (
      tester,
    ) async {
      final TextEditingController controller = TextEditingController();
      String? changed;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                AppTextField(
                  controller: controller,
                  onChanged: (String value) => setState(() => changed = value),
                ),
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), '250');
      await tester.pump();
      expect(controller.text, '250');
      expect(changed, '250');
    });

    testWidgets('maxLines > 1 grows past 48px with the same styling', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const AppTextField(maxLines: 4)));
      await tester.pump();

      final InputDecoration deco = tester
          .widget<TextField>(find.byType(TextField))
          .decoration!;
      expect(deco.fillColor, AppColors.scaffold);
      expect(
        (deco.enabledBorder! as OutlineInputBorder).borderRadius,
        BorderRadius.circular(16),
      );
      expect(tester.getSize(find.byType(TextField)).height, greaterThan(48));
    });
  });
}
