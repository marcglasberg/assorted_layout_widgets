import "dart:async";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

typedef ButtonBuilder = Widget Function({
  /// True when the button is tapped-down.
  required bool isPressed,
});

/// Transforms any widget in a button, with visual feedback in the onPointerDown.
/// The widget must be created with a [builder] of type [ButtonBuilder], which provides an
/// [isPressed] boolean to indicate whether the button is pressed or not.
///
/// Thus, the widget can change its look according to these values.
///
/// There are 3 possibilities to detect gestures:
///
/// 1) Use the [onTap] parameter.
///
/// 2) The widget itself can contain a [GestureDetector].
///
/// 3) The Button can be inside a parent that detects gestures. Even with a null [onTap], the look
/// still changes when you touch the button. This allows the button to be used inside other widgets
/// that detect gestures. Note that [isPressed] is changed immediately as soon as the user touches
/// the button, through a listener, which is faster than GestureDetector (which has a delay to
/// differentiate between the various types of gestures).
///
class Button extends StatefulWidget {
  //
  static const delayMillis = 75;

  final ButtonBuilder builder;
  final VoidCallback? onTap;
  final VoidCallback? onDragUp;

  /// You should pass delay=true only when the widget is inside a scrollable. This makes the button
  /// color change wait a few milliseconds (for when the user actually wants to start a scroll and
  /// not press the button).
  final bool delay;

  /// The minimum duration you want the button to show it was tapped.
  final Duration? minVisualTapDuration;

  /// The button does not allow calling [onTap] more than once per [tapThrottle]. Note: Visually it
  /// may appear to respond, but [onTap] is not called. Note: If [tapThrottle] doesn't seem to be
  /// working, check that you're not accidentally calling initState. Obviously, initState resets
  /// the time count.
  final Duration? tapThrottle;

  /// If [disable] is true, the [onTap] and [onDragUp] won't work.
  final bool disable;

  final EdgeInsetsGeometry? clickAreaMargin;

  final Color colorOfClickableArea;

  const Button({
    Key? key,
    required this.builder,
    required this.onTap,
    bool? disable,
    this.onDragUp,
    this.delay = false,
    this.minVisualTapDuration,
    this.tapThrottle,
    this.clickAreaMargin,
    bool debugShowClickableArea = false,
  })  : disable = disable ?? false,
        colorOfClickableArea =
            debugShowClickableArea ? const Color(0xBBFF0000) : const Color(0x00000000),
        super(key: key);

  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  //
  late bool _isPressed;
  late int _keepPressedCount;
  Offset? _offset;
  DateTime? _lastTap;
  double? dragStartPosition;

  @override
  void initState() {
    super.initState();
    _isPressed = false;
    _keepPressedCount = 0;
  }

  Timer? timer;

  @override
  Widget build(BuildContext context) {
    //
    // Here we use a listener, not a GestureDetector, because we want
    // allow the parent to detect the tap when [onTap] is null.
    var listener = Listener(
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: widget.colorOfClickableArea,
        padding: widget.clickAreaMargin,
        child: widget.builder(isPressed: _isPressed),
      ),

      // Visual change starts on onPointerDown.
      onPointerDown: (_) {
        timer?.cancel();
        _offset = Offset.zero;

        void start() {
          _isPressed = true;
          _keepPressedCount++;
        }

        if (!_isPressed && mounted) {
          //

          if (widget.delay)
            timer = Timer(const Duration(milliseconds: Button.delayMillis), () {
              if (mounted) setState(start);
            });
          //
          else {
            setState(start);
          }
        }
      },

      // Visual change ends if you move too far away from the initial position..
      onPointerMove: (evt) {
        if (_offset != null) {
          _offset = _offset! + evt.delta;
          if (mounted) {
            if (_offset!.distance > 18) {
              if (_isPressed)
                _ends();
              else {
                _offset = null;
                timer?.cancel();
              }
            }
          }
        }
      },

      // Visual change also ends if you cancel by removing the pointer.
      onPointerCancel: (_) {
        if (mounted && _isPressed) _ends();
      },

      // Visual change also ends if you cancel by removing the pointer.
      // Waits a minimum of 100 milliseconds for the effect to appear
      // (but tap occurs immediately).
      onPointerUp: (_) {
        if (mounted) _endsWithTouch();
      },
    );

    // ---

    // If onTap and onDragUp are null, changes the visuals only.
    if ((widget.onTap == null && onDragUp == null) || widget.disable)
      return listener;
    //
    // If onTap is NOT null, changes the visuals and also detects the gesture.
    else
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        //
        onVerticalDragStart: (onDragUp == null)
            ? null
            : (DragStartDetails details) {
                dragStartPosition = details.localPosition.dy;
              },
        onVerticalDragUpdate: (onDragUp == null)
            ? null
            : (DragUpdateDetails details) {
                var dragPosition = details.localPosition.dy;
                if ((dragStartPosition != null) && dragPosition - dragStartPosition! < -15.0) {
                  dragStartPosition = null;
                  onDragUp!();
                }
              },
        onVerticalDragEnd: (onDragUp == null)
            ? null
            : (DragEndDetails details) {
                dragStartPosition = null;
              },
        child: listener,
      );
  }

  void _ends() {
    timer?.cancel();
    _offset = null;

    setState(() {
      _isPressed = false;
    });
    _keepPressedCount++;
  }

  void _endsWithTouch() {
    timer?.cancel();

    if (widget.minVisualTapDuration == null)
      setState(() {
        _isPressed = false;
      });
    else {
      var _count = _keepPressedCount;
      Future.delayed(widget.minVisualTapDuration!, () {
        if ((_count == _keepPressedCount) && mounted && _isPressed)
          setState(() {
            _isPressed = false;
          });
      });
    }
  }

  VoidCallback? get onDragUp => widget.onDragUp;

  void _onTap() {
    if (widget.onTap == null) return;
    // ---

    if (widget.tapThrottle == null) {
      widget.onTap!();
      return;
    }
    //
    else {
      DateTime currentDayTime = DateTime.now();

      var ifTheTimePassed =
          (_lastTap == null) || ((currentDayTime.difference(_lastTap!)) > widget.tapThrottle!);

      if (ifTheTimePassed) {
        _lastTap = currentDayTime;
        widget.onTap!();
      }
    }
  }
}
