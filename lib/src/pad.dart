import "package:flutter/material.dart";

/// [Pad] is an [EdgeInsetsGeometry] which is easy to type and remember.
///
/// Instead of `padding: EdgeInsets.all(12)`
/// You can write this `padding: Pad(all: 12)`
///
/// Instead of `padding: EdgeInsets.only(top: 8, bottom: 8, left: 4)`
/// You can write this `padding: Pad(top: 8, bottom: 8, left: 4)`
///
/// Instead of `padding: EdgeInsets.symmetric(vertical: 12)`
/// You can write this `padding: Pad(vertical: 12)`
///
/// You can also compose paddings. For example, if you want 40 pixels of
/// padding in all directions, except the top with 50 pixels:
/// `padding: Pad(all: 40, top: 10)`.
///
///
class Pad extends EdgeInsets {
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
  /// const Pad(all: 40.0, top: 10);
  /// ```
  ///
  const Pad({
    double all = 0.0,
    double vertical = 0.0,
    double horizontal = 0.0,
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
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

  /// Creates a copy of this padding but with the given fields replaced
  /// with the new values.
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
