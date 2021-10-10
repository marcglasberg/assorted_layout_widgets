import 'package:flutter/widgets.dart';

/// Global-key that uses equals [operator ==] of the String [value] to identify the key.
///
/// See also:
/// * If your [value] is NOT a String, you can use a [GlobalValueKey].
/// * To compare by identity (using [identical]), try using a [GlobalObjectKey].
///
class GlobalStringKey extends GlobalKey {
  //
  const GlobalStringKey(this.value) : super.constructor();

  /// The String used by this key's [operator==].
  final String value;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is GlobalStringKey && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'GlobalStringKey{$value}';
}

/// Global-key that uses equals [operator ==] of the [keyValue] to identify the key.
///
/// See also:
/// * If your [keyValue] is a String, you can use a [GlobalStringKey].
/// * To compare by identity (using [identical]), try using a [GlobalObjectKey].
///
class GlobalValueKey<T extends State<StatefulWidget>> extends GlobalKey<T> {
  //
  const GlobalValueKey(this.keyValue) : super.constructor();

  /// The object whose identity is used by this key's [operator==].
  final Object? keyValue;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is GlobalValueKey<T> && other.keyValue == keyValue;
  }

  @override
  int get hashCode => keyValue.hashCode;

  @override
  String toString() => 'GlobalValueKey{$keyValue}';
}
