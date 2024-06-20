import "package:flutter/material.dart";

/// [Pad] is an [EdgeInsetsGeometry] which is easy to type and remember.
/// It can be used in all widgets that accept `padding`,
/// like `Container`, `Padding` and `Box`.
///
/// Instead of `EdgeInsets.all(12)`,
/// write `Pad(all: 12)`
///
/// Instead of `EdgeInsets.only(top: 8, bottom: 8, left: 4)`,
/// write `Pad(top: 8, bottom: 8, left: 4)`
///
/// Instead of `EdgeInsets.symmetric(vertical: 12)`,
/// write `Pad(vertical: 12)`
///
/// You can also compose paddings. For example, if you want 40 pixels of
/// padding in all directions, but you want the top with 50 pixels,
/// write `Pad(all: 40, top: 10)`.
///
class Pad extends EdgeInsets {
  //

  /// Creates insets with the given values:
  /// * `top`, `bottom`, `left` and `right` pixels.
  /// * `all` pixels will be added to the top, bottom, left and right.
  /// * `vertical` pixels will be added to the top and bottom.
  /// * `horizontal` pixels will be added to the left and right.
  ///
  /// You can also compose paddings. For example, for all directions
  /// with 40 pixels of padding, except the top with 50 pixels:
  ///
  /// ```dart
  /// Pad(all: 40, top: 10);
  /// ```
  ///
  /// Note constructor parameters `all`, `vertical` and `horizontal` are used only to compose
  /// the final padding value. The resulting `Pad` object contains only left/right/top/bottom.
  /// For example:
  ///
  /// ```dart
  /// Pad(all: 40, vertical: 5, top: 10).top == (40 + 5 + 10) == 55;
  /// ```
  ///
  const Pad({
    double all = 0,
    double vertical = 0,
    double horizontal = 0,
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) : super.fromLTRB(
          all + left + horizontal,
          all + top + vertical,
          all + right + horizontal,
          all + bottom + vertical,
        );

  /// No padding.
  static const zero = Pad();

  /// Sometimes you need to temporarily remove the padding, for debugging reasons.
  /// Unfortunately you can't just comment the padding parameter, because the
  /// [Padding] widget doesn't accept `null` padding. But you can just add `.x` to
  /// the [Pad] class to remove it. It's marked as [deprecated] so that you don't
  /// forget to change it back to normal.
  @Deprecated("Use this for debugging purposes only.")
  const Pad.x({
    double? all, // ignore: avoid_unused_constructor_parameters
    double? vertical, // ignore: avoid_unused_constructor_parameters
    double? horizontal, // ignore: avoid_unused_constructor_parameters
    double? left, // ignore: avoid_unused_constructor_parameters
    double? top, // ignore: avoid_unused_constructor_parameters
    double? right, // ignore: avoid_unused_constructor_parameters
    double? bottom, // ignore: avoid_unused_constructor_parameters
  }) : super.fromLTRB(0, 0, 0, 0);

  /// Creates a copy of this padding, plus the given parameters.
  ///
  /// Example:
  /// ```dart
  /// // Same as Pad(all: 40, top: 10)
  /// Pad(all: 40).plus(top: 10);
  /// ```
  ///
  Pad plus({
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? all = 0,
    double? vertical = 0,
    double? horizontal = 0,
  }) {
    return Pad(
      left: this.left + (left ?? 0),
      top: this.top + (top ?? 0),
      right: this.right + (right ?? 0),
      bottom: this.bottom + (bottom ?? 0),
      all: all ?? 0,
      vertical: vertical ?? 0,
      horizontal: horizontal ?? 0,
    );
  }

  /// Creates a copy of this padding, minus the given parameters.
  ///
  /// Example:
  /// ```dart
  /// // Same as Pad(all: 40, top: -10)
  /// Pad(all: 40).minus(top: 10);
  /// ```
  ///
  Pad minus({
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? all = 0,
    double? vertical = 0,
    double? horizontal = 0,
  }) {
    return Pad(
      left: this.left - (left ?? 0),
      top: this.top - (top ?? 0),
      right: this.right - (right ?? 0),
      bottom: this.bottom - (bottom ?? 0),
      all: (all != null) ? -all : 0,
      vertical: (vertical != null) ? -vertical : 0,
      horizontal: (horizontal != null) ? -horizontal : 0,
    );
  }

  /// Creates a copy of this padding but with the given fields replaced
  /// with the new values.
  ///
  /// IMPORTANT:
  /// This will replace the final value of the resulting padding left/right/top/bottom,
  /// after applying `all`, `vertical` and `horizontal`.
  /// For example:
  ///
  /// ```
  /// // Same as Pad(left: 40, right: 40, top: 40, bottom: 10)
  /// Pad(all: 40).copyWith(bottom: 10);
  /// ```
  @override
  Pad copyWith({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return Pad(
      left: left ?? this.left,
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
    );
  }
}
