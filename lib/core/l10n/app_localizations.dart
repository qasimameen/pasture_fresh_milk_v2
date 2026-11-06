import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  /// Bottom navigation label for Home dashboard
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation label for Customers directory
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get navCustomers;

  /// Bottom navigation label for Today's Deliveries
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get navDeliveries;

  /// Bottom navigation label for Payments & Accounts
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get navPayments;

  /// Bottom navigation label for Suppliers & Procurement
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get navSuppliers;

  /// Store status badge label
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get storeStatusActive;

  /// Default store name fallback
  ///
  /// In en, this message translates to:
  /// **'Al-Madina Dairy'**
  String get storeDefaultName;

  /// Pill indicating active shift
  ///
  /// In en, this message translates to:
  /// **'{shift} Active'**
  String shiftActivePill(String shift);

  /// Morning shift name
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get shiftMorning;

  /// Evening shift name
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get shiftEvening;

  /// Link button text to go to deliveries
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get deliveriesNav;

  /// Progress label for completed vs total deliveries
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} delivered'**
  String deliveriesProgress(int completed, int total);

  /// Remaining deliveries badge
  ///
  /// In en, this message translates to:
  /// **'{count} Remaining'**
  String statusRemaining(int count);

  /// Skipped deliveries badge
  ///
  /// In en, this message translates to:
  /// **'{count} Skipped'**
  String statusSkipped(int count);

  /// Label for Total Customers metric
  ///
  /// In en, this message translates to:
  /// **'Total Customers'**
  String get kpiTotalCustomers;

  /// Subtitle showing active customer count
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String kpiActiveSubtitle(int count);

  /// Label for Total Dues metric
  ///
  /// In en, this message translates to:
  /// **'Total Dues'**
  String get kpiTotalDues;

  /// Subtitle showing overdue count
  ///
  /// In en, this message translates to:
  /// **'{count} overdue'**
  String kpiOverdueSubtitle(int count);

  /// Label for Daily Sell metric
  ///
  /// In en, this message translates to:
  /// **'Daily Sell'**
  String get kpiDailySell;

  /// Subtitle for Daily Sell metric
  ///
  /// In en, this message translates to:
  /// **'Morning + Evening Quota'**
  String get kpiDailySellSubtitle;

  /// Label for Monthly Sell metric
  ///
  /// In en, this message translates to:
  /// **'Monthly Sell'**
  String get kpiMonthlySell;

  /// Subtitle showing month-over-month growth percent
  ///
  /// In en, this message translates to:
  /// **'{percent}% vs last month'**
  String kpiGrowthSubtitle(String percent);

  /// Label for Today's Cash metric
  ///
  /// In en, this message translates to:
  /// **'Today\'s Cash'**
  String get kpiTodayCash;

  /// Subtitle for Today's Cash metric
  ///
  /// In en, this message translates to:
  /// **'Rider & counter inflow'**
  String get kpiTodayCashSubtitle;

  /// Label for Advance Held metric
  ///
  /// In en, this message translates to:
  /// **'Advance Held'**
  String get kpiAdvanceHeld;

  /// Subtitle showing prepaid customers count
  ///
  /// In en, this message translates to:
  /// **'{count} prepaid'**
  String kpiPrepaidSubtitle(int count);

  /// Label for Monthly Collection banner
  ///
  /// In en, this message translates to:
  /// **'Monthly Collection'**
  String get monthlyCollection;

  /// Monthly collection percent of target
  ///
  /// In en, this message translates to:
  /// **'{percent}% of target'**
  String monthlyTargetSubtitle(String percent);

  /// Header for Local Counter Sales section
  ///
  /// In en, this message translates to:
  /// **'Counter Sales'**
  String get localSalesTitle;

  /// Totals for today's counter sales
  ///
  /// In en, this message translates to:
  /// **'Today: {litres} L • Rs. {amount}'**
  String todayTotals(String litres, String amount);

  /// Quick-tap sale button label
  ///
  /// In en, this message translates to:
  /// **'+{litres}L'**
  String quickSaleButton(String litres);

  /// Button to open custom quick sale dialog or bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Add Quick Sale (Custom Quantity / Cash)'**
  String get quickSaleCustomCta;

  /// Display for most recent sale
  ///
  /// In en, this message translates to:
  /// **'Last: {litres}L • Rs. {amount}'**
  String lastSaleLabel(String litres, String amount);

  /// Undo action button text
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoAction;

  /// Snackbar message on recording a quick sale
  ///
  /// In en, this message translates to:
  /// **'{litres}L sale recorded'**
  String quickSaleSuccess(String litres);

  /// Snackbar message when last sale is undone
  ///
  /// In en, this message translates to:
  /// **'Sale undone'**
  String get saleUndone;

  /// Title for Delivery Schedule Overview section
  ///
  /// In en, this message translates to:
  /// **'Delivery Schedule'**
  String get deliveryScheduleTitle;

  /// Departure time label
  ///
  /// In en, this message translates to:
  /// **'Departure: {time}'**
  String departureTime(String time);

  /// Start time label
  ///
  /// In en, this message translates to:
  /// **'Start: {time}'**
  String startTime(String time);

  /// Order count display
  ///
  /// In en, this message translates to:
  /// **'{count} Orders'**
  String orderCount(int count);

  /// Crates status label
  ///
  /// In en, this message translates to:
  /// **'Crates: {status}'**
  String crateStatus(String status);

  /// Crates ready status
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get cratesReady;

  /// Crates pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get cratesPending;

  /// Retry button label on failure
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Error banner message when dashboard fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load dashboard data'**
  String get loadFailed;

  /// Title of quick sale bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Quick Counter Sale'**
  String get quickSaleTitle;

  /// Product or milk type selection label
  ///
  /// In en, this message translates to:
  /// **'Product / Milk Type'**
  String get milkType;

  /// Quantity field label
  ///
  /// In en, this message translates to:
  /// **'Quantity (Litres)'**
  String get quantityLitres;

  /// Label for quick quantity chips
  ///
  /// In en, this message translates to:
  /// **'Quick Quantity ({unit})'**
  String quickQuantity(String unit);

  /// Label for quick amount chips
  ///
  /// In en, this message translates to:
  /// **'Quick Amount (Rs.)'**
  String get quickAmount;

  /// Rate field label
  ///
  /// In en, this message translates to:
  /// **'Rate per Litre'**
  String get ratePerLitre;

  /// Total calculated amount label
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// Button label to submit quick sale
  ///
  /// In en, this message translates to:
  /// **'Record Sale'**
  String get recordSale;

  /// Confirmation message after recording custom quick sale
  ///
  /// In en, this message translates to:
  /// **'Sale recorded successfully'**
  String get saleRecorded;

  /// Validation error for quantity
  ///
  /// In en, this message translates to:
  /// **'Enter a valid quantity greater than 0'**
  String get errorInvalidQuantity;

  /// Validation error for rate
  ///
  /// In en, this message translates to:
  /// **'Enter a valid rate greater than 0'**
  String get errorInvalidRate;

  /// Validation error for product
  ///
  /// In en, this message translates to:
  /// **'Please select a product'**
  String get errorSelectProduct;

  /// Title of the Customers screen
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customersTitle;

  /// Customer count display
  ///
  /// In en, this message translates to:
  /// **'{count} Customers'**
  String customersCount(int count);

  /// Label for total customers stat
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalStatLabel;

  /// Label for with dues stat
  ///
  /// In en, this message translates to:
  /// **'With Dues'**
  String get withDuesStatLabel;

  /// Label for on advance stat
  ///
  /// In en, this message translates to:
  /// **'On Advance'**
  String get onAdvanceStatLabel;

  /// Filter chip: all customers
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Filter chip: customers with dues
  ///
  /// In en, this message translates to:
  /// **'Has Dues'**
  String get filterHasDues;

  /// Filter chip: customers on advance
  ///
  /// In en, this message translates to:
  /// **'On Advance'**
  String get filterOnAdvance;

  /// Filter chip: morning deliveries
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get filterMorning;

  /// Filter chip: evening deliveries
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get filterEvening;

  /// Search input hint in customers directory
  ///
  /// In en, this message translates to:
  /// **'Search by name, phone, area...'**
  String get searchCustomersHint;

  /// Search input hint in suppliers directory
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone...'**
  String get searchSuppliersHint;

  /// Search input hint in transactions feed
  ///
  /// In en, this message translates to:
  /// **'Search by name or note...'**
  String get searchTransactionsHint;

  /// Morning quota prefix
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get quotaAmLabel;

  /// Evening quota prefix
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get quotaPmLabel;

  /// Rate suffix per litre
  ///
  /// In en, this message translates to:
  /// **'Rs/L'**
  String get ratePerLitreSuffix;

  /// Financial balance label for customer with dues
  ///
  /// In en, this message translates to:
  /// **'Due: Rs. {amount}'**
  String dueBalanceLabel(String amount);

  /// Financial balance label for customer on advance
  ///
  /// In en, this message translates to:
  /// **'Advance: Rs. {amount}'**
  String advanceBalanceLabel(String amount);

  /// Financial balance label for customer with zero balance
  ///
  /// In en, this message translates to:
  /// **'Cleared: Rs. 0'**
  String get clearedBalanceLabel;

  /// Action button to record a payment
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPaymentAction;

  /// Action button to add prepaid credit
  ///
  /// In en, this message translates to:
  /// **'Add Recharge'**
  String get addRechargeAction;

  /// Action button to resume delivery supply
  ///
  /// In en, this message translates to:
  /// **'Resume Supply'**
  String get resumeSupplyAction;

  /// Snackbar message when supply is resumed
  ///
  /// In en, this message translates to:
  /// **'Supply resumed for {name}'**
  String supplyResumedMessage(String name);

  /// Action button to view customer ledger
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get ledgerAction;

  /// Floating action button label to add a customer
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomerFab;

  /// Empty state title when no customers match
  ///
  /// In en, this message translates to:
  /// **'No customers found'**
  String get noCustomersFound;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filter'**
  String get noCustomersMatching;

  /// Button to reset search and filters
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFiltersAction;

  /// Sheet title when creating a customer
  ///
  /// In en, this message translates to:
  /// **'Add New Customer'**
  String get addCustomerTitle;

  /// Sheet title when editing a customer
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get editCustomerTitle;

  /// Label for customer name input
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerNameLabel;

  /// Label for customer phone input
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get customerPhoneLabel;

  /// Label for customer address input
  ///
  /// In en, this message translates to:
  /// **'Address / House #'**
  String get customerAddressLabel;

  /// Label for delivery sequence order
  ///
  /// In en, this message translates to:
  /// **'Delivery Sequence'**
  String get deliverySequenceLabel;

  /// Label for morning quota input
  ///
  /// In en, this message translates to:
  /// **'Morning Quota (Litres)'**
  String get dailyQuotaAmLabel;

  /// Label for evening quota input
  ///
  /// In en, this message translates to:
  /// **'Evening Quota (Litres)'**
  String get dailyQuotaPmLabel;

  /// Label for agreed rate input
  ///
  /// In en, this message translates to:
  /// **'Agreed Rate per Litre'**
  String get agreedRateLabel;

  /// Label for customer notes input
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesLabel;

  /// Button label to save edits
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesAction;

  /// Confirmation message after adding customer
  ///
  /// In en, this message translates to:
  /// **'Customer added successfully'**
  String get customerAddedMessage;

  /// Confirmation message after updating customer
  ///
  /// In en, this message translates to:
  /// **'Customer updated successfully'**
  String get customerUpdatedMessage;

  /// Validation error when customer name is empty
  ///
  /// In en, this message translates to:
  /// **'Customer name is required'**
  String get errorNameRequired;

  /// Validation error when phone number is empty
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get errorPhoneRequired;

  /// Validation error when phone number exceeds 11 digits
  ///
  /// In en, this message translates to:
  /// **'Phone number cannot be more than 11 digits'**
  String get errorPhoneTooLong;

  /// Validation error when both morning and evening quotas are zero
  ///
  /// In en, this message translates to:
  /// **'At least one quota (AM or PM) must be greater than 0'**
  String get errorQuotaRequired;

  /// Screen title for Customer Detail
  ///
  /// In en, this message translates to:
  /// **'Customer Profile'**
  String get customerDetailTitle;

  /// Action button label to edit customer profile
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileAction;

  /// Label for due balance card
  ///
  /// In en, this message translates to:
  /// **'Payable Balance'**
  String get payableBalanceLabel;

  /// Label for advance balance card
  ///
  /// In en, this message translates to:
  /// **'Prepaid Reserve'**
  String get prepaidReserveLabel;

  /// Section header for customer delivery preferences
  ///
  /// In en, this message translates to:
  /// **'Delivery Preferences'**
  String get deliveryPreferencesTitle;

  /// Tab title for customer ledger
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get tabAdvanceLedger;

  /// Tab title for customer delivery history
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get tabDeliveryHistory;

  /// Tab title for customer payment history
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get tabPaymentHistory;

  /// Button to record payment from customer
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPaymentCta;

  /// Button to add advance topup for customer
  ///
  /// In en, this message translates to:
  /// **'Add Topup'**
  String get addTopupCta;

  /// Button to share customer bill or ledger statement
  ///
  /// In en, this message translates to:
  /// **'Share Bill'**
  String get shareBillCta;

  /// Button to share details
  ///
  /// In en, this message translates to:
  /// **'Share Details'**
  String get shareDetailsAction;

  /// CTA button in sticky bottom bar on customer detail screen
  ///
  /// In en, this message translates to:
  /// **'Collect Payment'**
  String get collectPaymentBottomBar;

  /// Empty state message when customer has no delivery history
  ///
  /// In en, this message translates to:
  /// **'No deliveries recorded yet'**
  String get noDeliveriesRecorded;

  /// Empty state message when customer has no payment history
  ///
  /// In en, this message translates to:
  /// **'No payments recorded yet'**
  String get noPaymentsRecorded;

  /// Error message when customer does not exist
  ///
  /// In en, this message translates to:
  /// **'Customer not found'**
  String get customerNotFound;

  /// Call action button label
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callAction;

  /// Section title for customer ledger list
  ///
  /// In en, this message translates to:
  /// **'Transactions & Ledger'**
  String get transactionsAndLedgerTitle;

  /// Badge label for delivery debit charge
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get ledgerDebitBadge;

  /// Badge label for payment received
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get ledgerPaidBadge;

  /// Badge label for advance balance credit
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get ledgerCreditBadge;

  /// Badge label for settled or cleared transaction
  ///
  /// In en, this message translates to:
  /// **'Cleared'**
  String get ledgerClearedBadge;

  /// Running balance note showing customer dues after transaction
  ///
  /// In en, this message translates to:
  /// **'Dues after charge: Rs. {amount}'**
  String duesAfterChargeLabel(String amount);

  /// Running balance note showing customer advance reserve after transaction
  ///
  /// In en, this message translates to:
  /// **'Advance reserve: Rs. {amount}'**
  String advanceReserveLabel(String amount);

  /// Ledger entry title for cash payment
  ///
  /// In en, this message translates to:
  /// **'Cash Payment Received'**
  String get cashPaymentTitle;

  /// Ledger entry title for Raast payment
  ///
  /// In en, this message translates to:
  /// **'Raast Payment Received'**
  String get raastPaymentTitle;

  /// Ledger entry title for bank transfer payment
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer Received'**
  String get bankPaymentTitle;

  /// Ledger entry title for advance topup
  ///
  /// In en, this message translates to:
  /// **'Advance Topup'**
  String get advanceTopupTitle;

  /// Ledger entry title for advance deduction
  ///
  /// In en, this message translates to:
  /// **'Advance Deduction'**
  String get advanceDeductionTitle;

  /// Ledger entry title for auto settlement
  ///
  /// In en, this message translates to:
  /// **'Auto Settlement'**
  String get autoSettlementTitle;

  /// Ledger entry title for morning delivery
  ///
  /// In en, this message translates to:
  /// **'Morning Delivery {quantity}L'**
  String morningDeliveryTitle(String quantity);

  /// Ledger entry title for evening delivery
  ///
  /// In en, this message translates to:
  /// **'Evening Delivery {quantity}L'**
  String eveningDeliveryTitle(String quantity);

  /// Empty state title when customer has no ledger entries
  ///
  /// In en, this message translates to:
  /// **'No ledger transactions yet'**
  String get noLedgerEntries;

  /// Empty state subtitle when customer has no ledger entries
  ///
  /// In en, this message translates to:
  /// **'Deliveries, payments and adjustments will appear here.'**
  String get noLedgerEntriesSubtitle;

  /// Button to load more ledger transactions
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMoreEntries;

  /// Section header for the delivery history tab
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get deliveryHistoryTitle;

  /// Empty state subtitle when customer has no delivery history
  ///
  /// In en, this message translates to:
  /// **'Deliveries for this customer will appear here.'**
  String get deliveryHistoryEmptySubtitle;

  /// Status badge label for a completed delivery
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get deliveryStatusDelivered;

  /// Status badge label for a skipped delivery
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get deliveryStatusSkipped;

  /// Status badge label for a pending delivery
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get deliveryStatusPending;

  /// Section header for the payment history tab
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistoryTitle;

  /// Empty state subtitle when customer has no payment history
  ///
  /// In en, this message translates to:
  /// **'Payments collected for this customer will appear here.'**
  String get paymentHistoryEmptySubtitle;

  /// Payment card title for cash payment type
  ///
  /// In en, this message translates to:
  /// **'Cash Payment'**
  String get paymentTypeCashPayment;

  /// Payment card title for advance topup type
  ///
  /// In en, this message translates to:
  /// **'Advance Topup'**
  String get paymentTypeAdvanceTopup;

  /// Method badge label for cash payment
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentMethodCash;

  /// Method badge label for Raast digital payment
  ///
  /// In en, this message translates to:
  /// **'Raast'**
  String get paymentMethodRaast;

  /// Method badge label for bank transfer
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get paymentMethodBank;

  /// Modal title for recording payment
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPaymentModalTitle;

  /// Modal title for adding advance topup
  ///
  /// In en, this message translates to:
  /// **'Add Advance Topup'**
  String get addTopupModalTitle;

  /// Segment tab to pay existing customer dues
  ///
  /// In en, this message translates to:
  /// **'Pay Dues'**
  String get paymentModeDues;

  /// Segment tab to add prepaid advance balance
  ///
  /// In en, this message translates to:
  /// **'Advance Topup'**
  String get paymentModeAdvance;

  /// Label for payment amount input field
  ///
  /// In en, this message translates to:
  /// **'Amount (Rs.)'**
  String get amountLabel;

  /// Quick chip to pay full outstanding dues
  ///
  /// In en, this message translates to:
  /// **'Pay Full: Rs. {amount}'**
  String payFullDueShortcut(String amount);

  /// Label for receipt or Raast reference input
  ///
  /// In en, this message translates to:
  /// **'Receipt / Ref Number (Optional)'**
  String get receiptRefLabel;

  /// Label for optional notes field
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptionalLabel;

  /// Validation error when payment amount is empty or zero
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount greater than 0'**
  String get errorAmountRequired;

  /// Snackbar message when payment is recorded
  ///
  /// In en, this message translates to:
  /// **'Payment of Rs. {amount} recorded'**
  String paymentRecordedSuccess(String amount);

  /// Snackbar message when advance topup is added
  ///
  /// In en, this message translates to:
  /// **'Topup of Rs. {amount} added'**
  String topupRecordedSuccess(String amount);

  /// Formatted WhatsApp text statement for bill sharing
  ///
  /// In en, this message translates to:
  /// **'Al-Madina Dairy Statement\nCustomer: {customer}\nPayable Dues: Rs. {dues}\nAdvance Balance: Rs. {advance}'**
  String shareBillMessage(String customer, String dues, String advance);

  /// Title of the main deliveries screen
  ///
  /// In en, this message translates to:
  /// **'Today\'s Deliveries'**
  String get deliveriesTitle;

  /// Bulk action button to mark deliveries
  ///
  /// In en, this message translates to:
  /// **'Mark All'**
  String get markAllAction;

  /// Hint text for deliveries search bar
  ///
  /// In en, this message translates to:
  /// **'Search by customer, phone, house #...'**
  String get searchDeliveriesHint;

  /// Title when no deliveries match filters or criteria
  ///
  /// In en, this message translates to:
  /// **'No deliveries found'**
  String get noDeliveriesFound;

  /// Subtitle when no deliveries match filters
  ///
  /// In en, this message translates to:
  /// **'Try adjusting date, shift, or search filter.'**
  String get noDeliveriesMatching;

  /// Button to mark a delivery as delivered
  ///
  /// In en, this message translates to:
  /// **'Deliver'**
  String get deliverAction;

  /// Button to skip a delivery
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipAction;

  /// Title of the delivery confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm Delivery'**
  String get confirmDeliverTitle;

  /// Body of the delivery confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Deliver {qty}L to this customer for Rs. {amount}?'**
  String confirmDeliverBody(String qty, String amount);

  /// Generic confirm button label
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmAction;

  /// Generic cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// Hint text for skip reason input
  ///
  /// In en, this message translates to:
  /// **'Reason for skipping (e.g. customer away)'**
  String get skipReasonHint;

  /// Title of the skip reason dialog
  ///
  /// In en, this message translates to:
  /// **'Skip Delivery'**
  String get skipDeliveryTitle;

  /// Validation error when skip reason is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason for skipping'**
  String get errorSkipReasonRequired;

  /// Title of Mark All confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Mark All Delivered'**
  String get markAllConfirmTitle;

  /// Body of Mark All confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This will mark all {count} pending deliveries as delivered (cash payment).'**
  String markAllConfirmBody(int count);

  /// Snackbar when a delivery is marked delivered
  ///
  /// In en, this message translates to:
  /// **'Delivery marked as delivered'**
  String get deliveredSuccess;

  /// Snackbar when a delivery is skipped
  ///
  /// In en, this message translates to:
  /// **'Delivery skipped'**
  String get skippedSuccess;

  /// Snackbar when a delivery is undone back to pending
  ///
  /// In en, this message translates to:
  /// **'Delivery reset to pending'**
  String get deliveryResetSuccess;

  /// Snackbar after Mark All completes
  ///
  /// In en, this message translates to:
  /// **'All deliveries marked as delivered'**
  String get markAllSuccess;

  /// Snackbar when auto-generation creates deliveries
  ///
  /// In en, this message translates to:
  /// **'Today\'s deliveries generated'**
  String get deliveriesGeneratedSuccess;

  /// Payment method chip: cash on delivery
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentMethodCashLabel;

  /// Payment method chip: add to dues
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get paymentMethodCreditLabel;

  /// Payment method chip: deduct from advance
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get paymentMethodAdvanceLabel;

  /// Label for payment method selector in deliver dialog
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get selectPaymentMethod;

  /// Title of the Payments & Accounts screen
  ///
  /// In en, this message translates to:
  /// **'Payments & Accounts'**
  String get paymentsTitle;

  /// KPI tile label for today's total inflow
  ///
  /// In en, this message translates to:
  /// **'Today\'s Inflow'**
  String get todayInflowKpi;

  /// KPI tile label for cash in hand
  ///
  /// In en, this message translates to:
  /// **'Cash in Hand'**
  String get cashInHandKpi;

  /// Subtitle note under Cash in Hand KPI
  ///
  /// In en, this message translates to:
  /// **'Counter verified'**
  String get counterVerifiedNote;

  /// KPI tile label for total customer dues
  ///
  /// In en, this message translates to:
  /// **'Customer Dues'**
  String get customerDuesKpi;

  /// KPI tile label for amounts payable to suppliers
  ///
  /// In en, this message translates to:
  /// **'Dairy Payables'**
  String get dairyPayablesKpi;

  /// Full-width CTA button on Payments screen
  ///
  /// In en, this message translates to:
  /// **'+ Record Payment In / Out'**
  String get recordPaymentInOutCta;

  /// Section header for WhatsApp reminder cards
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Reminders'**
  String get whatsappRemindersTitle;

  /// Button to send WhatsApp payment reminder
  ///
  /// In en, this message translates to:
  /// **'Send Reminder'**
  String get sendReminderAction;

  /// Button to open payment sheet from reminder card
  ///
  /// In en, this message translates to:
  /// **'+ Log Cash Received'**
  String get logCashReceivedAction;

  /// Badge showing how many days overdue a customer is
  ///
  /// In en, this message translates to:
  /// **'{days}d overdue'**
  String overdueLabel(int days);

  /// Filter chip: customer payment collections
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get filterCollections;

  /// Filter chip: supplier outflows / payables
  ///
  /// In en, this message translates to:
  /// **'Payables'**
  String get filterPayables;

  /// Section header above the unified transaction feed
  ///
  /// In en, this message translates to:
  /// **'Today\'s Transactions & Ledgers'**
  String get transactionsHeader;

  /// Static live sync indicator pill
  ///
  /// In en, this message translates to:
  /// **'LIVE SYNC'**
  String get liveSyncLabel;

  /// Transaction feed card type: customer payment received
  ///
  /// In en, this message translates to:
  /// **'Customer Collection'**
  String get txCustomerCollection;

  /// Transaction feed card type: advance balance topup
  ///
  /// In en, this message translates to:
  /// **'Advance Deposit'**
  String get txAdvanceDeposit;

  /// Transaction feed card type: payment sent to supplier
  ///
  /// In en, this message translates to:
  /// **'Supplier Outflow'**
  String get txSupplierOutflow;

  /// Transaction feed card type: walk-in counter sale
  ///
  /// In en, this message translates to:
  /// **'Counter Retail'**
  String get txCounterRetail;

  /// Empty state when transaction feed is empty
  ///
  /// In en, this message translates to:
  /// **'No transactions today'**
  String get noTransactionsFound;

  /// Empty state subtitle for transaction feed
  ///
  /// In en, this message translates to:
  /// **'Payments, deliveries, and sales will appear here.'**
  String get noTransactionsSubtitle;

  /// Empty state when no customers have dues
  ///
  /// In en, this message translates to:
  /// **'No overdue customers'**
  String get noOverdueCustomers;

  /// Badge label on supplier outflow transaction cards
  ///
  /// In en, this message translates to:
  /// **'Supplier Outflow'**
  String get supplierPaymentBadge;

  /// Badge label on advance deposit transaction cards
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get advanceBadge;

  /// Badge label on cleared collection transaction cards
  ///
  /// In en, this message translates to:
  /// **'Cleared'**
  String get clearedBadge;

  /// Badge label on counter retail transaction cards
  ///
  /// In en, this message translates to:
  /// **'Daily Retail'**
  String get dailyRetailBadge;

  /// App bar title on suppliers screen
  ///
  /// In en, this message translates to:
  /// **'Suppliers & Procurement'**
  String get suppliersScreenTitle;

  /// KPI metric title for milk collected today
  ///
  /// In en, this message translates to:
  /// **'Milk Received'**
  String get totalMilkInwardKpi;

  /// KPI metric title for supplier payables today
  ///
  /// In en, this message translates to:
  /// **'Today\'s Payable'**
  String get todayPayableKpi;

  /// Average rate subtitle on payable KPI
  ///
  /// In en, this message translates to:
  /// **'Avg rate'**
  String get avgRateSubtitle;

  /// Section header above supplier cards
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliersSectionTitle;

  /// Farm count badge in suppliers section header
  ///
  /// In en, this message translates to:
  /// **'{count} Farms'**
  String farmsCountBadge(int count);

  /// Filter chip for suppliers with pending khata
  ///
  /// In en, this message translates to:
  /// **'Pending Khata'**
  String get filterPendingKhata;

  /// Log drop action button on awaiting supplier card
  ///
  /// In en, this message translates to:
  /// **'Log Drop'**
  String get logDropAction;

  /// Pay cash action button on supplier card
  ///
  /// In en, this message translates to:
  /// **'Pay Cash'**
  String get payCashAction;

  /// View khata action button on supplier card
  ///
  /// In en, this message translates to:
  /// **'View Khata'**
  String get viewKhataAction;

  /// Pending khata label on supplier card
  ///
  /// In en, this message translates to:
  /// **'Pending Khata'**
  String get pendingKhataLabel;

  /// Advance payment label on supplier card
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get advanceLabel;

  /// All khata cleared label on supplier card
  ///
  /// In en, this message translates to:
  /// **'All Khata Cleared'**
  String get allClearedKhataLabel;

  /// Quantity column header in metrics grid
  ///
  /// In en, this message translates to:
  /// **'QTY'**
  String get qtyLabel;

  /// Rate per litre column header in metrics grid
  ///
  /// In en, this message translates to:
  /// **'RATE/L'**
  String get ratePerLitreLabel;

  /// Batch value label on supplier card
  ///
  /// In en, this message translates to:
  /// **'Batch Value'**
  String get batchValueLabel;

  /// Empty state title when no suppliers match filter
  ///
  /// In en, this message translates to:
  /// **'No suppliers found'**
  String get noSuppliersFound;

  /// Empty state subtitle for suppliers list
  ///
  /// In en, this message translates to:
  /// **'Suppliers and their incoming milk batches will appear here.'**
  String get noSuppliersSubtitle;

  /// Title of pay supplier cash modal sheet
  ///
  /// In en, this message translates to:
  /// **'Pay Supplier Cash'**
  String get paySupplierModalTitle;

  /// Label for pending khata amount owed to supplier
  ///
  /// In en, this message translates to:
  /// **'Pending Khata Owed'**
  String get amountOwedLabel;

  /// Modal title for recording inward milk from supplier
  ///
  /// In en, this message translates to:
  /// **'Record Inward Milk'**
  String get recordMilkModalTitle;

  /// Label for milk quantity input in litres
  ///
  /// In en, this message translates to:
  /// **'Quantity (Litres)'**
  String get quantityLitresLabel;

  /// Label for live calculated batch total value
  ///
  /// In en, this message translates to:
  /// **'Calculated Batch Value'**
  String get batchValueCalculatedLabel;

  /// Button to save inward milk batch
  ///
  /// In en, this message translates to:
  /// **'Record Batch'**
  String get recordBatchAction;

  /// Snackbar message when milk batch is recorded
  ///
  /// In en, this message translates to:
  /// **'Inward milk batch recorded successfully'**
  String get batchRecordedSuccess;

  /// Validation error when quantity is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity greater than 0'**
  String get errorQuantityRequired;

  /// Validation error when the selected supplier has no rate configured
  ///
  /// In en, this message translates to:
  /// **'Please set the supplier\'s rate per litre first'**
  String get errorSupplierRateNotSet;

  /// Screen title for supplier khata ledger
  ///
  /// In en, this message translates to:
  /// **'Supplier Khata'**
  String get supplierKhataTitle;

  /// Tab label for milk collection history
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collectionHistoryTab;

  /// Tab label for payments made to supplier
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentsMadeTab;

  /// Empty state title for supplier collections
  ///
  /// In en, this message translates to:
  /// **'No milk collections recorded'**
  String get noCollectionsRecorded;

  /// Empty state subtitle for supplier collections
  ///
  /// In en, this message translates to:
  /// **'Logged milk collections for this supplier will appear here.'**
  String get noCollectionsSubtitle;

  /// Empty state title for supplier payments
  ///
  /// In en, this message translates to:
  /// **'No payments recorded yet'**
  String get noSupplierPaymentsRecorded;

  /// Empty state subtitle for supplier payments
  ///
  /// In en, this message translates to:
  /// **'Cash and bank payments made to this supplier will appear here.'**
  String get noSupplierPaymentsSubtitle;

  /// Label for total milk supplied metric
  ///
  /// In en, this message translates to:
  /// **'Total Milk Supplied'**
  String get totalMilkSupplied;

  /// Litres of milk still to be paid for, shown in the supplier khata banner
  ///
  /// In en, this message translates to:
  /// **'Unpaid milk'**
  String get unpaidMilkLabel;

  /// Button to call supplier phone
  ///
  /// In en, this message translates to:
  /// **'Call Supplier'**
  String get callSupplierAction;

  /// App bar title for the Settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Subtitle on settings screen
  ///
  /// In en, this message translates to:
  /// **'Store configuration and delivery operations'**
  String get settingsSubtitle;

  /// Settings menu item for store profile
  ///
  /// In en, this message translates to:
  /// **'Store Profile'**
  String get settingsStoreProfile;

  /// Subtitle for store profile menu item
  ///
  /// In en, this message translates to:
  /// **'Shop name, contact phone, and address'**
  String get settingsStoreProfileSubtitle;

  /// Settings menu item for products and pricing
  ///
  /// In en, this message translates to:
  /// **'Products & Pricing'**
  String get settingsProductsPricing;

  /// Subtitle for products and pricing menu item
  ///
  /// In en, this message translates to:
  /// **'Manage milk products and rates'**
  String get settingsProductsPricingSubtitle;

  /// Title of the store profile edit screen
  ///
  /// In en, this message translates to:
  /// **'Store Profile'**
  String get storeProfileTitle;

  /// Input label for store name
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get storeNameLabel;

  /// Input label for store phone
  ///
  /// In en, this message translates to:
  /// **'Store Phone'**
  String get storePhoneLabel;

  /// Input label for store address
  ///
  /// In en, this message translates to:
  /// **'Store Address'**
  String get storeAddressLabel;

  /// Snackbar message when store profile is saved
  ///
  /// In en, this message translates to:
  /// **'Store profile saved successfully'**
  String get profileSavedSuccess;

  /// Validation error when store name is blank
  ///
  /// In en, this message translates to:
  /// **'Store name cannot be empty'**
  String get errorStoreNameRequired;

  /// Screen title for products and pricing
  ///
  /// In en, this message translates to:
  /// **'Products & Pricing'**
  String get productsPricingTitle;

  /// FAB label to add a new product
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProductFab;

  /// Modal title for adding a product
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProductModalTitle;

  /// Modal title for editing a product
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProductModalTitle;

  /// Label for product name input
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productNameInputLabel;

  /// Label for product description input
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get productDescriptionInputLabel;

  /// Label for product default rate input
  ///
  /// In en, this message translates to:
  /// **'Default Rate / Litre (Rs.)'**
  String get productDefaultRateInputLabel;

  /// Snackbar message when product is saved
  ///
  /// In en, this message translates to:
  /// **'Product saved successfully'**
  String get productSavedSuccess;

  /// Snackbar message when product is deactivated
  ///
  /// In en, this message translates to:
  /// **'Product deactivated'**
  String get productDeactivatedSuccess;

  /// Snackbar message when product is activated
  ///
  /// In en, this message translates to:
  /// **'Product activated'**
  String get productActivatedSuccess;

  /// Title of product deactivation confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Deactivate Product'**
  String get deactivateProductTitle;

  /// Confirmation message to deactivate a product
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to deactivate \"{name}\"?'**
  String deactivateProductConfirm(String name);

  /// Warning message when attempting to deactivate a product that is in use
  ///
  /// In en, this message translates to:
  /// **'Cannot deactivate: Active customers are assigned to this product.'**
  String get cannotDeactivateProduct;

  /// Empty state title for products screen
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// Empty state subtitle for products screen
  ///
  /// In en, this message translates to:
  /// **'Add milk products and default pricing.'**
  String get noProductsSubtitle;

  /// Active status label
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// Inactive status label
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactiveStatus;

  /// Section header for shifts
  ///
  /// In en, this message translates to:
  /// **'Delivery Shifts'**
  String get shiftsSectionTitle;

  /// Display name for morning delivery shift
  ///
  /// In en, this message translates to:
  /// **'Morning Shift'**
  String get morningShiftName;

  /// Display name for evening delivery shift
  ///
  /// In en, this message translates to:
  /// **'Evening Shift'**
  String get eveningShiftName;

  /// Label for shift start time
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get shiftStartTimeLabel;

  /// Label for shift end time
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get shiftEndTimeLabel;

  /// Snackbar message when shift is updated
  ///
  /// In en, this message translates to:
  /// **'Shift updated successfully'**
  String get shiftSavedSuccess;

  /// No description provided for @billReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'BILL'**
  String get billReceiptTitle;

  /// No description provided for @billReceiptDate.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String billReceiptDate(Object date);

  /// No description provided for @billReceiptPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone: {phone}'**
  String billReceiptPhone(Object phone);

  /// No description provided for @billReceiptAddress.
  ///
  /// In en, this message translates to:
  /// **'Address: {address}'**
  String billReceiptAddress(Object address);

  /// No description provided for @billPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration of bill:'**
  String get billPeriodLabel;

  /// No description provided for @billPeriodDates.
  ///
  /// In en, this message translates to:
  /// **'{start} to {end}'**
  String billPeriodDates(Object start, Object end);

  /// No description provided for @billCustomerPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone: '**
  String get billCustomerPhone;

  /// No description provided for @billCustomerAddress.
  ///
  /// In en, this message translates to:
  /// **'Address: '**
  String get billCustomerAddress;

  /// No description provided for @billProduct.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT'**
  String get billProduct;

  /// No description provided for @billRate.
  ///
  /// In en, this message translates to:
  /// **'RATE'**
  String get billRate;

  /// No description provided for @billWeight.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get billWeight;

  /// No description provided for @billTotal.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get billTotal;

  /// No description provided for @billDues.
  ///
  /// In en, this message translates to:
  /// **'Dues'**
  String get billDues;

  /// No description provided for @billPreviousAdvance.
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get billPreviousAdvance;

  /// No description provided for @billPaidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid Amount'**
  String get billPaidAmount;

  /// No description provided for @billRefundAmount.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get billRefundAmount;

  /// No description provided for @billSubtotalDue.
  ///
  /// In en, this message translates to:
  /// **'Subtotal (Amount Due): '**
  String get billSubtotalDue;

  /// No description provided for @billSubtotalAdvance.
  ///
  /// In en, this message translates to:
  /// **'Subtotal (Advance): '**
  String get billSubtotalAdvance;

  /// No description provided for @billSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get billSubtotal;

  /// No description provided for @billThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your business!'**
  String get billThankYou;

  /// Hint for delivery search text field
  ///
  /// In en, this message translates to:
  /// **'Search by date (e.g. 15 Oct, 2026)'**
  String get searchByDateHint;

  /// Filter label for undelivered deliveries
  ///
  /// In en, this message translates to:
  /// **'Undelivered'**
  String get filterUndelivered;

  /// No description provided for @shareDeliveryReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Delivery Report'**
  String get shareDeliveryReportTitle;

  /// No description provided for @shareReportThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get shareReportThisWeek;

  /// No description provided for @shareReportThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get shareReportThisMonth;

  /// No description provided for @shareReportCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom Date Range'**
  String get shareReportCustom;

  /// No description provided for @addReceiverNote.
  ///
  /// In en, this message translates to:
  /// **'Add Receiver Note'**
  String get addReceiverNote;

  /// No description provided for @receiverNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Received by Ali'**
  String get receiverNoteHint;

  /// No description provided for @deliveryReportPreview.
  ///
  /// In en, this message translates to:
  /// **'Report Preview'**
  String get deliveryReportPreview;

  /// No description provided for @shareTextBtn.
  ///
  /// In en, this message translates to:
  /// **'Share via WhatsApp/SMS'**
  String get shareTextBtn;

  /// No description provided for @receiverNamePrefix.
  ///
  /// In en, this message translates to:
  /// **'Note: '**
  String get receiverNamePrefix;

  /// No description provided for @addNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter name or note'**
  String get addNoteHint;

  /// Tab title for customer summary
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get tabSummary;

  /// Status badge label for active state
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// Status badge label for inactive state
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactive;

  /// Product label fallback
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// Title for the share delivery report screen
  ///
  /// In en, this message translates to:
  /// **'Share Report'**
  String get shareDeliveryReportScreenTitle;

  /// No description provided for @filterToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get filterToday;

  /// No description provided for @filterYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get filterYesterday;

  /// No description provided for @filterThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get filterThisWeek;

  /// No description provided for @filterLast15Days.
  ///
  /// In en, this message translates to:
  /// **'Last 15 Days'**
  String get filterLast15Days;

  /// No description provided for @filterLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get filterLastMonth;

  /// No description provided for @filterCurrentMonth.
  ///
  /// In en, this message translates to:
  /// **'Current Month'**
  String get filterCurrentMonth;

  /// No description provided for @filterCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get filterCustom;

  /// No description provided for @filterFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get filterFrom;

  /// No description provided for @filterTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get filterTo;

  /// No description provided for @errorFromAfterTo.
  ///
  /// In en, this message translates to:
  /// **'From date cannot be after To date'**
  String get errorFromAfterTo;

  /// No description provided for @emptyDeliveriesInRange.
  ///
  /// In en, this message translates to:
  /// **'No deliveries in this range'**
  String get emptyDeliveriesInRange;

  /// Button to share
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareAction;

  /// Footer for delivered status
  ///
  /// In en, this message translates to:
  /// **'{qty} {unit} delivered  •  Rs. {amount}'**
  String deliveryFooterDelivered(String qty, String unit, String amount);

  /// Title of the Add Supplier sheet
  ///
  /// In en, this message translates to:
  /// **'Add Supplier'**
  String get addSupplierTitle;

  /// Label for supplier name input
  ///
  /// In en, this message translates to:
  /// **'Supplier Name'**
  String get supplierNameLabel;

  /// Hint for supplier name input
  ///
  /// In en, this message translates to:
  /// **'e.g. Ahmed Dairy Farm'**
  String get supplierNameHint;

  /// Label for supplier phone input
  ///
  /// In en, this message translates to:
  /// **'Phone Number (Optional)'**
  String get supplierPhoneLabel;

  /// Label for supplier location input
  ///
  /// In en, this message translates to:
  /// **'Location / Area (Optional)'**
  String get supplierLocationLabel;

  /// Hint for supplier location input
  ///
  /// In en, this message translates to:
  /// **'e.g. Vehari'**
  String get supplierLocationHint;

  /// Label for supplier milk type input
  ///
  /// In en, this message translates to:
  /// **'Milk Type (Optional)'**
  String get supplierMilkTypeLabel;

  /// Hint for supplier milk type input
  ///
  /// In en, this message translates to:
  /// **'e.g. Buffalo, Cow'**
  String get supplierMilkTypeHint;

  /// Label for supplier rate input
  ///
  /// In en, this message translates to:
  /// **'Rate per Litre'**
  String get supplierRateLabel;

  /// Hint for supplier rate input
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get supplierRateHint;

  /// Button label to save supplier
  ///
  /// In en, this message translates to:
  /// **'Save Supplier'**
  String get saveSupplierAction;

  /// Validation error when supplier name is empty
  ///
  /// In en, this message translates to:
  /// **'Supplier name is required'**
  String get errorSupplierNameRequired;

  /// Snackbar message when supplier is added
  ///
  /// In en, this message translates to:
  /// **'Supplier added successfully'**
  String get supplierSavedSuccess;

  /// Error message when saving a supplier fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save supplier. Please try again.'**
  String get errorSavingSupplier;

  /// Title of the Edit Supplier sheet
  ///
  /// In en, this message translates to:
  /// **'Edit Supplier'**
  String get editSupplierTitle;

  /// Button label to archive supplier
  ///
  /// In en, this message translates to:
  /// **'Archive Supplier'**
  String get archiveSupplierAction;

  /// Title for archive confirm dialog
  ///
  /// In en, this message translates to:
  /// **'Archive Supplier'**
  String get archiveSupplierConfirmTitle;

  /// Body for archive confirm dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to archive this supplier?'**
  String get archiveSupplierConfirmBody;

  /// Error when trying to archive with pending khata
  ///
  /// In en, this message translates to:
  /// **'Khata must be cleared before archiving'**
  String get errorKhataMustBeCleared;

  /// Tooltip for edit supplier button
  ///
  /// In en, this message translates to:
  /// **'Edit Supplier'**
  String get editSupplierTooltip;

  /// Snackbar message when supplier is updated
  ///
  /// In en, this message translates to:
  /// **'Supplier updated successfully'**
  String get supplierUpdatedSuccess;

  /// Snackbar message when supplier is archived
  ///
  /// In en, this message translates to:
  /// **'Supplier archived'**
  String get supplierArchivedSuccess;

  /// Generic cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// Generic confirm action
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// Floating action button label to add a supplier
  ///
  /// In en, this message translates to:
  /// **'Add Supplier'**
  String get addSupplierFab;

  /// Error message when milk recording fails
  ///
  /// In en, this message translates to:
  /// **'Failed to record milk. Please try again.'**
  String get errorRecordingMilk;

  /// Label for the selected date when recording milk
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get recordDateLabel;

  /// Title for the milk inward history screen
  ///
  /// In en, this message translates to:
  /// **'Milk Inward History'**
  String get milkInwardHistoryTitle;

  /// Filter chip for today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get historyRangeToday;

  /// Label for supplier dropdown
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get historySupplierLabel;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No deliveries in this period'**
  String get historyNoDeliveries;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Try another date range, supplier or shift.'**
  String get historyNoDeliveriesSubtitle;

  /// Count of history entries
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String historyEntriesCount(String count);

  /// Label for total amount metric
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get historyTotalAmount;

  /// Suffix added to archived suppliers in history screen
  ///
  /// In en, this message translates to:
  /// **'(Archived)'**
  String get historyArchivedSuffix;

  /// Fallback name when a supplier is not found in history screen
  ///
  /// In en, this message translates to:
  /// **'Unknown supplier'**
  String get historyUnknownSupplier;

  /// Generic error message when data fails to load in history screen
  ///
  /// In en, this message translates to:
  /// **'Could not load data. Please try again.'**
  String get historyLoadError;

  /// No description provided for @actionEditEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEditEntry;

  /// No description provided for @actionDeleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDeleteEntry;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone from the app and the balance will be recalculated'**
  String get deleteConfirmMessage;

  /// No description provided for @entryDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted successfully'**
  String get entryDeletedSuccess;

  /// No description provided for @entrySavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Entry saved successfully'**
  String get entrySavedSuccess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
