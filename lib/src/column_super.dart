import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

// Developed by Marcelo Glasberg (nov 2019).

/// Given a list of children widgets, this will arrange them in a column.
/// It can overlap cells, add separators and more.
///
/// Note this is not a substitute for Flutter's native `Column`, it doesn't try to
/// have a similar API, and it doesn't do all that `Column` does. In special,
/// `Expanded` and `Flexible` widgets don't work inside of `ColumnSuper`, and it will
/// overflow if the column is not big enough to fit its contents.
/// `ColumnSuper` is meant only for certain use cases where `Column` won't work,
/// like when you need overlapping cells or separators.
///
/// For more info, see: https://pub.dartlang.org/packages/assorted_layout_widgets
class ColumnSuper extends MultiChildRenderObjectWidget {
  //
  /// The distance in pixels before the first and after the last widget.
  /// It can be negative, in which case the cells will overflow the column
  /// (without any overflow warnings).
  final double outerDistance;

  /// The distance in pixels between the cells. It can be negative,
  /// in which case the cells will overlap.
  final double innerDistance;

  /// If `true` will paint the cells that come first on top of the ones that come later.
  /// If `false` (the default) the cells that come later are painted on top.
  /// This is specially useful when cells overlap (negative innerDistance).
  final bool invert;

  /// How to align the cells horizontally,
  /// if they are smaller than the available horizontal space.
  final Alignment alignment;

  /// The separator is a widget which will be painted between each cell.
  /// Its height doesn't matter, since the distance between cells is given by
  /// innerDistance (in other words, separators don't occupy space).
  /// The separator may overflow if its width is larger than the column's width.
  final Widget? separator;

  /// If `true` (the default) will paint the separator on top of the cells.
  /// If `false` will paint the separator below the cells.
  final bool separatorOnTop;

  /// If `true`, children with zero height will not result in an extra [innerDistance]
  /// and [separator]. If all children have zero height, the [outerDistance] will also
  /// be removed. In other words, it's as if children with zero height are removed,
  /// except for the fact they still occupy width. The default is `false`.
  final bool removeChildrenWithNoHeight;

  /// Given a list of children widgets, this will arrange them in a column.
  /// It can overlap cells, add separators and more.
  ///
  /// Note this is not a substitute for Flutter's native `Column`, it doesn't try to
  /// have a similar API, and it doesn't do all that `Column` does. In special,
  /// `Expanded` and `Flexible` widgets don't work inside of `ColumnSuper`, and it will
  /// overflow if the column is not big enough to fit its contents.
  /// `ColumnSuper` is meant only for certain use cases where `Column` won't work,
  /// like when you need overlapping cells or separators.
  ///
  /// For more info, see: https://pub.dartlang.org/packages/assorted_layout_widgets
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

  /// The non-null children, followed by the separator (if it's used).
  static List<Widget> _childrenPlusSeparator(List<Widget?> children, Widget? separator) =>
      [
        for (final Widget? child in children)
          if (child != null) child,
        if (separator != null && children.isNotEmpty) separator,
      ];

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
    required this._outerDistance,
    required this._innerDistance,
    required this._invert,
    required this._alignment,
    required this._hasSeparator,
    required this._separatorOnTop,
    required this._removeChildrenWithNoHeight,
  });

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

  /// Only changes the order in which the cells are painted and hit-tested.
  set invert(bool value) {
    if (_invert == value) return;
    _invert = value;
    markNeedsPaint();
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

  /// Only changes the order in which the separators are painted.
  set separatorOnTop(bool value) {
    if (_separatorOnTop == value) return;
    _separatorOnTop = value;
    markNeedsPaint();
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

  /// The separator, which is the last child (when there is a separator).
  /// Found during layout.
  RenderBox? _renderSeparator;

  /// The cells, which are all the children except the separator.
  /// Found during layout.
  List<RenderBox> _cells = const [];

  /// The index of the first cell that occupies space in the column. This is the first
  /// cell, unless [removeChildrenWithNoHeight] is true, in which case it's the first
  /// cell with a non-zero height. Calculated during layout.
  int _firstCellInUse = 0;

  /// All the children except the separator. This doesn't depend on the layout,
  /// so it may also be used to calculate the intrinsic sizes.
  List<RenderBox> _findCells() {
    final RenderBox? separator = hasSeparator ? lastChild : null;
    final List<RenderBox> cells = <RenderBox>[];

    RenderBox? child = firstChild;
    while (child != null && child != separator) {
      cells.add(child);
      child = childAfter(child);
    }

    return cells;
  }

  @override
  void performLayout() {
    //
    final List<RenderBox> cells = _cells = _findCells();
    final RenderBox? separator = _renderSeparator = hasSeparator ? lastChild : null;

    final BoxConstraints constraints = this.constraints;
    final innerConstraints = BoxConstraints(maxWidth: constraints.maxWidth);

    // The separator occupies no space, so the layout doesn't depend on its size.
    // It's positioned later, when it's painted.
    separator?.layout(innerConstraints, parentUsesSize: false);

    double maxChildWidth = 0.0;
    int firstCellWithHeight = cells.length;

    for (int i = 0; i < cells.length; i++) {
      final RenderBox cell = cells[i];
      cell.layout(innerConstraints, parentUsesSize: true);

      final Size cellSize = cell.size;
      if (cellSize.width > maxChildWidth) maxChildWidth = cellSize.width;
      if (cellSize.height != 0 && i < firstCellWithHeight) firstCellWithHeight = i;
    }

    _firstCellInUse = removeChildrenWithNoHeight ? firstCellWithHeight : 0;

    // No cells in use: Either there are no cells, or all of them have zero height
    // and are removed (in which case the outer distance is also removed).
    if (_firstCellInUse == cells.length) {
      size = constraints.constrain(Size(maxChildWidth, 0.0));
      return;
    }

    maxChildWidth = max(min(maxChildWidth, constraints.maxWidth), constraints.minWidth);

    double dy = outerDistance;

    for (final RenderBox cell in cells) {
      final cellParentData = cell.parentData! as MultiChildLayoutParentData;
      cellParentData.offset = Offset(_dx(cell, maxChildWidth), dy);

      if (cell.size.height != 0 || !removeChildrenWithNoHeight)
        dy += cell.size.height + innerDistance;
    }

    size = constraints.constrain(Size(maxChildWidth, dy - innerDistance + outerDistance));
  }

  /// The horizontal position of the [child] inside the given [width],
  /// according to the [alignment].
  double _dx(RenderBox child, double width) {
    final double centerX = (width - child.size.width) / 2.0;
    return centerX + alignment.x * centerX;
  }

  /// The cell painted on top is the first one to be hit-tested. The separator is not
  /// hit-tested, since the same separator is painted in many places (once per gap).
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final List<RenderBox> cells = _cells;
    final int step = invert ? 1 : -1;

    for (int i = invert ? 0 : cells.length - 1; i >= 0 && i < cells.length; i += step) {
      final RenderBox cell = cells[i];
      final cellParentData = cell.parentData! as MultiChildLayoutParentData;

      final bool isHit = result.addWithPaintOffset(
        offset: cellParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - cellParentData.offset);
          return cell.hitTest(result, position: transformed);
        },
      );

      if (isHit) return true;
    }

    return false;
  }

  /// Usually, each cell is painted on top of the previous ones. If [invert] is true,
  /// the cells are painted from the last to the first, so that the first ones are
  /// on top.
  @override
  void paint(PaintingContext context, Offset offset) {
    final List<RenderBox> cells = _cells;
    final int start = invert ? cells.length - 1 : 0;
    final int step = invert ? -1 : 1;

    // Separators below the cells are all painted before the cells.
    if (!separatorOnTop)
      for (int i = start; i >= 0 && i < cells.length; i += step) {
        _paintSeparatorBefore(i, context, offset);
      }

    for (int i = start; i >= 0 && i < cells.length; i += step) {
      final RenderBox cell = cells[i];
      final cellParentData = cell.parentData! as MultiChildLayoutParentData;
      context.paintChild(cell, cellParentData.offset + offset);

      // A separator on top is painted right after the two cells it separates.
      if (separatorOnTop) _paintSeparatorBefore(invert ? i + 1 : i, context, offset);
    }
  }

  /// Paints the separator in the gap between the cell with the given [index] and the
  /// previous cell (if there is a separator, and there is such a gap).
  void _paintSeparatorBefore(int index, PaintingContext context, Offset offset) {
    final RenderBox? separator = _renderSeparator;
    if (separator == null || index >= _cells.length) return;

    // There is no gap before the first cell in use.
    if (index <= _firstCellInUse) return;

    // There is no gap before a removed cell.
    final RenderBox cell = _cells[index];
    if (removeChildrenWithNoHeight && cell.size.height == 0) return;

    final cellParentData = cell.parentData! as MultiChildLayoutParentData;

    context.paintChild(
      separator,
      offset +
          Offset(
            _dx(separator, size.width),
            cellParentData.offset.dy - (innerDistance + separator.size.height) / 2,
          ),
    );
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    double width = 0.0;
    for (final RenderBox cell in _findCells()) {
      width = max(width, cell.getMinIntrinsicWidth(height));
    }
    return width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    double width = 0.0;
    for (final RenderBox cell in _findCells()) {
      width = max(width, cell.getMaxIntrinsicWidth(height));
    }
    return width;
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      _intrinsicHeight((RenderBox cell) => cell.getMinIntrinsicHeight(width));

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _intrinsicHeight((RenderBox cell) => cell.getMaxIntrinsicHeight(width));

  /// The sum of the heights of the cells (given by [cellHeight]), plus the distances.
  double _intrinsicHeight(double Function(RenderBox cell) cellHeight) {
    int cellsInUse = 0;
    double height = 0.0;

    for (final RenderBox cell in _findCells()) {
      final double intrinsicHeight = cellHeight(cell);
      if (removeChildrenWithNoHeight && intrinsicHeight == 0.0) continue;
      cellsInUse++;
      height += intrinsicHeight;
    }

    if (cellsInUse > 0)
      height += ((cellsInUse - 1) * innerDistance) + (outerDistance * 2);

    return height;
  }
}
