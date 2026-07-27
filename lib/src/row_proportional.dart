import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// Developed by Marcelo Glasberg (jul 2026).

/// The [RowProportional] widget arranges its [children] horizontally, dividing all
/// the available horizontal space between them, proportionally to their preferred
/// (natural, intrinsic) widths.
///
/// In other words, it first asks each child how wide it would like to be, and then
/// scales all children by the same factor, so that together they fill the available
/// width exactly. Children are forced to their calculated widths, which means the
/// row never overflows: if there is extra space the children grow, and if space is
/// short they shrink, always keeping their relative proportions.
///
/// For example, if the first child is a `Text('Hello')` that wants to be 70 pixels
/// wide, the second child is a `SizedBox(width: 100)`, and the [RowProportional]
/// is 200 pixels wide, then the first child will be `200 / 170 * 70` pixels wide,
/// and the second child will be `200 / 170 * 100` pixels wide:
///
/// ```dart
/// RowProportional(
///   children: [
///     Text('Hello'), // Gets 200 / 170 * 70 ≈ 82.4 pixels.
///     SizedBox(width: 100), // Gets 200 / 170 * 100 ≈ 117.6 pixels.
///   ],
/// );
/// ```
///
/// ## Expanded and Flexible
///
/// If a child is wrapped in an [Expanded] with some `flex`, its preferred width is
/// multiplied by that flex, for the purpose of the proportional distribution. For
/// example, `Expanded(flex: 2, child: Text('Hello'))` where the text wants to be
/// 70 pixels wide, will be treated as if it wanted to be 140 pixels wide
/// (70 pixels times 2).
///
/// Both plain children and [Expanded] children are forced to assume exactly their
/// calculated widths. If instead you use a [Flexible], the child is allowed to be
/// SMALLER than its calculated width (but not larger). In that case the space
/// reserved for the child is still its full calculated width, and the child is
/// aligned to the start of that space.
///
/// ## Spacer
///
/// A different behavior happens if one or more of the children is a [Spacer].
/// In that case there is no proportional scaling anymore: all other children are
/// simply given their preferred widths (multiplied by their flexes, if they have
/// any), and the space left over is given to the [Spacer] (or divided between all
/// the spacers, proportionally to their flexes). For example:
///
/// ```dart
/// RowProportional(
///   children: [
///     Text('Hello'), // Gets its preferred width: 70 pixels.
///     Spacer(), // Gets all the leftover space.
///     SizedBox(width: 100), // Gets 100 pixels.
///   ],
/// );
/// ```
///
/// If there is no space left over (the other children alone already exceed the
/// available width), the spacers get zero width and the other children shrink
/// proportionally, just as if the spacers were not there.
///
/// Note: More precisely, any [Expanded] or [Flexible] child with zero preferred
/// width acts as a spacer (a [Spacer] is just an [Expanded] with an empty child).
/// For example, `Expanded(child: Container(color: Colors.red))` will fill the
/// leftover space, since a [Container] with no child has zero preferred width.
///
/// ## Fixed widths
///
/// Sometimes you want some children to have a specific immutable width that never
/// scales. This is usually for gaps, but can have other uses. To that end, wrap
/// the child in a [FixedWidth] widget (or use [FixedWidth] with no child at all,
/// which creates an empty gap):
///
/// ```dart
/// RowProportional(
///   children: [
///     Text('Hello'),
///     FixedWidth(width: 8), // An immutable 8 pixel gap.
///     FixedWidth(child: Text('World')), // Fixed at the text's natural width.
///     FixedWidth(width: 10), // An immutable 10 pixel gap.
///     FixedWidth(width: 50, child: Icon(Icons.add)), // Pinned at 50 pixels.
///   ],
/// );
/// ```
///
/// If you don't provide the `width`, the child is fixed at its preferred width:
/// in the example above, `Text('World')` always keeps exactly its natural width,
/// while the other children scale.
///
/// The fixed widths are carved out of the available space first, and only the
/// remaining space is distributed between the other children (proportionally, or
/// according to the spacers). In the unlikely case where the fixed widths alone
/// exceed the available space, the other children get zero width and the fixed
/// children shrink, proportionally to their fixed widths, so that the row still
/// never overflows.
///
/// ## Other details
///
/// * The preferred width of a child is its max intrinsic width: the width it
///   would have if it was completely unconstrained. For a [Text] this is the
///   width of the text laid out in a single line.
///
/// * If the available horizontal space is unbounded (for example, inside a
///   horizontal [ListView]), there is nothing to distribute: all children simply
///   get their preferred widths, and spacers get zero width.
///
/// * The [crossAxisAlignment] property specifies how to align the children
///   vertically. The default is to center them. To use
///   [CrossAxisAlignment.baseline], you must also provide the [textBaseline]
///   property, just like in a [Row].
///
/// * The [textDirection] property controls the direction that children are laid
///   out in, just like in a [Row]. If not provided, the ambient [Directionality]
///   is used.
///
/// For more info, see: https://pub.dartlang.org/packages/assorted_layout_widgets
///
class RowProportional extends MultiChildRenderObjectWidget {
  //
  /// The [RowProportional] widget arranges its [children] horizontally, dividing all
  /// the available horizontal space between them, proportionally to their preferred
  /// (natural, intrinsic) widths.
  ///
  /// In other words, it first asks each child how wide it would like to be, and then
  /// scales all children by the same factor, so that together they fill the available
  /// width exactly. Children are forced to their calculated widths, which means the
  /// row never overflows: if there is extra space the children grow, and if space is
  /// short they shrink, always keeping their relative proportions.
  ///
  /// For example, if the first child is a `Text('Hello')` that wants to be 70 pixels
  /// wide, the second child is a `SizedBox(width: 100)`, and the [RowProportional]
  /// is 200 pixels wide, then the first child will be `200 / 170 * 70` pixels wide,
  /// and the second child will be `200 / 170 * 100` pixels wide.
  ///
  /// * Wrapping a child in an [Expanded] multiplies its preferred width by the
  ///   `flex`, for the purpose of the proportional distribution.
  ///
  /// * Wrapping a child in a [Flexible] does the same, but also allows the child
  ///   to be SMALLER than its calculated width (while an [Expanded] or a plain
  ///   child is forced to assume its calculated width exactly).
  ///
  /// * If one or more children are [Spacer]s, there is no proportional scaling
  ///   anymore: the other children simply get their preferred widths (times their
  ///   flexes), and the leftover space is divided between the spacers.
  ///
  /// * Children wrapped in [FixedWidth] get an immutable width, which is carved
  ///   out of the available space before the proportional distribution. Use
  ///   `FixedWidth(width: 8)` with no child for a fixed 8 pixel gap, or
  ///   `FixedWidth(child: ...)` with no width to fix a child at its preferred
  ///   width. If the fixed widths alone exceed the available space, they shrink
  ///   proportionally to each other, so the row never overflows.
  ///
  /// For more info, see: https://pub.dartlang.org/packages/assorted_layout_widgets
  ///
  const RowProportional({
    super.key,
    super.children,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.textBaseline,
  }) : assert(
            crossAxisAlignment != CrossAxisAlignment.baseline || textBaseline != null,
            'To use CrossAxisAlignment.baseline, you must also provide a textBaseline.');

  /// The [crossAxisAlignment] property specifies how to align the children
  /// vertically. The default is to center them. To use
  /// [CrossAxisAlignment.baseline], you must also provide the [textBaseline]
  /// property, just like in a [Row].
  final CrossAxisAlignment crossAxisAlignment;

  /// The [textBaseline] property defines which baseline to use when aligning
  /// the children with [CrossAxisAlignment.baseline]. It's required when
  /// [crossAxisAlignment] is [CrossAxisAlignment.baseline], and ignored
  /// otherwise.
  final TextBaseline? textBaseline;

  /// The [textDirection] property controls the direction that children are laid
  /// out in. [TextDirection.ltr] lays out the first child to the left, with
  /// subsequent children following to the right. [TextDirection.rtl] does the
  /// opposite. If not provided, the ambient [Directionality] is used.
  final TextDirection? textDirection;

  TextDirection _effectiveTextDirection(BuildContext context) =>
      textDirection ?? Directionality.maybeOf(context) ?? TextDirection.ltr;

  @override
  _RenderRowProportional createRenderObject(BuildContext context) =>
      _RenderRowProportional(
        crossAxisAlignment: crossAxisAlignment,
        textDirection: _effectiveTextDirection(context),
        textBaseline: textBaseline,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderRowProportional renderObject) {
    renderObject
      ..crossAxisAlignment = crossAxisAlignment
      ..textDirection = _effectiveTextDirection(context)
      ..textBaseline = textBaseline;
  }
}

/// The [FixedWidth] widget gives a child of [RowProportional] an immutable width,
/// that never scales and does not participate in the proportional distribution of
/// space. The fixed widths are carved out of the available space first, and only
/// the remaining space is distributed between the other children.
///
/// If you provide a [width], the child is given exactly that width. If you don't
/// provide it, the child is fixed at its own preferred (natural, intrinsic)
/// width. This is usually for gaps, but can have other uses:
///
/// ```dart
/// RowProportional(
///   children: [
///     Text('Hello'),
///     FixedWidth(width: 8), // An immutable 8 pixel gap.
///     FixedWidth(child: Text('World')), // Fixed at the text's natural width.
///     FixedWidth(width: 50, child: Icon(Icons.add)), // Pinned at 50 pixels.
///   ],
/// );
/// ```
///
/// In the example above, `Text('World')` always keeps exactly the width that fits
/// the text, while the other children scale. A `FixedWidth()` with neither width
/// nor child is simply a zero width box.
///
/// There is one exception to the immutability: if the fixed widths alone exceed
/// the available space, the fixed children shrink, proportionally to their fixed
/// widths, so that the row never overflows (all other children get zero width in
/// that case).
///
/// The [FixedWidth] widget must be a direct child of a [RowProportional]
/// (just like an [Expanded] must be a direct child of a [Row]).
///
class FixedWidth extends ParentDataWidget<RowProportionalParentData> {
  //
  /// The [FixedWidth] widget gives a child of [RowProportional] an immutable
  /// width, that never scales and does not participate in the proportional
  /// distribution of space. If you provide a [width], the child is given exactly
  /// that width; otherwise the child is fixed at its own preferred (natural,
  /// intrinsic) width. If you don't provide a [child], you get an empty gap of
  /// the given [width]. Must be a direct child of a [RowProportional].
  const FixedWidth({
    super.key,
    this.width,
    Widget? child,
  })  : assert(width == null || width >= 0.0,
            'The width must be equal to or greater than zero.'),
        super(child: child ?? const SizedBox.shrink());

  /// The exact width, in pixels, that the child will be given. If not provided,
  /// the child is fixed at its preferred (natural, intrinsic) width.
  final double? width;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is RowProportionalParentData);
    final parentData = renderObject.parentData! as RowProportionalParentData;

    if (!parentData.isFixedWidth || parentData.fixedWidth != width) {
      parentData.isFixedWidth = true;
      parentData.fixedWidth = width;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => RowProportional;
}

/// Parent data for use with [RowProportional].
///
/// It extends [FlexParentData] so that [Expanded], [Flexible] and [Spacer]
/// (which write their `flex` and `fit` into [FlexParentData]) may be used as
/// direct children of [RowProportional].
class RowProportionalParentData extends FlexParentData {
  //
  /// If true, the child does not participate in the proportional distribution of
  /// space: it's given exactly [fixedWidth] pixels, or its preferred width if
  /// [fixedWidth] is null. Set by the [FixedWidth] widget.
  bool isFixedWidth = false;

  /// The immutable width given to the child, when [isFixedWidth] is true.
  /// If null, the child's preferred width is used instead.
  /// Set by the [FixedWidth] widget.
  double? fixedWidth;
}

enum _Kind { fixed, spacer, proportional }

/// How a single child participates in the layout:
/// * [_Kind.fixed]: [value] is its immutable width in pixels.
/// * [_Kind.spacer]: [value] is its flex.
/// * [_Kind.proportional]: [value] is its weight (preferred width times flex).
class _Measure {
  _Measure.fixed(this.value) : kind = _Kind.fixed;

  _Measure.spacer(int flex)
      : kind = _Kind.spacer,
        value = flex.toDouble();

  _Measure.proportional(this.value) : kind = _Kind.proportional;

  final _Kind kind;
  final double value;
}

class _Measurements {
  _Measurements(this.measures, this.fixedTotal, this.weightTotal, this.spacerFlexTotal);

  final List<_Measure> measures;
  final double fixedTotal;
  final double weightTotal;
  final int spacerFlexTotal;
}

class _RenderRowProportional extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, RowProportionalParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, RowProportionalParentData> {
  //
  _RenderRowProportional({
    required CrossAxisAlignment crossAxisAlignment,
    required TextDirection textDirection,
    required TextBaseline? textBaseline,
  })  : _crossAxisAlignment = crossAxisAlignment,
        _textDirection = textDirection,
        _textBaseline = textBaseline;

  CrossAxisAlignment _crossAxisAlignment;
  TextDirection _textDirection;
  TextBaseline? _textBaseline;

  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;

  TextDirection get textDirection => _textDirection;

  TextBaseline? get textBaseline => _textBaseline;

  set crossAxisAlignment(CrossAxisAlignment value) {
    if (_crossAxisAlignment == value) return;
    _crossAxisAlignment = value;
    markNeedsLayout();
  }

  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  set textBaseline(TextBaseline? value) {
    if (_textBaseline == value) return;
    _textBaseline = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RowProportionalParentData)
      child.parentData = RowProportionalParentData();
  }

  /// Measures all the children, deciding how each one participates in the layout.
  _Measurements _measure() {
    final measures = <_Measure>[];
    double fixedTotal = 0.0;
    double weightTotal = 0.0;
    int spacerFlexTotal = 0;

    RenderBox? child = firstChild;
    while (child != null) {
      final parentData = child.parentData! as RowProportionalParentData;

      // 1) A child wrapped in `FixedWidth` gets its immutable width: either the
      // given width, or the child's own preferred width if none was given.
      if (parentData.isFixedWidth) {
        final double fixedWidth =
            parentData.fixedWidth ?? child.getMaxIntrinsicWidth(double.infinity);
        fixedTotal += fixedWidth;
        measures.add(_Measure.fixed(fixedWidth));
      }
      //
      else {
        final int flex = parentData.flex ?? 0;
        final double preferredWidth = child.getMaxIntrinsicWidth(double.infinity);

        // 2) A flexed child with no preferred width of its own is a `Spacer`.
        if (flex > 0 && preferredWidth == 0.0) {
          spacerFlexTotal += flex;
          measures.add(_Measure.spacer(flex));
        }
        // 3) Any other child participates proportionally to its preferred width,
        // multiplied by its flex (if it's wrapped in an `Expanded` or `Flexible`).
        else {
          final double weight = preferredWidth * math.max(1, flex);
          weightTotal += weight;
          measures.add(_Measure.proportional(weight));
        }
      }

      child = parentData.nextSibling;
    }

    return _Measurements(measures, fixedTotal, weightTotal, spacerFlexTotal);
  }

  /// Calculates the width each child should be given, considering the
  /// available [maxWidth] (which may be infinite).
  List<double> _childWidths(double maxWidth) {
    final _Measurements m = _measure();

    double scale = 1.0;
    double fixedScale = 1.0;
    double spacerSpace = 0.0;

    if (maxWidth.isFinite) {
      //
      // If the fixed widths alone exceed the available space, the fixed children
      // shrink proportionally to each other, and everything else gets zero.
      if (m.fixedTotal > maxWidth) {
        fixedScale = maxWidth / m.fixedTotal;
        scale = 0.0;
      }
      //
      else {
        // The fixed widths are carved out of the available space first.
        final double remaining = maxWidth - m.fixedTotal;
        final double leftover = remaining - m.weightTotal;

        // If there are spacers AND leftover space, children get their preferred
        // widths (times flex) and the spacers divide the leftover between them.
        if (m.spacerFlexTotal > 0 && leftover >= 0.0) {
          spacerSpace = leftover;
        }
        // Otherwise, the remaining space is distributed proportionally
        // (growing or shrinking the children), and spacers get zero.
        else {
          scale = (m.weightTotal == 0.0) ? 0.0 : remaining / m.weightTotal;
        }
      }
    }
    // If the available space is unbounded, there is nothing to distribute:
    // children simply get their preferred widths, and spacers get zero.

    return m.measures.map((measure) {
      switch (measure.kind) {
        case _Kind.fixed:
          return measure.value * fixedScale;
        case _Kind.spacer:
          return spacerSpace * measure.value / m.spacerFlexTotal;
        case _Kind.proportional:
          return measure.value * scale;
      }
    }).toList();
  }

  BoxConstraints _childConstraints({
    required double width,
    required bool loose,
    required BoxConstraints constraints,
  }) {
    final bool stretch = (crossAxisAlignment == CrossAxisAlignment.stretch) &&
        constraints.maxHeight.isFinite;

    return BoxConstraints(
      // `Flexible` children may be smaller than their calculated width.
      minWidth: loose ? 0.0 : width,
      maxWidth: width,
      minHeight: stretch ? constraints.maxHeight : 0.0,
      maxHeight: constraints.maxHeight,
    );
  }

  double _totalWidth(BoxConstraints constraints, List<double> widths) =>
      constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : widths.fold(0.0, (a, b) => a + b);

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    final List<double> widths = _childWidths(constraints.maxWidth);

    // --- Layout all the children with their calculated widths. ---
    double maxChildHeight = 0.0;
    int index = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final parentData = child.parentData! as RowProportionalParentData;

      child.layout(
        _childConstraints(
          width: widths[index],
          loose: parentData.fit == FlexFit.loose,
          constraints: constraints,
        ),
        parentUsesSize: true,
      );

      maxChildHeight = math.max(maxChildHeight, child.size.height);
      index++;
      child = parentData.nextSibling;
    }

    // For `CrossAxisAlignment.baseline`, children are shifted down to align
    // their baselines, which may make the row taller than its tallest child.
    double maxAboveBaseline = 0.0;
    if (crossAxisAlignment == CrossAxisAlignment.baseline) {
      assert(textBaseline != null,
          'To use CrossAxisAlignment.baseline, you must also provide a textBaseline.');

      double maxBelowBaseline = 0.0;
      double maxHeightNoBaseline = 0.0;

      child = firstChild;
      while (child != null) {
        final double? baseline =
            child.getDistanceToBaseline(textBaseline!, onlyReal: true);

        // Children with no baseline are aligned to the top, like in a `Row`.
        if (baseline == null)
          maxHeightNoBaseline = math.max(maxHeightNoBaseline, child.size.height);
        else {
          maxAboveBaseline = math.max(maxAboveBaseline, baseline);
          maxBelowBaseline = math.max(maxBelowBaseline, child.size.height - baseline);
        }

        child = (child.parentData! as RowProportionalParentData).nextSibling;
      }

      maxChildHeight =
          math.max(maxHeightNoBaseline, maxAboveBaseline + maxBelowBaseline);
    }

    size = constraints.constrain(Size(_totalWidth(constraints, widths), maxChildHeight));

    // --- Position the children. ---
    final bool ltr = (textDirection == TextDirection.ltr);
    double x = ltr ? 0.0 : size.width;
    index = 0;
    child = firstChild;
    while (child != null) {
      final parentData = child.parentData! as RowProportionalParentData;
      final double slotWidth = widths[index];

      final double slotLeft;
      if (ltr) {
        slotLeft = x;
        x += slotWidth;
      } else {
        x -= slotWidth;
        slotLeft = x;
      }

      // A `Flexible` child smaller than its calculated width is aligned to the
      // start of the space reserved for it (its left side, for LTR).
      final double dx = ltr ? slotLeft : (slotLeft + slotWidth - child.size.width);

      parentData.offset = Offset(dx, _dy(child, size.height, maxAboveBaseline));
      index++;
      child = parentData.nextSibling;
    }
  }

  double _dy(RenderBox child, double rowHeight, double maxAboveBaseline) {
    final double childHeight = child.size.height;

    switch (crossAxisAlignment) {
      case CrossAxisAlignment.start:
      case CrossAxisAlignment.stretch:
        return 0.0;
      case CrossAxisAlignment.end:
        return rowHeight - childHeight;
      case CrossAxisAlignment.center:
        return (rowHeight - childHeight) / 2.0;
      case CrossAxisAlignment.baseline:
        final double? baseline =
            child.getDistanceToBaseline(textBaseline!, onlyReal: true);
        // Children with no baseline are aligned to the top, like in a `Row`.
        return (baseline == null) ? 0.0 : maxAboveBaseline - baseline;
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final List<double> widths = _childWidths(constraints.maxWidth);

    final double height = _rowHeight(constraints, widths,
        (child, childConstraints) => child.getDryLayout(childConstraints).height);

    return constraints.constrain(Size(_totalWidth(constraints, widths), height));
  }

  /// The height of the row, given the calculated child [widths], using
  /// [childHeight] to measure each child. For [CrossAxisAlignment.baseline],
  /// children are shifted down to align their (dry) baselines, which may make
  /// the row taller than its tallest child.
  double _rowHeight(
    BoxConstraints constraints,
    List<double> widths,
    double Function(RenderBox child, BoxConstraints childConstraints) childHeight,
  ) {
    final bool isBaseline = (crossAxisAlignment == CrossAxisAlignment.baseline);

    double maxHeight = 0.0;
    double maxAboveBaseline = 0.0;
    double maxBelowBaseline = 0.0;

    int index = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final parentData = child.parentData! as RowProportionalParentData;

      final BoxConstraints childConstraints = _childConstraints(
        width: widths[index],
        loose: parentData.fit == FlexFit.loose,
        constraints: constraints,
      );

      final double height = childHeight(child, childConstraints);
      final double? baseline =
          isBaseline ? child.getDryBaseline(childConstraints, textBaseline!) : null;

      // Children with no baseline are aligned to the top, like in a `Row`.
      if (baseline == null)
        maxHeight = math.max(maxHeight, height);
      else {
        maxAboveBaseline = math.max(maxAboveBaseline, baseline);
        maxBelowBaseline = math.max(maxBelowBaseline, height - baseline);
      }

      index++;
      child = parentData.nextSibling;
    }

    return math.max(maxHeight, maxAboveBaseline + maxBelowBaseline);
  }

  /// The row can be given any width without overflowing: even the fixed-width
  /// children shrink, when the fixed widths alone exceed the available space.
  @override
  double computeMinIntrinsicWidth(double height) => 0.0;

  /// The natural width of the row: all fixed widths, plus all preferred widths
  /// (times their flexes). Spacers count as zero.
  @override
  double computeMaxIntrinsicWidth(double height) {
    final _Measurements m = _measure();
    return m.fixedTotal + m.weightTotal;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final List<double> widths = _childWidths(width);
    return _rowHeight(
        BoxConstraints(maxWidth: width),
        widths,
        (child, childConstraints) =>
            child.getMinIntrinsicHeight(childConstraints.maxWidth));
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final List<double> widths = _childWidths(width);
    return _rowHeight(
        BoxConstraints(maxWidth: width),
        widths,
        (child, childConstraints) =>
            child.getMaxIntrinsicHeight(childConstraints.maxWidth));
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      defaultComputeDistanceToHighestActualBaseline(baseline);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);
}
