extension LocalizedUnit on String {
  /// Returns the localized unit string based on [localeCode].
  String localizeUnit(String? localeCode) {
    if (localeCode == 'ur') {
      switch (toLowerCase()) {
        case 'litre': return 'لیٹر';
        case 'kg': return 'کلو';
        case 'glass': return 'گلاس';
        case 'piece': return 'عدد';
      }
    }
    return this;
  }

  /// Returns the formatted display unit string based on [localeCode].
  /// English uses 'L' for 'litre', otherwise returns the unit.
  /// Urdu returns the localized unit.
  String displayUnit(String? localeCode) {
    if (localeCode == 'ur') {
      return localizeUnit(localeCode);
    }
    return toLowerCase() == 'litre' ? 'L' : this;
  }
}
