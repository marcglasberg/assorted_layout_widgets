import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'minimum_raggedness.dart';

enum WrapSuperAlignment { left, right, center }

enum WrapType {
  /// Will fit all widgets it can in a line, and then move to the next one.
  fit,

  /// The number of lines will be the same as in [WrapType.fit],
  /// however, it will try to minimize the difference between line widths.
  balanced,
}

class WrapSuper extends MultiChildRenderObjectWidget {
  /// `WrapSuper` is just like `Wrap`, but follows a more balanced layout.
  /// It will result in a similar number of lines as `Wrap`, but
  /// lines will tend to be more similar in width.
  ///
  /// For example, this would be a Wrap's layout:
  /// ```
  /// aaaaaaaaaa bbbbbbbb cccccccccccccccc
  /// ddddd eee
  /// ```
  ///
  /// While this would be a `WrapSuper`'s layout:
  /// ```
  /// aaaaaaaaaa bbbbbbbb
  /// cccccccccccccccc ddddd eee
  /// ```
  ///
  /// You can see my original StackOverflow question that prompted this widget here:
  /// https://stackoverflow.com/questions/51679895/in-flutter-how-to-balance-the-children-of-the-wrap-widget
  ///
  /// And you can see its algorithm here:
  /// https://cs.stackexchange.com/questions/123276/whats-the-most-efficient-in-terms-of-time-algorithm-to-calculate-the-minimum
  ///
  WrapSuper({
    Key key,
    this.wrapType = WrapType.balanced,
    this.spacing = 0.0,
    this.lineSpacing = 0.0,
    this.curve,
    this.alignment = WrapSuperAlignment.left,
    List<Widget> children = const <Widget>[],
  })
      : assert(wrapType != null),
        assert(wrapType != WrapType.balanced || curve == null),
        super(key: key, children: children);

  final WrapSuperAlignment alignment;

  /// Defaults to 0.0.
  final double spacing;

  /// Defaults to 0.0.
  final double lineSpacing;

  final WrapType wrapType;

  /// This will be used only when the [wrapType] is [WrapType.fit].
  /// If [wrapType] is [WrapType.balanced], then [curve] must be null.
  final double Function(int line) curve;

  @override
  _RenderWrapSuper createRenderObject(BuildContext context) {
    return _RenderWrapSuper(
      spacing: spacing,
      runSpacing: lineSpacing,
      alignment: alignment,
      wrapType: wrapType,
      curve: curve,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderWrapSuper renderObject) {
    renderObject
      ..spacing = spacing
      ..runSpacing = lineSpacing
      ..alignment = alignment
      ..wrapType = wrapType
      ..curve = curve;
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class _RenderWrapSuper extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>,
        RenderBoxContainerDefaultsMixin<RenderBox, ContainerBoxParentData<RenderBox>> {
  /// Creates a wrap render object.
  ///
  /// By default, the wrap layout is horizontal and both the children and the
  /// runs are aligned to the start.
  _RenderWrapSuper({
    List<RenderBox> children,
    double spacing = 0.0,
    double runSpacing = 0.0,
    WrapSuperAlignment alignment = WrapSuperAlignment.left,
    WrapType wrapType = WrapType.balanced,
    double Function(int line) curve,
  })
      : assert(spacing != null),
        assert(runSpacing != null),
        assert(alignment != null),
        _spacing = spacing,
        _runSpacing = runSpacing,
        _alignment = alignment,
        _curve = curve,
        _wrapType = wrapType {
    addAll(children);
  }

  /// Defaults to 0.0.
  double get spacing => _spacing;
  double _spacing;

  set spacing(double value) {
    assert(value != null);
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  /// Defaults to 0.0.
  double get runSpacing => _runSpacing;
  double _runSpacing;

  set runSpacing(double value) {
    assert(value != null);
    if (_runSpacing == value) return;
    _runSpacing = value;
    markNeedsLayout();
  }

  WrapSuperAlignment get alignment => _alignment;
  WrapSuperAlignment _alignment;

  set alignment(WrapSuperAlignment value) {
    assert(value != null);
    if (_alignment == value) return;
    _alignment = value;
    markNeedsLayout();
  }

  WrapType get wrapType => _wrapType;
  WrapType _wrapType;

  set wrapType(WrapType value) {
    assert(value != null);
    if (_wrapType == value) return;
    _wrapType = value;
    markNeedsLayout();
  }

  double Function(int line) get curve => _curve;
  double Function(int line) _curve;

  set curve(double Function(int line) value) {
    if (_curve == value) return;
    _curve = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! WrapParentData) child.parentData = WrapParentData();
  }

  double _computeIntrinsicHeightForWidth(double width) {
    return 0;
//    int runCount = 0;
//    double height = 0.0;
//    double runWidth = 0.0;
//    double runHeight = 0.0;
//    int childCount = 0;
//    RenderBox child = firstChild;
//    while (child != null) {
//      final double childWidth = child.getMaxIntrinsicWidth(double.infinity);
//      final double childHeight = child.getMaxIntrinsicHeight(childWidth);
//      if (runWidth + childWidth > width) {
//        height += runHeight;
//        if (runCount > 0) height += runSpacing;
//        runCount += 1;
//        runWidth = 0.0;
//        runHeight = 0.0;
//        childCount = 0;
//      }
//      runWidth += childWidth;
//      runHeight = math.max(runHeight, childHeight);
//      if (childCount > 0) runWidth += spacing;
//      childCount += 1;
//      child = childAfter(child);
//    }
//    if (childCount > 0) height += runHeight + runSpacing;
//    return height;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    double width = 0.0;
    RenderBox child = firstChild;
    while (child != null) {
      width = max(width, child.getMinIntrinsicWidth(double.infinity));
      child = childAfter(child);
    }
    return width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    double width = 0.0;
    RenderBox child = firstChild;
    while (child != null) {
      width += child.getMaxIntrinsicWidth(double.infinity);
      child = childAfter(child);
    }
    return width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _computeIntrinsicHeightForWidth(width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _computeIntrinsicHeightForWidth(width);
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  double _getMainAxisExtent(RenderBox child) {
    return child.size.width;
  }

  double _getCrossAxisExtent(RenderBox child) {
    return child.size.height;
  }

  Offset _getOffset(double mainAxisOffset, double crossAxisOffset) {
    return Offset(mainAxisOffset, crossAxisOffset);
  }

  double _getChildCrossAxisOffset(bool flipCrossAxis,
      double runCrossAxisExtent,
      double childCrossAxisExtent,) {
    return 0.0;
//    final double freeSpace = runCrossAxisExtent - childCrossAxisExtent;
//    switch (crossAxisAlignment) {
//      case WrapCrossAlignment.start:
//        return flipCrossAxis ? freeSpace : 0.0;
//      case WrapCrossAlignment.end:
//        return flipCrossAxis ? 0.0 : freeSpace;
//      case WrapCrossAlignment.center:
//        return freeSpace / 2.0;
//    }
//    return 0.0;
  }

  bool _hasVisualOverflow = false;

  @override
  void performLayout() {
    //
    double availableWidth = constraints.maxWidth;
    var childConstraints = BoxConstraints(maxWidth: availableWidth);

    int count = 0;
    List<RenderBox> children = [];
    List<ContainerBoxParentData> parentData = [];
    List<double> widths = [];
    List<double> heights = [];
    List<_Line> lines = [];

    RenderBox child = firstChild;

    // First save all info.
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);

      final double width = child.size.width;
      final double height = child.size.height;
      final ContainerBoxParentData childParentData = child.parentData;

      count++;
      children.add(child);
      parentData.add(childParentData);
      widths.add(width);
      heights.add(height);

      child = childParentData.nextSibling;
    }

    // ------------------

    // Now calculate which widgets go in which lines.

    /// Will try to minimize the difference between line widths.
    if (wrapType == WrapType.balanced) {
      List<List<num>> result = MinimumRaggedness.divide(widths, availableWidth, spacing: spacing);
      lines = result.map((List<num> indexes) =>
      _Line()
        ..indexes = indexes).toList();
    }
    //
    // Will fit all widgets it can in a line, and then move to the next one.
    else if (wrapType == WrapType.fit) {
      double x = 0;
      _Line line = _Line();
      lines.add(line);

      for (int index = 0; index < count; index++) {
        child = children[index];
        double width = widths[index];

        if (x > 0 && (x + width) > availableWidth) {
          x = 0;
          line = _Line();
          lines.add(line);
        }

        line.indexes.add(index);
        x += width + spacing;
      }
    }
    //
    else {
      print('wrapType = ${wrapType}');
      throw AssertionError(wrapType);
    }

    // ------------------

    double y = 0;
    for (_Line line in lines) {
      double maxY = 0;
      double x = 0;

      for (int index in line.indexes) {
        maxY = max(maxY, heights[index]);
        x += widths[index] + spacing;
      }

      line.width = x - spacing;
      line.top = y;

      y += maxY + runSpacing;
    }

    /////////

    for (_Line line in lines) {
      double x;
      if (alignment == WrapSuperAlignment.left)
        x = 0;
      else if (alignment == WrapSuperAlignment.right)
        x = availableWidth - line.width;
      else if (alignment == WrapSuperAlignment.center)
        x = (availableWidth - line.width) / 2;
      else
        x = 0;

      for (int index in line.indexes) {
        var childParentData = parentData[index];
        childParentData.offset = Offset(x, line.top);
        x += widths[index] + spacing;
      }
    }

    // ---

    size = constraints.constrain(Size(availableWidth, y - runSpacing));
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // TODO(ianh): move the debug flex overflow paint logic somewhere common so
    // it can be reused here
//    if (_hasVisualOverflow)
//      context.pushClipRect(needsCompositing, offset, Offset.zero & size, defaultPaint);
//    else
    defaultPaint(context, offset);
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class _Line {
  List<int> indexes = [];
  double width = 0;
  double top = 0;

//  _Line({@required this.top});
}

////////////////////////////////////////////////////////////////////////////////////////////////////
