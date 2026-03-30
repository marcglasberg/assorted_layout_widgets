import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// Widget [KeepTallest] tracks its child's height and never visually shrinks
/// its own height below the tallest height observed so far. Growing is always
/// instantaneous.
///
/// ## Problem
///
/// When multiple children of different heights share the same space (e.g. tab
/// content), switching from a tall child to a short one causes the surrounding
/// layout to collapse, which can feel jarring: Content below jumps up, scroll
/// position shifts, etc. It would be good if we could add some space below the
/// shorter child to match the taller height, so that the layout doesn't shift when
/// switching between them. This space doesn't need to be there all the time. It can
/// be added the moment we go from taller to shorter. Optionally, we can shrink it with
/// an animation.
///
/// ## Solution
///
/// Wrap the variable-height content in [KeepTallest]. The widget
/// measures its child's **natural** height (ignoring its own min-height
/// constraint) and keeps the container at least as tall as the tallest child
/// seen so far. If the child grows, the container grows immediately. If the
/// child shrinks, the container stays at the previous (larger) height.
///
/// For example, if the child's height changes through:
/// `100 → 300 → 200 → 0 → 1000 → 100`
/// the container height will be:
/// `100 → 300 → 300 → 300 → 1000 → 1000`
///
/// ## Optional animated shrinking
///
/// Set [shrink] to `true` to allow the container to eventually shrink back to
/// the child's height. When the child becomes smaller:
///
/// 1. The widget waits [shrinkDelay] (default 200 ms).
/// 2. Then animates down to the child's current height over [duration]
///    (default 500 ms) using [curve] (default [Curves.easeInOut]).
///
/// If the child grows again at any point during the delay or animation, the
/// container immediately snaps to the new larger height (growing is never
/// animated).
///
/// Use [minShrinkDifference] to suppress small shrinks. The animated shrink
/// only triggers when the difference between the current container height and
/// the child's natural height exceeds this threshold. With the default of `0`,
/// every decrease triggers a shrink.
///
/// ## Route visibility
///
/// When the widget's route becomes inactive (e.g. another route is pushed on
/// top), [KeepTallest] immediately snaps to the child's natural height
/// without animation or delay, regardless of all other parameters. This is detected via
/// [TickerMode]. When the user pops back, the layout is already correct, with no
/// stale extra space or jarring animation on return.
///
/// ### PageView and TabBarView
///
/// [PageView] and [TabBarView] don't automatically stop tickers for offscreen pages,
/// so if you want [KeepTallest] to immediately snap the child's height whe
/// a page becomes invisible, you need to wrap the page in a [TickerMode] and turn it off
/// when the page is not visible. Note this has the added benefit of making your app more
/// performant by stopping tickers and other active animations on pages that are
/// completely offscreen. Example:
///
/// ```dart
/// class TickerPageViewExample extends StatefulWidget {
///   const TickerPageViewExample({super.key});
///
///   @override
///   State<TickerPageViewExample> createState() =>
///       _TickerPageViewExampleState();
/// }
///
/// class _TickerPageViewExampleState extends State<TickerPageViewExample> {
///   final _controller = PageController();
///
///   bool _isVisible(int index, double page) {
///     // A page is visible if it's less than 1 page away
///     return (page - index).abs() < 1.0;
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: const Text('TickerMode + PageView')),
///       body: AnimatedBuilder(
///         animation: _controller,
///         builder: (context, _) {
///           final page = _controller.hasClients &&
///                   _controller.position.hasViewportDimension
///               ? (_controller.page ?? 0.0)
///               : 0.0;
///
///           return PageView(
///             controller: _controller,
///             children: List.generate(3, (index) {
///               return TickerMode(
///                 enabled: _isVisible(index, page),
///                 child: _DemoPage(index: index),
///               );
///             }),
///           );
///         },
///       ),
///     );
///   }
/// }
///
/// class _DemoPage extends StatefulWidget {
///   final int index;
///
///   const _DemoPage({required this.index});
///
///   @override
///   State<_DemoPage> createState() => _DemoPageState();
/// }
///
/// class _DemoPageState extends State<_DemoPage> with SingleTickerProviderStateMixin {
///   late final AnimationController _controller;
///
///   @override
///   void initState() {
///     super.initState();
///     _controller = AnimationController(
///       vsync: this,
///       duration: const Duration(seconds: 2),
///     )..repeat();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Center(
///       child: RotationTransition(
///         turns: _controller,
///         child: Text(
///           'Page ${widget.index}',
///           style: const TextStyle(fontSize: 32),
///         ),
///       ),
///     );
///   }
///
///   @override
///   void dispose() {
///     _controller.dispose();
///     super.dispose();
///   }
/// }
/// ```
///
class KeepTallest extends StatefulWidget {
  final Widget child;

  /// If false (default), the widget never shrinks — it keeps the largest height seen.
  /// If true, when the child gets smaller, the widget will wait [shrinkDelay] and then
  /// animate down to the child's height over [duration] using [curve].
  /// Growing is always instantaneous regardless of this flag.
  final bool shrink;

  /// How long the shrink animation takes. Only used when [shrink] is true.
  /// Defaults to 500ms.
  final Duration duration;

  /// The animation curve for the shrink transition. Only used when [shrink] is true.
  /// Defaults to [Curves.easeInOut].
  final Curve curve;

  /// The delay before the shrink animation starts after the child becomes smaller.
  /// Only used when [shrink] is true. Defaults to 200ms.
  final Duration shrinkDelay;

  /// The minimum difference between the current height and the child's height
  /// required to trigger a shrink. If the difference is less than or equal to this
  /// value, the widget keeps its current height instead of shrinking.
  /// Only used when [shrink] is true. Must be >= 0. Defaults to 0 (always shrinks).
  final double minShrinkDifference;

  const KeepTallest({
    super.key,
    required this.child,
    this.shrink = false,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
    this.shrinkDelay = const Duration(milliseconds: 200),
    this.minShrinkDifference = 0,
  }) : assert(minShrinkDifference >= 0);

  @override
  State<KeepTallest> createState() => _KeepTallestState();
}

class _KeepTallestState extends State<KeepTallest>
    with TickerProviderStateMixin {
  double _currentHeight = 0;
  double _childHeight = 0;

  AnimationController? _controller;
  late Animation<double> _animation;
  Timer? _shrinkTimer;

  ValueListenable<TickerModeData>? _tickerModeNotifier;
  bool _active = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var notifier = TickerMode.getValuesNotifier(context);
    if (_tickerModeNotifier != notifier) {
      _tickerModeNotifier?.removeListener(_onTickerModeChanged);
      _tickerModeNotifier = notifier;
      _tickerModeNotifier!.addListener(_onTickerModeChanged);
      _handleActiveChange(notifier.value.enabled);
    }
  }

  void _onTickerModeChanged() {
    _handleActiveChange(_tickerModeNotifier!.value.enabled);
  }

  void _handleActiveChange(bool enabled) {
    if (_active == enabled) return;
    _active = enabled;

    // When the route becomes inactive, snap to the child's natural height immediately.
    if (!enabled) {
      _shrinkTimer?.cancel();
      _controller?.stop();
      _controller?.dispose();
      _controller = null;
      if (_childHeight != _currentHeight) {
        setState(() => _currentHeight = _childHeight);
      }
    }
  }

  @override
  void dispose() {
    _tickerModeNotifier?.removeListener(_onTickerModeChanged);
    _controller?.dispose();
    _shrinkTimer?.cancel();
    super.dispose();
  }

  void _onChildHeightChanged(double height) {
    if (height == _childHeight) return;
    _childHeight = height;

    // Growing: always instantaneous (deferred to avoid setState during layout).
    if (height >= _currentHeight) {
      print('KeepTallest → ${_currentHeight.round()} to ${height.round()}');
      _shrinkTimer?.cancel();
      _controller?.stop();
      _setCurrentHeightPostFrame(height);
    }
    //
    // Shrinking: delayed, then animated.
    else if (widget.shrink && (_currentHeight - height) > widget.minShrinkDifference) {
      print(
        'KeepTallest → ${_currentHeight.round()} to ${height.round()} '
        '(shrink: above ${widget.minShrinkDifference.round()})',
      );
      _scheduleShrink(height);
    }
    //
    // Don't shrink because the difference is too small.
    else if (widget.shrink) {
      print(
        'KeepTallest → ${_currentHeight.round()} to ${height.round()} '
        '(dont shrink: below ${widget.minShrinkDifference.round()})',
      );
    }
  }

  void _setCurrentHeightPostFrame(double height) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _currentHeight = height);
    });
  }

  void _scheduleShrink(double targetHeight) {
    _shrinkTimer?.cancel();
    _shrinkTimer = Timer(widget.shrinkDelay, () {
      if (!mounted) return;
      _animateTo(_childHeight);
    });
  }

  void _animateTo(double targetHeight) {
    _controller?.dispose();

    var controller = AnimationController(duration: widget.duration, vsync: this);
    _controller = controller;

    _animation = Tween<double>(
      begin: _currentHeight,
      end: targetHeight,
    ).chain(CurveTween(curve: widget.curve)).animate(controller);

    _animation.addListener(() {
      if (_childHeight > _currentHeight) return;
      setState(() => _currentHeight = _animation.value);
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return _HeightObserver(
      minHeight: _currentHeight,
      onHeightChanged: _onChildHeightChanged,
      child: widget.child,
    );
  }
}

class _HeightObserver extends SingleChildRenderObjectWidget {
  final double minHeight;
  final ValueChanged<double> onHeightChanged;

  const _HeightObserver({
    required this.minHeight,
    required this.onHeightChanged,
    required super.child,
  });

  @override
  _RenderHeightObserver createRenderObject(BuildContext context) {
    return _RenderHeightObserver(minHeight: minHeight, onHeightChanged: onHeightChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderHeightObserver renderObject,
  ) {
    renderObject
      ..minHeight = minHeight
      ..onHeightChanged = onHeightChanged;
  }
}

class _RenderHeightObserver extends RenderProxyBox {
  double _minHeight;
  ValueChanged<double> onHeightChanged;

  _RenderHeightObserver({required double minHeight, required this.onHeightChanged})
    : _minHeight = minHeight;

  double get minHeight => _minHeight;

  set minHeight(double value) {
    if (_minHeight == value) return;
    _minHeight = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    if (child != null) {
      // Measure the child's natural height without the min height constraint.
      child!.layout(constraints.copyWith(minHeight: 0), parentUsesSize: true);
      double naturalHeight = child!.size.height;
      onHeightChanged(naturalHeight);

      // Apply actual constraints with minHeight enforced.
      var enforcedConstraints = constraints.copyWith(
        minHeight: clampDouble(minHeight, constraints.minHeight, constraints.maxHeight),
      );
      child!.layout(enforcedConstraints, parentUsesSize: true);
      size = child!.size;
    } else {
      size = constraints.constrain(Size(0, minHeight));
    }
  }
}
