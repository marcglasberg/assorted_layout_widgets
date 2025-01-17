import 'package:flutter/material.dart';

/// This widget is meant only to be used for layout demonstrations of other widgets.
///
/// The child widget will be wrapped in a container that animates its width,
/// between [maxWidth] and [minWidth], with the given [border] around it.
/// The animation will repeat indefinitely. It takes [moveDuration] to move from
/// [maxWidth] to [minWidth] and vice versa. It will hold at [maxWidth] for
/// [maxHoldDuration] and at [minWidth] for [minHoldDuration].
///
class BoxAnimatingWidth extends StatefulWidget {
  //
  final Widget child;
  final double minWidth;
  final double? maxWidth;
  final Duration moveDuration;
  final Duration maxHoldDuration;
  final Duration minHoldDuration;
  final Border? border;

  const BoxAnimatingWidth({
    Key? key,
    required this.child,
    this.minWidth = 80.0,
    this.maxWidth,
    this.moveDuration = const Duration(milliseconds: 3500),
    this.maxHoldDuration = const Duration(seconds: 1),
    this.minHoldDuration = const Duration(seconds: 1),
    this.border,
  }) : super(key: key);

  @override
  State<BoxAnimatingWidth> createState() => _BoxAnimatingWidthState();
}

class _BoxAnimatingWidthState extends State<BoxAnimatingWidth>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Total duration is the sum of all durations.
    final totalDuration =
        widget.moveDuration * 2 + widget.maxHoldDuration + widget.minHoldDuration;

    _controller = AnimationController(
      vsync: this,
      duration: totalDuration,
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double parentWidth = constraints.maxWidth;

        final Animation<double> _widthAnimation = TweenSequence<double>([
          TweenSequenceItem(
            tween:
                Tween<double>(begin: widget.maxWidth ?? parentWidth, end: widget.minWidth)
                    .chain(CurveTween(curve: Curves.easeInOut)),
            weight: widget.moveDuration.inMilliseconds.toDouble(),
          ),
          TweenSequenceItem(
            tween: ConstantTween<double>(widget.minWidth),
            weight: widget.minHoldDuration.inMilliseconds.toDouble(),
          ),
          TweenSequenceItem(
            tween:
                Tween<double>(begin: widget.minWidth, end: widget.maxWidth ?? parentWidth)
                    .chain(CurveTween(curve: Curves.easeInOut)),
            weight: widget.moveDuration.inMilliseconds.toDouble(),
          ),
          TweenSequenceItem(
            tween: ConstantTween<double>(widget.maxWidth ?? parentWidth),
            weight: widget.maxHoldDuration.inMilliseconds.toDouble(),
          ),
        ]).animate(_controller);

        return AnimatedBuilder(
          animation: _widthAnimation,
          builder: (context, child) {
            return Container(
              width: _widthAnimation.value,
              constraints: const BoxConstraints(minHeight: 10),
              decoration: BoxDecoration(
                border: widget.border ?? Border.all(color: Colors.black, width: 1),
              ),
              child: widget.child,
            );
          },
        );
      },
    );
  }
}
