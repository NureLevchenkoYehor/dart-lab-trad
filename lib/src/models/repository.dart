import 'package:trad/src/models/identifiable.dart';

/// A generic in-memory repository for storing and querying [Identifiable] entities.
///
/// The type parameter [T] is bounded by [Identifiable], which guarantees at compile time
/// that all stored items have an [id] property and avoids unsafe dynamic casting.
class Repository<T extends Identifiable> {
  final Map<String, T> _items = {};

  /// Adds an [item] to the repository, keyed by its [Identifiable.id].
  void add(T item) {
    _items[item.id] = item;
  }

  /// Adds all [items] to the repository.
  void addAll(Iterable<T> items) {
    for (final item in items) {
      add(item);
    }
  }

  /// Finds and returns the entity with the specified [id], or `null` if not found.
  T? findById(String id) => _items[id];

  /// Filters repository items matching the specified [test] predicate.
  Iterable<T> where(bool Function(T) test) => _items.values.where(test);

  /// Returns all stored entities as an unmodifiable list.
  List<T> getAll() => List.unmodifiable(_items.values);

  /// The total number of items currently stored in the repository.
  int get count => _items.length;

  /// Removes the entity with the specified [id] from the repository.
  ///
  /// Returns `true` if an entity was removed, or `false` if it was not found.
  bool remove(String id) => _items.remove(id) != null;

  /// Clears all entities from the repository.
  void clear() => _items.clear();
}
