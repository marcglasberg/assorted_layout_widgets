import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Animates smoothly between two children, cross-fading their content
/// while resizing the enclosing box. The old and new children can
/// differ in both width and height; their sizes do not need to be
/// known in advance — they are measured as they lay out.
///
/// ## Transition model
///
/// Each transition runs two animations concurrently:
///
/// - a **cross-fade** between the old child (fading out) and the new
///   child (fading in), running for [fadeDuration],
/// - a **size change** from the old box size to the new one, running
///   for a derived duration that scales with the size difference.
///
/// The size duration is computed from [fadeDuration] and
/// [sizeDurationFactor]. Let `P` be the proportional area difference
/// between the two children (larger area over smaller area — so `P ≥ 1`).
/// Then:
///
/// ```
/// R = P ^ (1 / sizeDurationFactor)
/// sizeDuration = fadeDuration * R
/// ```
///
/// Because `P ≥ 1` and `sizeDurationFactor ≥ 1`, we always have
/// `R ≥ 1`, so the size animation is never shorter than the fade.
/// Larger [sizeDurationFactor] dampens the effect of `P`, pulling the
/// size duration closer to the fade duration. At `sizeDurationFactor = 1`,
/// the size duration scales linearly with `P`. Example: if one child
/// has 4× the area of the other (`P = 4`), then with
/// `sizeDurationFactor = 2` the size animation is `√4 = 2`× the fade,
/// and with `sizeDurationFactor = 3` it is `∛4 ≈ 1.59`× the fade.
///
/// When the width and height directions disagree (e.g. the new child
/// is wider but shorter), grow vs. shrink is decided by overall
/// **area**, so the transition commits to a single direction rather
/// than mixing.
///
/// The fade and size animations are coordinated so that they always
/// end together on grow, and always start together on shrink:
///
/// - **Growing** (new child larger by area): the size animation starts
///   first; the fade starts later, so the fade finishes at the same
///   moment the size animation does. The box opens to make room, and
///   the new child reveals into that room right as it settles.
/// - **Shrinking** (new child smaller by area): both animations start
///   together. The fade finishes first (since it is the shorter of the
///   two), so the new, smaller child is already visible while the box
///   settles around it.
///
/// The fade and size animations use independent curves ([fadeCurve]
/// and [sizeCurve]), so each can be tuned separately.
///
/// ## The visual effect
///
/// The container change and the content change happen in the order
/// the eye expects:
///
/// - On grow, space opens and then fills — the new (larger) child
///   never looks cramped inside a still-small box.
/// - On shrink, new content arrives and then the frame tightens
///   around it — the box never looks like it's cutting off the new child.
///
/// The default curves ([fadeCurve] = `Curves.easeInOut`, [sizeCurve] =
/// a custom cubic) reinforce this: both animations settle toward the
/// end, so the two directions read as a single coordinated gesture
/// rather than two separate animations running side by side.
///
/// ## Widget identity caveat
///
/// If the new child is the same widget type as the old one *and* has
/// the same key, Flutter treats them as the same widget and updates
/// the existing element in place, with no transition. To force a transition,
/// give each visually distinct child its own [Key], usually a [ValueKey]:
///
/// ```dart
/// AnimatedBetween(
///   child: toggle
///     ? const Text('A', key: ValueKey('a'))
///     : const Text('B', key: ValueKey('b')),
/// )
/// ```
///
/// To animate a single widget in and out (null ↔ widget), use
/// [AnimatedBetween.showHide].
///
class AnimatedBetween extends StatefulWidget {
  /// Creates an [AnimatedBetween].
  ///
  /// See the class documentation for how [fadeDuration],
  /// [sizeDurationFactor], [fadeCurve] and [sizeCurve] combine to
  /// produce the grow/shrink transition.
  const AnimatedBetween({
    super.key,
    required this.child,
    this.fadeDuration = const Duration(milliseconds: 250),
    this.sizeDurationFactor = 15.0,
    this.fadeCurve = Curves.easeInOut,
    this.sizeCurve = const Cubic(.29, .65, .35, .97),
    this.alignment = Alignment.center,
    this.clipBehavior = Clip.none,
    this.modeShorterChild = AnimatedBetweenMode.resize,
    this.modeLargerChild = AnimatedBetweenMode.fit,
    this.printDebug = false,
  }) : assert(sizeDurationFactor >= 1.0, 'sizeDurationFactor must be >= 1.0');

  /// Convenience constructor that animates a single widget in and out.
  ///
  /// When [show] is true the child is animated in; when [show] is
  /// false the child is treated as `null` and the box animates down
  /// to zero size. The grow/shrink model described in the class
  /// documentation applies: showing grows, hiding shrinks.
  const AnimatedBetween.showHide({
    super.key,
    required bool show,
    required Widget child,
    this.fadeDuration = const Duration(milliseconds: 200),
    this.sizeDurationFactor = 20.0,
    this.fadeCurve = Curves.easeInOut,
    this.sizeCurve = const Cubic(.29, .65, .35, .97),
    this.alignment = Alignment.topCenter,
    this.clipBehavior = Clip.none,
    AnimatedBetweenMode mode = AnimatedBetweenMode.fit,
    this.printDebug = true,
  }) : assert(sizeDurationFactor >= 1.0, 'sizeDurationFactor must be >= 1.0'),
       modeLargerChild = mode,
       modeShorterChild = AnimatedBetweenMode.fit,
       child = show ? child : null;

  /// The child currently shown. Changing it triggers a transition to
  /// the new value. A `null` child is valid and animates the box to
  /// zero size.
  final Widget? child;

  /// Duration of the cross-fade between the old child (fading out)
  /// and the new child (fading in).
  ///
  /// This also serves as the base for the size animation's duration;
  /// see [sizeDurationFactor].
  final Duration fadeDuration;

  /// Controls how much longer the size animation is, relative to the
  /// fade, as a function of the size ratio between the two children.
  /// Must be `>= 1`.
  ///
  /// Let `P` be the proportional area difference (larger area over
  /// smaller area, so `P ≥ 1`). The size animation runs for
  /// `fadeDuration * P ^ (1 / sizeDurationFactor)`.
  ///
  /// Intuition:
  /// - `sizeDurationFactor = 1` — size scales linearly with `P`
  ///   (bigger size change → proportionally longer size animation).
  /// - Larger values dampen the effect of `P`, pulling the size
  ///   duration closer to [fadeDuration].
  ///
  /// Because `R = P ^ (1 / sizeDurationFactor)` is always `>= 1`, the
  /// size animation is never shorter than the fade.
  final double sizeDurationFactor;

  /// Curve applied to the cross-fade animation, in both directions.
  /// Defaults to `Curves.easeInOut`, which reads naturally for growing
  /// and shrinking alike.
  final Curve fadeCurve;

  /// Curve applied to the size animation, in both directions. Defaults
  /// to a custom cubic `(.29, .65, .35, .97)` that accelerates a bit
  /// into the change and settles gently at the end.
  final Curve sizeCurve;

  /// Where each child is placed inside the animated box. Also
  /// determines the anchor point from which the box appears to grow
  /// or shrink (e.g. `Alignment.center` expands from the center,
  /// `Alignment.topLeft` expands down-right).
  final Alignment alignment;

  /// How content that exceeds the current animated box size is clipped
  /// during the transition.
  final Clip clipBehavior;

  /// How the child with the **smaller** natural area fills the animated
  /// box during a transition. See [AnimatedBetweenMode] for the
  /// available modes ([AnimatedBetweenMode.overflow],
  /// [AnimatedBetweenMode.fit], [AnimatedBetweenMode.resize]).
  ///
  /// When the two children have the exact same area, both use
  /// [modeShorterChild]. When one side is `null` (as in
  /// [AnimatedBetween.showHide]), the non-null side is always treated
  /// as the larger child and uses [modeLargerChild].
  ///
  /// This does not affect how the box itself is sized; grow/shrink
  /// direction and target sizes are still determined from each child's
  /// natural size.
  final AnimatedBetweenMode modeShorterChild;

  /// How the child with the **larger** natural area fills the animated
  /// box during a transition. See [AnimatedBetweenMode] for the
  /// available modes.
  ///
  /// When the two children have the exact same area, [modeShorterChild]
  /// is used for both and this parameter is ignored.
  final AnimatedBetweenMode modeLargerChild;

  /// When true, prints the computed fade and size durations (in
  /// milliseconds) at the start of every transition, and whenever the
  /// size target changes mid-transition. Intended for debugging the
  /// effect of [fadeDuration] and [sizeDurationFactor]. Defaults to
  /// false.
  final bool printDebug;

  @override
  State<AnimatedBetween> createState() => _AnimatedBetweenState();
}

class _AnimatedBetweenState extends State<AnimatedBetween> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _sizeController;

  /// Pending delayed start of the fade animation, used on grow
  /// transitions so the fade ends together with the (longer) size
  /// animation. Cancelled if the transition is interrupted or the
  /// widget is disposed.
  Timer? _fadeStartTimer;

  Widget? _currentChild;
  Widget? _outgoingChild;

  Size? _currentChildSize;
  Size? _outgoingChildSize;

  Size _sizeBegin = Size.zero;
  Size _sizeEnd = Size.zero;

  bool _isTransitioning = false;

  /// True while a transition is in flight but the incoming child has
  /// not been measured yet. Until the measure arrives we don't know
  /// both sizes, so neither the fade nor the size animation can start.
  bool _waitingForCurrentSize = false;

  @override
  void initState() {
    super.initState();

    _currentChild = widget.child;
    _currentChildSize = widget.child == null ? Size.zero : null;

    // The size controller's duration is re-assigned at the start of
    // each transition based on the computed size animation length.
    _fadeController = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
      value: 1.0,
    )..addStatusListener((_) => _maybeFinishTransition());

    _sizeController = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
      value: 1.0,
    )..addStatusListener((_) => _maybeFinishTransition());

    if (_currentChild == null) {
      _setRestingSize(Size.zero);
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedBetween oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.fadeDuration != oldWidget.fadeDuration) {
      _fadeController.duration = widget.fadeDuration;
    }

    final Widget? newChild = widget.child;

    if (_canUpdate(_currentChild, newChild)) {
      if (!identical(_currentChild, newChild)) {
        setState(() {
          _currentChild = newChild;
          if (newChild == null) {
            _currentChildSize = Size.zero;
            if (!_isTransitioning) {
              _setRestingSize(Size.zero);
            }
          }
        });
      }
      return;
    }

    if (_currentChild == null && newChild == null) {
      return;
    }

    _startTransitionTo(newChild);
  }

  @override
  void dispose() {
    _cancelFadeStartTimer();
    _fadeController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  bool _canUpdate(Widget? oldWidget, Widget? newWidget) {
    return oldWidget != null &&
        newWidget != null &&
        Widget.canUpdate(oldWidget, newWidget);
  }

  double get _fadeT => widget.fadeCurve.transform(_fadeController.value);

  double get _sizeT => widget.sizeCurve.transform(_sizeController.value);

  Size get _displaySize => Size.lerp(_sizeBegin, _sizeEnd, _sizeT) ?? _sizeEnd;

  void _setRestingSize(Size size) {
    _sizeBegin = size;
    _sizeEnd = size;
    _sizeController.value = 1.0;
  }

  void _cancelFadeStartTimer() {
    _fadeStartTimer?.cancel();
    _fadeStartTimer = null;
  }

  /// Computes the size animation duration from the old and new sizes
  /// using [AnimatedBetween.fadeDuration] and
  /// [AnimatedBetween.sizeDurationFactor].
  ///
  /// `P` is the proportional area difference (larger area over smaller
  /// area, clamped to at least 1). The returned duration is
  /// `fadeDuration * P ^ (1 / sizeDurationFactor)`.
  Duration _computeSizeDuration(Size from, Size to) {
    final double fromArea = from.width * from.height;
    final double toArea = to.width * to.height;
    final double larger = math.max(fromArea, toArea);
    final double smaller = math.min(fromArea, toArea);

    final double p;
    if (smaller <= 0.0) {
      if (larger <= 0.0) {
        // Both zero: nothing to animate for size; fall back to fade.
        return widget.fadeDuration;
      }
      // One side is empty (null child or zero-sized). Treat the
      // smaller area as a single unit so P equals the larger area in
      // pixels²; clamp so `R` stays finite for any real geometry.
      p = larger.clamp(1.0, 1e6);
    } else {
      p = larger / smaller;
    }

    final double r = math.pow(p, 1.0 / widget.sizeDurationFactor).toDouble();
    final int micros = (widget.fadeDuration.inMicroseconds * r).round();
    return Duration(microseconds: micros);
  }

  /// Launches the fade and size controllers for a transition whose box
  /// animates from [from] to [to]. Applies the grow/shrink timing rule:
  ///
  /// - Growing (`toArea > fromArea`): size starts now; fade is
  ///   delayed so both end at the same instant.
  /// - Shrinking (or equal): both start now; fade ends first.
  void _runTransitionAnimations(Size from, Size to) {
    _cancelFadeStartTimer();

    final Duration sizeDuration = _computeSizeDuration(from, to);
    if (widget.printDebug) {
      debugPrint(
        'AnimatedBetween transition: '
        'fade=${widget.fadeDuration.inMilliseconds}ms, '
        'size=${sizeDuration.inMilliseconds}ms',
      );
    }

    _sizeController.duration = sizeDuration;
    _fadeController.duration = widget.fadeDuration;

    final double fromArea = from.width * from.height;
    final double toArea = to.width * to.height;
    final bool growing = toArea > fromArea;

    _sizeController.forward(from: 0.0);

    if (growing) {
      final Duration fadeDelay = sizeDuration - widget.fadeDuration;
      if (fadeDelay <= Duration.zero) {
        _fadeController.forward(from: 0.0);
      } else {
        _fadeController.value = 0.0;
        _fadeStartTimer = Timer(fadeDelay, () {
          _fadeStartTimer = null;
          if (!mounted) return;
          _fadeController.forward(from: 0.0);
        });
      }
    } else {
      _fadeController.forward(from: 0.0);
    }
  }

  void _startTransitionTo(Widget? newChild) {
    _cancelFadeStartTimer();
    final Size startSize = _currentChildSize ?? _displaySize;
    final Widget? outgoing = _currentChild;

    setState(() {
      _isTransitioning = true;
      _outgoingChild = outgoing;
      _outgoingChildSize = _currentChildSize ?? startSize;

      _currentChild = newChild;
      _currentChildSize = newChild == null ? Size.zero : null;

      _sizeBegin = startSize;
      _sizeEnd = newChild == null ? Size.zero : startSize;

      if (newChild == null) {
        // Shrink to nothing: both sizes are known now, so we can kick
        // off both animations immediately.
        _waitingForCurrentSize = false;
        _runTransitionAnimations(startSize, Size.zero);
      } else {
        // Any transition into a non-null child needs the target's
        // measurement before we can compute the size duration and
        // grow/shrink direction. Hold both animations at their resting
        // values until _handleCurrentChildSizeChanged fires.
        _waitingForCurrentSize = true;
        _fadeController.value = 0.0;
        _sizeController.value = 1.0;
      }
    });
  }

  void _maybeFinishTransition() {
    if (!_isTransitioning) {
      return;
    }
    if (_waitingForCurrentSize) {
      return;
    }
    if (_fadeStartTimer != null) {
      return;
    }
    if (_fadeController.isAnimating || _sizeController.isAnimating) {
      return;
    }
    if (_fadeController.value < 1.0 || _sizeController.value < 1.0) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isTransitioning = false;
      _outgoingChild = null;
      _outgoingChildSize = null;
      _setRestingSize(_currentChildSize ?? Size.zero);
    });
  }

  void _handleCurrentChildSizeChanged(Size size) {
    if (_currentChildSize == size) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _currentChildSize = size;

      if (_isTransitioning) {
        final bool wasWaiting = _waitingForCurrentSize;
        _waitingForCurrentSize = false;
        final Size startSize = _displaySize;
        _sizeBegin = startSize;
        _sizeEnd = size;

        if (wasWaiting) {
          // First measurement of the incoming child: we finally know
          // both sizes, so compute the size duration, pick grow vs.
          // shrink timing, and launch the fade + size animations.
          final Size outSize = _outgoingChildSize ?? startSize;
          _runTransitionAnimations(outSize, size);
        } else {
          // Mid-transition retarget (incoming child's natural size
          // changed again). Keep the fade as-is and restart size from
          // the current visual size to the new target, with a fresh
          // duration based on that ratio.
          final Duration sizeDuration = _computeSizeDuration(startSize, size);
          if (widget.printDebug) {
            debugPrint(
              'AnimatedBetween retarget: '
              'fade=${widget.fadeDuration.inMilliseconds}ms, '
              'size=${sizeDuration.inMilliseconds}ms',
            );
          }
          _sizeController.duration = sizeDuration;
          _sizeController.forward(from: 0.0);
        }
      } else {
        _setRestingSize(size);
      }
    });

    _maybeFinishTransition();
  }

  void _handleOutgoingChildSizeChanged(Size size) {
    if (_outgoingChildSize == size) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _outgoingChildSize = size;
    });
  }

  Widget _buildAnimatedLayer({
    required Widget child,
    required Size? knownSize,
    required double opacity,
    required BoxConstraints parentConstraints,
    required ValueChanged<Size> onSizeChanged,
    required AnimatedBetweenMode mode,
  }) {
    final Widget opacityChild = Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: _MeasureSize(onChanged: onSizeChanged, child: child),
    );

    if (mode == AnimatedBetweenMode.fit && knownSize != null) {
      // SizedBox pins the child to its measured natural size so layouts
      // that need bounded constraints (e.g. Row + Expanded) resolve;
      // FittedBox then scales that rendered output to fill the animated
      // box.
      return IgnorePointer(
        child: FittedBox(
          fit: BoxFit.fill,
          alignment: widget.alignment,
          child: SizedBox.fromSize(size: knownSize, child: opacityChild),
        ),
      );
    }

    if (mode == AnimatedBetweenMode.resize && knownSize != null) {
      // Pass tight constraints through directly so the child re-lays out at
      // the animated box size. _MeasureSize is dropped here: under tight
      // constraints it would keep reporting the box size as the "natural"
      // size and freeze the animation target.
      return IgnorePointer(
        child: Opacity(opacity: opacity.clamp(0.0, 1.0), child: child),
      );
    }

    // overflow mode, or fit/resize's first frame before the natural size
    // is known. In the latter case opacity is held near 0 by the
    // transition controller, so the unconstrained child is not visible.
    final double maxWidth = parentConstraints.hasBoundedWidth
        ? parentConstraints.maxWidth
        : double.infinity;
    final double maxHeight = parentConstraints.hasBoundedHeight
        ? parentConstraints.maxHeight
        : double.infinity;
    return IgnorePointer(
      child: Align(
        alignment: widget.alignment,
        child: OverflowBox(
          alignment: widget.alignment,
          minWidth: 0,
          minHeight: 0,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          child: opacityChild,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[_fadeController, _sizeController]),
          builder: (BuildContext context, Widget? child) {
            if (!_isTransitioning) {
              if (_currentChild == null) {
                return const SizedBox.shrink();
              }

              return _MeasureSize(
                onChanged: _handleCurrentChildSizeChanged,
                child: _currentChild!,
              );
            }

            final double incomingOpacity = _currentChild == null ? 0.0 : _fadeT;
            final double outgoingOpacity = _outgoingChild == null ? 0.0 : 1.0 - _fadeT;
            final Size displaySize = _displaySize;

            // Classify each child as the "shorter" or "larger" by
            // natural area, and apply the corresponding mode. When
            // one side is null and the other isn't, the non-null one
            // is unambiguously the larger side regardless of whether
            // the incoming child has been measured yet — this avoids
            // treating an unmeasured non-null child as tied with a
            // null child and so misapplying modeShorterChild on the
            // first frame of a showHide grow. When the areas tie
            // with both sides non-null, both use modeShorterChild
            // per the widget contract.
            final AnimatedBetweenMode outgoingMode;
            final AnimatedBetweenMode incomingMode;
            if (_outgoingChild == null && _currentChild != null) {
              outgoingMode = widget.modeShorterChild;
              incomingMode = widget.modeLargerChild;
            } else if (_outgoingChild != null && _currentChild == null) {
              outgoingMode = widget.modeLargerChild;
              incomingMode = widget.modeShorterChild;
            } else {
              final double outArea = _outgoingChild == null
                  ? 0.0
                  : (_outgoingChildSize?.width ?? 0) *
                      (_outgoingChildSize?.height ?? 0);
              final double inArea = _currentChild == null
                  ? 0.0
                  : (_currentChildSize?.width ?? 0) *
                      (_currentChildSize?.height ?? 0);
              if (outArea == inArea) {
                outgoingMode = widget.modeShorterChild;
                incomingMode = widget.modeShorterChild;
              } else if (outArea > inArea) {
                outgoingMode = widget.modeLargerChild;
                incomingMode = widget.modeShorterChild;
              } else {
                outgoingMode = widget.modeShorterChild;
                incomingMode = widget.modeLargerChild;
              }
            }

            return ClipRect(
              clipBehavior: widget.clipBehavior,
              child: SizedBox(
                width: displaySize.width,
                height: displaySize.height,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: widget.alignment,
                  children: <Widget>[
                    if (_outgoingChild != null)
                      Positioned.fill(
                        child: _buildAnimatedLayer(
                          child: _outgoingChild!,
                          knownSize: _outgoingChildSize,
                          opacity: outgoingOpacity,
                          parentConstraints: constraints,
                          onSizeChanged: _handleOutgoingChildSizeChanged,
                          mode: outgoingMode,
                        ),
                      ),
                    if (_currentChild != null)
                      Positioned.fill(
                        child: _buildAnimatedLayer(
                          child: _currentChild!,
                          knownSize: _currentChildSize,
                          opacity: incomingOpacity,
                          parentConstraints: constraints,
                          onSizeChanged: _handleCurrentChildSizeChanged,
                          mode: incomingMode,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({required this.onChanged, super.child});

  final ValueChanged<Size> onChanged;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _MeasureSizeRenderObject(onChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _MeasureSizeRenderObject renderObject,
  ) {
    renderObject.onChanged = onChanged;
  }
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  _MeasureSizeRenderObject(this.onChanged);

  ValueChanged<Size> onChanged;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();

    final Size newSize = child?.size ?? size;
    if (_oldSize == newSize) {
      return;
    }

    _oldSize = newSize;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (attached) {
        onChanged(newSize);
      }
    });
  }
}

/// Controls how each child of [AnimatedBetween] fills the animated box
/// during a transition.
enum AnimatedBetweenMode {
  /// Each child is forced to the current animated box size via tight
  /// constraints (no scaling). The child re-lays out at that size, so
  /// text rewraps, flex children redistribute, etc. The effect is like
  /// dragging the edge of a resizable container: the content reshapes
  /// continuously as the box grows or shrinks.
  resize,

  /// Each child is rendered at its natural size inside the animated box.
  /// If the box is currently smaller than the child, the child overflows
  /// and is clipped by the widget's `clipBehavior`; if the box is larger,
  /// the child is aligned with empty space around it. The box opens or
  /// closes around content that itself never changes size.
  overflow,

  /// Each child is scaled (via [FittedBox] with `BoxFit.fill`) to match
  /// the current animated box size. The children visually stretch or
  /// compress together with the box, so the incoming child starts at the
  /// outgoing child's size and ends at its own natural size. Aspect ratio
  /// is not preserved — the two axes scale independently.
  fit,
}
