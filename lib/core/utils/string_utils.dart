/// String helper functions for consistent text formatting.
class StringUtils {
  const StringUtils._();

  /// Capitalizes the first letter of [text] (or each word if multiple words).
  ///
  /// Examples:
  /// - "ali" -> "Ali"
  /// - "ali ahmed" -> "Ali Ahmed"
  /// - "  ali  " -> "Ali"
  static String capitalizeWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;

    return trimmed
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) return word;
          if (word.length == 1) return word.toUpperCase();
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}
