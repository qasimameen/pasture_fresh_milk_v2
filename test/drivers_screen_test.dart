import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/models/driver.dart';
import 'package:pasture_fresh_milk/models/shift.dart';
import 'package:pasture_fresh_milk/providers/driver_provider.dart';
import 'package:pasture_fresh_milk/providers/shift_provider.dart';
import 'package:pasture_fresh_milk/repositories/driver_repository.dart';
import 'package:pasture_fresh_milk/repositories/shift_repository.dart';
import 'package:pasture_fresh_milk/screens/settings/drivers_screen.dart';
import 'package:pasture_fresh_milk/widgets/app_button.dart';
import 'package:pasture_fresh_milk/widgets/app_snack_bar.dart';

class _FakeDriverRepository implements DriverRepository {
  _FakeDriverRepository(this.drivers);

  final List<Driver> drivers;
  bool insertCalled = false;
  bool updateCalled = false;
  Driver? lastInserted;
  Driver? lastUpdated;

  @override
  String get tableName => 'drivers';

  @override
  Driver fromMap(Map<String, dynamic> map) => Driver.fromMap(map);

  @override
  Map<String, dynamic> toMap(Driver item) => item.toMap();

  @override
  Future<List<Driver>> getAll() async => List.from(drivers);

  @override
  Future<List<Driver>> getActiveDrivers() async =>
      drivers.where((d) => d.isActive).toList();

  @override
  Future<void> insert(Driver item) async {
    insertCalled = true;
    lastInserted = item;
    drivers.add(item);
  }

  @override
  Future<void> update(Driver item) async {
    updateCalled = true;
    lastUpdated = item;
    final index = drivers.indexWhere((d) => d.id == item.id);
    if (index != -1) {
      drivers[index] = item;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeShiftRepository implements ShiftRepository {
  _FakeShiftRepository(this.shifts);

  final List<Shift> shifts;

  @override
  String get tableName => 'shifts';

  @override
  Shift fromMap(Map<String, dynamic> map) => Shift.fromMap(map);

  @override
  Map<String, dynamic> toMap(Shift item) => item.toMap();

  @override
  Future<List<Shift>> getAll() async => List.from(shifts);

  @override
  Future<List<Shift>> getActiveShifts() async =>
      shifts.where((s) => s.isActive).toList();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final now = DateTime(2026, 9, 14);

  final mockDrivers = [
    Driver(
      id: 'd_1',
      name: 'Rashid Khan',
      phone: '03001234567',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ),
    Driver(
      id: 'd_2',
      name: 'Tariq Mehmood',
      phone: '03007654321',
      isActive: false,
      createdAt: now,
      updatedAt: now,
    ),
  ];

  final mockShifts = [
    Shift(
      id: 's_morning',
      name: 'Morning',
      startTime: '05:30',
      endTime: '12:00',
      leadDriverId: 'd_1',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ),
    Shift(
      id: 's_evening',
      name: 'Evening',
      startTime: '16:30',
      endTime: '20:00',
      leadDriverId: null,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ),
  ];

  Widget buildTestWidget({
    required List<Driver> drivers,
    List<Shift>? shifts,
    Locale locale = const Locale('en'),
    _FakeDriverRepository? driverRepo,
    _FakeShiftRepository? shiftRepo,
  }) {
    final dRepo = driverRepo ?? _FakeDriverRepository(drivers);
    final sRepo = shiftRepo ?? _FakeShiftRepository(shifts ?? mockShifts);

    return ProviderScope(
      overrides: [
        driverRepositoryProvider.overrideWithValue(dRepo),
        shiftRepositoryProvider.overrideWithValue(sRepo),
        allDriverListProvider.overrideWith((ref) => dRepo.getAll()),
        driverListProvider.overrideWith((ref) => dRepo.getActiveDrivers()),
        allShiftListProvider.overrideWith((ref) => sRepo.getAll()),
        shiftListProvider.overrideWith((ref) => sRepo.getActiveShifts()),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DriversScreen(),
      ),
    );
  }

  void setTallSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('DriversScreen (C-M19)', () {
    testWidgets('renders driver list with names, phones, and status badges',
        (tester) async {
      setTallSurface(tester);

      await tester.pumpWidget(buildTestWidget(drivers: mockDrivers));
      await tester.pumpAndSettle();

      expect(find.text('Drivers'), findsOneWidget);
      expect(find.text('Rashid Khan'), findsOneWidget);
      expect(find.text('03001234567'), findsOneWidget);
      expect(find.text('Tariq Mehmood'), findsOneWidget);
      expect(find.text('03007654321'), findsOneWidget);

      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Inactive'), findsOneWidget);
      expect(find.text('+ Add Driver'), findsOneWidget);
    });

    testWidgets('tapping + Add Driver FAB opens sheet, enters details, and inserts driver',
        (tester) async {
      setTallSurface(tester);

      final dRepo = _FakeDriverRepository(List.from(mockDrivers));

      await tester.pumpWidget(buildTestWidget(
        drivers: dRepo.drivers,
        driverRepo: dRepo,
      ));
      await tester.pumpAndSettle();

      // Tap FAB
      await tester.tap(find.text('+ Add Driver'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Add Driver'), findsOneWidget);

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Asif Ali');
      await tester.enterText(textFields.at(1), '03009998877');
      await tester.pumpAndSettle();

      final saveBtn = find.widgetWithText(AppButton, 'Save Changes');
      await tester.tap(saveBtn, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(dRepo.insertCalled, isTrue);
      expect(dRepo.lastInserted?.name, 'Asif Ali');
      expect(dRepo.lastInserted?.phone, '03009998877');
      expect(dRepo.lastInserted?.isActive, isTrue);
      expect(find.text('Driver saved successfully'), findsOneWidget);

      AppSnackBar.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('editing existing driver updates driver in repository',
        (tester) async {
      setTallSurface(tester);

      final dRepo = _FakeDriverRepository(List.from(mockDrivers));

      await tester.pumpWidget(buildTestWidget(
        drivers: dRepo.drivers,
        driverRepo: dRepo,
      ));
      await tester.pumpAndSettle();

      // Tap Edit on Rashid Khan (first Edit button)
      final editButtons = find.widgetWithText(AppButton, 'Edit');
      await tester.tap(editButtons.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Edit Driver'), findsOneWidget);

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(1), '03115554433');
      await tester.pumpAndSettle();

      final saveBtn = find.widgetWithText(AppButton, 'Save Changes');
      await tester.tap(saveBtn, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(dRepo.updateCalled, isTrue);
      expect(dRepo.lastUpdated?.phone, '03115554433');
      expect(find.text('Driver saved successfully'), findsOneWidget);

      AppSnackBar.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('cannot deactivate driver when assigned as lead driver to active shift',
        (tester) async {
      setTallSurface(tester);

      final dRepo = _FakeDriverRepository(List.from(mockDrivers));

      await tester.pumpWidget(buildTestWidget(
        drivers: dRepo.drivers,
        shifts: mockShifts, // Morning shift has leadDriverId: 'd_1'
        driverRepo: dRepo,
      ));
      await tester.pumpAndSettle();

      // Tap Deactivate on Rashid Khan (d_1)
      final deactivateBtn = find.widgetWithText(AppButton, 'Deactivate');
      expect(deactivateBtn, findsOneWidget);
      await tester.tap(deactivateBtn, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Deactivation is prevented
      expect(dRepo.updateCalled, isFalse);
      expect(
        find.text(
            'Cannot deactivate: Driver is currently assigned as lead driver to an active shift.'),
        findsOneWidget,
      );

      AppSnackBar.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('deactivating driver with no active lead assignment asks confirmation and deactivates',
        (tester) async {
      setTallSurface(tester);

      final driver3 = Driver(
        id: 'd_3',
        name: 'Usman Ghani',
        phone: '03003332211',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final dRepo = _FakeDriverRepository([driver3]);

      await tester.pumpWidget(buildTestWidget(
        drivers: dRepo.drivers,
        shifts: mockShifts, // No shift assigned to d_3
        driverRepo: dRepo,
      ));
      await tester.pumpAndSettle();

      // Tap Deactivate on Usman Ghani
      final deactivateBtn = find.widgetWithText(AppButton, 'Deactivate');
      await tester.tap(deactivateBtn, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Deactivate Driver'), findsOneWidget);
      expect(
        find.text('Are you sure you want to deactivate "Usman Ghani"?'),
        findsOneWidget,
      );

      final confirmBtn = find.text('Confirm');
      await tester.tap(confirmBtn, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(dRepo.updateCalled, isTrue);
      expect(dRepo.lastUpdated?.isActive, isFalse);
      expect(find.text('Driver deactivated'), findsOneWidget);

      AppSnackBar.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('tapping Activate reactivates an inactive driver',
        (tester) async {
      setTallSurface(tester);

      final dRepo = _FakeDriverRepository(List.from(mockDrivers));

      await tester.pumpWidget(buildTestWidget(
        drivers: dRepo.drivers,
        driverRepo: dRepo,
      ));
      await tester.pumpAndSettle();

      // Tariq Mehmood is inactive, tap Activate
      final activateBtn = find.widgetWithText(AppButton, 'Activate');
      expect(activateBtn, findsOneWidget);
      await tester.tap(activateBtn, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(dRepo.updateCalled, isTrue);
      expect(dRepo.lastUpdated?.id, 'd_2');
      expect(dRepo.lastUpdated?.isActive, isTrue);
      expect(find.text('Driver activated'), findsOneWidget);

      AppSnackBar.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('renders EmptyState when driver list is empty',
        (tester) async {
      setTallSurface(tester);

      await tester.pumpWidget(buildTestWidget(drivers: []));
      await tester.pumpAndSettle();

      expect(find.text('No drivers found'), findsOneWidget);
      expect(find.text('Add delivery personnel and contact numbers.'),
          findsOneWidget);
    });

    testWidgets('renders cleanly in Urdu locale with RTL',
        (tester) async {
      setTallSurface(tester);

      await tester.pumpWidget(buildTestWidget(
        drivers: mockDrivers,
        locale: const Locale('ur'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('ڈرائیورز'), findsOneWidget);
      expect(find.text('+ نیا ڈرائیور شامل کریں'), findsOneWidget);
      expect(find.text('فعال'), findsOneWidget);
      expect(find.text('غیر فعال'), findsOneWidget);
    });
  });
}
