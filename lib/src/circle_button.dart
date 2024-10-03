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
    bool debugShowClickableArea = false,
  })  : colorOfClickableArea =
            debugShowClickableArea ? const Color(0xBBFF0000) : const Color(0x00000000),
        super(key: key);

  @override
  State<CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<CircleButton> {
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
      cursor: widget.cursor ?? MouseCursor.defer,
      child: Button(
        onTap: widget.onTap,
        minVisualTapDuration: CircleButton.minVisualTapDuration,
        builder: ({required bool isPressed}) {
          var child = widget.icon;

          if (widget.iconPadding != null)
            child = Padding(
              padding: widget.iconPadding!,
              child: widget.icon,
            );

          return Container(
            color: widget.colorOfClickableArea,
            padding: widget.clickAreaMargin,
            child: Container(
                height: widget.size,
                width: widget.size,
                decoration: BoxDecoration(
                  border: widget.border,
                  color: isPressed
                      ? widget.tapColor
                      : (isHover
                          ? (widget.hoverColor ?? widget.backgroundColor)
                          : widget.backgroundColor),
                  shape: BoxShape.circle,
                  boxShadow: (isPressed || widget.elevation == null || widget.elevation == 0.0)
                      ? null
                      : [
                          BoxShadow(
                            color: const Color(0x60000000),
                            offset: Offset(widget.elevation! / 2, widget.elevation!),
                            blurRadius: widget.elevation!,
                          ),
                          BoxShadow(
                            color: const Color(0xFFFFFFFF),
                            blurRadius: widget.elevation!,
                          ),
                        ],
                ),
                child: child),
          );
        },
      ),
    );
  }
}
