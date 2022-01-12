import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// /////////////////////////////////////////////////////////////////////////////////////////////////

// Developed by Marcelo Glasberg (jan 2022).

/// The [SideBySide] widget disposes 2 widgets horizontally, while achieving a layout which is
/// impossible for both the native [Row] and the [RowSuper] widgets.
///
/// * The [startChild]  will be on the left, and will occupy as much space as it wants, up to the
/// available horizontal space.
///
/// * The [endChild]  will be on the right of the [startChild] , and it will occupy the endChild of
/// the available space. Note: This means, if the `start` widget occupies all the available space,
/// then endChild widget will not be displayed (since it will be sized as `0` width).
///
/// For example, suppose you want to create a title, with a divider that occupies the endChild of
/// the space. You want the distance between the [startChild] and the divider widgets to be at
/// least 8 pixels, and you want the divider to occupy at least 15 pixels of horizontal space:
///
/// ```
/// return SideBySide(
///   startChild: Text("First Chapter", textWidthBasis: TextWidthBasis.longestLine),
///   endChild: Divider(color: Colors.grey),
///   innerDistance: 8,
///   minEndChildWidth: 20,
/// );
/// ```
///
/// You can add an [innerDistance], in pixels, between the [startChild] and [endChild] s. It can be
/// negative, in which case the widgets will overlap.
///
/// The [crossAxisAlignment] parameter specifies how to align the [startChild] and [endChild]
/// widgets vertically. The default is to center them. At the moment, only
/// `CrossAxisAlignment.start`, `CrossAxisAlignment.end` and `CrossAxisAlignment.center` work.
///
/// For more info, see: https://pub.dartlang.org/packages/assorted_layout_widgets
///
class SideBySide extends MultiChildRenderObjectWidget {
  //

  /// The [startChild]  will be on the left, and will occupy as much space as it wants,
  /// up to the available horizontal space.
  final Widget startChild;

  /// The [endChild]  will be on the right of the [startChild] , and it will occupy the endChild of
  /// the available space. Note: This means, if the `start` widget occupies all the available space,
  /// then endChild widget will not be displayed (since it will be sized as `0` width).
  final Widget endChild;

  /// The [crossAxisAlignment] parameter specifies how to align the [startChild] and [endChild]
  /// vertically. The default is to center them. At the moment, only [CrossAxisAlignment.start],
  /// [CrossAxisAlignment.end] and [CrossAxisAlignment.center] work.
  final CrossAxisAlignment crossAxisAlignment;

  /// The distance in pixels between the [startChild] and [endChild] s.
  /// The default is zero. It can be negative, in which case the widgets will overlap.
  final double innerDistance;

  /// The minimum width, in pixels, that the [endChild]  should occupy.
  /// The default is zero.
  final double minEndChildWidth;

  SideBySide({
    Key? key,
    required this.startChild,
    required this.endChild,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.innerDistance = 0,
    this.minEndChildWidth = 0,
  }) : super(
          key: key,
          children: [startChild, endChild],
        );

  @override
  _RenderSideBySide createRenderObject(BuildContext context) => _RenderSideBySide(
        crossAxisAlignment: crossAxisAlignment,
        innerDistance: innerDistance,
        minEndChildWidth: minEndChildWidth,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderSideBySide renderObject) {
    renderObject
      ..crossAxisAlignment = crossAxisAlignment
      ..innerDistance = innerDistance
      ..minEndChildWidth = minEndChildWidth;
  }
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

class _RenderSideBySide extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  //
  _RenderSideBySide({
    required CrossAxisAlignment crossAxisAlignment,
    required double innerDistance,
    required double minEndChildWidth,
  })  : _crossAxisAlignment = crossAxisAlignment,
        _innerDistance = innerDistance,
        _minEndChildWidth = minEndChildWidth;

  CrossAxisAlignment _crossAxisAlignment;
  double _innerDistance;
  double _minEndChildWidth;

  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;

  double get innerDistance => _innerDistance;

  double get minEndChildWidth => _minEndChildWidth;

  set crossAxisAlignment(CrossAxisAlignment value) {
    if (_crossAxisAlignment == value) return;
    _crossAxisAlignment = value;
    markNeedsLayout();
  }

  set innerDistance(double value) {
    if (_innerDistance == value) return;
    _innerDistance = value;
    markNeedsLayout();
  }

  set minEndChildWidth(double value) {
    if (_minEndChildWidth == value) return;
    _minEndChildWidth = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData)
      child.parentData = MultiChildLayoutParentData();
  }

  late RenderBox _startChild;

  RenderBox get startChild => _startChild;

  late RenderBox _endChild;

  RenderBox get endChild => _endChild;

  void _findChildren() {
    _startChild = firstChild!;
    _endChild = lastChild!;
  }

  @override
  void performLayout() {
    _findChildren();
    _performLayout();
  }

  late double maxChildHeight;

  void _performLayout() {
    //

    // At the minimum, we have the min-endChild plus the inner-distance.
    // But if the min-endChild is zero, then we don't need to add the inner-distance.
    double minEndChildAndInnerDistance =
        (minEndChildWidth == 0) ? 0 : minEndChildWidth + innerDistance;

    // StartChild: ---

    var startChildConstraints = BoxConstraints(
      minWidth: max(0.0, constraints.minWidth - minEndChildAndInnerDistance),
      maxWidth: max(0.0, constraints.maxWidth - minEndChildAndInnerDistance),
      minHeight: constraints.minHeight,
      maxHeight: constraints.maxHeight,
    );

    startChild.layout(startChildConstraints, parentUsesSize: true);
    double startChildWidth = startChild.size.width;

    // EndChild: ---

    var endChildConstraints =
        constraints.tighten(width: constraints.maxWidth - startChildWidth - innerDistance);

    endChild.layout(endChildConstraints, parentUsesSize: true);

    double maxChildHeight = max(startChild.size.height, endChild.size.height);

    // ---

    final MultiChildLayoutParentData startChildParentData =
        startChild.parentData as MultiChildLayoutParentData;
    startChildParentData.offset = Offset(0, dy(startChild, maxChildHeight));

    final MultiChildLayoutParentData endChildParentData =
        endChild.parentData as MultiChildLayoutParentData;
    endChildParentData.offset =
        Offset(startChildWidth + innerDistance, dy(endChild, maxChildHeight));

    // ---

    size = Size(constraints.maxWidth, maxChildHeight);
  }

  double dy(RenderBox child, double maxChildHeight) {
    final childHeight = child.size.height;

    if (crossAxisAlignment == CrossAxisAlignment.start)
      return 0.0;
    //
    else if (crossAxisAlignment == CrossAxisAlignment.end)
      return maxChildHeight - childHeight;
    //
    else if (crossAxisAlignment == CrossAxisAlignment.center)
      return (maxChildHeight - childHeight) / 2;
    //
    // TODO: Not yet implemented.
    else if (crossAxisAlignment == CrossAxisAlignment.baseline)
      return (maxChildHeight - childHeight) / 2;
    //
    // TODO: Not yet implemented.
    else if (crossAxisAlignment == CrossAxisAlignment.stretch)
      return (maxChildHeight - childHeight) / 2;
    //
    else
      throw AssertionError(crossAxisAlignment);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    _findChildren();
    return startChild.computeMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    _findChildren();
    return startChild.computeMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    _findChildren();
    return max(
      startChild.computeMinIntrinsicHeight(width),
      endChild.computeMinIntrinsicHeight(width),
    );
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    _findChildren();
    return max(
      startChild.computeMaxIntrinsicHeight(width),
      endChild.computeMaxIntrinsicHeight(width),
    );
  }
}

// /////////////////////////////////////////////////////////////////////////////////////////////////
