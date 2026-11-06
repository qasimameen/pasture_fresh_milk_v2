// B-M12 rendering verification for AppDropdown (plan.md B-M12).
//
// Confirms the closed field mirrors AppTextField's styling (label, value /
// hint, 48px scaffold surface with 16px radius, chevron), the error state
// (2px #DC2626 border + caption message), the isRequired asterisk, the
// bottom-sheet picker (opened on tap, listing all items with the label as
// title), selection firing onChanged and closing the sheet, and the
// selected item being visually indicated.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pasture_fresh_milk/core/theme/app_colors.dart';
import 'package:pasture_fresh_milk/core/theme/app_spacing.dart';
import 'package:pasture_fresh_milk/widgets/app_bottom_sheet.dart';
import 'package:pasture_fresh_milk/widgets/app_dropdown.dart';

const List<String> _kItems = <String>['Cow Milk', 'Buffalo Milk', 'Blend'];

Widget _app(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

AppDropdown<String> _dropdown({
  String? label,
  String? hint = 'Choose product',
  String? value,
  ValueChanged<String>? onChanged,
  String? errorText,
  bool isRequired = false,
}) {
  return AppDropdown<String>(
    label: label,
    hintText: hint,
    value: value,
    items: _kItems,
    itemLabelBuilder: (String item) => item,
    onChanged: onChanged,
    errorText: errorText,
    isRequired: isRequired,
  );
}

/// Opens the picker by tapping the closed field.
Future<void> _openPicker(WidgetTester tester) async {
  await tester.tap(find.byType(AppDropdown<String>));
  await tester.pumpAndSettle();
}

/// The closed field's surface container — the only one tinted scaffold.
Container _field(WidgetTester tester) => tester
    .widgetList<Container>(
      find.descendant(
        of: find.byType(AppDropdown<String>),
        matching: find.byType(Container),
      ),
    )
    .where(
      (Container c) =>
          (c.decoration! as BoxDecoration).color == AppColors.scaffold,
    )
    .single;

void main() {
  group('AppDropdown (closed field)', () {
    testWidgets(
      'field: scaffold bg, 16px radius, 48px, 16px h-pad, no border',
      (tester) async {
        await tester.pumpWidget(_app(_dropdown(value: 'Cow Milk')));
        await tester.pump();

        final BoxDecoration deco = _field(tester).decoration! as BoxDecoration;
        expect(deco.color, AppColors.scaffold);
        expect(deco.borderRadius, BorderRadius.circular(16)); // radiusXl
        expect(
          (deco.border! as Border).top.color,
          Colors.transparent, // rest border: none
        );
        final EdgeInsets padding = _field(tester).padding! as EdgeInsets;
        expect(padding.left, AppSpacing.spaceMd);
        expect(padding.right, AppSpacing.spaceMd);
        expect(
          tester.getSize(find.byType(InkWell)).height,
          AppSpacing.targetMin,
        );

        // Trailing chevron — expand_more, 20px, #64748B.
        final Icon chevron = tester.widget<Icon>(
          find.byIcon(Icons.expand_more),
        );
        expect(chevron.size, 20);
        expect(chevron.color, AppColors.neutralMuted);
      },
    );

    testWidgets('label mirrors AppTextField: uppercase caption + asterisk when '
        'required', (tester) async {
      await tester.pumpWidget(_app(_dropdown(label: 'Product')));
      await tester.pump();

      final TextSpan span =
          tester.widget<Text>(find.text('PRODUCT')).textSpan! as TextSpan;
      expect(span.toPlainText(), 'PRODUCT');
      expect(span.style!.fontSize, 11);
      expect(span.style!.fontWeight, FontWeight.w700);
      expect(span.style!.color, AppColors.neutralMuted);
      expect(span.style!.letterSpacing, closeTo(0.04 * 11, 0.001));
      expect(span.children, isNull);

      // Required: red asterisk appended.
      await tester.pumpWidget(
        _app(_dropdown(label: 'Product', isRequired: true)),
      );
      await tester.pump();
      final TextSpan required =
          tester.widget<Text>(find.text('PRODUCT *')).textSpan! as TextSpan;
      expect(required.toPlainText(), 'PRODUCT *');
      final TextSpan star = required.children!.last as TextSpan;
      expect(star.text, '*');
      expect(star.style!.color, AppColors.errorMain);
    });

    testWidgets('value renders via itemLabelBuilder; hint when no value', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_dropdown(value: 'Cow Milk')));
      await tester.pump();

      final Text valueText = tester.widget<Text>(find.text('Cow Milk'));
      expect(valueText.style!.fontSize, 14);
      expect(valueText.style!.fontWeight, FontWeight.w400);
      expect(valueText.style!.color, AppColors.neutralTitle);

      await tester.pumpWidget(_app(_dropdown()));
      await tester.pump();

      final Text hint = tester.widget<Text>(find.text('Choose product'));
      expect(hint.style!.fontSize, 14);
      expect(hint.style!.fontWeight, FontWeight.w400);
      expect(hint.style!.color, AppColors.neutralFaint);
    });

    testWidgets('error state: 2px #DC2626 border + caption message below', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_dropdown(errorText: 'Required')));
      await tester.pump();

      final BoxDecoration deco = _field(tester).decoration! as BoxDecoration;
      expect((deco.border! as Border).top.color, AppColors.errorMain);
      expect((deco.border! as Border).top.width, 2);

      final Text message = tester.widget<Text>(find.text('Required'));
      expect(message.style!.fontSize, 11);
      expect(message.style!.fontWeight, FontWeight.w700);
      expect(message.style!.color, AppColors.errorText);
      expect(
        tester.getRect(find.text('Required')).top,
        greaterThanOrEqualTo(tester.getRect(find.byType(InkWell)).bottom),
      );
    });
  });

  group('AppDropdown (picker sheet)', () {
    testWidgets('tapping the field opens the sheet with all items', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_dropdown(label: 'Product')));
      await tester.pump();

      await _openPicker(tester);

      expect(find.byType(AppBottomSheet), findsOneWidget);
      // Title uses the label (documented choice).
      expect(find.text('Product'), findsOneWidget);
      for (final String item in _kItems) {
        expect(find.text(item), findsOneWidget);
      }
    });

    testWidgets('selecting an item fires onChanged and closes the sheet', (
      tester,
    ) async {
      String? selected;
      await tester.pumpWidget(
        _app(_dropdown(onChanged: (String v) => selected = v)),
      );
      await tester.pump();

      await _openPicker(tester);
      expect(find.byType(AppBottomSheet), findsOneWidget);

      await tester.tap(find.text('Buffalo Milk'));
      await tester.pumpAndSettle();

      // Sheet dismissed; onChanged fired with the selection.
      expect(find.byType(AppBottomSheet), findsNothing);
      expect(selected, 'Buffalo Milk');
    });

    testWidgets('the current selection is visually indicated', (tester) async {
      await tester.pumpWidget(_app(_dropdown(value: 'Cow Milk')));
      await tester.pump();

      await _openPicker(tester);

      // Exactly one check icon — on the selected row — tinted brandPrimary.
      expect(find.byIcon(Icons.check), findsOneWidget);
      final Icon check = tester.widget<Icon>(find.byIcon(Icons.check));
      expect(check.size, 20);
      expect(check.color, AppColors.brandPrimary);

      // Selected row's label is brandPrimary; the others neutralTitle.
      final Text selectedLabel = tester.widget<Text>(
        find.descendant(
          of: find.byType(AppBottomSheet),
          matching: find.text('Cow Milk'),
        ),
      );
      expect(selectedLabel.style!.color, AppColors.brandPrimary);
      final Text otherLabel = tester.widget<Text>(
        find.descendant(
          of: find.byType(AppBottomSheet),
          matching: find.text('Buffalo Milk'),
        ),
      );
      expect(otherLabel.style!.color, AppColors.neutralTitle);
    });

    testWidgets('dismissing the sheet does not fire onChanged', (tester) async {
      String? selected;
      await tester.pumpWidget(
        _app(_dropdown(onChanged: (String v) => selected = v)),
      );
      await tester.pump();

      await _openPicker(tester);
      await tester.tapAt(const Offset(10, 10)); // barrier tap → dismissal
      await tester.pumpAndSettle();

      expect(find.byType(AppBottomSheet), findsNothing);
      expect(selected, isNull);
    });
  });
}
