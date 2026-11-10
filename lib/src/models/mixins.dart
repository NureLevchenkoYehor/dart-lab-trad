import 'package:trad/src/models/identifiable.dart';

/// Provides auditing, cataloging, and URN generation for an [Identifiable] entity.
///
/// This mixin is constrained with `on Identifiable`, ensuring it can only be applied
/// to classes that implement or extend [Identifiable] and giving access to the [id]
/// member directly inside the mixin methods.
mixin Auditable on Identifiable {
  /// Generates a standardized Uniform Resource Name (URN) for catalog referencing.
  String get urn => 'urn:trad:entity:$id';

  /// Generates a formatted audit entry record for the specified [action].
  String formatAuditEntry({required String action}) {
    return '[$action] Entity(id: "$id")';
  }

  /// Determines whether the entity's [id] matches the provided [searchQuery] (case-insensitive).
  bool matchesId(String searchQuery) {
    return id.toLowerCase().contains(searchQuery.toLowerCase());
  }
}
