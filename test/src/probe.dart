import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Counts how much work the render object of a [Probe] was asked to do.
/// Used by the tests to make sure the widgets don't do more work than necessary.
class ProbeLog {
  /// How many times the max intrinsic width of the probe was actually computed
  /// (not counting the times when its cached value was used).
  int maxIntrinsicWidths = 0;

  void reset() => maxIntrinsicWidths = 0;
}

/// A widget that behaves exactly like its [child], but counts in the [log] how
/// many times its max intrinsic width is computed.
class Probe extends SingleChildRenderObjectWidget {
  const Probe({super.key, required this.log, super.child});

  final ProbeLog log;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderProbe(log);

  @override
  void updateRenderObject(BuildContext context, covariant _RenderProbe renderObject) {
    renderObject.log = log;
  }
}

class _RenderProbe extends RenderProxyBox {
  _RenderProbe(this.log);

  ProbeLog log;

  @override
  double computeMaxIntrinsicWidth(double height) {
    log.maxIntrinsicWidths++;
    return super.computeMaxIntrinsicWidth(height);
  }
}
