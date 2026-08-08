import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Box extends StatelessWidget {
  /// Box is something between a Container and a SizedBox.
  /// Unlike a Container it can be made `const`, so it's good for creating colored boxes,
  /// with or without padding:
  ///
  /// ```
  /// const Box(color: Colors.red, width: 50, height:30, child: myChild);
  /// ```
  ///
  /// The `padding` is only applied if the child is NOT NULL. If the `child` is `null`
  /// and `width` and `height` are also `null`, this means the box will occupy no space
  /// (will be hidden). **Note:** This will be extended in the future, so that it ignores
  /// horizontal padding when the child has zero width, and ignores vertical padding when
  /// the child has zero height.
  ///
  /// You can also hide the box by making the `show` parameter equal to `false`.
  ///
  /// Note: You can use the [Pad] class (provided in the assorted_layout_widgets
  /// package) for the `padding`, instead of [EdgeInsets].
  ///
  /// # Debugging:
  /// * If need to quickly and temporarily add a color to your box so that you can see it,
  /// you can use the constructors `Box.r` for red, `Box.g` for green, and `Box.b` for blue.
  /// * If you want to see rebuilds, you can use the `Box.rand` constructor.
  /// It will then change its color to a random one, whenever its build method is called.
  ///
  const Box({
    Key? key,
    this.show = true,
    this.color,
    this.padding,
    this.width,
    this.height,
    this.alignment,
    this.child,
    this.removePaddingWhenNoChild = false,
    this.decoration,
    this.decorationPosition = DecorationPosition.background,
  })  : _random = false,
        _fixedColor = false,
        super(key: key);

  /// Creates a square box with [gap] by [gap] pixels.
  /// This may be used for small gaps between widgets. For example:
  ///
  /// ```
  /// Column(
  ///   children: [
  ///    Text('A'),
  ///    const Box.gap(10),
  ///    Text('B'),
  ///   ],
  /// );
  ///  ```
  ///
  const Box.gap(double gap) : this(width: gap, height: gap);

  const Box._({
    Key? key,
    this.show = true,
    this.color,
    this.padding,
    this.width,
    this.height,
    this.alignment,
    this.child,
    bool? random,
    bool? removePaddingWhenNoChild,
    this.decoration,
    this.decorationPosition = DecorationPosition.background,
    required bool fixedColor,
  })  : _random = random ?? false,
        removePaddingWhenNoChild = removePaddingWhenNoChild ?? false,
        _fixedColor = fixedColor,
        super(key: key);

  /// Adding `.r` to the box will make it red.
  /// Use this for debugging purposes only.
  /// This constructor is marked as deprecated so that you don't forget to remove it.
  @Deprecated("Use this for debugging purposes only.")
  const Box.r({
    Key? key,
    bool show = true,
    // ignore: avoid_unused_constructor_parameters
    Color? color,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    Alignment? alignment,
    Widget? child,
    bool removePaddingWhenNoChild = false,
    Decoration? decoration,
    DecorationPosition decorationPosition = DecorationPosition.background,
  }) : this._(
          key: key,
          show: show,
          color: Colors.red,
          padding: padding,
          width: width,
          height: height,
          alignment: alignment,
          child: child,
          removePaddingWhenNoChild: removePaddingWhenNoChild,
          decoration: decoration,
          decorationPosition: decorationPosition,
          fixedColor: true,
        );

  /// Adding `.g` to the box will make it green.
  /// Use this for debugging purposes only.
  /// This constructor is marked as deprecated so that you don't forget to remove it.
  @Deprecated("Use this for debugging purposes only.")
  const Box.g({
    Key? key,
    bool show = true,
    // ignore: avoid_unused_constructor_parameters
    Color? color,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    Alignment? alignment,
    Widget? child,
    bool removePaddingWhenNoChild = false,
    Decoration? decoration,
    DecorationPosition decorationPosition = DecorationPosition.background,
  }) : this._(
          key: key,
          show: show,
          color: Colors.green,
          padding: padding,
          width: width,
          height: height,
          alignment: alignment,
          child: child,
          removePaddingWhenNoChild: removePaddingWhenNoChild,
          decoration: decoration,
          decorationPosition: decorationPosition,
          fixedColor: true,
        );

  /// Adding `.b` to the box will make it blue.
  /// Use this for debugging purposes only.
  /// This constructor is marked as deprecated so that you don't forget to remove it.
  @Deprecated("Use this for debugging purposes only.")
  const Box.b({
    Key? key,
    bool show = true,
    // ignore: avoid_unused_constructor_parameters
    Color? color,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    Alignment? alignment,
    Widget? child,
    bool removePaddingWhenNoChild = false,
    Decoration? decoration,
    DecorationPosition decorationPosition = DecorationPosition.background,
  }) : this._(
          key: key,
          show: show,
          color: Colors.blue,
          padding: padding,
          width: width,
          height: height,
          alignment: alignment,
          child: child,
          removePaddingWhenNoChild: removePaddingWhenNoChild,
          decoration: decoration,
          decorationPosition: decorationPosition,
          fixedColor: true,
        );

  /// Adding `.y` to the box will make it yellow.
  /// Use this for debugging purposes only.
  /// This constructor is marked as deprecated so that you don't forget to remove it.
  @Deprecated("Use this for debugging purposes only.")
  const Box.y({
    Key? key,
    bool show = true,
    // ignore: avoid_unused_constructor_parameters
    Color? color,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    Alignment? alignment,
    Widget? child,
    bool removePaddingWhenNoChild = false,
    Decoration? decoration,
    DecorationPosition decorationPosition = DecorationPosition.background,
  }) : this._(
          key: key,
          show: show,
          color: Colors.yellow,
          padding: padding,
          width: width,
          height: height,
          alignment: alignment,
          child: child,
          removePaddingWhenNoChild: removePaddingWhenNoChild,
          decoration: decoration,
          decorationPosition: decorationPosition,
          fixedColor: true,
        );

  /// Use the `Box.rand` constructor to see when the widget rebuilds.
  /// It will change its color to a random one, whenever its build method is called.
  /// This constructor is marked as deprecated so that you don't forget to remove it.
  @Deprecated("Use this for debugging purposes only.")
  const Box.rand({
    Key? key,
    this.show = true,
    this.color,
    this.padding,
    this.width,
    this.height,
    this.alignment,
    this.child,
    this.removePaddingWhenNoChild = false,
    this.decoration,
    this.decorationPosition = DecorationPosition.background,
  })  : _random = true,
        _fixedColor = true,
        super(key: key);

  final Color? color;
  final bool show;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final Widget? child;
  final bool _random;
  final bool removePaddingWhenNoChild;
  final Decoration? decoration;
  final DecorationPosition decorationPosition;
  final bool _fixedColor;

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox();
    Widget? current = child;

    if (alignment != null) current = Align(alignment: alignment!, child: current);

    if (padding != null && (child != null || !removePaddingWhenNoChild))
      current = Padding(padding: padding!, child: current);

    var color = this.color;

    if (_random) {
      var rand = Random();

      double r = (color == null)
          ? (30 + rand.nextInt(196)) / 255.0
          : (color.red / 255.0 + rand.nextDouble()) / 2;

      double g = (color == null)
          ? (30 + rand.nextInt(196)) / 255.0
          : (color.green / 255.0 + rand.nextDouble()) / 2;

      double b = (color == null)
          ? (30 + rand.nextInt(196)) / 255.0
          : (color.blue / 255.0 + rand.nextDouble()) / 2;

      color = Color.fromRGBO(
        (r * 255).round(),
        (g * 255).round(),
        (b * 255).round(),
        1.0,
      );
    }

    if (decoration != null) {
      if (color != null) {
        if (decoration is BoxDecoration) {
          BoxDecoration boxDecoration = (decoration as BoxDecoration);

          if (boxDecoration.color != null && !_fixedColor)
            throw ArgumentError(
                "You can't set both 'color' and a 'BoxDecoration' at the same time.");

          current = DecoratedBox(
            decoration: boxDecoration.copyWith(color: color),
            position: decorationPosition,
            child: current,
          );
        }
        //
        else if (decoration is ShapeDecoration) {
          ShapeDecoration shapeDecoration = (decoration as ShapeDecoration);

          if (shapeDecoration.color != null && !_fixedColor)
            throw ArgumentError(
                "You can't set both 'color' and a 'ShapeDecoration' at the same time.");

          current = DecoratedBox(
            decoration: shapeDecoration.copyWith(color: color),
            position: decorationPosition,
            child: current,
          );
        }
        //
        else
          throw ArgumentError(
              "You can't set both 'color' and 'decoration' at the same time. Use only one of them.");
      }
      //
      // Color is null.
      else {
        current = DecoratedBox(
          decoration: decoration!,
          position: decorationPosition,
          child: current,
        );
      }
    }
    //
    else if (color != null)
      current = DecoratedBox(
        decoration: BoxDecoration(color: color),
        child: current,
      );

    if (width != null || height != null)
      current = ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: width, height: height),
        child: current,
      );

    return current ?? Container();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Color>('color', color, defaultValue: null));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding));
    properties.add(DoubleProperty('width', width, defaultValue: null));
    properties.add(DoubleProperty('height', height, defaultValue: null));
    properties.add(DiagnosticsProperty<AlignmentGeometry>('alignment', alignment,
        showName: false, defaultValue: null));
  }

  /// Creates a copy of this Box but with the given fields replaced
  /// with the new values.
  Box copyWith({
    Key? key,
    bool? show,
    Color? color,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    AlignmentGeometry? alignment,
    bool? random,
    Decoration? decoration,
    DecorationPosition? decorationPosition,
    Widget? child,
  }) {
    return Box._(
      key: key ?? this.key,
      show: show ?? this.show,
      color: color ?? this.color,
      padding: padding ?? this.padding,
      width: width ?? this.width,
      height: height ?? this.height,
      alignment: alignment ?? this.alignment,
      random: random ?? _random,
      decoration: decoration ?? this.decoration,
      decorationPosition: decorationPosition ?? this.decorationPosition,
      fixedColor: _fixedColor,
      child: child ?? this.child,
    );
  }

  /// You can create boxes by adding a [Box] to one these types:
  /// [bool], [Color], [EdgeInsetsGeometry], [AlignmentGeometry], or [Widget].
  ///
  /// Examples:
  ///
  /// ```
  /// // To hide the box:
  /// Box(...) + false;
  ///
  /// // To show the box:
  /// Box(...) + true;
  ///
  /// // To change the box color:
  /// Box(...) + Colors.green;
  ///
  /// // To change the box padding:
  /// Box(...) + Pad(all: 10);
  ///
  /// // To substitute the box child:
  /// Box(...) + Text('abc');
  ///
  /// // To put a box inside of another:
  /// Box(...) + Box(...);
  /// ```
  ///
  /// Note: If you add null, that's not an error. It will simply return the same Box.
  /// However, if you add an invalid type it will throw an error in RUNTIME.
  ///
  Box operator +(Object? obj) {
    if (obj == null) return this;

    bool isBool = obj is bool;
    bool isColor = obj is Color;
    bool isEdgeInsetsGeometry = obj is EdgeInsetsGeometry;
    bool isAlignmentGeometry = obj is AlignmentGeometry;
    bool isWidget = obj is Widget;

    if (!isBool && !isColor && !isEdgeInsetsGeometry && !isAlignmentGeometry && !isWidget)
      throw ArgumentError("Can't add Box to ${obj.runtimeType}.");
    else
      return copyWith(
        show: isBool ? obj : null,
        color: isColor ? obj : null,
        padding: isEdgeInsetsGeometry ? obj : null,
        alignment: isAlignmentGeometry ? obj : null,
        child: isWidget ? obj : null,
      );
  }

  /// Return the width/height of the box, if set.
  /// Note this is not the real size of the box, since it ignores the child and the layout.
  Size get size => Size(width ?? 0.0, height ?? 0.0);

  /// Returns a box with its width or height increased by [width] or [height]
  /// (or decreased if the given [width] or [height] are negative, clamped to zero).
  Box add({
    double? width,
    double? height,
  }) =>
      copyWith(
        width: width == null ? this.width : max(0, ((this.height ?? 0.0) + width)),
        height: height == null ? this.height : max(0, ((this.height ?? 0.0) + height)),
      );

  /// Returns a box with its width or height decreased by [width] or [height]
  /// (clamped to zero).
  Box subtract({
    double? width,
    double? height,
  }) =>
      copyWith(
        width: width == null ? this.width : max(0, ((this.width ?? 0.0) - width)),
        height: height == null ? this.height : max(0, ((this.height ?? 0.0) - height)),
      );
}

extension ShapeDecorationCopyWithExtension on ShapeDecoration {
  ShapeDecoration copyWith({
    Color? color,
    DecorationImage? image,
    Gradient? gradient,
    List<BoxShadow>? shadows,
    ShapeBorder? shape,
  }) {
    return ShapeDecoration(
      color: color ?? this.color,
      image: image ?? this.image,
      gradient: gradient ?? this.gradient,
      shadows: shadows ?? this.shadows,
      shape: shape ?? this.shape,
    );
  }
}
