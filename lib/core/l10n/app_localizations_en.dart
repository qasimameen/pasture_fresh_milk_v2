// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navCustomers => 'Customers';

  @override
  String get navDeliveries => 'Deliveries';

  @override
  String get navPayments => 'Payments';

  @override
  String get navSuppliers => 'Suppliers';

  @override
  String get storeStatusActive => 'Active';

  @override
  String get storeDefaultName => 'Al-Madina Dairy';

  @override
  String shiftActivePill(String shift) {
    return '$shift Active';
  }

  @override
  String get shiftMorning => 'Morning';

  @override
  String get shiftEvening => 'Evening';

  @override
  String get deliveriesNav => 'Deliveries';

  @override
  String deliveriesProgress(int completed, int total) {
    return '$completed of $total delivered';
  }

  @override
  String statusRemaining(int count) {
    return '$count Remaining';
  }

  @override
  String statusSkipped(int count) {
    return '$count Skipped';
  }

  @override
  String get kpiTotalCustomers => 'Total Customers';

  @override
  String kpiActiveSubtitle(int count) {
    return '$count active';
  }

  @override
  String get kpiTotalDues => 'Total Dues';

  @override
  String kpiOverdueSubtitle(int count) {
    return '$count overdue';
  }

  @override
  String get kpiDailySell => 'Daily Sell';

  @override
  String get kpiDailySellSubtitle => 'Morning + Evening Quota';

  @override
  String get kpiMonthlySell => 'Monthly Sell';

  @override
  String kpiGrowthSubtitle(String percent) {
    return '$percent% vs last month';
  }

  @override
  String get kpiTodayCash => 'Today\'s Cash';

  @override
  String get kpiTodayCashSubtitle => 'Rider & counter inflow';

  @override
  String get kpiAdvanceHeld => 'Advance Held';

  @override
  String kpiPrepaidSubtitle(int count) {
    return '$count prepaid';
  }

  @override
  String get monthlyCollection => 'Monthly Collection';

  @override
  String monthlyTargetSubtitle(String percent) {
    return '$percent% of target';
  }

  @override
  String get localSalesTitle => 'Counter Sales';

  @override
  String todayTotals(String litres, String amount) {
    return 'Today: $litres L • Rs. $amount';
  }

  @override
  String quickSaleButton(String litres) {
    return '+${litres}L';
  }

  @override
  String get quickSaleCustomCta => 'Add Quick Sale (Custom Quantity / Cash)';

  @override
  String lastSaleLabel(String litres, String amount) {
    return 'Last: ${litres}L • Rs. $amount';
  }

  @override
  String get undoAction => 'Undo';

  @override
  String quickSaleSuccess(String litres) {
    return '${litres}L sale recorded';
  }

  @override
  String get saleUndone => 'Sale undone';

  @override
  String get deliveryScheduleTitle => 'Delivery Schedule';

  @override
  String departureTime(String time) {
    return 'Departure: $time';
  }

  @override
  String startTime(String time) {
    return 'Start: $time';
  }

  @override
  String orderCount(int count) {
    return '$count Orders';
  }

  @override
  String crateStatus(String status) {
    return 'Crates: $status';
  }

  @override
  String get cratesReady => 'Ready';

  @override
  String get cratesPending => 'Pending';

  @override
  String get retry => 'Retry';

  @override
  String get loadFailed => 'Failed to load dashboard data';

  @override
  String get quickSaleTitle => 'Quick Counter Sale';

  @override
  String get milkType => 'Product / Milk Type';

  @override
  String get quantityLitres => 'Quantity (Litres)';

  @override
  String quickQuantity(String unit) {
    return 'Quick Quantity ($unit)';
  }

  @override
  String get quickAmount => 'Quick Amount (Rs.)';

  @override
  String get ratePerLitre => 'Rate per Litre';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get recordSale => 'Record Sale';

  @override
  String get saleRecorded => 'Sale recorded successfully';

  @override
  String get errorInvalidQuantity => 'Enter a valid quantity greater than 0';

  @override
  String get errorInvalidRate => 'Enter a valid rate greater than 0';

  @override
  String get errorSelectProduct => 'Please select a product';

  @override
  String get customersTitle => 'Customers';

  @override
  String customersCount(int count) {
    return '$count Customers';
  }

  @override
  String get totalStatLabel => 'Total';

  @override
  String get withDuesStatLabel => 'With Dues';

  @override
  String get onAdvanceStatLabel => 'On Advance';

  @override
  String get filterAll => 'All';

  @override
  String get filterHasDues => 'Has Dues';

  @override
  String get filterOnAdvance => 'On Advance';

  @override
  String get filterMorning => 'Morning';

  @override
  String get filterEvening => 'Evening';

  @override
  String get searchCustomersHint => 'Search by name, phone, area...';

  @override
  String get searchSuppliersHint => 'Search by name or phone...';

  @override
  String get searchTransactionsHint => 'Search by name or note...';

  @override
  String get quotaAmLabel => 'AM';

  @override
  String get quotaPmLabel => 'PM';

  @override
  String get ratePerLitreSuffix => 'Rs/L';

  @override
  String dueBalanceLabel(String amount) {
    return 'Due: Rs. $amount';
  }

  @override
  String advanceBalanceLabel(String amount) {
    return 'Advance: Rs. $amount';
  }

  @override
  String get clearedBalanceLabel => 'Cleared: Rs. 0';

  @override
  String get recordPaymentAction => 'Record Payment';

  @override
  String get addRechargeAction => 'Add Recharge';

  @override
  String get resumeSupplyAction => 'Resume Supply';

  @override
  String supplyResumedMessage(String name) {
    return 'Supply resumed for $name';
  }

  @override
  String get ledgerAction => 'Ledger';

  @override
  String get addCustomerFab => 'Add Customer';

  @override
  String get noCustomersFound => 'No customers found';

  @override
  String get noCustomersMatching => 'Try adjusting your search or filter';

  @override
  String get clearFiltersAction => 'Clear Filters';

  @override
  String get addCustomerTitle => 'Add New Customer';

  @override
  String get editCustomerTitle => 'Edit Customer';

  @override
  String get customerNameLabel => 'Customer Name';

  @override
  String get customerPhoneLabel => 'Phone Number';

  @override
  String get customerAddressLabel => 'Address / House #';

  @override
  String get deliverySequenceLabel => 'Delivery Sequence';

  @override
  String get dailyQuotaAmLabel => 'Morning Quota (Litres)';

  @override
  String get dailyQuotaPmLabel => 'Evening Quota (Litres)';

  @override
  String get agreedRateLabel => 'Agreed Rate per Litre';

  @override
  String get notesLabel => 'Notes (Optional)';

  @override
  String get saveChangesAction => 'Save Changes';

  @override
  String get customerAddedMessage => 'Customer added successfully';

  @override
  String get customerUpdatedMessage => 'Customer updated successfully';

  @override
  String get errorNameRequired => 'Customer name is required';

  @override
  String get errorPhoneRequired => 'Phone number is required';

  @override
  String get errorPhoneTooLong => 'Phone number cannot be more than 11 digits';

  @override
  String get errorQuotaRequired =>
      'At least one quota (AM or PM) must be greater than 0';

  @override
  String get customerDetailTitle => 'Customer Profile';

  @override
  String get editProfileAction => 'Edit Profile';

  @override
  String get payableBalanceLabel => 'Payable Balance';

  @override
  String get prepaidReserveLabel => 'Prepaid Reserve';

  @override
  String get deliveryPreferencesTitle => 'Delivery Preferences';

  @override
  String get tabAdvanceLedger => 'Ledger';

  @override
  String get tabDeliveryHistory => 'Deliveries';

  @override
  String get tabPaymentHistory => 'Payments';

  @override
  String get recordPaymentCta => 'Record Payment';

  @override
  String get addTopupCta => 'Add Topup';

  @override
  String get shareBillCta => 'Share Bill';

  @override
  String get shareDetailsAction => 'Share Details';

  @override
  String get collectPaymentBottomBar => 'Collect Payment';

  @override
  String get noDeliveriesRecorded => 'No deliveries recorded yet';

  @override
  String get noPaymentsRecorded => 'No payments recorded yet';

  @override
  String get customerNotFound => 'Customer not found';

  @override
  String get callAction => 'Call';

  @override
  String get transactionsAndLedgerTitle => 'Transactions & Ledger';

  @override
  String get ledgerDebitBadge => 'Debit';

  @override
  String get ledgerPaidBadge => 'Paid';

  @override
  String get ledgerCreditBadge => 'Credit';

  @override
  String get ledgerClearedBadge => 'Cleared';

  @override
  String duesAfterChargeLabel(String amount) {
    return 'Dues after charge: Rs. $amount';
  }

  @override
  String advanceReserveLabel(String amount) {
    return 'Advance reserve: Rs. $amount';
  }

  @override
  String get cashPaymentTitle => 'Cash Payment Received';

  @override
  String get raastPaymentTitle => 'Raast Payment Received';

  @override
  String get bankPaymentTitle => 'Bank Transfer Received';

  @override
  String get advanceTopupTitle => 'Advance Topup';

  @override
  String get advanceDeductionTitle => 'Advance Deduction';

  @override
  String get autoSettlementTitle => 'Auto Settlement';

  @override
  String morningDeliveryTitle(String quantity) {
    return 'Morning Delivery ${quantity}L';
  }

  @override
  String eveningDeliveryTitle(String quantity) {
    return 'Evening Delivery ${quantity}L';
  }

  @override
  String get noLedgerEntries => 'No ledger transactions yet';

  @override
  String get noLedgerEntriesSubtitle =>
      'Deliveries, payments and adjustments will appear here.';

  @override
  String get loadMoreEntries => 'Load More';

  @override
  String get deliveryHistoryTitle => 'Deliveries';

  @override
  String get deliveryHistoryEmptySubtitle =>
      'Deliveries for this customer will appear here.';

  @override
  String get deliveryStatusDelivered => 'Delivered';

  @override
  String get deliveryStatusSkipped => 'Skipped';

  @override
  String get deliveryStatusPending => 'Pending';

  @override
  String get paymentHistoryTitle => 'Payment History';

  @override
  String get paymentHistoryEmptySubtitle =>
      'Payments collected for this customer will appear here.';

  @override
  String get paymentTypeCashPayment => 'Cash Payment';

  @override
  String get paymentTypeAdvanceTopup => 'Advance Topup';

  @override
  String get paymentMethodCash => 'Cash';

  @override
  String get paymentMethodRaast => 'Raast';

  @override
  String get paymentMethodBank => 'Bank';

  @override
  String get recordPaymentModalTitle => 'Record Payment';

  @override
  String get addTopupModalTitle => 'Add Advance Topup';

  @override
  String get paymentModeDues => 'Pay Dues';

  @override
  String get paymentModeAdvance => 'Advance Topup';

  @override
  String get amountLabel => 'Amount (Rs.)';

  @override
  String payFullDueShortcut(String amount) {
    return 'Pay Full: Rs. $amount';
  }

  @override
  String get receiptRefLabel => 'Receipt / Ref Number (Optional)';

  @override
  String get notesOptionalLabel => 'Notes (Optional)';

  @override
  String get errorAmountRequired =>
      'Please enter a valid amount greater than 0';

  @override
  String paymentRecordedSuccess(String amount) {
    return 'Payment of Rs. $amount recorded';
  }

  @override
  String topupRecordedSuccess(String amount) {
    return 'Topup of Rs. $amount added';
  }

  @override
  String shareBillMessage(String customer, String dues, String advance) {
    return 'Al-Madina Dairy Statement\nCustomer: $customer\nPayable Dues: Rs. $dues\nAdvance Balance: Rs. $advance';
  }

  @override
  String get deliveriesTitle => 'Today\'s Deliveries';

  @override
  String get markAllAction => 'Mark All';

  @override
  String get searchDeliveriesHint => 'Search by customer, phone, house #...';

  @override
  String get noDeliveriesFound => 'No deliveries found';

  @override
  String get noDeliveriesMatching =>
      'Try adjusting date, shift, or search filter.';

  @override
  String get deliverAction => 'Deliver';

  @override
  String get skipAction => 'Skip';

  @override
  String get confirmDeliverTitle => 'Confirm Delivery';

  @override
  String confirmDeliverBody(String qty, String amount) {
    return 'Deliver ${qty}L to this customer for Rs. $amount?';
  }

  @override
  String get confirmAction => 'Confirm';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get skipReasonHint => 'Reason for skipping (e.g. customer away)';

  @override
  String get skipDeliveryTitle => 'Skip Delivery';

  @override
  String get errorSkipReasonRequired => 'Please enter a reason for skipping';

  @override
  String get markAllConfirmTitle => 'Mark All Delivered';

  @override
  String markAllConfirmBody(int count) {
    return 'This will mark all $count pending deliveries as delivered (cash payment).';
  }

  @override
  String get deliveredSuccess => 'Delivery marked as delivered';

  @override
  String get skippedSuccess => 'Delivery skipped';

  @override
  String get deliveryResetSuccess => 'Delivery reset to pending';

  @override
  String get markAllSuccess => 'All deliveries marked as delivered';

  @override
  String get deliveriesGeneratedSuccess => 'Today\'s deliveries generated';

  @override
  String get paymentMethodCashLabel => 'Cash';

  @override
  String get paymentMethodCreditLabel => 'Credit';

  @override
  String get paymentMethodAdvanceLabel => 'Advance';

  @override
  String get selectPaymentMethod => 'Payment Method';

  @override
  String get paymentsTitle => 'Payments & Accounts';

  @override
  String get todayInflowKpi => 'Today\'s Inflow';

  @override
  String get cashInHandKpi => 'Cash in Hand';

  @override
  String get counterVerifiedNote => 'Counter verified';

  @override
  String get customerDuesKpi => 'Customer Dues';

  @override
  String get dairyPayablesKpi => 'Dairy Payables';

  @override
  String get recordPaymentInOutCta => '+ Record Payment In / Out';

  @override
  String get whatsappRemindersTitle => 'WhatsApp Reminders';

  @override
  String get sendReminderAction => 'Send Reminder';

  @override
  String get logCashReceivedAction => '+ Log Cash Received';

  @override
  String overdueLabel(int days) {
    return '${days}d overdue';
  }

  @override
  String get filterCollections => 'Collections';

  @override
  String get filterPayables => 'Payables';

  @override
  String get transactionsHeader => 'Today\'s Transactions & Ledgers';

  @override
  String get liveSyncLabel => 'LIVE SYNC';

  @override
  String get txCustomerCollection => 'Customer Collection';

  @override
  String get txAdvanceDeposit => 'Advance Deposit';

  @override
  String get txSupplierOutflow => 'Supplier Outflow';

  @override
  String get txCounterRetail => 'Counter Retail';

  @override
  String get noTransactionsFound => 'No transactions today';

  @override
  String get noTransactionsSubtitle =>
      'Payments, deliveries, and sales will appear here.';

  @override
  String get noOverdueCustomers => 'No overdue customers';

  @override
  String get supplierPaymentBadge => 'Supplier Outflow';

  @override
  String get advanceBadge => 'Advance';

  @override
  String get clearedBadge => 'Cleared';

  @override
  String get dailyRetailBadge => 'Daily Retail';

  @override
  String get suppliersScreenTitle => 'Suppliers & Procurement';

  @override
  String get totalMilkInwardKpi => 'Milk Received';

  @override
  String get todayPayableKpi => 'Today\'s Payable';

  @override
  String get avgRateSubtitle => 'Avg rate';

  @override
  String get suppliersSectionTitle => 'Suppliers';

  @override
  String farmsCountBadge(int count) {
    return '$count Farms';
  }

  @override
  String get filterPendingKhata => 'Pending Khata';

  @override
  String get logDropAction => 'Log Drop';

  @override
  String get payCashAction => 'Pay Cash';

  @override
  String get viewKhataAction => 'View Khata';

  @override
  String get pendingKhataLabel => 'Pending Khata';

  @override
  String get advanceLabel => 'Advance';

  @override
  String get allClearedKhataLabel => 'All Khata Cleared';

  @override
  String get qtyLabel => 'QTY';

  @override
  String get ratePerLitreLabel => 'RATE/L';

  @override
  String get batchValueLabel => 'Batch Value';

  @override
  String get noSuppliersFound => 'No suppliers found';

  @override
  String get noSuppliersSubtitle =>
      'Suppliers and their incoming milk batches will appear here.';

  @override
  String get paySupplierModalTitle => 'Pay Supplier Cash';

  @override
  String get amountOwedLabel => 'Pending Khata Owed';

  @override
  String get recordMilkModalTitle => 'Record Inward Milk';

  @override
  String get quantityLitresLabel => 'Quantity (Litres)';

  @override
  String get batchValueCalculatedLabel => 'Calculated Batch Value';

  @override
  String get recordBatchAction => 'Record Batch';

  @override
  String get batchRecordedSuccess => 'Inward milk batch recorded successfully';

  @override
  String get errorQuantityRequired =>
      'Please enter a valid quantity greater than 0';

  @override
  String get errorSupplierRateNotSet =>
      'Please set the supplier\'s rate per litre first';

  @override
  String get supplierKhataTitle => 'Supplier Khata';

  @override
  String get collectionHistoryTab => 'Collections';

  @override
  String get paymentsMadeTab => 'Payments';

  @override
  String get noCollectionsRecorded => 'No milk collections recorded';

  @override
  String get noCollectionsSubtitle =>
      'Logged milk collections for this supplier will appear here.';

  @override
  String get noSupplierPaymentsRecorded => 'No payments recorded yet';

  @override
  String get noSupplierPaymentsSubtitle =>
      'Cash and bank payments made to this supplier will appear here.';

  @override
  String get totalMilkSupplied => 'Total Milk Supplied';

  @override
  String get unpaidMilkLabel => 'Unpaid milk';

  @override
  String get callSupplierAction => 'Call Supplier';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Store configuration and delivery operations';

  @override
  String get settingsStoreProfile => 'Store Profile';

  @override
  String get settingsStoreProfileSubtitle =>
      'Shop name, contact phone, and address';

  @override
  String get settingsProductsPricing => 'Products & Pricing';

  @override
  String get settingsProductsPricingSubtitle =>
      'Manage milk products and rates';

  @override
  String get storeProfileTitle => 'Store Profile';

  @override
  String get storeNameLabel => 'Store Name';

  @override
  String get storePhoneLabel => 'Store Phone';

  @override
  String get storeAddressLabel => 'Store Address';

  @override
  String get profileSavedSuccess => 'Store profile saved successfully';

  @override
  String get errorStoreNameRequired => 'Store name cannot be empty';

  @override
  String get productsPricingTitle => 'Products & Pricing';

  @override
  String get addProductFab => 'Add Product';

  @override
  String get addProductModalTitle => 'Add Product';

  @override
  String get editProductModalTitle => 'Edit Product';

  @override
  String get productNameInputLabel => 'Product Name';

  @override
  String get productDescriptionInputLabel => 'Description (Optional)';

  @override
  String get productDefaultRateInputLabel => 'Default Rate / Litre (Rs.)';

  @override
  String get productSavedSuccess => 'Product saved successfully';

  @override
  String get productDeactivatedSuccess => 'Product deactivated';

  @override
  String get productActivatedSuccess => 'Product activated';

  @override
  String get deactivateProductTitle => 'Deactivate Product';

  @override
  String deactivateProductConfirm(String name) {
    return 'Are you sure you want to deactivate \"$name\"?';
  }

  @override
  String get cannotDeactivateProduct =>
      'Cannot deactivate: Active customers are assigned to this product.';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get noProductsSubtitle => 'Add milk products and default pricing.';

  @override
  String get activeStatus => 'Active';

  @override
  String get inactiveStatus => 'Inactive';

  @override
  String get shiftsSectionTitle => 'Delivery Shifts';

  @override
  String get morningShiftName => 'Morning Shift';

  @override
  String get eveningShiftName => 'Evening Shift';

  @override
  String get shiftStartTimeLabel => 'Start Time';

  @override
  String get shiftEndTimeLabel => 'End Time';

  @override
  String get shiftSavedSuccess => 'Shift updated successfully';

  @override
  String get billReceiptTitle => 'BILL';

  @override
  String billReceiptDate(Object date) {
    return 'Date: $date';
  }

  @override
  String billReceiptPhone(Object phone) {
    return 'Phone: $phone';
  }

  @override
  String billReceiptAddress(Object address) {
    return 'Address: $address';
  }

  @override
  String get billPeriodLabel => 'Duration of bill:';

  @override
  String billPeriodDates(Object start, Object end) {
    return '$start to $end';
  }

  @override
  String get billCustomerPhone => 'Phone: ';

  @override
  String get billCustomerAddress => 'Address: ';

  @override
  String get billProduct => 'PRODUCT';

  @override
  String get billRate => 'RATE';

  @override
  String get billWeight => 'WEIGHT';

  @override
  String get billTotal => 'TOTAL';

  @override
  String get billDues => 'Dues';

  @override
  String get billPreviousAdvance => 'Advance';

  @override
  String get billPaidAmount => 'Paid Amount';

  @override
  String get billRefundAmount => 'Refund';

  @override
  String get billSubtotalDue => 'Subtotal (Amount Due): ';

  @override
  String get billSubtotalAdvance => 'Subtotal (Advance): ';

  @override
  String get billSubtotal => 'Subtotal';

  @override
  String get billThankYou => 'Thank you for your business!';

  @override
  String get searchByDateHint => 'Search by date (e.g. 15 Oct, 2026)';

  @override
  String get filterUndelivered => 'Undelivered';

  @override
  String get shareDeliveryReportTitle => 'Share Delivery Report';

  @override
  String get shareReportThisWeek => 'This Week';

  @override
  String get shareReportThisMonth => 'This Month';

  @override
  String get shareReportCustom => 'Custom Date Range';

  @override
  String get addReceiverNote => 'Add Receiver Note';

  @override
  String get receiverNoteHint => 'e.g. Received by Ali';

  @override
  String get deliveryReportPreview => 'Report Preview';

  @override
  String get shareTextBtn => 'Share via WhatsApp/SMS';

  @override
  String get receiverNamePrefix => 'Note: ';

  @override
  String get addNoteHint => 'Enter name or note';

  @override
  String get tabSummary => 'Summary';

  @override
  String get statusActive => 'Active';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get product => 'Product';

  @override
  String get shareDeliveryReportScreenTitle => 'Share Report';

  @override
  String get filterToday => 'Today';

  @override
  String get filterYesterday => 'Yesterday';

  @override
  String get filterThisWeek => 'This Week';

  @override
  String get filterLast15Days => 'Last 15 Days';

  @override
  String get filterLastMonth => 'Last Month';

  @override
  String get filterCurrentMonth => 'Current Month';

  @override
  String get filterCustom => 'Custom';

  @override
  String get filterFrom => 'From';

  @override
  String get filterTo => 'To';

  @override
  String get errorFromAfterTo => 'From date cannot be after To date';

  @override
  String get emptyDeliveriesInRange => 'No deliveries in this range';

  @override
  String get shareAction => 'Share';

  @override
  String deliveryFooterDelivered(String qty, String unit, String amount) {
    return '$qty $unit delivered  •  Rs. $amount';
  }

  @override
  String get addSupplierTitle => 'Add Supplier';

  @override
  String get supplierNameLabel => 'Supplier Name';

  @override
  String get supplierNameHint => 'e.g. Ahmed Dairy Farm';

  @override
  String get supplierPhoneLabel => 'Phone Number (Optional)';

  @override
  String get supplierLocationLabel => 'Location / Area (Optional)';

  @override
  String get supplierLocationHint => 'e.g. Vehari';

  @override
  String get supplierMilkTypeLabel => 'Milk Type (Optional)';

  @override
  String get supplierMilkTypeHint => 'e.g. Buffalo, Cow';

  @override
  String get supplierRateLabel => 'Rate per Litre';

  @override
  String get supplierRateHint => '0';

  @override
  String get saveSupplierAction => 'Save Supplier';

  @override
  String get errorSupplierNameRequired => 'Supplier name is required';

  @override
  String get supplierSavedSuccess => 'Supplier added successfully';

  @override
  String get errorSavingSupplier =>
      'Failed to save supplier. Please try again.';

  @override
  String get editSupplierTitle => 'Edit Supplier';

  @override
  String get archiveSupplierAction => 'Archive Supplier';

  @override
  String get archiveSupplierConfirmTitle => 'Archive Supplier';

  @override
  String get archiveSupplierConfirmBody =>
      'Are you sure you want to archive this supplier?';

  @override
  String get errorKhataMustBeCleared =>
      'Khata must be cleared before archiving';

  @override
  String get editSupplierTooltip => 'Edit Supplier';

  @override
  String get supplierUpdatedSuccess => 'Supplier updated successfully';

  @override
  String get supplierArchivedSuccess => 'Supplier archived';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get addSupplierFab => 'Add Supplier';

  @override
  String get errorRecordingMilk => 'Failed to record milk. Please try again.';

  @override
  String get recordDateLabel => 'Date';

  @override
  String get milkInwardHistoryTitle => 'Milk Inward History';

  @override
  String get historyRangeToday => 'Today';

  @override
  String get historySupplierLabel => 'Supplier';

  @override
  String get historyNoDeliveries => 'No deliveries in this period';

  @override
  String get historyNoDeliveriesSubtitle =>
      'Try another date range, supplier or shift.';

  @override
  String historyEntriesCount(String count) {
    return '$count entries';
  }

  @override
  String get historyTotalAmount => 'Total Amount';

  @override
  String get historyArchivedSuffix => '(Archived)';

  @override
  String get historyUnknownSupplier => 'Unknown supplier';

  @override
  String get historyLoadError => 'Could not load data. Please try again.';

  @override
  String get actionEditEntry => 'Edit';

  @override
  String get actionDeleteEntry => 'Delete';

  @override
  String get deleteConfirmTitle => 'Delete Entry?';

  @override
  String get deleteConfirmMessage =>
      'This cannot be undone from the app and the balance will be recalculated';

  @override
  String get entryDeletedSuccess => 'Entry deleted successfully';

  @override
  String get entrySavedSuccess => 'Entry saved successfully';
}
