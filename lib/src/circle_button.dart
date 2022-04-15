import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import "package:flutter/material.dart";

/// Circular button, similar to IconButton, but with the following differences:
///
/// 1) A [clickAreaMargin] can be set, defining a rectangle around the circle, and all that
/// rectangle is clickable, so that it's easier to click the button.
///
/// 2) The [tapColor] is shown in the tap-down, faster than the GestureDetector.
///
/// 3) if [onTap] is null, still the tapColor will be applied. This allows the button to be used
/// inside of other widgets that detect gestures.
///
/// 4) Pass [debugShowClickableArea] true to see the clickable area.
///
class CircleButton extends StatelessWidget {
  //
  static const defaultSize = 44.0;

  static const minVisualTapDuration = Duration(milliseconds: 100);

  final Widget icon;
  final EdgeInsetsGeometry? clickAreaMargin;
  final EdgeInsetsGeometry? iconPadding;
  final Border? border;
  final Color? tapColor;
  final Color colorOfClickableArea;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final double size;
  final double? elevation;

  const CircleButton({
    Key? key,
    required this.icon,
    this.clickAreaMargin = const Pad(all: 3.0, left: 3.5),
    this.tapColor = Colors.white24,
    this.border,
    this.onTap,
    this.backgroundColor = Colors.transparent,
    this.size = defaultSize,
    this.iconPadding,
    this.elevation,
    bool debugShowClickableArea = false,
  })  : colorOfClickableArea =
            debugShowClickableArea ? const Color(0xBBFF0000) : const Color(0x00000000),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    //
    return Button(
      onTap: onTap,
      minVisualTapDuration: minVisualTapDuration,
      builder: ({required bool isPressed}) {
        var child = icon;

        if (iconPadding != null)
          child = Padding(
            padding: iconPadding!,
            child: icon,
          );

        return Container(
          color: colorOfClickableArea,
          padding: clickAreaMargin,
          child: Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                border: border,
                color: isPressed ? tapColor : backgroundColor,
                shape: BoxShape.circle,
                boxShadow: (isPressed || elevation == null || elevation == 0.0)
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
                      ],
              ),
              child: child),
        );
      },
    );
  }
}
