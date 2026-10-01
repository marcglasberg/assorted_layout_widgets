import 'dart:math';

import 'package:assorted_layout_widgets/src/row_super.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

// Developed by Marcelo Glasberg (jan 2022).

/// The [SideBySide] widget arranges its [children] widgets horizontally, achieving a
/// layout that is not possible with [Row] or [RowSuper] widgets.
///
/// The first widget in [children] will be on the left, and will occupy as much
/// horizontal space as it wants, up to the available horizontal space. Then, the
/// next widget will be displayed to the right of the previous widget, and so on,
/// one by one, until they run out of available space. After the available space
/// is occupied, the widgets that did not fit will not be displayed (or, more
/// precisely, will be sized as `0` width).
///
/// ## Why this layout is not possible with [Row]?
///
/// Suppose you want to display two texts is a row, such as they occupy the
/// available space: `Row(children: [Text("One"), Text("Two")])`. If the available
/// horizontal space is not enough, the texts will overflow. You can fix this by
/// wrapping the texts in `Expanded` widgets, but then they will each occupy half of
/// the available space. If instead you use `Flexible` to wrap the texts, they will
/// occupy the available space only if there is enough space for both of them,
/// otherwise they will each occupy half of the available space.
///
/// If instead you use `SideBySide(children: [Text("One"), Text("Two")])`, the first
/// text will occupy as much space as it wants, and the second text will occupy the
/// remaining space, if there is any.
///
/// ## The last widget
///
/// The last widget in [children] is an is a special case, for two reasons. First,
/// it will be given all the remaining horizontal space, after the previous widgets
/// have been displayed. This means you can align it to the right if you want:
///
/// ```dart
/// SideBySide(
///    children: [
///       const Text("Some text", textWidthBasis: TextWidthBasis.longestLine),
///       Align(
///          alignment: Alignment.centerRight,
///          child: const Text("more text", textWidthBasis: TextWidthBasis.longestLine),
///       ),
///    ],
/// );
/// ```
///
/// Second, you can specify the minimum width that it should occupy, using
/// the [minEndChildWidth] property. This means that the last widget will occupy
/// AT LEAST that width, even if it means that the previous widgets will be pushed out
/// of the available space. However, if the total available space is less
/// than [minEndChildWidth], then the last widget will be displayed only up to the
/// available space.
///
/// ## Gaps
///
/// You can add gaps between the widgets, using the [gaps] property. The gaps are
/// a list of doubles representing pixels. If you have two children, you should
/// provide one gap. If you have three children, you should provide two gaps, and so on.
///
/// Note the gaps can be negative, in which case the widgets will overlap.
///
/// If you provide less than the required number of gaps, the last gap will be used
/// for all the remaining widgets. If you provide more gaps than required, the extra
/// gaps will be ignored.
///
/// ## Cross alignment and main axis size
///
/// The [crossAxisAlignment] property specifies how to align the widgets vertically.
/// The default is to center them. All alignments work:
///
/// * [CrossAxisAlignment.start], [CrossAxisAlignment.end] and
///   [CrossAxisAlignment.center] align the children to the top, bottom or center.
///
/// * [CrossAxisAlignment.stretch] forces the children to fill the available height,
///   just like in a [Row]. However, while a [Row] can't stretch its children when the
///   available height is unbounded (for example, inside a [Column]), [SideBySide] will
///   instead stretch all children to the height of the tallest one.
///
/// * [CrossAxisAlignment.baseline] aligns the children by their baselines. To use it
///   you must also provide the [textBaseline] property, just like in a [Row].
///   Children with no baseline are aligned to the top.
///
/// The [mainAxisSize] property determines whether the widget will occupy the full
/// available width ([MainAxisSize.max]) or only as much as it needs ([MainAxisSize.min]).
///
/// ## Using Text as children
///
/// When you use [Text] widgets in your children, it's strongly recommended that
/// you use property `textWidthBasis: TextWidthBasis.longestLine`. The default
/// `textWidthBasis` is usually `textWidthBasis: TextWidthBasis.parent`, which
/// is almost never what you want. For example, instead of writing:
/// `Text("Hello")`, you should write:
/// `Text("Hello", textWidthBasis: TextWidthBasis.longestLine)`.
///
/// ## Examples
///
/// Suppose you want to create a title aligned to the left, with a divider that
/// occupies the rest of the space. You want the distance between the title and
/// the divider to be at least 8 pixels, and you want the divider to occupy at
/// least 20 pixels of horizontal space:
///
/// ```
/// return SideBySide(
///   children: [
///     Text("First Chapter", textWidthBasis: TextWidthBasis.longestLine),
///     Divider(color: Colors.grey),
///   ],
///   gaps: [8.0],
///   minEndChildWidth: 20.0,
/// );
/// ```
///
/// Another example, with 3 widgets:
///
/// ```
/// return SideBySide(
///   children: [
///     Text("Hello!", textWidthBasis: TextWidthBasis.longestLine),
///     Text("How are you?", textWidthBasis: TextWidthBasis.longestLine),
///     Text("I'm good, thank you.", textWidthBasis: TextWidthBasis.longestLine),
///   ],
///   gaps: [8.0, 12.0],
/// );
/// ```
///
/// For more info, see: https://pub.dartlang.org/packages/assorted_layout_widgets
///
class SideBySide extends MultiChildRenderObjectWidget {
  //
  /// The [SideBySide] widget arranges its [children] widgets horizontally, achieving a
  /// layout that is not possible with [Row] or [RowSuper] widgets.
  ///
  /// The first widget in [children] will be on the left, and will occupy as much
  /// horizontal space as it wants, up to the available horizontal space. Then, the
  /// next widget will be displayed to the right of the previous widget, and so on,
  /// one by one, until they run out of available space. After the available space
  /// is occupied, the widgets that did not fit will not be displayed (or, more
  /// precisely, will be sized as `0` width).
  ///
  /// ## Why this layout is not possible with [Row]?
  ///
  /// Suppose you want to display two texts is a row, such as they occupy the
  /// available space: `Row(children: [Text("One"), Text("Two")])`. If the available
  /// horizontal space is not enough, the texts will overflow. You can fix this by
  /// wrapping the texts in `Expanded` widgets, but then they will each occupy half of
  /// the available space. If instead you use `Flexible` to wrap the texts, they will
  /// occupy the available space only if there is enough space for both of them,
  /// otherwise they will each occupy half of the available space.
  ///
  /// If instead you use `SideBySide(children: [Text("One"), Text("Two")])`, the first
  /// text will occupy as much space as it wants, and the second text will occupy the
  /// remaining space, if there is any.
  ///
  /// ## The last widget
  ///
  /// The last widget in [children] is an is a special case, for two reasons. First,
  /// it will be given all the remaining horizontal space, after the previous widgets
  /// have been displayed. This means you can align it to the right if you want:
  ///
  /// ```dart
  /// SideBySide(
  ///    children: [
  ///       const Text("Some text", textWidthBasis: TextWidthBasis.longestLine),
  ///       Align(
  ///          alignment: Alignment.centerRight,
  ///          child: const Text("more text", textWidthBasis: TextWidthBasis.longestLine),
  ///       ),
  ///    ],
  /// );
  /// ```
  ///
  /// Second, you can specify the minimum width that it should occupy, using
  /// the [minEndChildWidth] property. This means that the last widget will occupy
  /// AT LEAST that width, even if it means that the previous widgets will be pushed out
  /// of the available space. However, if the total available space is less
  /// than [minEndChildWidth], then the last widget will be displayed only up to the
  /// available space.
  ///
  /// ## Gaps
  ///
  /// You can add gaps between the widgets, using the [gaps] property. The gaps are
  /// a list of doubles representing pixels. If you have two children, you should
  /// provide one gap. If you have three children, you should provide two gaps, and so on.
  ///
  /// Note the gaps can be negative, in which case the widgets will overlap.
  ///
  /// If you provide less than the required number of gaps, the last gap will be used
  /// for all the remaining widgets. If you provide more gaps than required, the extra
  /// gaps will be ignored.
  ///
  /// ## Cross alignment and main axis size
  ///
  /// The [crossAxisAlignment] property specifies how to align the widgets vertically.
  /// The default is to center them. All alignments work:
  ///
  /// * [CrossAxisAlignment.start], [CrossAxisAlignment.end] and
  ///   [CrossAxisAlignment.center] align the children to the top, bottom or center.
  ///
  /// * [CrossAxisAlignment.stretch] forces the children to fill the available height,
  ///   just like in a [Row]. However, while a [Row] can't stretch its children when the
  ///   available height is unbounded (for example, inside a [Column]), [SideBySide] will
  ///   instead stretch all children to the height of the tallest one.
  ///
  /// * [CrossAxisAlignment.baseline] aligns the children by their baselines. To use it
  ///   you must also provide the [textBaseline] property, just like in a [Row].
  ///   Children with no baseline are aligned to the top.
  ///
  /// The [mainAxisSize] property determines whether the widget will occupy the full
  /// available width ([MainAxisSize.max]) or only as much as it needs ([MainAxisSize.min]).
  ///
  /// ## Using Text as children
  ///
  /// When you use [Text] widgets in your children, it's strongly recommended that
  /// you use property `textWidthBasis: TextWidthBasis.longestLine`. The default
  /// `textWidthBasis` is usually `textWidthBasis: TextWidthBasis.parent`, which
  /// is almost never what you want. For example, instead of writing:
  /// `Text("Hello")`, you should write:
  /// `Text("Hello", textWidthBasis: TextWidthBasis.longestLine)`.
  ///
  /// ## Examples
  ///
  /// Suppose you want to create a title aligned to the left, with a divider that
  /// occupies the rest of the space. You want the distance between the title and
  /// the divider to be at least 8 pixels, and you want the divider to occupy at
  /// least 20 pixels of horizontal space:
  ///
  /// ```
  /// return SideBySide(
  ///   children: [
  ///     Text("First Chapter", textWidthBasis: TextWidthBasis.longestLine),
  ///     Divider(color: Colors.grey),
  ///   ],
  ///   gaps: [8.0],
  ///   minEndChildWidth: 20.0,
  /// );
  /// ```
  ///
  /// Another example, with 3 widgets:
  ///
  /// ```
  /// return SideBySide(
  ///   children: [
  ///     Text("Hello!", textWidthBasis: TextWidthBasis.longestLine),
  ///     Text("How are you?", textWidthBasis: TextWidthBasis.longestLine),
  ///     Text("I'm good, thank you.", textWidthBasis: TextWidthBasis.longestLine),
  ///   ],
  ///   gaps: [8.0, 12.0],
  /// );
  /// ```
  ///
  /// For more info, see: https://pub.dartlang.org/packages/assorted_layout_widgets
  ///
  factory SideBySide({
    Key? key,
    List<Widget> children = const [],
    //
    List<double> gaps = const [],
    //
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    //
    TextDirection textDirection = TextDirection.ltr,
    //
    TextBaseline? textBaseline,
    //
    double minEndChildWidth = 0,
    //
    MainAxisSize mainAxisSize = MainAxisSize.max,
    //
  }) {
    assert(crossAxisAlignment != CrossAxisAlignment.baseline || textBaseline != null,
        'To use CrossAxisAlignment.baseline, you must also provide a textBaseline.');

    // 1) Empty usage.
    if (children.isEmpty)
      return SideBySide._(
        key: key,
        startChild: const SizedBox(),
        endChild: const SizedBox(),
        textDirection: textDirection,
        mainAxisSize: mainAxisSize,
      );

    // 2) A single child.
    if (children.length == 1)
      return SideBySide._(
        key: key,
        startChild: children[0],
        endChild: const SizedBox(),
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        textBaseline: textBaseline,
        mainAxisSize: mainAxisSize,
      );

    Widget nestedSideBySide = children.last;

    // Create something like: s(1, s(2,3))
    for (int i = children.length - 2; i >= 0; i--) {
      nestedSideBySide = SideBySide._(
        key: key,
        startChild: children[i],
        endChild: nestedSideBySide,
        crossAxisAlignment: crossAxisAlignment,
        minEndChildWidth: minEndChildWidth,
        innerDistance: gaps.isNotEmpty //
            ? (i < gaps.length ? gaps[i] : gaps.last) //
            : 0,
        textDirection: textDirection,
        textBaseline: textBaseline,
        mainAxisSize: mainAxisSize,
      );
    }

    return nestedSideBySide as SideBySide;
  }

  SideBySide._({
    Key? key,
    required this.startChild,
    required this.endChild,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection = TextDirection.ltr,
    this.textBaseline,
    this.innerDistance = 0,
    this.minEndChildWidth = 0,
    this.mainAxisSize = MainAxisSize.max,
  }) : super(
          key: key,
          children: [startChild, endChild],
        );

  /// The [startChild]  will be on the left, and will occupy as much space as it wants,
  /// up to the available horizontal space. Note that `startChild` should NOT be used
  /// directly  (use `children` instead).
  final Widget startChild;

  /// The [endChild] will be on the right of the [startChild] , and it will occupy the
  /// remaining of the available space. This means, if the `start` widget occupies all
  /// the available space, then endChild widget will not be displayed (since it will
  /// be sized as `0` width). Note that `endChild` should NOT be used
  /// directly (use `children` instead).
  final Widget endChild;

  /// The [crossAxisAlignment] property specifies how to align the widgets vertically.
  /// The default is to center them. To use [CrossAxisAlignment.baseline], you must
  /// also provide the [textBaseline] property, just like in a [Row].
  final CrossAxisAlignment crossAxisAlignment;

  /// The [textDirection] property controls the direction that children are rendered in.
  /// [TextDirection.ltr] is the default direction, so the first child is rendered to the
  /// left, with subsequent children following to the right. If you want to order
  /// children in the opposite direction (right to left), then use [TextDirection.rtl].
  ///
  /// This can be used with RTL (right to left) languages, but also when you want to
  /// align children to the right.
  final TextDirection textDirection;

  /// The [textBaseline] property defines which baseline to use when aligning the
  /// children with [CrossAxisAlignment.baseline]. It's required when
  /// [crossAxisAlignment] is [CrossAxisAlignment.baseline], and ignored otherwise.
  final TextBaseline? textBaseline;

  /// The distance in pixels between the widgets. The default is zero.
  /// It can be negative, in which case the widgets will overlap.
  final double innerDistance;

  /// The minimum width, in pixels, that the [endChild]  should occupy.
  /// The default is zero.
  final double minEndChildWidth;

  /// Determines whether the widget will occupy the full available width
  /// ([MainAxisSize.max]) or only as much as it needs ([MainAxisSize.min]).
  final MainAxisSize mainAxisSize;

  @override
  _RenderSideBySide createRenderObject(BuildContext context) => _RenderSideBySide(
        crossAxisAlignment: crossAxisAlignment,
        innerDistance: innerDistance,
        minEndChildWidth: minEndChildWidth,
        textDirection: textDirection,
        textBaseline: textBaseline,
        mainAxisSize: mainAxisSize,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderSideBySide renderObject) {
    renderObject
      ..crossAxisAlignment = crossAxisAlignment
      ..innerDistance = innerDistance
      ..minEndChildWidth = minEndChildWidth
      ..textDirection = textDirection
      ..textBaseline = textBaseline
      ..mainAxisSize = mainAxisSize;
  }
}

class _RenderSideBySide extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  //
  _RenderSideBySide({
    required this._crossAxisAlignment,
    required this._innerDistance,
    required this._minEndChildWidth,
    required this._textDirection,
    required this._textBaseline,
    required this._mainAxisSize,
  });

  CrossAxisAlignment _crossAxisAlignment;
  double _innerDistance;
  double _minEndChildWidth;
  TextDirection _textDirection;
  TextBaseline? _textBaseline;
  MainAxisSize _mainAxisSize;

  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;

  double get innerDistance => _innerDistance;

  double get minEndChildWidth => _minEndChildWidth;

  TextDirection get textDirection => _textDirection;

  TextBaseline? get textBaseline => _textBaseline;

  MainAxisSize get mainAxisSize => _mainAxisSize;

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

    final double correctedInnerDistance;

    if (crossAxisAlignment == CrossAxisAlignment.stretch) {
      // With a bounded height, the children fill it, just like in a `Row`.
      if (constraints.hasBoundedHeight)
        correctedInnerDistance = _layoutChildren(stretchedHeight: constraints.maxHeight);
      //
      // With an unbounded height (for example, inside a `Column`) the children can't
      // fill it. Instead, we lay them out once to find the tallest one, and then lay
      // them out again, stretched to its height.
      else {
        _layoutChildren();
        correctedInnerDistance = _layoutChildren(
            stretchedHeight: max(startChild.size.height, endChild.size.height));
      }
    }
    //
    else
      correctedInnerDistance = _layoutChildren();

    _positionChildren(correctedInnerDistance);
  }

  /// Lays out the [startChild] and the [endChild], and returns the distance between
  /// them. If [stretchedHeight] is provided, both children are forced to that height.
  double _layoutChildren({double? stretchedHeight}) {
    //
    final double minHeight = stretchedHeight ?? constraints.minHeight;
    final double maxHeight = stretchedHeight ?? constraints.maxHeight;

    // What is the minimum width the endChild can occupy?
    // At the minimum, we have the `minEndChildWidth` plus the inner-distance, except if
    // the minEndChildWidth is zero, in which case we don't add the inner-distance.
    final double minEndChildAndInnerDistance =
        (minEndChildWidth == 0) ? 0 : (minEndChildWidth + innerDistance);

    // StartChild: ---
    // It can take up to (maxWidth - minEndChildAndInnerDistance).
    final startChildConstraints = BoxConstraints(
      minWidth: 0.0,
      maxWidth: max(0.0, constraints.maxWidth - minEndChildAndInnerDistance),
      minHeight: minHeight,
      maxHeight: maxHeight,
    );

    startChild.layout(startChildConstraints, parentUsesSize: true);
    final double startChildWidth = startChild.size.width;

    // If the startChild is zero width, remove the gap.
    final double correctedInnerDistance = (startChildWidth == 0.0) ? 0.0 : innerDistance;

    // EndChild: ---
    // For MainAxisSize.max, endChild fills leftover width.
    // For MainAxisSize.min, endChild can take up to leftover width.
    final leftover = constraints.maxWidth - startChildWidth - correctedInnerDistance;

    BoxConstraints endChildConstraints;
    if (mainAxisSize == MainAxisSize.max) {
      endChildConstraints = constraints
          .copyWith(minWidth: 0, minHeight: minHeight, maxHeight: maxHeight)
          .tighten(width: leftover);
    } else {
      endChildConstraints = BoxConstraints(
        minWidth: 0,
        maxWidth: leftover < 0 ? 0 : leftover,
        minHeight: minHeight,
        maxHeight: maxHeight,
      );
    }

    endChild.layout(endChildConstraints, parentUsesSize: true);

    return correctedInnerDistance;
  }

  void _positionChildren(double correctedInnerDistance) {
    final double startChildWidth = startChild.size.width;
    final double endChildWidth = endChild.size.width;
    double height = max(startChild.size.height, endChild.size.height);

    // For `CrossAxisAlignment.baseline`, children are shifted down to align
    // their baselines, which may make this widget taller than its tallest child.
    double maxAboveBaseline = 0.0;
    if (crossAxisAlignment == CrossAxisAlignment.baseline) {
      assert(textBaseline != null,
          'To use CrossAxisAlignment.baseline, you must also provide a textBaseline.');

      maxAboveBaseline = max(
        startChild.getDistanceToBaseline(textBaseline!, onlyReal: true) ?? 0.0,
        endChild.getDistanceToBaseline(textBaseline!, onlyReal: true) ?? 0.0,
      );

      height = max(
        _dy(startChild, height, maxAboveBaseline) + startChild.size.height,
        _dy(endChild, height, maxAboveBaseline) + endChild.size.height,
      );
    }

    // Decide final size:
    // For MainAxisSize.max, fill available width.
    // For MainAxisSize.min, match total children width (within constraints).
    final double width = (mainAxisSize == MainAxisSize.max)
        ? constraints.maxWidth
        : startChildWidth + correctedInnerDistance + endChildWidth;

    size = constraints.constrain(Size(width, height));

    final double startChildDx, endChildDx;

    // In LTR, place the startChild on the far left,
    // and the endChild to its right (with the gap in between).
    if (textDirection == TextDirection.ltr) {
      startChildDx = 0.0;
      endChildDx = startChildWidth + correctedInnerDistance;
    }
    //
    // In RTL, place the startChild on the far right,
    // and the endChild to its left (with the gap in between).
    else if (textDirection == TextDirection.rtl) {
      startChildDx = size.width - startChildWidth;
      endChildDx = size.width - startChildWidth - correctedInnerDistance - endChildWidth;
    }
    //
    else
      throw AssertionError(textDirection);

    final MultiChildLayoutParentData startChildParentData =
        startChild.parentData as MultiChildLayoutParentData;
    startChildParentData.offset =
        Offset(startChildDx, _dy(startChild, height, maxAboveBaseline));

    final MultiChildLayoutParentData endChildParentData =
        endChild.parentData as MultiChildLayoutParentData;
    endChildParentData.offset =
        Offset(endChildDx, _dy(endChild, height, maxAboveBaseline));
  }

  double _dy(RenderBox child, double height, double maxAboveBaseline) {
    final double childHeight = child.size.height;

    switch (crossAxisAlignment) {
      case CrossAxisAlignment.start:
      case CrossAxisAlignment.stretch:
        return 0.0;
      case CrossAxisAlignment.end:
        return height - childHeight;
      case CrossAxisAlignment.center:
        return (height - childHeight) / 2;
      case CrossAxisAlignment.baseline:
        final double? baseline =
            child.getDistanceToBaseline(textBaseline!, onlyReal: true);
        // Children with no baseline are aligned to the top, like in a `Row`.
        return (baseline == null) ? 0.0 : maxAboveBaseline - baseline;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  /// Reports the baseline of the children, so that nested [SideBySide]s (which is how
  /// a [SideBySide] with more than two children is implemented) can be aligned by
  /// their baselines.
  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      defaultComputeDistanceToHighestActualBaseline(baseline);

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
