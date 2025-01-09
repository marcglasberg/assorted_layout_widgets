import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import "package:flutter/material.dart";

typedef CircleButtonBuilder = Widget Function({
  required bool isHover, // True when the mouse is over the button.
  required bool isPressed, // True when the button is tapped-down.
  required Widget child, // The widget that's displayed when there is no builder.
});

/// Circular button, similar to IconButton, but with the following differences:
///
/// - The [icon] will be displayed inside the button.
///
/// - A [clickAreaMargin] can be set, defining a rectangle around the circle, and all
///   that rectangle is clickable, so that it's easier to click the button.
///
/// - The [backgroundColor]: The background color of the button.
///
/// - The [tapColor] is shown when the button is tapped-down.
///
/// - The [hoverColor] is shown when the mouse is over the button.
///
/// - [elevation]: The elevation of the button.
///
/// - The [onTap] is the callback called when the button is tapped. If it's null,
///   the tapColor will still be applied. This allows the button to be used inside of
///   other widgets that detect gestures.
///
/// - [size]: The size of the button.
///
/// - [iconPadding]: The padding around the icon inside the button.
///
/// - [border]: The border of the button.
///
/// - [cursor]: The mouse cursor to be shown when hovering over the button.
///
/// - [clickAreaMargin]: The margin around the circle that is also clickable.
///
/// - [colorOfClickableArea] is the color of the clickable area, which is only shown
///   when [debugShowClickableArea] is set to true, for debugging purposes. Otherwise,
///   it's transparent.
///
/// - [builder]: An optional custom builder function to modify the button's child widget.
///   This can be used to animate the button when the button is tapped, or when the
///   mouse is over it.
///
class CircleButton extends StatefulWidget {
  //
  static const defaultSize = 44.0;

  static const minVisualTapDuration = Duration(milliseconds: 100);

  final Widget icon;
  final EdgeInsetsGeometry? clickAreaMargin;
  final EdgeInsetsGeometry? iconPadding;
  final Border? border;
  final Color? tapColor, hoverColor;
  final Color colorOfClickableArea;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final double size;
  final double? elevation;
  final MouseCursor? cursor;

  /// The builder can be used to animate the button when the button is tapped,
  /// or when the mouse is over it.
  final CircleButtonBuilder? builder;

  /// Circular button, similar to IconButton, but with the following differences:
  ///
  /// - The [icon] will be displayed inside the button.
  ///
  /// - A [clickAreaMargin] can be set, defining a rectangle around the circle, and all
  ///   that rectangle is clickable, so that it's easier to click the button.
  ///
  /// - The [backgroundColor]: The background color of the button.
  ///
  /// - The [tapColor] is shown when the button is tapped-down.
  ///
  /// - The [hoverColor] is shown when the mouse is over the button.
  ///
  /// - [elevation]: The elevation of the button.
  ///
  /// - The [onTap] is the callback called when the button is tapped. If it's null,
  ///   the tapColor will still be applied. This allows the button to be used inside of
  ///   other widgets that detect gestures.
  ///
  /// - [size]: The size of the button.
  ///
  /// - [iconPadding]: The padding around the icon inside the button.
  ///
  /// - [border]: The border of the button.
  ///
  /// - [cursor]: The mouse cursor to be shown when hovering over the button.
  ///
  /// - [clickAreaMargin]: The margin around the circle that is also clickable.
  ///
  /// - [colorOfClickableArea] is the color of the clickable area, which is only shown
  ///   when [debugShowClickableArea] is set to true, for debugging purposes. Otherwise,
  ///   it's transparent.
  ///
  /// - [builder]: An optional custom builder function to modify the button's child widget.
  ///   This can be used to animate the button when the button is tapped, or when the
  ///   mouse is over it.
  ///
  const CircleButton({
    Key? key,
    required this.icon,
    this.clickAreaMargin = const Pad(all: 3.0, left: 3.5),
    this.tapColor = Colors.white24,
    this.hoverColor,
    this.border,
    this.onTap,
    this.backgroundColor = Colors.transparent,
    this.size = defaultSize,
    this.iconPadding,
    this.elevation,
    this.cursor = SystemMouseCursors.click,
    this.builder,
    bool debugShowClickableArea = false,
  })  : colorOfClickableArea =
            debugShowClickableArea ? const Color(0xBBFF0000) : const Color(0x00000000),
        super(key: key);

  @override
  State<CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<CircleButton> {
  //
  Widget get icon => widget.icon;

  EdgeInsetsGeometry? get clickAreaMargin => widget.clickAreaMargin;

  EdgeInsetsGeometry? get iconPadding => widget.iconPadding;

  Border? get border => widget.border;

  Color? get tapColor => widget.tapColor;

  Color? get hoverColor => widget.hoverColor;

  Color get colorOfClickableArea => widget.colorOfClickableArea;

  Color get backgroundColor => widget.backgroundColor;

  VoidCallback? get onTap => widget.onTap;

  double get size => widget.size;

  double? get elevation => widget.elevation;

  MouseCursor? get cursor => widget.cursor;

  CircleButtonBuilder? get builder => widget.builder;

  bool isHover = false;

  void _onEnter(_) {
    setState(() {
      isHover = true;
    });
  }

  void _onExit(_) {
    setState(() {
      isHover = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    //
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      cursor: cursor ?? MouseCursor.defer,
      child: Button(
        onTap: onTap,
        minVisualTapDuration: CircleButton.minVisualTapDuration,
        builder: ({required bool isPressed}) {
          return Container(
              color: colorOfClickableArea,
              padding: clickAreaMargin,
              child: (builder == null)
                  ? _content(isPressed)
                  : builder!(
                      isHover: isHover,
                      isPressed: isPressed,
                      child: _content(isPressed)));
        },
      ),
    );
  }

  Container _content(bool isPressed) {
    return Container(
      height: size,
      width: size,
      decoration: _decoration(isPressed),
      child: icon,
    );
  }

  BoxDecoration _decoration(bool isPressed) {
    return BoxDecoration(
      border: border,
      color: isPressed
          ? tapColor
          : (isHover ? (hoverColor ?? backgroundColor) : backgroundColor),
      shape: BoxShape.circle,
      boxShadow: _boxShadow(isPressed),
    );
  }

  List<BoxShadow>? _boxShadow(bool isPressed) {
    return (isPressed || elevation == null || elevation == 0.0)
        ? null
        : [
            BoxShadow(
              color: const Color(0x60000000),
              offset: Offset(elevation! / 2, elevation!),
              blurRadius: elevation!,
            ),
            BoxShadow(
              color: const Color(0xFFFFFFFF),
              blurRadius: elevation!,
            ),
          ];
  }
}
