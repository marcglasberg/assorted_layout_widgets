import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A widget that imposes different constraints on its child than it gets
/// from its parent, possibly allowing the child to overflow the parent.
///
/// A [NormalizedOverflowBox] is similar to an [OverflowBox]. The difference
/// is that an [OverflowBox] may throw errors if it gets constraints which
/// are incompatible with its own constraints. For example, if an
/// [OverflowBox] is inside a container with maxWidth 100, and its own
/// minWidth is 150, it will throw:
///
///     The following assertion was thrown during performLayout():
///     BoxConstraints has non-normalized width constraints.
///
/// However, the [NormalizedOverflowBox] will just make sure maxWidth is
/// also 150, and throw no errors. In other words, a [NormalizedOverflowBox]
/// is safer to use. In my opinion, [NormalizedOverflowBox] has the behavior
/// [OverflowBox] should have.
///
/// See also:
///
///  * [RenderConstrainedOverflowBox] for details about how [OverflowBox] is
///    rendered.
///  * [SizedOverflowBox], a widget that is a specific size but passes its
///    original constraints through to its child, which may then overflow.
///  * [ConstrainedBox], a widget that imposes additional constraints on its
///    child.
///  * [UnconstrainedBox], a container that tries to let its child draw without
///    constraints.
///  * [SizedBox], a box with a specified size.
///  * The [catalog of layout widgets](https://flutter.dev/widgets/layout/).
class NormalizedOverflowBox extends SingleChildRenderObjectWidget {
  /// Creates a widget that lets its child overflow itself,
  /// but prevents invalid constraints.
  const NormalizedOverflowBox({
    Key? key,
    this.alignment = Alignment.center,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    Widget? child,
  }) : super(key: key, child: child);

  /// How to align the child.
  ///
  /// The x and y values of the alignment control the horizontal and vertical
  /// alignment, respectively. An x value of -1.0 means that the left edge of
  /// the child is aligned with the left edge of the parent whereas an x value
  /// of 1.0 means that the right edge of the child is aligned with the right
  /// edge of the parent. Other values interpolate (and extrapolate) linearly.
  /// For example, a value of 0.0 means that the center of the child is aligned
  /// with the center of the parent.
  ///
  /// Defaults to [Alignment.center].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  /// The minimum width constraint to give the child. Set this to null (the
  /// default) to use the constraint from the parent instead.
  final double? minWidth;

  /// The maximum width constraint to give the child. Set this to null (the
  /// default) to use the constraint from the parent instead.
  final double? maxWidth;

  /// The minimum height constraint to give the child. Set this to null (the
  /// default) to use the constraint from the parent instead.
  final double? minHeight;

  /// The maximum height constraint to give the child. Set this to null (the
  /// default) to use the constraint from the parent instead.
  final double? maxHeight;

  @override
  RenderConstrainedNormalizedOverflowBox createRenderObject(BuildContext context) {
    return RenderConstrainedNormalizedOverflowBox(
      alignment: alignment,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      textDirection: Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderConstrainedNormalizedOverflowBox renderObject) {
    renderObject
      ..alignment = alignment
      ..minWidth = minWidth
      ..maxWidth = maxWidth
      ..minHeight = minHeight
      ..maxHeight = maxHeight
      ..textDirection = Directionality.maybeOf(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AlignmentGeometry>('alignment', alignment));
    properties.add(DoubleProperty('minWidth', minWidth, defaultValue: null));
    properties.add(DoubleProperty('maxWidth', maxWidth, defaultValue: null));
    properties.add(DoubleProperty('minHeight', minHeight, defaultValue: null));
    properties.add(DoubleProperty('maxHeight', maxHeight, defaultValue: null));
  }
}

class RenderConstrainedNormalizedOverflowBox extends RenderAligningShiftedBox {
  /// Creates a render object that lets its child overflow itself.
  RenderConstrainedNormalizedOverflowBox({
    RenderBox? child,
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
    AlignmentGeometry alignment = Alignment.center,
    TextDirection? textDirection,
  })  : _minWidth = minWidth,
        _maxWidth = maxWidth,
        _minHeight = minHeight,
        _maxHeight = maxHeight,
        super(child: child, alignment: alignment, textDirection: textDirection);

  /// The minimum width constraint to give the child. Set this to null (the
  /// default) to use the constraint from the parent instead.
  double? get minWidth => _minWidth;
  double? _minWidth;

  set minWidth(double? value) {
    if (_minWidth == value) return;
    _minWidth = value;
    markNeedsLayout();
  }

  /// The maximum width constraint to give the child. Set this to null (the
  /// default) to use the constraint from the parent instead.
  double? get maxWidth => _maxWidth;
  double? _maxWidth;

  set maxWidth(double? value) {
    if (_maxWidth == value) return;
    _maxWidth = value;
    markNeedsLayout();
  }

  /// The minimum height constraint to give the child. Set this to null (the
  /// default) to use the constraint from the parent instead.
  double? get minHeight => _minHeight;
  double? _minHeight;

  set minHeight(double? value) {
    if (_minHeight == value) return;
    _minHeight = value;
    markNeedsLayout();
  }

  /// The maximum height constraint to give the child. Set this to null (the
  /// default) to use the constraint from the parent instead.
  double? get maxHeight => _maxHeight;
  double? _maxHeight;

  set maxHeight(double? value) {
    if (_maxHeight == value) return;
    _maxHeight = value;
    markNeedsLayout();
  }

  BoxConstraints _getInnerConstraints(BoxConstraints constraints) {
    double minW = constraints.minWidth;
    double minH = constraints.minHeight;
    double maxW = constraints.maxWidth;
    double maxH = constraints.maxHeight;

    if ((_minWidth != null) && maxW < _minWidth!) maxW = _minWidth!;
    if ((_minHeight != null) && maxH < _minHeight!) maxH = _minHeight!;

    if ((_maxWidth != null) && minW > _maxWidth!) minW = _maxWidth!;
    if ((_maxHeight != null) && minH > _maxHeight!) minH = _maxHeight!;

    return BoxConstraints(
      minWidth: _minWidth ?? minW,
      maxWidth: _maxWidth ?? maxW,
      minHeight: _minHeight ?? minH,
      maxHeight: _maxHeight ?? maxH,
    );
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void performLayout() {
    if (child != null) {
      child?.layout(_getInnerConstraints(constraints), parentUsesSize: true);
      alignChild();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('minWidth', minWidth, ifNull: 'use parent minWidth constraint'));
    properties.add(DoubleProperty('maxWidth', maxWidth, ifNull: 'use parent maxWidth constraint'));
    properties
        .add(DoubleProperty('minHeight', minHeight, ifNull: 'use parent minHeight constraint'));
    properties
        .add(DoubleProperty('maxHeight', maxHeight, ifNull: 'use parent maxHeight constraint'));
  }
}
