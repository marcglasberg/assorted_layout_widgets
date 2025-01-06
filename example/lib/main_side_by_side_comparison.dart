import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Demo(),
      ),
    );

class Demo extends StatelessWidget {
  const Demo({super.key});

  static var w1 = Box(
    color: Colors.red.withValues(alpha: 0.2),
    child: const Text(
      "Hello there!",
      style: TextStyle(color: Colors.red),
      overflow: TextOverflow.ellipsis,
    ),
  );

  static var w2 = Box(
    color: Colors.blue.withValues(alpha: 0.2),
    child: const Text(
      "How are you doing?",
      style: TextStyle(color: Colors.blue),
      overflow: TextOverflow.ellipsis,
    ),
  );

  static var w3 = Box(
    color: Colors.green.withValues(alpha: 0.2),
    child: const Text(
      "I'm doing fine.",
      style: TextStyle(color: Colors.green),
      overflow: TextOverflow.ellipsis,
    ),
  );

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparing SideBySide/Row/RowSuper',
            style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.blue,
      ),
      body: SizedBox.expand(
        child: Padding(
          padding: const Pad(all: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _content(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //
        const Text("SideBySide", style: TextStyle(fontWeight: FontWeight.bold)),
        const Box(height: 4),
        BoxAnimatingWidth(
          child: Box(
            color: Colors.grey[300],
            width: 120,
            child: SideBySide(children: [w1, w2, w3]),
          ),
        ),
        //
        const Box(height: 30),
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "SideBySide",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: " with gap and fixed last widget",
              ),
            ],
          ),
        ),
        const Box(height: 4),
        BoxAnimatingWidth(
          child: Box(
            color: Colors.grey[300],
            width: 120,
            child: SideBySide(children: [w1, w2, w3], gaps: [35], minEndChildWidth: 95),
          ),
        ),
        //
        const Box(height: 30),
        const Text("Row", style: TextStyle(fontWeight: FontWeight.bold)),
        const Box(height: 4),
        BoxAnimatingWidth(
          child: Box(
            color: Colors.grey[300],
            width: 120,
            child: Row(
              children: [w1, w2, w3],
            ),
          ),
        ),
        //
        const Box(height: 30),
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Row",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: " with Expanded",
              ),
            ],
          ),
        ),
        const Box(height: 4),
        BoxAnimatingWidth(
          child: Box(
            color: Colors.grey[300],
            width: 120,
            child: Row(
              children: [
                Expanded(child: Align(alignment: Alignment.centerLeft, child: w1)),
                Expanded(child: Align(alignment: Alignment.centerLeft, child: w2)),
                Expanded(child: Align(alignment: Alignment.centerLeft, child: w3)),
              ],
            ),
          ),
        ),
        //
        const Box(height: 30),
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Row",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: " with Flexible",
              ),
            ],
          ),
        ),
        const Box(height: 4),
        BoxAnimatingWidth(
          child: Box(
            color: Colors.grey[300],
            width: 120,
            child: Row(
              children: [Flexible(child: w1), Flexible(child: w2), Flexible(child: w3)],
            ),
          ),
        ),
        //
        const Box(height: 30),
        const Text("RowSuper", style: TextStyle(fontWeight: FontWeight.bold)),
        const Box(height: 4),
        BoxAnimatingWidth(
          child: Box(
            color: Colors.grey[300],
            width: 120,
            child: RowSuper(
              children: [w1, w2, w3],
            ),
          ),
        ),
        //
        const Box(height: 30),
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "RowSuper",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: " with `fill: true`",
              ),
            ],
          ),
        ),
        const Box(height: 4),
        BoxAnimatingWidth(
          child: Box(
            color: Colors.grey[300],
            width: 120,
            child: RowSuper(
              fill: true,
              children: [w1, w2, w3],
            ),
          ),
        ),
        //
      ],
    );
  }
}

class BoxAnimatingWidth extends StatefulWidget {
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
    this.minWidth = 100.0,
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

  // late final Animation<double> _widthAnimation;

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
