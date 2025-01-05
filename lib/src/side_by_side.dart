import 'dart:math';

import 'package:assorted_layout_widgets/src/row_super.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
/// the [minEndChildWidth] parameter. This means that the last widget will occupy
/// AT LEAST that width, even if it means that the previous widgets will be pushed out
/// of the available space. However, if the total available space is less
/// than [minEndChildWidth], then the last widget will be displayed only up to the
/// available space.
///
/// ## Gaps
///
/// You can add gaps between the widgets, using the [gaps] parameter. The gaps are
/// a list of doubles representing pixels. If you have two children, you should
/// provide one gap. If you have three children, you should provide two gaps, and so on.
///
/// Note the gaps can be negative, in which case the widgets will overlap.
///
/// If you provide less than the required number of gaps, the last gap will be used
/// for all the remaining widgets. If you provide more gaps than required, the extra
/// gaps will be ignored.
///
/// ## Cross alignment
///
/// The [crossAxisAlignment] parameter specifies how to align the widgets vertically.
/// The default is to center them. At the moment, only [CrossAxisAlignment.start],
/// [CrossAxisAlignment.end] and [CrossAxisAlignment.center] work. If you provide
/// [CrossAxisAlignment.baseline] or [CrossAxisAlignment.stretch], you'll get
/// an [UnimplementedError].
///
/// ## Using Text as children
///
/// When you use [Text] widgets in your children, it's strongly recommended that
/// you use parameter `textWidthBasis: TextWidthBasis.longestLine`. The default
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
/// ## Deprecated usage
///
/// The `startChild` and `endChild` parameters are deprecated. Use the `children`
/// parameter instead. The `innerDistance` parameter is also deprecated. Use the `gaps`
/// parameter instead.
///
/// For example, this deprecated code:
///
/// ```
/// return SideBySide(
///   startChild: Text("Hello!", textWidthBasis: TextWidthBasis.longestLine),
///   endChild: Text("How are you?", textWidthBasis: TextWidthBasis.longestLine),
///   innerDistance: 8.0,
/// );
/// ```
///
/// Should be replaced with:
///
/// ```
/// return SideBySide(
///   children: [
///     Text("Hello!", textWidthBasis: TextWidthBasis.longestLine),
///     Text("How are you?", textWidthBasis: TextWidthBasis.longestLine),
///   ],
///   gaps: [8.0],
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
  /// the [minEndChildWidth] parameter. This means that the last widget will occupy
  /// AT LEAST that width, even if it means that the previous widgets will be pushed out
  /// of the available space. However, if the total available space is less
  /// than [minEndChildWidth], then the last widget will be displayed only up to the
  /// available space.
  ///
  /// ## Gaps
  ///
  /// You can add gaps between the widgets, using the [gaps] parameter. The gaps are
  /// a list of doubles representing pixels. If you have two children, you should
  /// provide one gap. If you have three children, you should provide two gaps, and so on.
  ///
  /// Note the gaps can be negative, in which case the widgets will overlap.
  ///
  /// If you provide less than the required number of gaps, the last gap will be used
  /// for all the remaining widgets. If you provide more gaps than required, the extra
  /// gaps will be ignored.
  ///
  /// ## Cross alignment
  ///
  /// The [crossAxisAlignment] parameter specifies how to align the widgets vertically.
  /// The default is to center them. At the moment, only [CrossAxisAlignment.start],
  /// [CrossAxisAlignment.end] and [CrossAxisAlignment.center] work. If you provide
  /// [CrossAxisAlignment.baseline] or [CrossAxisAlignment.stretch], you'll get
  /// an [UnimplementedError].
  ///
  /// ## Using Text as children
  ///
  /// When you use [Text] widgets in your children, it's strongly recommended that
  /// you use parameter `textWidthBasis: TextWidthBasis.longestLine`. The default
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
  /// ## Deprecated usage
  ///
  /// The `startChild` and `endChild` parameters are deprecated. Use the `children`
  /// parameter instead. The `innerDistance` parameter is also deprecated. Use the `gaps`
  /// parameter instead.
  ///
  /// For example, this deprecated code:
  ///
  /// ```
  /// return SideBySide(
  ///   startChild: Text("Hello!", textWidthBasis: TextWidthBasis.longestLine),
  ///   endChild: Text("How are you?", textWidthBasis: TextWidthBasis.longestLine),
  ///   innerDistance: 8.0,
  /// );
  /// ```
  ///
  /// Should be replaced with:
  ///
  /// ```
  /// return SideBySide(
  ///   children: [
  ///     Text("Hello!", textWidthBasis: TextWidthBasis.longestLine),
  ///     Text("How are you?", textWidthBasis: TextWidthBasis.longestLine),
  ///   ],
  ///   gaps: [8.0],
  /// );
  /// ```
  ///
  /// For more info, see: https://pub.dartlang.org/packages/assorted_layout_widgets
  ///
  factory SideBySide({
    Key? key,
    List<Widget> children = const [],
    //
    @Deprecated('Use the `children` parameter instead.') Widget? startChild,
    //
    @Deprecated('Use the `children` parameter instead.') Widget? endChild,
    //
    List<double> gaps = const [],
    //
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    //
    @Deprecated('Use the `gaps` parameter instead.') double innerDistance = 0,
    //
    double minEndChildWidth = 0,
  }) {
    // 1) Deprecated usage.
    if (startChild != null && endChild != null) {
      //
      if (children.isNotEmpty)
        throw ArgumentError(
            'Cannot use `startChild` and `endChild` with the `children` parameter.');

      if (gaps.isNotEmpty)
        throw ArgumentError('Cannot use `gaps` with the `startChild` parameter.');

      return SideBySide._(
        key: key,
        startChild: startChild,
        endChild: endChild,
        crossAxisAlignment: crossAxisAlignment,
        innerDistance: innerDistance,
        minEndChildWidth: minEndChildWidth,
      );
    }

    if (startChild != null && endChild == null)
      throw ArgumentError(
          'If you provide `startChild` you should also provide `endChild`. '
          'However, it is better to provide only `children` instead, '
          'as `startChild` and `endChild` are deprecated.');

    if (startChild == null && endChild != null)
      throw ArgumentError(
          'If you provide `endChild` you should also provide `startChild`. '
          'However, it is better to provide only `children` instead, '
          'as `startChild` and `endChild` are deprecated.');

    // 2) Empty usage.
    if (children.isEmpty)
      return SideBySide._(
          key: key, startChild: const SizedBox(), endChild: const SizedBox());

    // 3) When providing [children], can't use `startChild` or `endChild`.
    if (startChild != null || endChild != null)
      throw ArgumentError(
          'Cannot use `startChild` or `endChild` with the `children` parameter.');

    if (innerDistance != 0)
      throw ArgumentError('Cannot use `innerDistance` with the `children` parameter. '
          'Use `gaps` instead.');

    // 4) A single child.
    if (children.length == 1)
      return SideBySide._(key: key, startChild: children[0], endChild: const SizedBox());

    Widget nestedSideBySide = children.last;

    // Create something like: s(1, s(2,3))
    for (int i = children.length - 2; i >= 0; i--) {
      nestedSideBySide = SideBySide._(
        key: key,
        startChild: children[i],
        endChild: nestedSideBySide,
        crossAxisAlignment: crossAxisAlignment,
        minEndChildWidth: minEndChildWidth,
        innerDistance: (innerDistance +
            (gaps.isNotEmpty //
                ? (i < gaps.length ? gaps[i] : gaps.last) //
                : 0)),
      );
    }

    return nestedSideBySide as SideBySide;
  }

  SideBySide._({
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

  /// The [crossAxisAlignment] parameter specifies how to align the widgets vertically.
  /// The default is to center them. At the moment, only [CrossAxisAlignment.start],
  /// [CrossAxisAlignment.end] and [CrossAxisAlignment.center] work.
  final CrossAxisAlignment crossAxisAlignment;

  /// The distance in pixels between the widgets. The default is zero.
  /// It can be negative, in which case the widgets will overlap.
  final double innerDistance;

  /// The minimum width, in pixels, that the [endChild]  should occupy.
  /// The default is zero.
  final double minEndChildWidth;

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

    // What is the minimum width the endChild can occupy?
    // At the minimum, we have the `minEndChildWidth` plus the inner-distance, except if
    // the minEndChildWidth is zero, in which case we don't even add the inner-distance.
    // Note: `minEndChildWidth` is the min-width the `endChild` occupies, and
    // `innerDistance` is the gap between `startChild` and `endChild`.
    double minEndChildAndInnerDistance =
        (minEndChildWidth == 0) ? 0 : (minEndChildWidth + innerDistance);

    // StartChild: ---

    var startChildConstraints = BoxConstraints(
      minWidth: 0.0,
      maxWidth: max(0.0, constraints.maxWidth - minEndChildAndInnerDistance),
      minHeight: constraints.minHeight,
      maxHeight: constraints.maxHeight,
    );

    startChild.layout(startChildConstraints, parentUsesSize: true);
    double startChildWidth = startChild.size.width;

    // If the startChild will not bne displayed, then we remove the innerDistance.
    var correctedInnerDistance = (startChildWidth == 0.0) ? 0 : innerDistance;

    // EndChild: ---

    var endChildConstraints = constraints.copyWith(minWidth: 0).tighten(
          width: constraints.maxWidth - startChildWidth - correctedInnerDistance,
        );

    endChild.layout(endChildConstraints, parentUsesSize: true);

    double maxChildHeight = max(startChild.size.height, endChild.size.height);

    // ---

    final MultiChildLayoutParentData startChildParentData =
        startChild.parentData as MultiChildLayoutParentData;
    startChildParentData.offset = Offset(0, dy(startChild, maxChildHeight));

    final MultiChildLayoutParentData endChildParentData =
        endChild.parentData as MultiChildLayoutParentData;
    endChildParentData.offset =
        Offset(startChildWidth + correctedInnerDistance, dy(endChild, maxChildHeight));

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
      throw UnimplementedError('CrossAxisAlignment.baseline is not yet implemented.');
    //
    // TODO: Not yet implemented.
    else if (crossAxisAlignment == CrossAxisAlignment.stretch)
      throw UnimplementedError('CrossAxisAlignment.stretch is not yet implemented.');
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
