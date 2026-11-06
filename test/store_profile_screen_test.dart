import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/models/store_profile.dart';
import 'package:pasture_fresh_milk/providers/store_profile_provider.dart';
import 'package:pasture_fresh_milk/repositories/store_profile_repository.dart';
import 'package:pasture_fresh_milk/screens/settings/store_profile_screen.dart';
import 'package:pasture_fresh_milk/widgets/app_snack_bar.dart';

class _FakeStoreProfileRepository implements StoreProfileRepository {
  _FakeStoreProfileRepository(this.profile);

  StoreProfile? profile;
  bool upsertCalled = false;
  StoreProfile? lastUpserted;

  @override
  String get tableName => 'store_profile';

  @override
  StoreProfile fromMap(Map<String, dynamic> map) => StoreProfile.fromMap(map);

  @override
  Map<String, dynamic> toMap(StoreProfile item) => item.toMap();

  @override
  Future<StoreProfile?> getProfile() async => profile;

  @override
  Future<void> upsertProfile(StoreProfile p) async {
    upsertCalled = true;
    lastUpserted = p;
    profile = p;
  }
}

void main() {
  final now = DateTime(2026, 9, 14);
  final testProfile = StoreProfile(
    id: 'prof_1',
    name: 'Al-Madina Dairy Farm',
    phone: '03001234567',
    address: 'Shop #4, Main Bazar',
    createdAt: now,
    updatedAt: now,
  );

  Widget buildHarness({
    required _FakeStoreProfileRepository repo,
    Locale locale = const Locale('en'),
  }) {
    return ProviderScope(
      overrides: [
        storeProfileRepositoryProvider.overrideWithValue(repo),
        storeProfileProvider.overrideWith((ref) async => repo.profile),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const StoreProfileScreen(),
      ),
    );
  }

  group('StoreProfileScreen (C-M16)', () {
    testWidgets('populates fields from existing store profile', (tester) async {
      final repo = _FakeStoreProfileRepository(testProfile);
      await tester.pumpWidget(buildHarness(repo: repo));
      await tester.pumpAndSettle();

      expect(find.text('Al-Madina Dairy Farm'), findsOneWidget);
      expect(find.text('03001234567'), findsOneWidget);
      expect(find.text('Shop #4, Main Bazar'), findsOneWidget);
    });

    testWidgets('shows validation error when store name is blank',
        (tester) async {
      final repo = _FakeStoreProfileRepository(testProfile);
      await tester.pumpWidget(buildHarness(repo: repo));
      await tester.pumpAndSettle();

      // Clear store name
      await tester.enterText(find.widgetWithText(TextField, 'Al-Madina Dairy Farm'), '');
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Store name cannot be empty'), findsOneWidget);
      expect(repo.upsertCalled, isFalse);
    });

    testWidgets('saves updated profile and dismisses', (tester) async {
      final repo = _FakeStoreProfileRepository(testProfile);
      await tester.pumpWidget(buildHarness(repo: repo));
      await tester.pumpAndSettle();

      // Update name & phone
      await tester.enterText(
        find.widgetWithText(TextField, 'Al-Madina Dairy Farm'),
        'Updated Pure Dairy',
      );
      await tester.enterText(
        find.widgetWithText(TextField, '03001234567'),
        '03119876543',
      );
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save Changes'));
      await tester.pump();

      expect(repo.upsertCalled, isTrue);
      expect(repo.lastUpserted?.name, equals('Updated Pure Dairy'));
      expect(repo.lastUpserted?.phone, equals('03119876543'));

      // Dismiss snackbar timer
      AppSnackBar.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('renders cleanly in Urdu locale with RTL', (tester) async {
      final repo = _FakeStoreProfileRepository(testProfile);
      await tester.pumpWidget(buildHarness(repo: repo, locale: const Locale('ur')));
      await tester.pumpAndSettle();

      expect(find.text('دکان کا پروفائل'), findsAtLeastNWidgets(1));
      expect(find.text('دکان کا نام *', findRichText: true), findsOneWidget);
      expect(find.text('دکان کا فون', findRichText: true), findsOneWidget);
      expect(find.text('دکان کا پتہ', findRichText: true), findsOneWidget);
      expect(find.text('تبدیلیاں محفوظ کریں'), findsOneWidget);
    });
  });
}
