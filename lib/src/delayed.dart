import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

// Developed by Marcelo Glasberg (copyright Aug 2020)

/// This widget can be used with implicitly animated widgets to give it
/// an initial value, and then quickly change it to another.
///
/// As soon as this widget is inserted into the tree, it will call the
/// [builder] with [initialized]==false.
///
/// If [delay] is null, then it will call the builder again in the next
/// frame (usually 1/16th of second later) with [initialized]==true.
///
/// If [delay] is NOT null, then it will call the builder again after
/// the delay, with [initialized]==true.
///
class Delayed extends StatefulWidget {
  //
  final Widget Function(BuildContext context, bool initialized) builder;
  final Duration? delay;

  const Delayed({
    Key? key,
    required this.builder,
    this.delay,
  }) : super(key: key);

  @override
  _DelayedState createState() => _DelayedState();
}

class _DelayedState extends State<Delayed> {
  late bool _initialized;

  @override
  void initState() {
    super.initState();
    _initialized = false;

    WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
      if (widget.delay != null)
        Future.delayed(widget.delay!, _delayedInit);
      else {
        _delayedInit();
      }
    });
  }

  void _delayedInit() {
    if (mounted)
      setState(() {
        _initialized = true;
      });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _initialized);
  }
}
