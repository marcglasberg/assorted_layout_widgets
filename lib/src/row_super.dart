import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// /////////////////////////////////////////////////////////////////////////////////////////////////

// Developed by Marcelo Glasberg (nov 2019).

/// For more info, see: https://pub.dartlang.org/packages/assorted_layout_widgets
class RowSuper extends MultiChildRenderObjectWidget {
  //
  final double outerDistance;
  final double innerDistance;
  final bool invert;
  final Alignment alignment;
  final Widget separator;
  final bool separatorOnTop;
  final bool fitHorizontally;
  final double shrinkLimit;
  final MainAxisSize mainAxisSize;

  RowSuper({
    Key key,
    List<Widget> children,
    this.outerDistance = 0.0,
    this.innerDistance = 0.0,
    this.invert = false,
    this.alignment = Alignment.center,
    this.separator,
    this.separatorOnTop = true,
    this.fitHorizontally = false,
    this.shrinkLimit,
    this.mainAxisSize = MainAxisSize.min,
  })  : assert(innerDistance != null),
        assert(invert != null),
        assert(alignment != null),
        assert(fitHorizontally != null),
        super(
            key: key,
            children: _childrenPlusSeparator(children, separator, fitHorizontally, shrinkLimit));

  static List<Widget> _childrenPlusSeparator(
    List<Widget> children,
    Widget separator,
    bool fitHorizontally,
    double shrinkLimit,
  ) {
    var iterable = children.where((child) => child != null);
    if (fitHorizontally)
      iterable = iterable.map((child) {
        if (child is RowSpacer)
          return child;
        else
          return FitHorizontally(child: child, shrinkLimit: shrinkLimit);
      });
    var list = iterable.toList();
    if (separator != null) list.add(separator);
    return list;
  }

  @override
  _RenderRowSuperBox createRenderObject(BuildContext context) => _RenderRowSuperBox(
        outerDistance: outerDistance ?? 0.0,
        innerDistance: innerDistance ?? 0.0,
        invert: invert ?? false,
        alignment: alignment ?? Alignment.center,
        hasSeparator: separator != null,
        separatorOnTop: separatorOnTop ?? true,
        mainAxisSize: mainAxisSize ?? MainAxisSize.min,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderRowSuperBox renderObject) {
    renderObject
      ..outerDistance = outerDistance ?? 0.0
      ..innerDistance = innerDistance ?? 0.0
      ..invert = invert ?? false
      ..alignment = alignment ?? Alignment.center
      ..hasSeparator = separator != null
      ..separatorOnTop = separatorOnTop ?? true
      ..mainAxisSize = mainAxisSize ?? MainAxisSize.min;
  }
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

class _RenderRowSuperBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  //
  _RenderRowSuperBox({
    RenderBox child,
    @required double outerDistance,
    @required double innerDistance,
    @required bool invert,
    @required Alignment alignment,
    @required bool hasSeparator,
    @required bool separatorOnTop,
    @required MainAxisSize mainAxisSize,
  })  : assert(innerDistance != null),
        assert(invert != null),
        _outerDistance = outerDistance,
        _innerDistance = innerDistance,
        _invert = invert,
        _alignment = alignment,
        _hasSeparator = hasSeparator,
        _separatorOnTop = separatorOnTop,
        _mainAxisSize = mainAxisSize,
        super();

  double _outerDistance;
  double _innerDistance;
  bool _invert;
  Alignment _alignment;
  bool _hasSeparator;
  bool _separatorOnTop;
  MainAxisSize _mainAxisSize;

  double get outerDistance => _outerDistance;

  double get innerDistance => _innerDistance;

  bool get invert => _invert;

  Alignment get alignment => _alignment;

  bool get hasSeparator => _hasSeparator;

  bool get separatorOnTop => _separatorOnTop;

  MainAxisSize get mainAxisSize => _mainAxisSize;

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

  set mainAxisSize(MainAxisSize value) {
    if (_mainAxisSize == value) return;
    _mainAxisSize = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData)
      child.parentData = MultiChildLayoutParentData();
  }

  RenderBox _renderSeparator;

  RenderBox get renderSeparator => _renderSeparator;

  List<RenderBox> _children;

  List<RenderBox> get children => _children;

  void _findChildrenAndSeparator() {
    _children = [];
    _renderSeparator = null;
    RenderBox child = firstChild;
    while (child != null) {
      final MultiChildLayoutParentData childParentData = child.parentData;
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

    if (_children.isEmpty) {
      size = constraints.constrain(Size.zero);
    } else {
      _performLayout();
    }
  }

  double maxChildHeight;

  void _performLayout() {
    //
    var availableWidth = max(
      0.0,
      constraints.maxWidth - (outerDistance * 2) - (innerDistance * (_children.length - 1)),
    );

    // If there is no space, don't display anything.
    if (availableWidth == 0.0) {
      _children = [];
      size = constraints.constrain(Size(0.0, double.infinity));
      return;
    }

    int numberOfSpacers = 0;
    List<double> childWidth = [];
    double totalChildrenWidth = 0.0;
    for (RenderBox child in _children) {
      if (child is RenderRowSpacer) numberOfSpacers++;
      var maxIntrinsicWidth = child.computeMaxIntrinsicWidth(constraints.maxHeight);
      childWidth.add(maxIntrinsicWidth);
      totalChildrenWidth += maxIntrinsicWidth;
    }

    double spacerWidth = (availableWidth <= totalChildrenWidth)
        ? 0.0
        : (availableWidth - totalChildrenWidth) / numberOfSpacers;

    var scale = min(1.0, availableWidth / totalChildrenWidth);
    List<double> maxChildWidth = [];
    for (double width in childWidth) {
      maxChildWidth.add(width * scale);
    }

    maxChildHeight = 0.0;

    for (int i = 0; i < _children.length; i++) {
      var innerConstraints =
          BoxConstraints(maxHeight: constraints.maxHeight, maxWidth: maxChildWidth[i]);
      var child = _children[i];
      child.layout(innerConstraints, parentUsesSize: true);
      maxChildHeight = max(maxChildHeight, child.size.height);
    }

    double dx = outerDistance;

    for (int i = 0; i < _children.length; i++) {
      var child = _children[i];
      final MultiChildLayoutParentData childParentData = child.parentData;
      childParentData.offset = Offset(dx, dy(child, maxChildHeight));
      dx += child.size.width + innerDistance;
      if (child is RenderRowSpacer) dx += spacerWidth;
    }

    dx = dx - innerDistance + outerDistance;

    if (mainAxisSize == MainAxisSize.min)
      size = constraints.constrain(Size(dx, maxChildHeight));
    else
      size = constraints.constrain(Size(constraints.maxWidth, maxChildHeight));

    if (hasSeparator) {
      var innerConstraints = BoxConstraints(maxHeight: constraints.maxHeight);
      renderSeparator.layout(innerConstraints, parentUsesSize: false);
    }
  }

  double dy(RenderBox child, double parentHeight) {
    final childHeight = child.size.height;
    final double centerY = (parentHeight - childHeight) / 2.0;
    var result = centerY + alignment.y * centerY;
    if (result.isNaN) throw AssertionError();
    return result;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
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
        final MultiChildLayoutParentData childParentData = _children[i].parentData;
        _paintSeparators(i, context, offset, childParentData);
      }

    for (int i = 0; i < _children.length; i++) {
      var child = _children[i];
      final MultiChildLayoutParentData childParentData = child.parentData;
      context.paintChild(child, childParentData.offset + offset);
      if (separatorOnTop) _paintSeparators(i, context, offset, childParentData);
    }
  }

  void invertPaint(PaintingContext context, Offset offset) {
    var children = _children.reversed.toList();

    if (!separatorOnTop)
      for (int i = 0; i < children.length; i++) {
        final MultiChildLayoutParentData childParentData = children[i].parentData;
        _paintSeparators(i, context, offset, childParentData);
      }

    for (int i = 0; i < children.length; i++) {
      var child = children[i];
      final MultiChildLayoutParentData childParentData = child.parentData;
      context.paintChild(child, childParentData.offset + offset);
      if (separatorOnTop) _paintSeparators(i, context, offset, childParentData);
    }
  }

  void _paintSeparators(
      int i, PaintingContext context, Offset offset, MultiChildLayoutParentData childParentData) {
    if (hasSeparator && i > 0 && i < _children.length) {
      context.paintChild(
          renderSeparator,
          offset +
              Offset(
                childParentData.offset.dx - (innerDistance + renderSeparator.size.width) / 2,
                dy(renderSeparator, maxChildHeight),
              ));
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (_children == null) _findChildrenAndSeparator();
    double dx = 0.0;
    for (RenderBox child in _children) {
      dx += child.computeMinIntrinsicWidth(height);
    }
    return dx;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (_children == null) _findChildrenAndSeparator();
    double dx = 0.0;
    for (RenderBox child in _children) {
      dx += child.computeMaxIntrinsicWidth(height);
    }
    return dx;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (_children == null) _findChildrenAndSeparator();
    double dy = 0.0;
    for (RenderBox child in _children) {
      dy += child.computeMinIntrinsicHeight(width);
    }
    return dy;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (_children == null) _findChildrenAndSeparator();
    double dy = 0.0;
    for (RenderBox child in _children) {
      dy += child.computeMaxIntrinsicHeight(width);
    }
    return dy;
  }
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

class RowSpacer extends MultiChildRenderObjectWidget {
  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderRowSpacer();
  }
}

class RenderRowSpacer extends RenderBox {
  void performLayout() {
    size = constraints.constrain(Size(0.0, 0.0));
  }
}

// /////////////////////////////////////////////////////////////////////////////////////////////////
