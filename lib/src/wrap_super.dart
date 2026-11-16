import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

import 'minimum_raggedness.dart';

enum WrapType {
  /// Will fit all widgets it can in a line, and then move to the next one.
  fit,

  /// The number of lines will be similar as in [WrapType.fit],
  /// however, it will try to minimize the difference between line widths.
  /// This is the default.
  balanced,
}

enum WrapFit {
  /// Will keep each widget's original width.
  min,

  /// After the calculation, will make widgets fit all the available space.
  /// All widgets in a line will have the same width, even if it makes them
  /// smaller that their original width.
  divided,

  /// After the calculation, will make widgets larger, so that they fit all the
  /// available space. Widgets width will be proportional to their original width.
  proportional,

  /// After the calculation, will make widgets larger, so that they fit all the
  /// available space. Will try to make all widgets the same width,
  /// but won't make any widgets smaller than their original width.
  ///
  /// The procedure is this:
  /// 1) First, divide the available line width by the number of widgets in the
  /// line. That is the preferred width.
  /// 2) Keep the width of all widgets larger than that preferred width.
  /// 3) Calculate the remaining width and divide it equally by the remaining
  /// widgets.
  ///
  /// This is the default.
  larger,
}

/// The horizontal alignment of each line of a [WrapSuper].
enum WrapSuperAlignment {
  /// Aligns each line to the left, whatever the text direction.
  left,

  /// Aligns each line to the right, whatever the text direction.
  right,

  /// Centers each line.
  center,

  /// Aligns each line to the start of the text direction: to the left in
  /// left-to-right text, and to the right in right-to-left text.
  /// This is the default.
  start,

  /// Aligns each line to the end of the text direction: to the right in
  /// left-to-right text, and to the left in right-to-left text.
  end,
}

class WrapSuper extends MultiChildRenderObjectWidget {
  /// `WrapSuper` is a `Wrap` with a better, minimum raggedness algorithm
  /// for line-breaks. Just like a regular `Wrap` widget with
  /// `direction = Axis.horizontal`, `WrapSuper` displays its children in lines.
  /// It will leave `spacing` horizontal space between each child,
  /// and it will leave `lineSpacing` vertical space between each line.
  /// Each line will then be aligned according to the `alignment`, and the
  /// children inside each line will be vertically aligned according to the
  /// `crossAxisAlignment`.
  ///
  /// `WrapSuper` with `WrapType.fit` is just like `Wrap`.
  ///
  /// However, `WrapSuper` with `WrapType.balanced` (the default)
  /// follows a more balanced layout. It will result in the same number
  /// of lines as `Wrap`, but lines will tend to be more similar in width.
  ///
  /// You can see my original StackOverflow question that prompted this widget here:
  /// https://stackoverflow.com/questions/51679895/in-flutter-how-to-balance-the-children-of-the-wrap-widget
  ///
  /// And you can see the algorithm I am using here (Divide and Conquer):
  /// https://xxyxyz.org/line-breaking/
  ///
  const WrapSuper({
    Key? key,
    this.wrapType = WrapType.balanced,
    this.wrapFit = WrapFit.min,
    this.spacing = 0.0,
    this.lineSpacing = 0.0,
    this.alignment = WrapSuperAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.textDirection,
    List<Widget> children = const [],
  }) : super(key: key, children: children);

  /// The horizontal alignment of each line.
  ///
  /// Defaults to [WrapSuperAlignment.start].
  final WrapSuperAlignment alignment;

  /// The vertical alignment of the children inside each line. Children
  /// shorter than the tallest child of their line will be placed at the top
  /// ([WrapCrossAlignment.start]), center ([WrapCrossAlignment.center]) or
  /// bottom ([WrapCrossAlignment.end]) of the line.
  ///
  /// Defaults to [WrapCrossAlignment.start].
  final WrapCrossAlignment crossAxisAlignment;

  /// The order in which the children are placed in each line. In
  /// [TextDirection.ltr] they go from left to right, and in [TextDirection.rtl]
  /// from right to left. It also defines where [WrapSuperAlignment.start] and
  /// [WrapSuperAlignment.end] are.
  ///
  /// Defaults to the ambient [Directionality], or [TextDirection.ltr] if there
  /// is none.
  final TextDirection? textDirection;

  /// Defaults to 0.0.
  final double spacing;

  /// Defaults to 0.0.
  final double lineSpacing;

  final WrapType wrapType;

  final WrapFit wrapFit;

  TextDirection _textDirection(BuildContext context) =>
      textDirection ?? Directionality.maybeOf(context) ?? TextDirection.ltr;

  @override
  _RenderWrapSuper createRenderObject(BuildContext context) {
    return _RenderWrapSuper(
      spacing: spacing,
      lineSpacing: lineSpacing,
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: _textDirection(context),
      wrapType: wrapType,
      wrapFit: wrapFit,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderWrapSuper renderObject) {
    renderObject
      ..spacing = spacing
      ..lineSpacing = lineSpacing
      ..alignment = alignment
      ..crossAxisAlignment = crossAxisAlignment
      ..textDirection = _textDirection(context)
      ..wrapType = wrapType
      ..wrapFit = wrapFit;
  }
}

class _RenderWrapSuper extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>,
        RenderBoxContainerDefaultsMixin<RenderBox, ContainerBoxParentData<RenderBox>> {
  //
  _RenderWrapSuper({
    List<RenderBox>? children,
    this._spacing = 0.0,
    this._lineSpacing = 0.0,
    this._alignment = WrapSuperAlignment.start,
    this._crossAxisAlignment = WrapCrossAlignment.start,
    this._textDirection = TextDirection.ltr,
    this._wrapType = WrapType.balanced,
    this._wrapFit = WrapFit.min,
  }) {
    addAll(children);
  }

  /// Defaults to 0.0.
  double get spacing => _spacing;
  double _spacing;

  set spacing(double value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  /// Defaults to 0.0.
  double get lineSpacing => _lineSpacing;
  double _lineSpacing;

  set lineSpacing(double value) {
    if (_lineSpacing == value) return;
    _lineSpacing = value;
    markNeedsLayout();
  }

  /// Defaults to WrapSuperAlignment.start.
  WrapSuperAlignment get alignment => _alignment;
  WrapSuperAlignment _alignment;

  set alignment(WrapSuperAlignment value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsLayout();
  }

  /// Defaults to WrapCrossAlignment.start.
  WrapCrossAlignment get crossAxisAlignment => _crossAxisAlignment;
  WrapCrossAlignment _crossAxisAlignment;

  set crossAxisAlignment(WrapCrossAlignment value) {
    if (_crossAxisAlignment == value) return;
    _crossAxisAlignment = value;
    markNeedsLayout();
  }

  /// Defaults to TextDirection.ltr.
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;

  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  WrapType get wrapType => _wrapType;
  WrapType _wrapType;

  set wrapType(WrapType value) {
    if (_wrapType == value) return;
    _wrapType = value;
    markNeedsLayout();
  }

  WrapFit get wrapFit => _wrapFit;
  WrapFit _wrapFit;

  set wrapFit(WrapFit value) {
    if (_wrapFit == value) return;
    _wrapFit = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! WrapParentData) child.parentData = WrapParentData();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    double width = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      width = max(width, child.getMinIntrinsicWidth(double.infinity));
      child = childAfter(child);
    }
    return width;
  }

  /// The width needed to fit all children in a single line.
  @override
  double computeMaxIntrinsicWidth(double height) {
    double width = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      width += child.getMaxIntrinsicWidth(double.infinity);
      child = childAfter(child);
    }
    if (childCount > 1) width += spacing * (childCount - 1);
    return width;
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      computeDryLayout(BoxConstraints(maxWidth: width)).height;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      computeDryLayout(BoxConstraints(maxWidth: width)).height;

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _layout(constraints, dry: true);

  @override
  void performLayout() {
    size = _layout(constraints, dry: false);
  }

  /// Calculates the layout. When [dry] is true, children are measured with
  /// [RenderBox.getDryLayout], and nothing is laid out or positioned. Otherwise,
  /// children are laid out and positioned. Both use the exact same algorithm,
  /// so that the dry layout size is always the same as the actual size.
  Size _layout(BoxConstraints constraints, {required bool dry}) {
    //
    final double maxWidth = constraints.maxWidth;
    final bool isBounded = maxWidth.isFinite;

    final List<RenderBox> children = getChildrenAsList();
    final int count = children.length;
    final List<Size> sizes = List<Size>.filled(count, Size.zero);

    Size sizeChild(int index, BoxConstraints childConstraints) {
      final RenderBox child = children[index];
      final Size childSize;
      if (dry) {
        childSize = child.getDryLayout(childConstraints);
      } else {
        child.layout(childConstraints, parentUsesSize: true);
        childSize = child.size;
      }
      sizes[index] = childSize;
      return childSize;
    }

    // There is no available width to fill when the width is unbounded.
    // In this case, all wrap-fits work like WrapFit.min.
    final bool fills = (wrapFit != WrapFit.min) && isBounded;

    // 1) The widths used to decide which children go in which lines.
    final List<double> breakWidths = [
      for (int index = 0; index < count; index++)
        if (fills)
          children[index].getMaxIntrinsicWidth(double.infinity)
        else
          sizeChild(index, BoxConstraints(maxWidth: maxWidth)).width,
    ];

    // 2) Calculate which children go in which lines.
    final List<List<int>> lines = _breakIntoLines(breakWidths, maxWidth);

    // 3) When the wrap-fit fills the lines, size the children to fill them.
    if (fills) {
      for (final List<int> line in lines) {
        _sizeChildrenToFillLine(line, breakWidths, maxWidth, sizeChild);
      }
    }

    // 4) Calculate the size, and position each line and its children.
    double width;
    if (isBounded)
      width = maxWidth;
    else {
      width = 0;
      for (final List<int> line in lines) width = max(width, _lineWidth(line, sizes));
    }
    width = constraints.constrainWidth(width);

    double y = 0;
    for (final List<int> line in lines) {
      double lineHeight = 0;
      for (final int index in line) lineHeight = max(lineHeight, sizes[index].height);

      if (!dry) _positionLine(line, children, sizes, width, top: y, lineHeight: lineHeight);

      y += lineHeight + lineSpacing;
    }

    final double height = lines.isEmpty ? 0 : y - lineSpacing;

    return constraints.constrain(Size(width, height));
  }

  /// Returns the children indexes of each line.
  List<List<int>> _breakIntoLines(List<double> widths, double maxWidth) {
    //
    if (widths.isEmpty) return [];

    // When the width is unbounded, all children fit in a single line.
    if (!maxWidth.isFinite) return [List<int>.generate(widths.length, (index) => index)];

    // Will try to minimize the difference between line widths.
    if (wrapType == WrapType.balanced) {
      return MinimumRaggedness.divide(widths, maxWidth, spacing: spacing);
    }
    //
    // Will fit all widgets it can in a line, and then move to the next one.
    else if (wrapType == WrapType.fit) {
      List<List<int>> lines = [];
      List<int> line = [];
      lines.add(line);
      double x = 0;

      for (int index = 0; index < widths.length; index++) {
        double width = widths[index];

        if (line.isNotEmpty && (x + width) > maxWidth) {
          x = 0;
          line = [];
          lines.add(line);
        }

        line.add(index);
        x += width + spacing;
      }

      return lines;
    }
    //
    else
      throw AssertionError(wrapType);
  }

  /// Sizes the children of the [line] so that they fill the available width,
  /// according to the [wrapFit].
  void _sizeChildrenToFillLine(
    List<int> line,
    List<double> intrinsicWidths,
    double availableWidth,
    Size Function(int index, BoxConstraints childConstraints) sizeChild,
  ) {
    final int numberOfChildrenInLine = line.length;
    final double availableWidthMinusSpacing =
        availableWidth - (spacing * (numberOfChildrenInLine - 1));

    // After the calculation, will make widgets fit all the available space.
    // All widgets in a line will have the same width, even if it makes them
    // smaller that their original width.
    if (wrapFit == WrapFit.divided) {
      final double width = availableWidthMinusSpacing / numberOfChildrenInLine;
      for (final int index in line) {
        sizeChild(index, BoxConstraints.tightFor(width: width));
      }
    }
    //
    // After the calculation, will make widgets larger, so that they fit all the
    // available space. Widgets width will be proportional to their original width.
    else if (wrapFit == WrapFit.proportional) {
      double sumOfWidgetsInLine = 0;
      for (final int index in line) sumOfWidgetsInLine += intrinsicWidths[index];

      for (final int index in line) {
        final double width =
            availableWidthMinusSpacing * (intrinsicWidths[index] / sumOfWidgetsInLine);
        sizeChild(index, BoxConstraints.tightFor(width: width));
      }
    }
    //
    // After the calculation, will make widgets larger, so that they fit all the
    // available space. Will try to make all widgets the same width,
    // but won't make any widgets smaller than their original width.
    //
    // The procedure is this:
    // 1) First, divide the available line width by the number of widgets in the
    // line. That is the preferred width.
    // 2) Keep the width of all widgets larger than that preferred width.
    // 3) Calculate the remaining width and divide it equally by the remaining
    // widgets.
    else if (wrapFit == WrapFit.larger) {
      // 1) First, divide the available line width by the number
      // of widgets in the line. That is the preferred width.
      final double preferredWidth = availableWidthMinusSpacing / numberOfChildrenInLine;

      // 3) Calculate the remaining width.
      double remainingWidth = availableWidthMinusSpacing;
      int numberOfLargerWidgets = 0;
      for (final int index in line) {
        final double childWidth = intrinsicWidths[index];
        if (childWidth >= preferredWidth) {
          numberOfLargerWidgets++;
          remainingWidth -= childWidth;
        }
      }

      // 3) Divide the remaining width by the remaining widgets.
      final double preferredWidthForRemainingWidgets =
          remainingWidth / (numberOfChildrenInLine - numberOfLargerWidgets);

      for (final int index in line) {
        final double childWidth = intrinsicWidths[index];

        final double width;

        // 2) Keep the width of all widgets larger than that preferred width.
        if (childWidth >= preferredWidth)
          width = min(childWidth, availableWidthMinusSpacing);
        //
        // 3) Divide the remaining width by the remaining widgets.
        else
          width = preferredWidthForRemainingWidgets;

        sizeChild(index, BoxConstraints.tightFor(width: width));
      }
    }
    //
    else
      throw AssertionError(wrapFit);
  }

  double _lineWidth(List<int> line, List<Size> sizes) {
    double width = 0;
    for (final int index in line) width += sizes[index].width;
    return width + spacing * (line.length - 1);
  }

  /// Positions the children of the [line], according to the [alignment],
  /// [crossAxisAlignment] and [textDirection].
  void _positionLine(
    List<int> line,
    List<RenderBox> children,
    List<Size> sizes,
    double width, {
    required double top,
    required double lineHeight,
  }) {
    final bool isRtl = textDirection == TextDirection.rtl;
    final double lineWidth = _lineWidth(line, sizes);
    final double freeSpace = width - lineWidth;

    // The left edge of the line.
    final double lineLeft = switch (alignment) {
      WrapSuperAlignment.left => 0,
      WrapSuperAlignment.right => freeSpace,
      WrapSuperAlignment.center => freeSpace / 2,
      WrapSuperAlignment.start => isRtl ? freeSpace : 0,
      WrapSuperAlignment.end => isRtl ? 0 : freeSpace,
    };

    final double crossAxisFactor = switch (crossAxisAlignment) {
      WrapCrossAlignment.start => 0,
      WrapCrossAlignment.center => 0.5,
      WrapCrossAlignment.end => 1,
    };

    // In RTL, the children go from right to left, starting at the right edge of the line.
    double x = isRtl ? lineLeft + lineWidth : lineLeft;

    for (final int index in line) {
      final Size childSize = sizes[index];
      final double dx = isRtl ? x - childSize.width : x;
      final double dy = top + (lineHeight - childSize.height) * crossAxisFactor;

      (children[index].parentData as ContainerBoxParentData).offset = Offset(dx, dy);

      x = isRtl ? x - childSize.width - spacing : x + childSize.width + spacing;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
