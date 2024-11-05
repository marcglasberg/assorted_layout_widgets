import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Developed by Marcelo Glasberg (nov 2019).

/// Given a list of children widgets, this will arrange them in a row.
/// It can overlap cells, add separators and more.
///
/// On contrary to `ColumnSuper` and the native `Row` (which will overflow if the
/// children are too large to fit the available free space), `RowSuper` may resize its
/// children proportionately to their minimum intrinsic width.
///
/// For more info, see: https://pub.dartlang.org/packages/assorted_layout_widgets
class RowSuper extends MultiChildRenderObjectWidget {
  //
  /// The distance in pixels before the first and after the last widget.
  /// It can be negative, in which case the cells will overflow the column
  /// (without any overflow warnings).
  final double outerDistance;

  /// The distance in pixels between the cells.
  /// It can be negative, in which case the cells will overlap.
  final double innerDistance;

  /// If true will paint the cells that come later on top of the ones that came before.
  /// This is specially useful when cells overlap (negative innerDistance).
  final bool invert;

  /// How to align the cells horizontally,
  /// if they are smaller than the available horizontal space.
  final Alignment alignment;

  /// The [separator] is a widget which will be painted between each cells.
  /// Its height doesn't matter, since the distance between cells is given by innerDistance
  /// (in other words, separators don't occupy space).
  /// The separator may overflow if its width is larger than the column's width.
  final Widget? separator;

  /// If true (the default) will paint the separator on top of the cells.
  /// If false will paint the separator below the cells.
  final bool separatorOnTop;

  /// If true will shrink the children, horizontally only, until the shrinkLimit is reached.
  /// This parameter is only useful if the children are too wide to fit the row width.
  /// Avoid using fitHorizontally together with [fill] true.
  final bool fitHorizontally;

  /// The shrink limit by default is 67%, which means the cell contents will shrink until
  /// 67% of their original width, and then overflow. Make the shrink limit equal to 0.0
  /// if you want the cell contents to shrink with no limits. Note, if [fitHorizontally]
  /// is false, the limit is not used.
  final double? shrinkLimit;

  /// How much space should be occupied in the main axis. The default is [MainAxisSize.min],
  /// which means the row will occupy no more than its content's width. Make it [MainAxisSize.max]
  /// to expand the row to occupy the whole horizontal space. Note: When [fill] is true,
  /// [mainAxisSize] is ignored because it will expand anyway.
  final MainAxisSize mainAxisSize;

  /// If true will force the children to grow their widths proportionately to their minimum
  /// intrinsic width, so that they fill the whole row width. This parameter is only useful
  /// if the children are not wide enough to fill the whole row width. In case the children are
  /// larger than the row width, they will always shrink proportionately to their minimum
  /// intrinsic width, and the fill parameter will be ignored.
  final bool fill;

  /// Given a list of children widgets, this will arrange them in a row.
  /// It can overlap cells, add separators and more.
  ///
  /// On contrary to `ColumnSuper` and the native `Row` (which will overflow if the
  /// children are too large to fit the available free space), `RowSuper` may resize its
  /// children proportionately to their minimum intrinsic width.
  ///
  /// For more info, see: https://pub.dartlang.org/packages/assorted_layout_widgets
  RowSuper({
    Key? key,
    required List<Widget?> children,
    this.outerDistance = 0.0,
    this.innerDistance = 0.0,
    this.invert = false,
    this.alignment = Alignment.center,
    this.separator,
    this.separatorOnTop = true,
    this.fitHorizontally = false,
    this.shrinkLimit,
    this.mainAxisSize = MainAxisSize.min,
    this.fill = false,
  }) : super(
            key: key,
            children: _childrenPlusSeparator(
                children, separator, fitHorizontally, shrinkLimit));

  static List<Widget> _childrenPlusSeparator(
    List<Widget?> children,
    Widget? separator,
    bool fitHorizontally,
    double? shrinkLimit,
  ) {
    var iterable = children.where((child) => child != null);
    if (fitHorizontally)
      iterable = iterable.map((child) {
        return (child is RowSpacer) //
            ? child
            : FitHorizontally(shrinkLimit: shrinkLimit, child: child);
      });
    List<Widget> list = List.of(iterable.cast());
    if (separator != null && children.isNotEmpty) list.add(separator);
    return list;
  }

  @override
  _RenderRowSuperBox createRenderObject(BuildContext context) => _RenderRowSuperBox(
        outerDistance: outerDistance,
        innerDistance: innerDistance,
        invert: invert,
        alignment: alignment,
        hasSeparator: separator != null && children.isNotEmpty,
        separatorOnTop: separatorOnTop,
        mainAxisSize: mainAxisSize,
        fill: fill,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderRowSuperBox renderObject) {
    renderObject
      ..outerDistance = outerDistance
      ..innerDistance = innerDistance
      ..invert = invert
      ..alignment = alignment
      ..hasSeparator = separator != null && children.isNotEmpty
      ..separatorOnTop = separatorOnTop
      ..mainAxisSize = mainAxisSize
      ..fill = fill;
  }
}

class _RenderRowSuperBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  //
  _RenderRowSuperBox({
    required double outerDistance,
    required double innerDistance,
    required bool invert,
    required Alignment alignment,
    required bool hasSeparator,
    required bool separatorOnTop,
    required MainAxisSize mainAxisSize,
    required bool fill,
  })  : _outerDistance = outerDistance,
        _innerDistance = innerDistance,
        _invert = invert,
        _alignment = alignment,
        _hasSeparator = hasSeparator,
        _separatorOnTop = separatorOnTop,
        _mainAxisSize = mainAxisSize,
        _fill = fill,
        super();

  double _outerDistance;
  double _innerDistance;
  bool _invert;
  Alignment _alignment;
  bool _hasSeparator;
  bool _separatorOnTop;
  MainAxisSize _mainAxisSize;
  bool _fill;

  double get outerDistance => _outerDistance;

  double get innerDistance => _innerDistance;

  bool get invert => _invert;

  Alignment get alignment => _alignment;

  bool get hasSeparator => _hasSeparator;

  bool get separatorOnTop => _separatorOnTop;

  MainAxisSize get mainAxisSize => _mainAxisSize;

  bool get fill => _fill;

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

  set fill(bool value) {
    if (_fill == value) return;
    _fill = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData)
      child.parentData = MultiChildLayoutParentData();
  }

  RenderBox? _renderSeparator;

  RenderBox? get renderSeparator => _renderSeparator;

  List<RenderBox>? _children;

  List<RenderBox>? get children => _children;

  void _findChildrenAndSeparator() {
    _children = [];
    _renderSeparator = null;
    RenderBox? child = firstChild;
    while (child != null) {
      final MultiChildLayoutParentData childParentData =
          child.parentData as MultiChildLayoutParentData;
      var recentChild = child;
      child = childParentData.nextSibling;
      if (!hasSeparator || child != null) _children!.add(recentChild);
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

    if (_children!.isEmpty) {
      size = constraints.constrain(Size.zero);
    } else {
      _performLayout();
    }
  }

  late double maxChildHeight;

  void _performLayout() {
    //
    var availableWidth = max(
      0.0,
      constraints.maxWidth -
          (outerDistance * 2) -
          (innerDistance * (_children!.length - 1)),
    );

    int numberOfSpacers = 0;
    List<double> childWidth = [];
    double totalChildrenWidth = 0.0;
    for (RenderBox child in _children!) {
      if (child is RenderRowSpacer) numberOfSpacers++;
      var maxIntrinsicWidth = child.computeMaxIntrinsicWidth(constraints.maxHeight);
      childWidth.add(maxIntrinsicWidth);
      totalChildrenWidth += maxIntrinsicWidth;
    }

    double spacerWidth = (availableWidth <= totalChildrenWidth)
        ? 0.0
        : (availableWidth - totalChildrenWidth) / numberOfSpacers;

    double scale = (fill)
        ? availableWidth / totalChildrenWidth
        : min(1.0, availableWidth / totalChildrenWidth);

    if (scale.isNaN) scale = 1.0;

    List<double> maxChildWidth = [];
    for (double width in childWidth) {
      maxChildWidth.add(width * scale);
    }

    maxChildHeight = 0.0;

    for (int i = 0; i < _children!.length; i++) {
      double width = maxChildWidth[i];

      BoxConstraints innerConstraints = BoxConstraints(
          maxHeight: constraints.maxHeight,
          maxWidth: width,
          minWidth: fill ? width : 0.0);

      var child = _children![i];
      child.layout(innerConstraints, parentUsesSize: true);
      maxChildHeight = max(maxChildHeight, child.size.height);
    }

    maxChildHeight =
        max(min(maxChildHeight, constraints.maxHeight), constraints.minHeight);

    // Apply horizontal alignment only if there are no RowSpacers and should not fill.
    double alignmentDisplacement = ((numberOfSpacers == 0) &&
                (availableWidth > totalChildrenWidth) &&
                (mainAxisSize == MainAxisSize.max)) &&
            !fill
        ? (availableWidth - totalChildrenWidth) * ((alignment.x + 1) / 2)
        : 0.0;

    double dx = outerDistance + alignmentDisplacement;

    for (int i = 0; i < _children!.length; i++) {
      var child = _children![i];
      final MultiChildLayoutParentData childParentData =
          child.parentData as MultiChildLayoutParentData;
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
      renderSeparator!.layout(innerConstraints, parentUsesSize: false);
    }
  }

  double dy(RenderBox child, double maxChildHeight) {
    final childHeight = child.size.height;
    final double centerY = (maxChildHeight - childHeight) / 2.0;
    var result = centerY + alignment.y * centerY;
    if (result.isNaN) throw AssertionError();
    return result;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return invert
        ? _invertedHitTestChildren(result, position: position)
        : _normalHitTestChildren(result, position: position);
  }

  bool _normalHitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = lastChild;
    while (child != null) {
      // The x, y parameters have the top left of the node's box as the origin.
      final childParentData = child.parentData! as ContainerBoxParentData<RenderBox>;
      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child!.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
      child = childParentData.previousSibling;
    }
    return false;
  }

  bool _invertedHitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = firstChild;

    while (child != null) {
      // The x, y parameters have the top left of the node's box as the origin.
      final childParentData = child.parentData! as ContainerBoxParentData<RenderBox>;

      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child!.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
      child = childParentData.nextSibling;
    }
    return false;
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
      for (int i = 0; i < _children!.length; i++) {
        final MultiChildLayoutParentData? childParentData =
            _children![i].parentData as MultiChildLayoutParentData?;
        _paintSeparators(i, context, offset, childParentData);
      }

    for (int i = 0; i < _children!.length; i++) {
      var child = _children![i];
      final MultiChildLayoutParentData childParentData =
          child.parentData as MultiChildLayoutParentData;
      context.paintChild(child, childParentData.offset + offset);
      if (separatorOnTop) _paintSeparators(i, context, offset, childParentData);
    }
  }

  void invertPaint(PaintingContext context, Offset offset) {
    var children = _children!.reversed.toList();

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

  void _paintSeparators(int i, PaintingContext context, Offset offset,
      MultiChildLayoutParentData? childParentData) {
    if (hasSeparator && i > 0 && i < _children!.length) {
      context.paintChild(
          renderSeparator!,
          offset +
              Offset(
                childParentData!.offset.dx -
                    (innerDistance + renderSeparator!.size.width) / 2,
                dy(renderSeparator!, maxChildHeight),
              ));
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    _findChildrenAndSeparator();
    double dx = 0.0;
    for (RenderBox child in _children!) {
      dx += child.computeMinIntrinsicWidth(height);
    }
    if (_children!.isNotEmpty) dx += ((_children!.length - 1) * innerDistance);
    dx += outerDistance * 2;
    return dx;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    _findChildrenAndSeparator();
    double dx = 0.0;
    for (RenderBox child in _children!) {
      dx += child.computeMaxIntrinsicWidth(height);
    }
    if (_children!.isNotEmpty) dx += ((_children!.length - 1) * innerDistance);
    dx += outerDistance * 2;
    return dx;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    _findChildrenAndSeparator();
    double dy = 0.0;
    for (RenderBox child in _children!) {
      dy = max(dy, child.computeMinIntrinsicHeight(width));
    }
    return dy;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    _findChildrenAndSeparator();
    double dy = 0.0;
    for (RenderBox child in _children!) {
      dy = max(dy, child.computeMaxIntrinsicHeight(width));
    }
    return dy;
  }
}

class RowSpacer extends MultiChildRenderObjectWidget {
  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderRowSpacer();
  }
}

class RenderRowSpacer extends RenderBox
    with
        ContainerRenderObjectMixin<RenderObject, ContainerParentDataMixin<RenderObject>> {
  @override
  void performLayout() {
    size = constraints.constrain(const Size(0.0, 0.0));
  }
}
