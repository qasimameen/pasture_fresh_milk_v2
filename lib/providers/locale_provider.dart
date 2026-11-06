import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences storage key for the application locale (plan.md B-M18).
const String kLocaleStorageKey = 'app_locale';

/// Notifier managing application locale with persistent storage (plan.md B-M18).
class LocaleNotifier extends StateNotifier<Locale> {
  /// Creates the locale notifier, optionally accepting pre-warmed [preferences].
  LocaleNotifier([SharedPreferences? preferences])
      : _preferences = preferences,
        super(const Locale('ur')) {
    _loadFromPreferences();
  }

  SharedPreferences? _preferences;

  Future<void> _loadFromPreferences() async {
    try {
      _preferences ??= await SharedPreferences.getInstance();
      final String? savedCode = _preferences?.getString(kLocaleStorageKey);
      if (savedCode != null && (savedCode == 'en' || savedCode == 'ur')) {
        state = Locale(savedCode);
      }
    } catch (_) {
      // Fallback cleanly to default Locale('ur') if preferences fail.
    }
  }

  /// Sets the application [Locale] and writes the preference to storage.
  Future<void> setLocale(Locale newLocale) async {
    if (state.languageCode == newLocale.languageCode) return;
    state = newLocale;
    try {
      _preferences ??= await SharedPreferences.getInstance();
      await _preferences?.setString(kLocaleStorageKey, newLocale.languageCode);
    } catch (_) {
      // Preference write failure does not crash the state update.
    }
  }

  /// Toggles between English ('en') and Urdu ('ur').
  Future<void> toggleLocale() async {
    final Locale next = state.languageCode == 'ur'
        ? const Locale('en')
        : const Locale('ur');
    await setLocale(next);
  }
}

/// Global provider for application locale state (plan.md B-M18).
/// Defaults to Urdu `Locale('ur')` and persists to [SharedPreferences].
final StateNotifierProvider<LocaleNotifier, Locale> localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((Ref ref) {
  return LocaleNotifier();
});
