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
  final bool capturingHorizontal;

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
    this.capturingHorizontal = false,
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
    this.capturingHorizontal = true,
    this.capturingForcePress = true,
    this.display = false,
  }) : super(key: key);

  /// Captures only single taps.
  const CaptureGestures.tap({
    Key? key,
    this.child,
    this.display = false,
  })  : capturingTap = true,
        capturingDoubleTap = false,
        capturingLongPress = false,
        capturingVerticalDrag = false,
        capturingHorizontal = false,
        capturingForcePress = false,
        super(key: key);

  /// Captures only drag gestures (preventing both vertical and horizontal scroll).
  const CaptureGestures.scroll({
    Key? key,
    this.child,
    this.display = false,
  })  : capturingTap = false,
        capturingDoubleTap = false,
        capturingLongPress = false,
        capturingVerticalDrag = true,
        capturingHorizontal = true,
        capturingForcePress = false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      dragStartBehavior: DragStartBehavior.start,
      //
      onTap: capturingTap ? () => print('onTap') : null,
      onTapDown: capturingTap ? (_) => print('onTapDown') : null,
      onTapUp: capturingTap ? (_) => print('onTapUp') : null,
      onTapCancel: capturingTap ? () => print('onTapCancel') : null,
      onSecondaryTap: capturingTap ? () => print('onSecondaryTap') : null,
      onSecondaryTapDown: capturingTap ? (_) => print('onSecondaryTapDown') : null,
      onSecondaryTapUp: capturingTap ? (_) => print('onSecondaryTapUp') : null,
      onSecondaryTapCancel: capturingTap ? () => print('onSecondaryTapCancel') : null,
      onTertiaryTapDown: capturingTap ? (_) => print('onTertiaryTapDown') : null,
      onTertiaryTapUp: capturingTap ? (_) => print('onTertiaryTapUp') : null,
      onTertiaryTapCancel: capturingTap ? () => print('onTertiaryTapCancel') : null,
      //
      onDoubleTapDown: capturingDoubleTap ? (_) => print('onDoubleTapDown') : null,
      onDoubleTap: capturingDoubleTap ? () => print('onDoubleTap') : null,
      onDoubleTapCancel: capturingDoubleTap ? () => print('onDoubleTapCancel') : null,
      //
      onLongPressDown: capturingLongPress ? (_) => print('onLongPressDown') : null,
      onLongPressCancel: capturingLongPress ? () => print('onLongPressCancel') : null,
      onLongPress: capturingLongPress ? () => print('onLongPress') : null,
      onLongPressStart: capturingLongPress ? (_) => print('onLongPressStart') : null,
      onLongPressMoveUpdate: capturingLongPress ? (_) => print('onLongPressMoveUpdate') : null,
      onLongPressUp: capturingLongPress ? () => print('onLongPressUp') : null,
      onLongPressEnd: capturingLongPress ? (_) => print('onLongPressEnd') : null,
      onSecondaryLongPressDown:
          capturingLongPress ? (_) => print('onSecondaryLongPressDown') : null,
      onSecondaryLongPressCancel:
          capturingLongPress ? () => print('onSecondaryLongPressCancel') : null,
      onSecondaryLongPress: capturingLongPress ? () => print('onSecondaryLongPress') : null,
      onSecondaryLongPressStart:
          capturingLongPress ? (_) => print('onSecondaryLongPressStart') : null,
      onSecondaryLongPressMoveUpdate:
          capturingLongPress ? (_) => print('onSecondaryLongPressMoveUpdate') : null,
      onSecondaryLongPressUp: capturingLongPress ? () => print('onSecondaryLongPressUp') : null,
      onSecondaryLongPressEnd: capturingLongPress ? (_) => print('onSecondaryLongPressEnd') : null,
      onTertiaryLongPressDown: capturingLongPress ? (_) => print('onTertiaryLongPressDown') : null,
      onTertiaryLongPressCancel:
          capturingLongPress ? () => print('onTertiaryLongPressCancel') : null,
      onTertiaryLongPress: capturingLongPress ? () => print('onTertiaryLongPress') : null,
      onTertiaryLongPressStart:
          capturingLongPress ? (_) => print('onTertiaryLongPressStart') : null,
      onTertiaryLongPressMoveUpdate:
          capturingLongPress ? (_) => print('onTertiaryLongPressMoveUpdate') : null,
      onTertiaryLongPressUp: capturingLongPress ? () => print('onTertiaryLongPressUp') : null,
      onTertiaryLongPressEnd: capturingLongPress ? (_) => print('onTertiaryLongPressEnd') : null,
      //
      onVerticalDragDown: capturingVerticalDrag ? (_) => print('onVerticalDragDown') : null,
      onVerticalDragStart: capturingVerticalDrag ? (_) => print('onVerticalDragStart') : null,
      onVerticalDragUpdate: capturingVerticalDrag ? (_) => print('onVerticalDragUpdate') : null,
      onVerticalDragEnd: capturingVerticalDrag ? (_) => print('onVerticalDragEnd') : null,
      onVerticalDragCancel: capturingVerticalDrag ? () => print('onVerticalDragCancel') : null,
      onHorizontalDragDown: capturingHorizontal ? (_) => print('onHorizontalDragDown') : null,
      onHorizontalDragStart: capturingHorizontal ? (_) => print('onHorizontalDragStart') : null,
      onHorizontalDragUpdate: capturingHorizontal ? (_) => print('onHorizontalDragUpdate') : null,
      onHorizontalDragEnd: capturingHorizontal ? (_) => print('onHorizontalDragEnd') : null,
      onHorizontalDragCancel: capturingHorizontal ? () => print('onHorizontalDragCancel') : null,
      //
      onForcePressStart: capturingForcePress ? (_) => print('onForcePressStart') : null,
      onForcePressPeak: capturingForcePress ? (_) => print('onForcePressPeak') : null,
      onForcePressUpdate: capturingForcePress ? (_) => print('onForcePressUpdate') : null,
      onForcePressEnd: capturingForcePress ? (_) => print('onForcePressEnd') : null,
      child: child,
    );
  }
}
