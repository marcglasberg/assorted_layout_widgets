import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Developed by Marcelo Glasberg (nov 2019).

/// For more info, see: https://pub.dartlang.org/packages/assorted_layout_widgets
class ColumnSuper extends MultiChildRenderObjectWidget {
  //
  final double outerDistance;
  final double innerDistance;
  final bool invert;
  final Alignment alignment;
  final Widget? separator;
  final bool separatorOnTop;

  /// If true, children with zero height will not result in an extra [innerDistance]
  /// and [separator]. If all children have zero height, the [outerDistance] will also be removed.
  /// In other words, it's as if children with zero height are removed, except for the fact
  /// they still occupy width. The default is false.
  final bool removeChildrenWithNoHeight;

  ColumnSuper({
    Key? key,
    required List<Widget?> children,
    this.outerDistance = 0.0,
    this.innerDistance = 0.0,
    this.invert = false,
    this.alignment = Alignment.center,
    this.separator,
    this.separatorOnTop = true,
    this.removeChildrenWithNoHeight = false,
  }) : super(key: key, children: _childrenPlusSeparator(children, separator));

  static List<Widget> _childrenPlusSeparator(List<Widget?> children, Widget? separator) {
    List<Widget> list = List.of(children.where((child) => child != null).cast());
    if (separator != null && children.isNotEmpty) list.add(separator);
    return list;
  }

  @override
  _RenderColumnSuperBox createRenderObject(BuildContext context) => _RenderColumnSuperBox(
        outerDistance: outerDistance,
        innerDistance: innerDistance,
        invert: invert,
        alignment: alignment,
        hasSeparator: separator != null && children.isNotEmpty,
        separatorOnTop: separatorOnTop,
        removeChildrenWithNoHeight: removeChildrenWithNoHeight,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderColumnSuperBox renderObject) {
    renderObject
      ..outerDistance = outerDistance
      ..innerDistance = innerDistance
      ..invert = invert
      ..alignment = alignment
      ..hasSeparator = separator != null && children.isNotEmpty
      ..separatorOnTop = separatorOnTop
      ..removeChildrenWithNoHeight = removeChildrenWithNoHeight;
  }
}

class _RenderColumnSuperBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  //
  _RenderColumnSuperBox({
    required double outerDistance,
    required double innerDistance,
    required bool invert,
    required Alignment alignment,
    required bool hasSeparator,
    required bool separatorOnTop,
    required bool removeChildrenWithNoHeight,
  })  : _outerDistance = outerDistance,
        _innerDistance = innerDistance,
        _invert = invert,
        _alignment = alignment,
        _hasSeparator = hasSeparator,
        _separatorOnTop = separatorOnTop,
        _removeChildrenWithNoHeight = removeChildrenWithNoHeight,
        super();

  double _outerDistance;
  double _innerDistance;
  bool _invert;
  Alignment _alignment;
  bool _hasSeparator;
  bool _separatorOnTop;
  bool _removeChildrenWithNoHeight;

  double get outerDistance => _outerDistance;

  double get innerDistance => _innerDistance;

  bool get invert => _invert;

  Alignment get alignment => _alignment;

  bool get hasSeparator => _hasSeparator;

  bool get separatorOnTop => _separatorOnTop;

  bool get removeChildrenWithNoHeight => _removeChildrenWithNoHeight;

  set outerDistance(double value) {
    if (_outerDistance == value) return;
    _outerDistance = value;
    markNeedsLayout();
  }

  set innerDistance(double value) {
    if (_innerDistance == value) return;
    _innerDistance = value;
    markNeedsLayout();
  }

  set invert(bool value) {
    if (_invert == value) return;
    _invert = value;
    markNeedsLayout();
  }

  set alignment(Alignment value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsLayout();
  }

  set hasSeparator(bool value) {
    if (_hasSeparator == value) return;
    _hasSeparator = value;
    markNeedsLayout();
  }

  set separatorOnTop(bool value) {
    if (_separatorOnTop == value) return;
    _separatorOnTop = value;
    markNeedsLayout();
  }

  set removeChildrenWithNoHeight(bool value) {
    if (_removeChildrenWithNoHeight == value) return;
    _removeChildrenWithNoHeight = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData)
      child.parentData = MultiChildLayoutParentData();
  }

  RenderBox? _renderSeparator;

  RenderBox? get renderSeparator => _renderSeparator;

  late List<RenderBox> _children;

  List<RenderBox> get children => _children;

  void _findChildrenAndSeparator() {
    _children = <RenderBox>[];
    _renderSeparator = null;
    RenderBox? child = firstChild;

    while (child != null) {
      final childParentData = child.parentData as MultiChildLayoutParentData;
      var recentChild = child;
      child = childParentData.nextSibling;
      if (!hasSeparator || child != null) _children.add(recentChild);
    }

    if (hasSeparator) _renderSeparator = lastChild;
  }

  /// The layout constraints provided by your parent are available via the [constraints] getter.
  ///
  /// If [sizedByParent] is true, then this function should not actually change
  /// the dimensions of this render object. Instead, that work should be done by
  /// [performResize]. If [sizedByParent] is false, then this function should
  /// both change the dimensions of this render object and instruct its children
  /// to layout.
  ///
  /// In implementing this function, you must call [layout] on each of your
  /// children, passing true for parentUsesSize if your layout information is
  /// dependent on your child's layout information. Passing true for
  /// parentUsesSize ensures that this render object will undergo layout if the
  /// child undergoes layout. Otherwise, the child can change its layout
  /// information without informing this render object.
  @override
  void performLayout() {
    //
    _findChildrenAndSeparator();

    final innerConstraints = BoxConstraints(maxWidth: constraints.maxWidth);

    for (RenderBox child in _children) {
      child.layout(innerConstraints, parentUsesSize: true);
    }

    if (removeChildrenWithNoHeight && _children.every((child) => child.size.height == 0)) {
      double width = 0;
      for (RenderBox child in _children) if (child.size.width > width) width = child.size.width;
      size = constraints.constrain(Size(width, 0.0));
      return;
    }

    if (_children.isEmpty) {
      size = constraints.constrain(const Size(0.0, 0.0));
      return;
    } else {
      double dy = outerDistance;
      double maxChildWidth = 0.0;

      for (RenderBox child in _children) {
        maxChildWidth = max(maxChildWidth, child.size.width);
      }

      maxChildWidth = max(min(maxChildWidth, constraints.maxWidth), constraints.minWidth);

      for (RenderBox child in _children) {
        final MultiChildLayoutParentData childParentData =
            child.parentData as MultiChildLayoutParentData;
        child.layout(innerConstraints, parentUsesSize: true);
        childParentData.offset = Offset(dx(child, maxChildWidth), dy);

        if (child.size.height != 0 || !removeChildrenWithNoHeight)
          dy += child.size.height + innerDistance;
      }

      if (hasSeparator) {
        renderSeparator!.layout(innerConstraints, parentUsesSize: false);
      }

      size = constraints.constrain(Size(maxChildWidth, dy - innerDistance + outerDistance));
    }
  }

  double dx(RenderBox child, double width) {
    final parentWidth = width;
    final childWidth = child.size.width;
    final double centerX = (parentWidth - childWidth) / 2.0;
    return centerX + alignment.x * centerX;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (invert)
      invertPaint(context, offset);
    else
      defaultPaint(context, offset);
  }

  @override
  void defaultPaint(PaintingContext context, Offset offset) {
    if (!separatorOnTop)
      for (int i = 0; i < _children.length; i++) {
        final MultiChildLayoutParentData? childParentData =
            _children[i].parentData as MultiChildLayoutParentData?;
        _paintSeparators(i, context, offset, childParentData);
      }

    for (int i = 0; i < _children.length; i++) {
      var child = _children[i];
      final MultiChildLayoutParentData childParentData =
          child.parentData as MultiChildLayoutParentData;
      context.paintChild(child, childParentData.offset + offset);
      if (separatorOnTop) _paintSeparators(i, context, offset, childParentData);
    }
  }

  void invertPaint(PaintingContext context, Offset offset) {
    var children = _children.reversed.toList();

    if (!separatorOnTop)
      for (int i = 0; i < children.length; i++) {
        final MultiChildLayoutParentData? childParentData =
            children[i].parentData as MultiChildLayoutParentData?;
        _paintSeparators(i, context, offset, childParentData);
      }

    for (int i = 0; i < children.length; i++) {
      var child = children[i];
      final MultiChildLayoutParentData childParentData =
          child.parentData as MultiChildLayoutParentData;
      context.paintChild(child, childParentData.offset + offset);
      if (separatorOnTop) _paintSeparators(i, context, offset, childParentData);
    }
  }

  void _paintSeparators(
    int i,
    PaintingContext context,
    Offset offset,
    MultiChildLayoutParentData? childParentData,
  ) {
    if (hasSeparator && (i > 0) && (i < _children.length)) {
      if (_children[i].size.height != 0 || !removeChildrenWithNoHeight)
        context.paintChild(
            renderSeparator!,
            offset +
                Offset(
                    dx(renderSeparator!, size.width),
                    childParentData!.offset.dy -
                        (innerDistance + renderSeparator!.size.height) / 2));
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    _findChildrenAndSeparator();

    double dx = 0.0;
    for (RenderBox child in _children) {
      final minIntrinsicWidth = child.computeMinIntrinsicWidth(height);
      dx = max(dx, minIntrinsicWidth);
    }
    return dx;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    _findChildrenAndSeparator();

    double dx = 0.0;
    for (RenderBox child in _children) {
      final maxIntrinsicWidth = child.computeMaxIntrinsicWidth(height);
      dx = max(dx, maxIntrinsicWidth);
    }
    return dx;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    _findChildrenAndSeparator();

    int removed = 0;
    double dy = 0.0;
    for (RenderBox child in _children) {
      final minIntrinsicHeight = child.computeMinIntrinsicHeight(width);
      if (removeChildrenWithNoHeight && minIntrinsicHeight == 0.0)
        removed++;
      else
        dy += minIntrinsicHeight;
    }

    if (_children.isNotEmpty && (_children.length != removed))
      dy += ((_children.length - removed - 1) * innerDistance) + (outerDistance * 2);

    return dy;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    _findChildrenAndSeparator();

    int removed = 0;
    double dy = 0.0;
    for (RenderBox child in _children) {
      final maxIntrinsicHeight = child.computeMaxIntrinsicHeight(width);
      if (removeChildrenWithNoHeight && maxIntrinsicHeight == 0.0)
        removed++;
      else
        dy += maxIntrinsicHeight;
    }

    if (_children.isNotEmpty && (_children.length != removed))
      dy += ((_children.length - removed - 1) * innerDistance) + (outerDistance * 2);

    return dy;
  }
}
