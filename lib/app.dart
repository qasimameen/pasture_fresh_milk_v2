import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_localizations.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'providers/locale_provider.dart';

/// Root widget of Al-Madina Dairy.
///
/// B-M1: applies [AppTheme.lightTheme], wires the generated localization
/// delegates/supported locales (en, ur), and switches the theme to the Urdu
/// variant when the active locale is `ur` so the Noto Nastaliq Urdu typeface
/// follows the RTL text direction.
///
/// B-M18: listens to [localeProvider] to drive the active application [Locale],
/// triggering full app rebuild and RTL text directionality when Urdu is active.
///
/// C-M1: wires [AppRoutes.onGenerateRoute] and the main [AppShell] with 5-tab
/// navigation and route management.
class AlMadinaDairyApp extends StatelessWidget {
  const AlMadinaDairyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          final Locale locale = ref.watch(localeProvider);
          return MaterialApp(
            title: 'Al-Madina Dairy',
            locale: locale,
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: AppRoutes.home,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            builder: (context, child) {
              final bool isUrduLocale =
                  Localizations.localeOf(context).languageCode == 'ur';
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Theme(
                  data: isUrduLocale
                      ? AppTheme.lightThemeUrdu
                      : AppTheme.lightTheme,
                  child: child!,
                ),
              );
            },
          );
        },
      ),
    );
  }
}