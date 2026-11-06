// Refresh helper

import 'customer_provider.dart';
import 'dashboard_provider.dart';
import 'delivery_provider.dart';
import 'milk_collection_provider.dart';
import 'payment_provider.dart';
import 'product_provider.dart';
import 'local_sale_provider.dart';
import 'supplier_provider.dart';
import 'supplier_payment_provider.dart';

/// Invalidates all global data providers so that active screens rebuild
/// with fresh data. Does NOT invalidate per-customer family providers.
void invalidateAllGlobalData(dynamic ref) {
  ref.invalidate(dashboardProvider);
  ref.invalidate(deliveryListProvider);
  ref.invalidate(deliveryStatsProvider);
  ref.invalidate(customerListProvider);
  ref.invalidate(allCustomersProvider);
  ref.invalidate(customerStatsProvider);
  ref.invalidate(todayPaymentsProvider);
  ref.invalidate(todayCashTotalProvider);
  ref.invalidate(monthlyCollectionProvider);
  ref.invalidate(todayLocalSalesProvider);
  ref.invalidate(productListProvider);
  ref.invalidate(allProductListProvider);
  ref.invalidate(supplierListProvider);
  ref.invalidate(supplierByIdProvider);
  ref.invalidate(supplierCollectionsProvider);
  ref.invalidate(supplierPaymentListProvider);
}

/// Invalidates data specific to a supplier and related collections/payments.
void invalidateSupplierData(dynamic ref, String supplierId) {
  ref.invalidate(supplierListProvider);
  ref.invalidate(supplierByIdProvider(supplierId));
  ref.invalidate(supplierCollectionsProvider(supplierId));
  ref.invalidate(supplierPaymentListProvider(supplierId));
  
  ref.invalidate(milkCollectionListProvider);
  ref.invalidate(milkCollectionStatsProvider);
  ref.invalidate(todaySupplierPaymentsProvider);
  invalidateAllGlobalData(ref);
}
