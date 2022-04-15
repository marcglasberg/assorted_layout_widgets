import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

// ////////////////////////////////////////////////////////////////////////////

class ButtonBarSuper extends StatelessWidget {
  //
  /// Overrides the surrounding [ButtonBarThemeData.buttonTextTheme] to define a
  /// button's base colors, size, internal padding and shape.
  ///
  /// If null then it will use the surrounding
  /// [ButtonBarThemeData.buttonTextTheme]. If that is null, it will default to
  /// [ButtonTextTheme.primary].
  final ButtonTextTheme? buttonTextTheme;

  /// Overrides the surrounding [ButtonThemeData.minWidth] to define a button's
  /// minimum width.
  ///
  /// If null then it will use the surrounding [ButtonBarThemeData.buttonMinWidth].
  /// If that is null, it will default to 64.0 logical pixels.
  final double? buttonMinWidth;

  /// Overrides the surrounding [ButtonThemeData.height] to define a button's
  /// minimum height.
  ///
  /// If null then it will use the surrounding [ButtonBarThemeData.buttonHeight].
  /// If that is null, it will default to 36.0 logical pixels.
  final double? buttonHeight;

  /// Overrides the surrounding [ButtonThemeData.padding] to define the padding
  /// for a button's child (typically the button's label).
  ///
  /// If null then it will use the surrounding [ButtonBarThemeData.buttonPadding].
  /// If that is null, it will default to 8.0 logical pixels on the left
  /// and right.
  final EdgeInsetsGeometry? buttonPadding;

  /// Defines whether a [ButtonBar] should size itself with a minimum size
  /// constraint or with padding.
  ///
  /// Overrides the surrounding [ButtonThemeData.layoutBehavior].
  ///
  /// If null then it will use the surrounding [ButtonBarThemeData.layoutBehavior].
  /// If that is null, it will default [ButtonBarLayoutBehavior.padded].
  final ButtonBarLayoutBehavior? layoutBehavior;

  final WrapSuperAlignment alignment;

  /// Defaults to 0.0.
  final double spacing;

  /// Defaults to 0.0.
  final double lineSpacing;

  final WrapType wrapType;

  final WrapFit wrapFit;

  /// The buttons to arrange horizontally.
  /// Typically [ElevatedButton] or [TextButton] widgets.
  final List<Widget> children;

  const ButtonBarSuper({
    this.buttonTextTheme,
    this.buttonMinWidth,
    this.buttonHeight,
    this.buttonPadding,
    this.layoutBehavior,
    this.wrapType = WrapType.balanced,
    this.wrapFit = WrapFit.larger,
    this.spacing = 0.0,
    this.lineSpacing = 0.0,
    this.alignment = WrapSuperAlignment.left,
    this.children = const <Widget>[],
  });

  @override
  Widget build(BuildContext context) {
    final ButtonThemeData parentButtonTheme = ButtonTheme.of(context);
    final ButtonBarThemeData barTheme = ButtonBarTheme.of(context);

    final ButtonThemeData buttonTheme = parentButtonTheme.copyWith(
      textTheme: buttonTextTheme ??
          barTheme.buttonTextTheme ??
          ButtonTextTheme.primary,
      minWidth: buttonMinWidth ?? barTheme.buttonMinWidth ?? 64.0,
      height: buttonHeight ?? barTheme.buttonHeight ?? 36.0,
      padding: buttonPadding ??
          barTheme.buttonPadding ??
          const EdgeInsets.symmetric(horizontal: 8.0),
      layoutBehavior: layoutBehavior ??
          barTheme.layoutBehavior ??
          ButtonBarLayoutBehavior.padded,
    );

    // We divide by 4.0 because we want half of the average of the left and right padding.
    final double paddingUnit = buttonTheme.padding.horizontal / 4.0;
    final Widget child = ButtonTheme.fromButtonThemeData(
      data: buttonTheme,
      child: WrapSuper(
        wrapType: wrapType,
        wrapFit: wrapFit,
        spacing: spacing,
        lineSpacing: lineSpacing,
        alignment: alignment,
        children: children.map<Widget>((Widget child) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingUnit),
            child: child,
          );
        }).toList(),
      ),
    );

    switch (buttonTheme.layoutBehavior) {
      case ButtonBarLayoutBehavior.padded:
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: 2.0 * paddingUnit,
            horizontal: paddingUnit,
          ),
          child: child,
        );
      case ButtonBarLayoutBehavior.constrained:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: paddingUnit),
          constraints: const BoxConstraints(minHeight: 52.0),
          alignment: Alignment.center,
          child: child,
        );
    }
  }
}
