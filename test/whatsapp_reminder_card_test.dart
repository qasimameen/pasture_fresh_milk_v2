import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/models/customer.dart';
import 'package:pasture_fresh_milk/screens/payments/widgets/whatsapp_reminder_card.dart';

void main() {
  Widget buildWrapper({
    required Widget child,
    Locale locale = const Locale('en'),
  }) {
    return MaterialApp(
      locale: locale,
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('WhatsAppReminderCard (Milestone C-M12)', () {
    final now = DateTime(2026, 9, 13);
    final customer = Customer(
      id: 'c_overdue',
      name: 'Usman Ghani',
      phone: '03001234567',
      address: 'House 4, Street 2',

      dailyQuotaAm: 2.0,
      agreedRate: 220.0,
      status: 'active',
      currentDue: 3500.0,
      advanceBalance: 0.0,
      createdAt: now.subtract(const Duration(days: 10)),
      updatedAt: now.subtract(const Duration(days: 4)),
    );

    testWidgets('renders customer name, phone, due balance, and overdue badge', (tester) async {
      await tester.pumpWidget(
        buildWrapper(
          child: WhatsAppReminderCard(
            customer: customer,
            daysOverdue: 4,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Usman Ghani'), findsOneWidget);
      expect(find.text('03001234567'), findsOneWidget);
      expect(find.text('U'), findsOneWidget); // Initials
      expect(find.text('4d overdue'), findsOneWidget);
      expect(find.text('Rs. 3500'), findsOneWidget);
      expect(find.text('Send Reminder'), findsOneWidget);
      expect(find.text('+ Log Cash Received'), findsOneWidget);
    });

    testWidgets('tapping Send Reminder fires onSendReminder callback', (tester) async {
      bool reminderTapped = false;

      await tester.pumpWidget(
        buildWrapper(
          child: WhatsAppReminderCard(
            customer: customer,
            onSendReminder: () => reminderTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('send_reminder_btn')));
      await tester.pumpAndSettle();

      expect(reminderTapped, isTrue);
    });

    testWidgets('tapping + Log Cash Received fires onLogCash callback', (tester) async {
      bool logCashTapped = false;

      await tester.pumpWidget(
        buildWrapper(
          child: WhatsAppReminderCard(
            customer: customer,
            onLogCash: () => logCashTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('log_cash_btn')));
      await tester.pumpAndSettle();

      expect(logCashTapped, isTrue);

    });

    testWidgets('renders in Urdu locale with RTL without errors', (tester) async {
      await tester.pumpWidget(
        buildWrapper(
          locale: const Locale('ur'),
          child: WhatsAppReminderCard(
            customer: customer,
            daysOverdue: 3,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Usman Ghani'), findsOneWidget);
      expect(find.text('Rs. 3500'), findsOneWidget);
      expect(find.textContaining('3'), findsWidgets);
    });
  });
}
