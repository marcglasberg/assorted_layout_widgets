import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

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

  /// If true will paint the cells that come first on top of the ones that come later.
  /// If false (the default) the cells that come later are painted on top.
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

  /// The non-null children (wrapped in a [FitHorizontally], if [fitHorizontally] is
  /// true), followed by the separator (if it's used).
  static List<Widget> _childrenPlusSeparator(
    List<Widget?> children,
    Widget? separator,
    bool fitHorizontally,
    double? shrinkLimit,
  ) =>
      [
        for (final Widget? child in children)
          if (child != null)
            if (fitHorizontally && child is! RowSpacer)
              FitHorizontally(shrinkLimit: shrinkLimit, child: child)
            else
              child,
        if (separator != null && children.isNotEmpty) separator,
      ];

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
    required this._outerDistance,
    required this._innerDistance,
    required this._invert,
    required this._alignment,
    required this._hasSeparator,
    required this._separatorOnTop,
    required this._mainAxisSize,
    required this._fill,
  });

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

  /// The separator, which is the last child (when there is a separator).
  /// Found during layout.
  RenderBox? _renderSeparator;

  /// The cells, which are all the children except the separator.
  /// Found during layout.
  List<RenderBox> _cells = const [];

  /// The height of the row, before applying its own constraints.
  /// Calculated during layout.
  double _maxChildHeight = 0.0;

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

    // The separator occupies no space, so the layout doesn't depend on its size.
    // It's positioned later, when it's painted.
    separator?.layout(
      BoxConstraints(maxHeight: constraints.maxHeight),
      parentUsesSize: false,
    );

    if (cells.isEmpty) {
      _maxChildHeight = 0.0;
      size = constraints.constrain(Size.zero);
      return;
    }

    final double availableWidth = max(
      0.0,
      constraints.maxWidth - (outerDistance * 2) - (innerDistance * (cells.length - 1)),
    );

    // 1) The preferred width of each cell.
    //
    // Note: This must ask for the max intrinsic width with `getMaxIntrinsicWidth`,
    // which caches its result until the cell changes. Otherwise, each layout of the
    // row would measure all the cells again (which is expensive for text).
    final List<double> preferredWidths = List<double>.filled(cells.length, 0.0);
    double totalPreferredWidth = 0.0;
    int numberOfSpacers = 0;

    for (int i = 0; i < cells.length; i++) {
      final RenderBox cell = cells[i];
      if (cell is RenderRowSpacer) numberOfSpacers++;

      final double preferredWidth = cell.getMaxIntrinsicWidth(constraints.maxHeight);
      preferredWidths[i] = preferredWidth;
      totalPreferredWidth += preferredWidth;
    }

    // The free space, if there is any, is divided between the spacers.
    final double spacerWidth = (availableWidth <= totalPreferredWidth)
        ? 0.0
        : (availableWidth - totalPreferredWidth) / numberOfSpacers;

    // Cells that don't fit always shrink. They only grow if they should fill the row.
    double scale = (fill)
        ? availableWidth / totalPreferredWidth
        : min(1.0, availableWidth / totalPreferredWidth);

    if (scale.isNaN) scale = 1.0;

    // 2) Lay out the cells, scaling their preferred widths.
    double maxChildHeight = 0.0;

    for (int i = 0; i < cells.length; i++) {
      final double width = preferredWidths[i] * scale;

      final RenderBox cell = cells[i];

      cell.layout(
        BoxConstraints(
          maxHeight: constraints.maxHeight,
          maxWidth: width,
          minWidth: fill ? width : 0.0,
        ),
        parentUsesSize: true,
      );

      maxChildHeight = max(maxChildHeight, cell.size.height);
    }

    maxChildHeight =
        max(min(maxChildHeight, constraints.maxHeight), constraints.minHeight);

    _maxChildHeight = maxChildHeight;

    // 3) Position the cells.
    //
    // Apply horizontal alignment only if there are no RowSpacers and should not fill.
    final double alignmentDisplacement = ((numberOfSpacers == 0) &&
                (availableWidth > totalPreferredWidth) &&
                (mainAxisSize == MainAxisSize.max)) &&
            !fill
        ? (availableWidth - totalPreferredWidth) * ((alignment.x + 1) / 2)
        : 0.0;

    double dx = outerDistance + alignmentDisplacement;

    for (final RenderBox cell in cells) {
      final cellParentData = cell.parentData! as MultiChildLayoutParentData;
      cellParentData.offset = Offset(dx, _dy(cell, maxChildHeight));
      dx += cell.size.width + innerDistance;
      if (cell is RenderRowSpacer) dx += spacerWidth;
    }

    dx = dx - innerDistance + outerDistance;

    if (mainAxisSize == MainAxisSize.min)
      size = constraints.constrain(Size(dx, maxChildHeight));
    else
      size = constraints.constrain(Size(constraints.maxWidth, maxChildHeight));
  }

  /// The vertical position of the [child] inside the given [height],
  /// according to the [alignment].
  double _dy(RenderBox child, double height) {
    final double centerY = (height - child.size.height) / 2.0;
    final double result = centerY + alignment.y * centerY;
    if (result.isNaN) throw AssertionError();
    return result;
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
    if (separator == null || index <= 0 || index >= _cells.length) return;

    final cellParentData = _cells[index].parentData! as MultiChildLayoutParentData;

    context.paintChild(
      separator,
      offset +
          Offset(
            cellParentData.offset.dx - (innerDistance + separator.size.width) / 2,
            _dy(separator, _maxChildHeight),
          ),
    );
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _intrinsicWidth((RenderBox cell) => cell.getMinIntrinsicWidth(height));

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _intrinsicWidth((RenderBox cell) => cell.getMaxIntrinsicWidth(height));

  /// The sum of the widths of the cells (given by [cellWidth]), plus the distances.
  double _intrinsicWidth(double Function(RenderBox cell) cellWidth) {
    final List<RenderBox> cells = _findCells();

    double width = 0.0;
    for (final RenderBox cell in cells) {
      width += cellWidth(cell);
    }

    if (cells.isNotEmpty) width += ((cells.length - 1) * innerDistance);
    width += outerDistance * 2;

    return width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    double height = 0.0;
    for (final RenderBox cell in _findCells()) {
      height = max(height, cell.getMinIntrinsicHeight(width));
    }
    return height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    double height = 0.0;
    for (final RenderBox cell in _findCells()) {
      height = max(height, cell.getMaxIntrinsicHeight(width));
    }
    return height;
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
