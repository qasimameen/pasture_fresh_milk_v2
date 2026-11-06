import 'package:flutter/material.dart';

import '../../screens/analytics/sales_analytics_screen.dart';
import '../../screens/app_shell.dart';
import '../../providers/sales_analytics_provider.dart';
import '../../screens/customers/bill_preview_screen.dart';
import '../../screens/customers/customer_detail_screen.dart';
import '../../screens/settings/products_pricing_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/settings/store_profile_screen.dart';
import '../../screens/suppliers/supplier_khata_screen.dart';

/// Central route definitions and generator for Al-Madina Dairy (plan.md C-M1).
abstract final class AppRoutes {
  /// Home shell route ('/').
  static const String home = '/';

  /// Base path for customer detail ('/customer/:id').
  static const String customerDetailPrefix = '/customer';

  /// Settings shell ('/settings').
  static const String settings = '/settings';

  /// Store profile settings ('/settings/profile').
  static const String settingsProfile = '/settings/profile';

  /// Products & pricing settings ('/settings/products').
  static const String settingsProducts = '/settings/products';

  /// Helper to generate a customer detail route path.
  static String customerPath(String id) => '/customer/$id';

  /// Helper to generate a bill preview route path.
  static String billPreviewPath(String id) => '/customer/$id/bill_preview';

  /// Helper to generate a supplier khata route path.
  static String supplierKhataPath(String id) => '/supplier/$id/khata';

  /// Helper to generate a sales analytics route path.
  static String salesAnalyticsPath(String timeframe) => '/analytics/sales/$timeframe';

  /// Generates application routes and parses dynamic parameters.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Uri uri = Uri.parse(settings.name ?? home);
    final List<String> segments = uri.pathSegments;

    // Home / Tab shell: '/'
    if (segments.isEmpty || uri.path == home) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const AppShell(),
      );
    }

    // Customer Detail: '/customer/:id'
    if (segments.length == 2 && segments[0] == 'customer') {
      final String customerId = segments[1];
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => CustomerDetailScreen(customerId: customerId),
      );
    }

    // Bill Preview: '/customer/:id/bill_preview'
    if (segments.length == 3 && segments[0] == 'customer' && segments[2] == 'bill_preview') {
      final String customerId = segments[1];
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => BillPreviewScreen(customerId: customerId),
      );
    }

    // Supplier Khata: '/supplier/:id/khata'
    if (segments.length == 3 && segments[0] == 'supplier' && segments[2] == 'khata') {
      final String supplierId = segments[1];
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => SupplierKhataScreen(supplierId: supplierId),
      );
    }

    // Analytics: '/analytics/sales/:timeframe'
    if (segments.length == 3 && segments[0] == 'analytics' && segments[1] == 'sales') {
      final String timeframeStr = segments[2];
      final Timeframe tf = timeframeStr == 'daily' ? Timeframe.daily : Timeframe.monthly;
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => SalesAnalyticsScreen(timeframe: tf),
      );
    }

    // Settings subroutes: '/settings/...'
    if (segments[0] == 'settings') {
      if (segments.length == 1) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SettingsScreen(),
        );
      }
      final String sub = segments[1];
      switch (sub) {
        case 'profile':
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const StoreProfileScreen(),
          );
        case 'products':
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const ProductsPricingScreen(),
          );
      }
    }

    // Fallback to AppShell
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const AppShell(),
    );
  }
}
