// A-M1 smoke test: the app launches and renders the blank shell.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pasture_fresh_milk/app.dart';

void main() {
  testWidgets('App launches without crashing (blank screen)', (tester) async {
    await tester.pumpWidget(const AlMadinaDairyApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    // A-M1 expected state: empty shell, no UI yet.
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
