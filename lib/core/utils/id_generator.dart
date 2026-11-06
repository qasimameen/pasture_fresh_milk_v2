import 'package:uuid/uuid.dart';

/// Generates unique primary-key identifiers (UUID v4).
abstract final class IdGenerator {
  static const Uuid _uuid = Uuid();

  /// Returns a new random UUID v4 string (36 characters).
  static String generate() => _uuid.v4();
}