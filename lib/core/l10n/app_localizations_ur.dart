// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get navHome => 'ہوم';

  @override
  String get navCustomers => 'گاہک';

  @override
  String get navDeliveries => 'ڈیلیوری';

  @override
  String get navPayments => 'ادائیگی';

  @override
  String get navSuppliers => 'سپلائر';

  @override
  String get storeStatusActive => 'فعال';

  @override
  String get storeDefaultName => 'المدینہ ڈیری';

  @override
  String shiftActivePill(String shift) {
    return '$shift فعال';
  }

  @override
  String get shiftMorning => 'صبح';

  @override
  String get shiftEvening => 'شام';

  @override
  String get deliveriesNav => 'ڈیلیوری';

  @override
  String deliveriesProgress(int completed, int total) {
    return '$total میں سے $completed مکمل';
  }

  @override
  String statusRemaining(int count) {
    return '$count باقی';
  }

  @override
  String statusSkipped(int count) {
    return '$count چھوڑ دیا';
  }

  @override
  String get kpiTotalCustomers => 'کل گاہک';

  @override
  String kpiActiveSubtitle(int count) {
    return '$count فعال';
  }

  @override
  String get kpiTotalDues => 'کل بقایا جات';

  @override
  String kpiOverdueSubtitle(int count) {
    return '$count واجب الادا';
  }

  @override
  String get kpiDailySell => 'روزانہ فروخت';

  @override
  String get kpiDailySellSubtitle => 'صبح اور شام کا کوٹہ';

  @override
  String get kpiMonthlySell => 'ماہانہ فروخت';

  @override
  String kpiGrowthSubtitle(String percent) {
    return 'پچھلے ماہ سے $percent%';
  }

  @override
  String get kpiTodayCash => 'آج کی وصولی';

  @override
  String get kpiTodayCashSubtitle => 'رائیڈر اور کاؤنٹر سے کیش';

  @override
  String get kpiAdvanceHeld => 'ایڈوانس رقم';

  @override
  String kpiPrepaidSubtitle(int count) {
    return '$count ایڈوانس گاہک';
  }

  @override
  String get monthlyCollection => 'ماہانہ وصولی';

  @override
  String monthlyTargetSubtitle(String percent) {
    return 'ٹارگٹ کا $percent%';
  }

  @override
  String get localSalesTitle => 'کاؤنٹر فروخت';

  @override
  String todayTotals(String litres, String amount) {
    return 'آج: $litres لیٹر • $amount روپے';
  }

  @override
  String quickSaleButton(String litres) {
    return '+$litres لیٹر';
  }

  @override
  String get quickSaleCustomCta => 'سیل درج کریں (مخصوص مقدار / رقم)';

  @override
  String lastSaleLabel(String litres, String amount) {
    return 'آخری: $litres لیٹر • $amount روپے';
  }

  @override
  String get undoAction => 'منسوخ';

  @override
  String quickSaleSuccess(String litres) {
    return '$litres لیٹر فروخت درج ہو گئی';
  }

  @override
  String get saleUndone => 'فروخت منسوخ کر دی گئی';

  @override
  String get deliveryScheduleTitle => 'ڈیلیوری شیڈول';

  @override
  String departureTime(String time) {
    return 'روانگی: $time';
  }

  @override
  String startTime(String time) {
    return 'شروع: $time';
  }

  @override
  String orderCount(int count) {
    return '$count آرڈرز';
  }

  @override
  String crateStatus(String status) {
    return 'کریٹس: $status';
  }

  @override
  String get cratesReady => 'تیار';

  @override
  String get cratesPending => 'باقی';

  @override
  String get retry => 'دوبارہ کوشش کریں';

  @override
  String get loadFailed => 'ڈیٹا لوڈ کرنے میں مسئلہ پیش آیا';

  @override
  String get quickSaleTitle => 'فوری کاؤنٹر فروخت';

  @override
  String get milkType => 'پروڈکٹ / دودھ کی قسم';

  @override
  String get quantityLitres => 'مقدار (لیٹر)';

  @override
  String quickQuantity(String unit) {
    return 'فوری مقدار ($unit)';
  }

  @override
  String get quickAmount => 'فوری رقم (روپے)';

  @override
  String get ratePerLitre => 'فی لیٹر ریٹ';

  @override
  String get totalAmount => 'کل رقم';

  @override
  String get recordSale => 'فروخت درج کریں';

  @override
  String get saleRecorded => 'فروخت کامیابی سے درج ہو گئی';

  @override
  String get errorInvalidQuantity => '0 سے زیادہ درست مقدار درج کریں';

  @override
  String get errorInvalidRate => '0 سے زیادہ درست ریٹ درج کریں';

  @override
  String get errorSelectProduct => 'براہ کرم پروڈکٹ منتخب کریں';

  @override
  String get customersTitle => 'گاہک';

  @override
  String customersCount(int count) {
    return '$count گاہک';
  }

  @override
  String get totalStatLabel => 'کل';

  @override
  String get withDuesStatLabel => 'واجب الادا';

  @override
  String get onAdvanceStatLabel => 'ایڈوانس پر';

  @override
  String get filterAll => 'تمام';

  @override
  String get filterHasDues => 'واجبات';

  @override
  String get filterOnAdvance => 'ایڈوانس';

  @override
  String get filterMorning => 'صبح';

  @override
  String get filterEvening => 'شام';

  @override
  String get searchCustomersHint => 'نام، فون یا علاقے سے تلاش کریں...';

  @override
  String get searchSuppliersHint => 'نام یا فون نمبر سے تلاش کریں...';

  @override
  String get searchTransactionsHint => 'نام یا نوٹ سے تلاش کریں...';

  @override
  String get quotaAmLabel => 'صبح';

  @override
  String get quotaPmLabel => 'شام';

  @override
  String get ratePerLitreSuffix => 'روپے/لیٹر';

  @override
  String dueBalanceLabel(String amount) {
    return 'واجب: $amount روپے';
  }

  @override
  String advanceBalanceLabel(String amount) {
    return 'ایڈوانس: $amount روپے';
  }

  @override
  String get clearedBalanceLabel => 'بے باق: 0 روپے';

  @override
  String get recordPaymentAction => 'ادائیگی درج کریں';

  @override
  String get addRechargeAction => 'ریچارج شامل کریں';

  @override
  String get resumeSupplyAction => 'سپلائی بحال کریں';

  @override
  String supplyResumedMessage(String name) {
    return '$name کی سپلائی بحال کر دی گئی ہے';
  }

  @override
  String get ledgerAction => 'کھاتہ';

  @override
  String get addCustomerFab => 'نیا گاہک';

  @override
  String get noCustomersFound => 'کوئی گاہک نہیں ملا';

  @override
  String get noCustomersMatching => 'اپنی تلاش یا فلٹر تبدیل کر کے دیکھیں';

  @override
  String get clearFiltersAction => 'فلٹرز ختم کریں';

  @override
  String get addCustomerTitle => 'نیا گاہک شامل کریں';

  @override
  String get editCustomerTitle => 'گاہک کی تفصیلات تبدیل کریں';

  @override
  String get customerNameLabel => 'گاہک کا نام';

  @override
  String get customerPhoneLabel => 'فون نمبر';

  @override
  String get customerAddressLabel => 'پتہ / مکان نمبر';

  @override
  String get deliverySequenceLabel => 'ڈیلیوری ترتیب نمبر';

  @override
  String get dailyQuotaAmLabel => 'صبح کا کوٹہ (لیٹر)';

  @override
  String get dailyQuotaPmLabel => 'شام کا کوٹہ (لیٹر)';

  @override
  String get agreedRateLabel => 'طے شدہ ریٹ فی لیٹر';

  @override
  String get notesLabel => 'نوٹس (اختیاری)';

  @override
  String get saveChangesAction => 'تبدیلیاں محفوظ کریں';

  @override
  String get customerAddedMessage => 'نیا گاہک کامیابی سے شامل ہو گیا';

  @override
  String get customerUpdatedMessage => 'گاہک کی معلومات اپڈیٹ ہو گئی';

  @override
  String get errorNameRequired => 'گاہک کا نام درج کرنا ضروری ہے';

  @override
  String get errorPhoneRequired => 'فون نمبر درج کرنا ضروری ہے';

  @override
  String get errorPhoneTooLong => 'فون نمبر 11 ہندسوں سے زیادہ نہیں ہو سکتا';

  @override
  String get errorQuotaRequired =>
      'صبح یا شام میں سے کم از کم ایک کوٹہ درج کریں';

  @override
  String get customerDetailTitle => 'گاہک کی تفصیلات';

  @override
  String get editProfileAction => 'پروفائل تبدیل کریں';

  @override
  String get payableBalanceLabel => 'قابل ادا واجبات';

  @override
  String get prepaidReserveLabel => 'ایڈوانس رقم';

  @override
  String get deliveryPreferencesTitle => 'ڈیلیوری ترجیحات';

  @override
  String get tabAdvanceLedger => 'کھاتہ';

  @override
  String get tabDeliveryHistory => 'ڈیلیوریز';

  @override
  String get tabPaymentHistory => 'ادائیگیاں';

  @override
  String get recordPaymentCta => 'رقم وصول کریں';

  @override
  String get addTopupCta => 'ایڈوانس شامل کریں';

  @override
  String get shareBillCta => 'بل بھیجیں';

  @override
  String get shareDetailsAction => 'تفصیلات شیئر کریں';

  @override
  String get collectPaymentBottomBar => 'ادائیگی وصول کریں';

  @override
  String get noDeliveriesRecorded => 'ابھی تک کوئی ڈیلیوری نہیں ہوئی';

  @override
  String get noPaymentsRecorded => 'ابھی تک کوئی ادائیگی نہیں ہوئی';

  @override
  String get customerNotFound => 'گاہک نہیں ملا';

  @override
  String get callAction => 'کال';

  @override
  String get transactionsAndLedgerTitle => 'لین دین اور کھاتہ';

  @override
  String get ledgerDebitBadge => 'بنام';

  @override
  String get ledgerPaidBadge => 'ادا شدہ';

  @override
  String get ledgerCreditBadge => 'جمع';

  @override
  String get ledgerClearedBadge => 'بے باق';

  @override
  String duesAfterChargeLabel(String amount) {
    return 'بقایا واجبات: روپے $amount';
  }

  @override
  String advanceReserveLabel(String amount) {
    return 'پیشگی امانت: روپے $amount';
  }

  @override
  String get cashPaymentTitle => 'نقد رقم وصول';

  @override
  String get raastPaymentTitle => 'راست رقم وصول';

  @override
  String get bankPaymentTitle => 'بینک ٹرانسفر رقم وصول';

  @override
  String get advanceTopupTitle => 'ایڈوانس رقم جمع';

  @override
  String get advanceDeductionTitle => 'ایڈوانس سے کٹوتی';

  @override
  String get autoSettlementTitle => 'خودکار سیٹلمنٹ';

  @override
  String morningDeliveryTitle(String quantity) {
    return 'صبح ڈیلیوری $quantity لیٹر';
  }

  @override
  String eveningDeliveryTitle(String quantity) {
    return 'شام ڈیلیوری $quantity لیٹر';
  }

  @override
  String get noLedgerEntries => 'ابھی تک کوئی لین دین نہیں ہوا';

  @override
  String get noLedgerEntriesSubtitle =>
      'یہاں تمام ترسیل، ادائیگیاں اور کھاتہ ظاہر ہوں گے۔';

  @override
  String get loadMoreEntries => 'مزید دیکھیں';

  @override
  String get deliveryHistoryTitle => 'ڈیلیوریاں';

  @override
  String get deliveryHistoryEmptySubtitle =>
      'اس گاہک کی ڈیلیوری یہاں ظاہر ہوگی۔';

  @override
  String get deliveryStatusDelivered => 'ڈیلیور ہوئی';

  @override
  String get deliveryStatusSkipped => 'چھوڑی گئی';

  @override
  String get deliveryStatusPending => 'زیر التوا';

  @override
  String get paymentHistoryTitle => 'ادائیگیوں کی تاریخ';

  @override
  String get paymentHistoryEmptySubtitle =>
      'اس گاہک سے وصول کی گئی ادائیگیاں یہاں ظاہر ہوں گی۔';

  @override
  String get paymentTypeCashPayment => 'نقد ادائیگی';

  @override
  String get paymentTypeAdvanceTopup => 'ایڈوانس رقم جمع';

  @override
  String get paymentMethodCash => 'نقد';

  @override
  String get paymentMethodRaast => 'راسٹ';

  @override
  String get paymentMethodBank => 'بینک';

  @override
  String get recordPaymentModalTitle => 'رقم وصول درج کریں';

  @override
  String get addTopupModalTitle => 'ایڈوانس رقم جمع کریں';

  @override
  String get paymentModeDues => 'واجبات کی ادائیگی';

  @override
  String get paymentModeAdvance => 'پیشگی امانت';

  @override
  String get amountLabel => 'رقم (روپے)';

  @override
  String payFullDueShortcut(String amount) {
    return 'مکمل واجبات: روپے $amount';
  }

  @override
  String get receiptRefLabel => 'رسید / ریفرنس نمبر (اختیاری)';

  @override
  String get notesOptionalLabel => 'نوٹس (اختیاری)';

  @override
  String get errorAmountRequired => 'براہ کرم صفر سے بڑی درست رقم درج کریں';

  @override
  String paymentRecordedSuccess(String amount) {
    return 'روپے $amount کی ادائیگی درج ہوگئی';
  }

  @override
  String topupRecordedSuccess(String amount) {
    return 'روپے $amount کا ایڈوانس جمع ہوگیا';
  }

  @override
  String shareBillMessage(String customer, String dues, String advance) {
    return 'المدینہ ڈیری کھاتہ تفصیل\nگاہک: $customer\nبقایا واجبات: روپے $dues\nپیشگی امانت: روپے $advance';
  }

  @override
  String get deliveriesTitle => 'آج کی ڈیلیوریز';

  @override
  String get markAllAction => 'سب مکمل کریں';

  @override
  String get searchDeliveriesHint => 'گاہک، فون یا مکان نمبر سے تلاش کریں...';

  @override
  String get noDeliveriesFound => 'کوئی ڈیلیوری نہیں ملی';

  @override
  String get noDeliveriesMatching =>
      'تاریخ، شفٹ یا تلاش فلٹر تبدیل کر کے دیکھیں۔';

  @override
  String get deliverAction => 'ڈیلیور کریں';

  @override
  String get skipAction => 'چھوڑ دیں';

  @override
  String get confirmDeliverTitle => 'ڈیلیوری کی تصدیق کریں';

  @override
  String confirmDeliverBody(String qty, String amount) {
    return 'اس گاہک کو $qty لیٹر ادا کریں — روپے $amount؟';
  }

  @override
  String get confirmAction => 'تصدیق کریں';

  @override
  String get cancelAction => 'منسوخ';

  @override
  String get skipReasonHint => 'چھوڑنے کی وجہ (مثلاً: گاہک گھر پر نہیں)';

  @override
  String get skipDeliveryTitle => 'ڈیلیوری چھوڑ دیں';

  @override
  String get errorSkipReasonRequired => 'براہ کرم چھوڑنے کی وجہ درج کریں';

  @override
  String get markAllConfirmTitle => 'سب ڈیلیور مارک کریں';

  @override
  String markAllConfirmBody(int count) {
    return 'تمام $count زیر التوا ڈیلیوریاں ڈیلیور (نقد) مارک کی جائیں گی۔';
  }

  @override
  String get deliveredSuccess => 'ڈیلیوری مکمل ہو گئی';

  @override
  String get skippedSuccess => 'ڈیلیوری چھوڑ دی گئی';

  @override
  String get deliveryResetSuccess => 'ڈیلیوری زیر التوا پر واپس کر دی گئی';

  @override
  String get markAllSuccess => 'تمام ڈیلیوریاں مکمل ہو گئیں';

  @override
  String get deliveriesGeneratedSuccess => 'آج کی ڈیلیوریاں تیار ہو گئیں';

  @override
  String get paymentMethodCashLabel => 'نقد';

  @override
  String get paymentMethodCreditLabel => 'ادھار';

  @override
  String get paymentMethodAdvanceLabel => 'ایڈوانس';

  @override
  String get selectPaymentMethod => 'ادائیگی کا طریقہ';

  @override
  String get paymentsTitle => 'ادائیگیاں اور کھاتے';

  @override
  String get todayInflowKpi => 'آج کی آمدنی';

  @override
  String get cashInHandKpi => 'ہاتھ میں نقد';

  @override
  String get counterVerifiedNote => 'کاؤنٹر تصدیق شدہ';

  @override
  String get customerDuesKpi => 'گاہک واجبات';

  @override
  String get dairyPayablesKpi => 'ڈیری واجبات';

  @override
  String get recordPaymentInOutCta => '+ ادائیگی درج کریں / دیں';

  @override
  String get whatsappRemindersTitle => 'واٹس ایپ یاددہانی';

  @override
  String get sendReminderAction => 'یاددہانی بھیجیں';

  @override
  String get logCashReceivedAction => '+ نقد وصول درج کریں';

  @override
  String overdueLabel(int days) {
    return '$days دن واجب الادا';
  }

  @override
  String get filterCollections => 'وصولیاں';

  @override
  String get filterPayables => 'واجبات';

  @override
  String get transactionsHeader => 'آج کے لین دین اور کھاتے';

  @override
  String get liveSyncLabel => 'لائیو سنک';

  @override
  String get txCustomerCollection => 'گاہک وصولی';

  @override
  String get txAdvanceDeposit => 'ایڈوانس جمع';

  @override
  String get txSupplierOutflow => 'سپلائر ادائیگی';

  @override
  String get txCounterRetail => 'کاؤنٹر فروخت';

  @override
  String get noTransactionsFound => 'آج کوئی لین دین نہیں';

  @override
  String get noTransactionsSubtitle =>
      'ادائیگیاں، ڈیلیوریاں اور فروخت یہاں ظاہر ہوں گی۔';

  @override
  String get noOverdueCustomers => 'کوئی واجب الادا گاہک نہیں';

  @override
  String get supplierPaymentBadge => 'سپلائر ادائیگی';

  @override
  String get advanceBadge => 'ایڈوانس';

  @override
  String get clearedBadge => 'ادا ہو گیا';

  @override
  String get dailyRetailBadge => 'روزانہ فروخت';

  @override
  String get suppliersScreenTitle => 'سپلائرز اور دودھ خریداری';

  @override
  String get totalMilkInwardKpi => 'موصول دودھ';

  @override
  String get todayPayableKpi => 'آج کی واجب الادا رقم';

  @override
  String get avgRateSubtitle => 'اوسط ریٹ';

  @override
  String get suppliersSectionTitle => 'سپلائرز';

  @override
  String farmsCountBadge(int count) {
    return '$count فارمز';
  }

  @override
  String get filterPendingKhata => 'بقایا کھاتہ';

  @override
  String get logDropAction => 'آمد درج کریں';

  @override
  String get payCashAction => 'نقد ادائیگی';

  @override
  String get viewKhataAction => 'کھاتہ دیکھیں';

  @override
  String get pendingKhataLabel => 'بقایا کھاتہ';

  @override
  String get advanceLabel => 'ایڈوانس';

  @override
  String get allClearedKhataLabel => 'تمام کھاتہ بے باق ہے';

  @override
  String get qtyLabel => 'مقدار';

  @override
  String get ratePerLitreLabel => 'ریٹ/لیٹر';

  @override
  String get batchValueLabel => 'بیچ کی کل قیمت';

  @override
  String get noSuppliersFound => 'کوئی سپلائر نہیں ملا';

  @override
  String get noSuppliersSubtitle =>
      'سپلائرز اور ان کے دودھ کے بیجز یہاں ظاہر ہوں گے۔';

  @override
  String get paySupplierModalTitle => 'سپلائر کو نقد ادائیگی';

  @override
  String get amountOwedLabel => 'واجب الادا بقایا کھاتہ';

  @override
  String get recordMilkModalTitle => 'دودھ کی آمد درج کریں';

  @override
  String get quantityLitresLabel => 'مقدار (لیٹر)';

  @override
  String get batchValueCalculatedLabel => 'بیچ کی کل قیمت';

  @override
  String get recordBatchAction => 'بیچ محفوظ کریں';

  @override
  String get batchRecordedSuccess => 'دودھ کا بیچ کامیابی سے درج ہو گیا';

  @override
  String get errorQuantityRequired => 'براہ کرم 0 سے زیادہ درست مقدار درج کریں';

  @override
  String get errorSupplierRateNotSet =>
      'براہ کرم پہلے سپلائر کا فی لیٹر ریٹ مقرر کریں';

  @override
  String get supplierKhataTitle => 'سپلائر کھاتہ';

  @override
  String get collectionHistoryTab => 'آمد دودھ';

  @override
  String get paymentsMadeTab => 'ادائیگیوں کی تفصیل';

  @override
  String get noCollectionsRecorded => 'دودھ کی کوئی وصولی ریکارڈ نہیں ہوئی';

  @override
  String get noCollectionsSubtitle =>
      'اس سپلائر کی آمدہ دودھ کی تفصیلات یہاں ظاہر ہوں گی۔';

  @override
  String get noSupplierPaymentsRecorded => 'ابھی تک کوئی ادائیگی نہیں کی گئی';

  @override
  String get noSupplierPaymentsSubtitle =>
      'اس سپلائر کو کی گئی نقد یا بینک ادائیگیاں یہاں ظاہر ہوں گی۔';

  @override
  String get totalMilkSupplied => 'کل فراہم کردہ دودھ';

  @override
  String get unpaidMilkLabel => 'غیر ادا شدہ دودھ';

  @override
  String get callSupplierAction => 'سپلائر کو کال کریں';

  @override
  String get settingsTitle => 'ترتیبات';

  @override
  String get settingsSubtitle => 'دکان کی معلومات، قیمتیں، شفٹس اور ڈرائیورز';

  @override
  String get settingsStoreProfile => 'دکان کا پروفائل';

  @override
  String get settingsStoreProfileSubtitle => 'دکان کا نام، رابطہ فون اور پتہ';

  @override
  String get settingsProductsPricing => 'مصنوعات اور قیمتیں';

  @override
  String get settingsProductsPricingSubtitle => 'دودھ کی اقسام اور مقررہ ریٹس';

  @override
  String get storeProfileTitle => 'دکان کا پروفائل';

  @override
  String get storeNameLabel => 'دکان کا نام';

  @override
  String get storePhoneLabel => 'دکان کا فون';

  @override
  String get storeAddressLabel => 'دکان کا پتہ';

  @override
  String get profileSavedSuccess => 'دکان کا پروفائل کامیابی سے محفوظ ہو گیا';

  @override
  String get errorStoreNameRequired => 'دکان کا نام خالی نہیں ہو سکتا';

  @override
  String get productsPricingTitle => 'مصنوعات اور قیمتیں';

  @override
  String get addProductFab => 'نئی پروڈکٹ شامل کریں';

  @override
  String get addProductModalTitle => 'نئی پروڈکٹ شامل کریں';

  @override
  String get editProductModalTitle => 'پروڈکٹ میں ترمیم کریں';

  @override
  String get productNameInputLabel => 'پروڈکٹ کا نام';

  @override
  String get productDescriptionInputLabel => 'تفصیل (اختیاری)';

  @override
  String get productDefaultRateInputLabel => 'مقررہ ریٹ / لیٹر (روپے)';

  @override
  String get productSavedSuccess => 'پروڈکٹ کامیابی سے محفوظ ہو گئی';

  @override
  String get productDeactivatedSuccess => 'پروڈکٹ غیر فعال کر دی گئی';

  @override
  String get productActivatedSuccess => 'پروڈکٹ فعال کر دی گئی';

  @override
  String get deactivateProductTitle => 'پروڈکٹ غیر فعال کریں';

  @override
  String deactivateProductConfirm(String name) {
    return 'کیا آپ واقعی \"$name\" کو غیر فعال کرنا چاہتے ہیں؟';
  }

  @override
  String get cannotDeactivateProduct =>
      'غیر فعال نہیں کیا جا سکتا: فعال کسٹمرز اس پروڈکٹ سے وابستہ ہیں۔';

  @override
  String get noProductsFound => 'کوئی پروڈکٹ موجود نہیں';

  @override
  String get noProductsSubtitle =>
      'فروخت شروع کرنے کے لیے دودھ کی اقسام اور ریٹس شامل کریں۔';

  @override
  String get activeStatus => 'فعال';

  @override
  String get inactiveStatus => 'غیر فعال';

  @override
  String get shiftsSectionTitle => 'ڈلیوری شفٹس';

  @override
  String get morningShiftName => 'صبح کی شفٹ';

  @override
  String get eveningShiftName => 'شام کی شفٹ';

  @override
  String get shiftStartTimeLabel => 'شروع کا وقت';

  @override
  String get shiftEndTimeLabel => 'ختم ہونے کا وقت';

  @override
  String get shiftSavedSuccess => 'شفٹ کی تفصیلات محفوظ ہو گئیں';

  @override
  String get billReceiptTitle => 'بل';

  @override
  String billReceiptDate(Object date) {
    return 'تاریخ: $date';
  }

  @override
  String billReceiptPhone(Object phone) {
    return 'فون: $phone';
  }

  @override
  String billReceiptAddress(Object address) {
    return 'پتہ: $address';
  }

  @override
  String get billPeriodLabel => 'بل کی مدت:';

  @override
  String billPeriodDates(Object start, Object end) {
    return '$start سے $end تک';
  }

  @override
  String get billCustomerPhone => 'فون: ';

  @override
  String get billCustomerAddress => 'پتہ: ';

  @override
  String get billProduct => 'پروڈکٹ';

  @override
  String get billRate => 'ریٹ';

  @override
  String get billWeight => 'وزن';

  @override
  String get billTotal => 'کل';

  @override
  String get billDues => 'بقایا جات';

  @override
  String get billPreviousAdvance => 'ایڈوانس';

  @override
  String get billPaidAmount => 'ادا شدہ رقم';

  @override
  String get billRefundAmount => 'رقم واپس';

  @override
  String get billSubtotalDue => 'کل واجبات (بقایا): ';

  @override
  String get billSubtotalAdvance => 'کل واجبات (ایڈوانس): ';

  @override
  String get billSubtotal => 'کل رقم';

  @override
  String get billThankYou => 'آپ کے کاروبار کا شکریہ!';

  @override
  String get searchByDateHint => 'تاریخ سے تلاش کریں  ';

  @override
  String get filterUndelivered => 'غیر ادا شدہ';

  @override
  String get shareDeliveryReportTitle => 'ڈلیوری رپورٹ شیئر کریں';

  @override
  String get shareReportThisWeek => 'اس ہفتے';

  @override
  String get shareReportThisMonth => 'اس مہینے';

  @override
  String get shareReportCustom => 'اپنی مرضی کی تاریخ';

  @override
  String get addReceiverNote => 'نوٹ شامل کریں';

  @override
  String get receiverNoteHint => 'مثلاً: علی نے وصول کیا';

  @override
  String get deliveryReportPreview => 'رپورٹ کا پیش نظارہ';

  @override
  String get shareTextBtn => 'شیئر کریں';

  @override
  String get receiverNamePrefix => 'نوٹ: ';

  @override
  String get addNoteHint => 'نام یا نوٹ درج کریں';

  @override
  String get tabSummary => 'خلاصہ';

  @override
  String get statusActive => 'فعال';

  @override
  String get statusInactive => 'غیر فعال';

  @override
  String get product => 'پروڈکٹ';

  @override
  String get shareDeliveryReportScreenTitle => 'رپورٹ شیئر کریں';

  @override
  String get filterToday => 'آج';

  @override
  String get filterYesterday => 'کل';

  @override
  String get filterThisWeek => 'اس ہفتے';

  @override
  String get filterLast15Days => 'پچھلے 15 دن';

  @override
  String get filterLastMonth => 'پچھلا مہینہ';

  @override
  String get filterCurrentMonth => 'موجودہ مہینہ';

  @override
  String get filterCustom => 'حسبِ ضرورت';

  @override
  String get filterFrom => 'سے';

  @override
  String get filterTo => 'تک';

  @override
  String get errorFromAfterTo => 'سے کی تاریخ تک کی تاریخ کے بعد نہیں ہو سکتی';

  @override
  String get emptyDeliveriesInRange => 'اس عرصے میں کوئی ڈیلیوری نہیں ہوئی';

  @override
  String get shareAction => 'شیئر کریں';

  @override
  String deliveryFooterDelivered(String qty, String unit, String amount) {
    return '$unit $qty ڈیلیور ہوا  •  Rs. $amount';
  }

  @override
  String get addSupplierTitle => 'سپلائر شامل کریں';

  @override
  String get supplierNameLabel => 'سپلائر کا نام';

  @override
  String get supplierNameHint => 'مثال کے طور پر حاجی بشیر ڈیری فارم';

  @override
  String get supplierPhoneLabel => 'فون نمبر (اختیاری)';

  @override
  String get supplierLocationLabel => 'مقام / علاقہ (اختیاری)';

  @override
  String get supplierLocationHint => 'مثال کے طور پر وہاڑی';

  @override
  String get supplierMilkTypeLabel => 'دودھ کی قسم (اختیاری)';

  @override
  String get supplierMilkTypeHint => 'مثال کے طور پر گائے، بھینس';

  @override
  String get supplierRateLabel => 'ریٹ فی لیٹر';

  @override
  String get supplierRateHint => '0';

  @override
  String get saveSupplierAction => 'سپلائر محفوظ کریں';

  @override
  String get errorSupplierNameRequired => 'سپلائر کا نام درکار ہے';

  @override
  String get supplierSavedSuccess => 'سپلائر کامیابی سے شامل ہو گیا';

  @override
  String get errorSavingSupplier =>
      'سپلائر محفوظ کرنے میں ناکامی۔ براہ کرم دوبارہ کوشش کریں۔';

  @override
  String get editSupplierTitle => 'سپلائر میں ترمیم کریں';

  @override
  String get archiveSupplierAction => 'سپلائر آرکائیو کریں';

  @override
  String get archiveSupplierConfirmTitle => 'سپلائر آرکائیو کریں';

  @override
  String get archiveSupplierConfirmBody =>
      'کیا آپ واقعی اس سپلائر کو آرکائیو کرنا چاہتے ہیں؟';

  @override
  String get errorKhataMustBeCleared =>
      'آرکائیو کرنے سے پہلے کھاتہ صاف ہونا چاہیے';

  @override
  String get editSupplierTooltip => 'سپلائر میں ترمیم کریں';

  @override
  String get supplierUpdatedSuccess => 'سپلائر کامیابی سے اپ ڈیٹ ہو گیا';

  @override
  String get supplierArchivedSuccess => 'سپلائر آرکائیو ہو گیا';

  @override
  String get actionCancel => 'منسوخ کریں';

  @override
  String get actionConfirm => 'تصدیق کریں';

  @override
  String get addSupplierFab => 'سپلائر شامل کریں';

  @override
  String get errorRecordingMilk =>
      'دودھ ریکارڈ کرنے میں ناکامی۔ براہ کرم دوبارہ کوشش کریں۔';

  @override
  String get recordDateLabel => 'تاریخ';

  @override
  String get milkInwardHistoryTitle => 'دودھ آمد کا ریکارڈ';

  @override
  String get historyRangeToday => 'آج';

  @override
  String get historySupplierLabel => 'سپلائر';

  @override
  String get historyNoDeliveries => 'اس مدت میں کوئی آمد نہیں';

  @override
  String get historyNoDeliveriesSubtitle =>
      'تاریخ، سپلائر یا شفٹ تبدیل کر کے دیکھیں۔';

  @override
  String historyEntriesCount(String count) {
    return '$count اندراجات';
  }

  @override
  String get historyTotalAmount => 'کل رقم';

  @override
  String get historyArchivedSuffix => '(آرکائیو)';

  @override
  String get historyUnknownSupplier => 'نامعلوم سپلائر';

  @override
  String get historyLoadError =>
      'ڈیٹا لوڈ نہیں ہو سکا۔ براہ کرم دوبارہ کوشش کریں۔';

  @override
  String get actionEditEntry => 'ترمیم کریں';

  @override
  String get actionDeleteEntry => 'حذف کریں';

  @override
  String get deleteConfirmTitle => 'اندراج حذف کریں؟';

  @override
  String get deleteConfirmMessage =>
      'یہ عمل ایپ سے واپس نہیں کیا جا سکتا اور کھاتہ دوبارہ گنا جائے گا۔';

  @override
  String get entryDeletedSuccess => 'اندراج کامیابی سے حذف ہو گیا۔';

  @override
  String get entrySavedSuccess => 'اندراج کامیابی سے محفوظ ہو گیا۔';
}
