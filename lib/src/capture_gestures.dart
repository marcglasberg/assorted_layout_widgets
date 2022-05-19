import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// All touches in the [child] will be captured and ignored.
///
/// This is different from [IgnorePointer] and [AbsorbPointer].
///
class CaptureGestures extends StatelessWidget {
  //
  final Widget? child;

  /// Turns on/off the capturing of tap gestures.
  final bool capturingTap;

  /// Turns on/off the capturing of double-tap gestures.
  final bool capturingDoubleTap;

  /// Turns on/off the capturing of long-press gestures.
  final bool capturingLongPress;

  /// Turns on/off the capturing of vertical-drag gestures.
  final bool capturingVerticalDrag;

  /// Turns on/off the capturing of horizontal-drag gestures.
  final bool capturingHorizontalDrag;

  /// Turns on/off the capturing of force-press gestures.
  final bool capturingForcePress;

  /// If true, prints the captured events to the console (for debug reasons only).
  /// The default is false.
  final bool display;

  /// Captures only the specified gestures.
  const CaptureGestures.only({
    Key? key,
    this.child,
    this.capturingTap = false,
    this.capturingDoubleTap = false,
    this.capturingLongPress = false,
    this.capturingVerticalDrag = false,
    this.capturingHorizontalDrag = false,
    this.capturingForcePress = false,
    this.display = false,
  }) : super(key: key);

  /// Captures all gestures.
  const CaptureGestures.all({
    Key? key,
    this.child,
    this.capturingTap = true,
    this.capturingDoubleTap = true,
    this.capturingLongPress = true,
    this.capturingVerticalDrag = true,
    this.capturingHorizontalDrag = true,
    this.capturingForcePress = true,
    this.display = false,
  }) : super(key: key);

  /// Captures only single taps.
  const CaptureGestures.tap({
    Key? key,
    this.child,
    bool capturing = true,
    this.display = false,
  })  : capturingTap = capturing,
        capturingDoubleTap = false,
        capturingLongPress = false,
        capturingVerticalDrag = false,
        capturingHorizontalDrag = false,
        capturingForcePress = false,
        super(key: key);

  /// Captures only drag gestures (preventing both vertical and horizontal scroll).
  const CaptureGestures.scroll({
    Key? key,
    this.child,
    bool capturing = true,
    this.display = false,
  })  : capturingTap = false,
        capturingDoubleTap = false,
        capturingLongPress = false,
        capturingVerticalDrag = capturing,
        capturingHorizontalDrag = capturing,
        capturingForcePress = false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      dragStartBehavior: DragStartBehavior.start,
      //
      onTap: capturingTap ? () => _print('onTap') : null,
      onTapDown: capturingTap ? (_) => _print('onTapDown') : null,
      onTapUp: capturingTap ? (_) => _print('onTapUp') : null,
      onTapCancel: capturingTap ? () => _print('onTapCancel') : null,
      onSecondaryTap: capturingTap ? () => _print('onSecondaryTap') : null,
      onSecondaryTapDown: capturingTap ? (_) => _print('onSecondaryTapDown') : null,
      onSecondaryTapUp: capturingTap ? (_) => _print('onSecondaryTapUp') : null,
      onSecondaryTapCancel: capturingTap ? () => _print('onSecondaryTapCancel') : null,
      onTertiaryTapDown: capturingTap ? (_) => _print('onTertiaryTapDown') : null,
      onTertiaryTapUp: capturingTap ? (_) => _print('onTertiaryTapUp') : null,
      onTertiaryTapCancel: capturingTap ? () => _print('onTertiaryTapCancel') : null,
      //
      onDoubleTapDown: capturingDoubleTap ? (_) => _print('onDoubleTapDown') : null,
      onDoubleTap: capturingDoubleTap ? () => _print('onDoubleTap') : null,
      onDoubleTapCancel: capturingDoubleTap ? () => _print('onDoubleTapCancel') : null,
      //
      onLongPressDown: capturingLongPress ? (_) => _print('onLongPressDown') : null,
      onLongPressCancel: capturingLongPress ? () => _print('onLongPressCancel') : null,
      onLongPress: capturingLongPress ? () => _print('onLongPress') : null,
      onLongPressStart: capturingLongPress ? (_) => _print('onLongPressStart') : null,
      onLongPressMoveUpdate: capturingLongPress ? (_) => _print('onLongPressMoveUpdate') : null,
      onLongPressUp: capturingLongPress ? () => _print('onLongPressUp') : null,
      onLongPressEnd: capturingLongPress ? (_) => _print('onLongPressEnd') : null,
      onSecondaryLongPressDown:
          capturingLongPress ? (_) => _print('onSecondaryLongPressDown') : null,
      onSecondaryLongPressCancel:
          capturingLongPress ? () => _print('onSecondaryLongPressCancel') : null,
      onSecondaryLongPress: capturingLongPress ? () => _print('onSecondaryLongPress') : null,
      onSecondaryLongPressStart:
          capturingLongPress ? (_) => _print('onSecondaryLongPressStart') : null,
      onSecondaryLongPressMoveUpdate:
          capturingLongPress ? (_) => _print('onSecondaryLongPressMoveUpdate') : null,
      onSecondaryLongPressUp: capturingLongPress ? () => _print('onSecondaryLongPressUp') : null,
      onSecondaryLongPressEnd: capturingLongPress ? (_) => _print('onSecondaryLongPressEnd') : null,
      onTertiaryLongPressDown: capturingLongPress ? (_) => _print('onTertiaryLongPressDown') : null,
      onTertiaryLongPressCancel:
          capturingLongPress ? () => _print('onTertiaryLongPressCancel') : null,
      onTertiaryLongPress: capturingLongPress ? () => _print('onTertiaryLongPress') : null,
      onTertiaryLongPressStart:
          capturingLongPress ? (_) => _print('onTertiaryLongPressStart') : null,
      onTertiaryLongPressMoveUpdate:
          capturingLongPress ? (_) => _print('onTertiaryLongPressMoveUpdate') : null,
      onTertiaryLongPressUp: capturingLongPress ? () => _print('onTertiaryLongPressUp') : null,
      onTertiaryLongPressEnd: capturingLongPress ? (_) => _print('onTertiaryLongPressEnd') : null,
      //
      onVerticalDragDown: capturingVerticalDrag ? (_) => _print('onVerticalDragDown') : null,
      onVerticalDragStart: capturingVerticalDrag ? (_) => _print('onVerticalDragStart') : null,
      onVerticalDragUpdate: capturingVerticalDrag ? (_) => _print('onVerticalDragUpdate') : null,
      onVerticalDragEnd: capturingVerticalDrag ? (_) => _print('onVerticalDragEnd') : null,
      onVerticalDragCancel: capturingVerticalDrag ? () => _print('onVerticalDragCancel') : null,
      onHorizontalDragDown: capturingHorizontalDrag ? (_) => _print('onHorizontalDragDown') : null,
      onHorizontalDragStart:
          capturingHorizontalDrag ? (_) => _print('onHorizontalDragStart') : null,
      onHorizontalDragUpdate:
          capturingHorizontalDrag ? (_) => _print('onHorizontalDragUpdate') : null,
      onHorizontalDragEnd: capturingHorizontalDrag ? (_) => _print('onHorizontalDragEnd') : null,
      onHorizontalDragCancel:
          capturingHorizontalDrag ? () => _print('onHorizontalDragCancel') : null,
      //
      onForcePressStart: capturingForcePress ? (_) => _print('onForcePressStart') : null,
      onForcePressPeak: capturingForcePress ? (_) => _print('onForcePressPeak') : null,
      onForcePressUpdate: capturingForcePress ? (_) => _print('onForcePressUpdate') : null,
      onForcePressEnd: capturingForcePress ? (_) => _print('onForcePressEnd') : null,
      child: child,
    );
  }

  void _print(String info) {
    if (display) print(info);
  }
}
