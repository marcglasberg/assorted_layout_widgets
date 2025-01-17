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
/// The default is to center them. At the moment, only [CrossAxisAlignment.start],
/// [CrossAxisAlignment.end] and [CrossAxisAlignment.center] work. If you provide
/// [CrossAxisAlignment.baseline] or [CrossAxisAlignment.stretch], you'll get
/// an [UnimplementedError].
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
/// ## Deprecated usage
///
/// The `startChild` and `endChild` properties are deprecated. Use the `children`
/// property instead. The `innerDistance` property is also deprecated. Use the `gaps`
/// property instead.
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
  /// The default is to center them. At the moment, only [CrossAxisAlignment.start],
  /// [CrossAxisAlignment.end] and [CrossAxisAlignment.center] work. If you provide
  /// [CrossAxisAlignment.baseline] or [CrossAxisAlignment.stretch], you'll get
  /// an [UnimplementedError].
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
  /// ## Deprecated usage
  ///
  /// The `startChild` and `endChild` properties are deprecated. Use the `children`
  /// property instead. The `innerDistance` property is also deprecated. Use the `gaps`
  /// property instead.
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
    @Deprecated('Use the `children` property instead.') Widget? startChild,
    //
    @Deprecated('Use the `children` property instead.') Widget? endChild,
    //
    List<double> gaps = const [],
    //
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    //
    TextDirection textDirection = TextDirection.ltr,
    //
    @Deprecated('Use the `gaps` property instead.') double innerDistance = 0,
    //
    double minEndChildWidth = 0,
    //
    MainAxisSize mainAxisSize = MainAxisSize.max,
    //
  }) {
    // 1) Deprecated usage.
    if (startChild != null && endChild != null) {
      //
      if (children.isNotEmpty)
        throw ArgumentError(
            'Cannot use `startChild` and `endChild` with the `children` property.');

      if (gaps.isNotEmpty)
        throw ArgumentError('Cannot use `gaps` with the `startChild` property.');

      return SideBySide._(
        key: key,
        startChild: startChild,
        endChild: endChild,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        innerDistance: innerDistance,
        minEndChildWidth: minEndChildWidth,
        mainAxisSize: mainAxisSize,
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
        key: key,
        startChild: const SizedBox(),
        endChild: const SizedBox(),
        textDirection: textDirection,
        mainAxisSize: mainAxisSize,
      );

    // 3) When providing [children], can't use `startChild` or `endChild`.
    if (startChild != null || endChild != null)
      throw ArgumentError(
          'Cannot use `startChild` or `endChild` with the `children` property.');

    if (innerDistance != 0)
      throw ArgumentError('Cannot use `innerDistance` with the `children` property. '
          'Use `gaps` instead.');

    // 4) A single child.
    if (children.length == 1)
      return SideBySide._(
        key: key,
        startChild: children[0],
        endChild: const SizedBox(),
        textDirection: textDirection,
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
        innerDistance: (innerDistance +
            (gaps.isNotEmpty //
                ? (i < gaps.length ? gaps[i] : gaps.last) //
                : 0)),
        textDirection: textDirection,
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
  /// The default is to center them. At the moment, only [CrossAxisAlignment.start],
  /// [CrossAxisAlignment.end] and [CrossAxisAlignment.center] work.
  final CrossAxisAlignment crossAxisAlignment;

  /// The [textDirection] property controls the direction that children are rendered in.
  /// [TextDirection.ltr] is the default direction, so the first child is rendered to the
  /// left, with subsequent children following to the right. If you want to order
  /// children in the opposite direction (right to left), then use [TextDirection.rtl].
  ///
  /// This can be used with RTL (right to left) languages, but also when you want to
  /// align children to the right.
  final TextDirection textDirection;

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
        mainAxisSize: mainAxisSize,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderSideBySide renderObject) {
    renderObject
      ..crossAxisAlignment = crossAxisAlignment
      ..innerDistance = innerDistance
      ..minEndChildWidth = minEndChildWidth
      ..textDirection = textDirection
      ..mainAxisSize = mainAxisSize;
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
    required TextDirection textDirection,
    required MainAxisSize mainAxisSize,
  })  : _crossAxisAlignment = crossAxisAlignment,
        _innerDistance = innerDistance,
        _minEndChildWidth = minEndChildWidth,
        _textDirection = textDirection,
        _mainAxisSize = mainAxisSize;

  CrossAxisAlignment _crossAxisAlignment;
  double _innerDistance;
  double _minEndChildWidth;
  TextDirection _textDirection;
  MainAxisSize _mainAxisSize;

  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;

  double get innerDistance => _innerDistance;

  double get minEndChildWidth => _minEndChildWidth;

  TextDirection get textDirection => _textDirection;

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
    _performLayout();
  }

  late double maxChildHeight;

  void _performLayout() {
    if (textDirection == TextDirection.ltr)
      _performLayoutLtr();
    //
    else if (textDirection == TextDirection.rtl)
      _performLayoutRtl();
    //
    else
      throw AssertionError(textDirection);
  }

  void _performLayoutRtl() {
    // How much space (min) the endChild needs + the gap:
    // If minEndChildWidth is zero, we consider zero for this calculation.
    final double minEndChildAndInnerDistance =
        (minEndChildWidth == 0) ? 0 : (minEndChildWidth + innerDistance);

    // --- Layout startChild. ---
    // It can take up to (maxWidth - minEndChildAndInnerDistance).
    final startChildConstraints = BoxConstraints(
      minWidth: 0.0,
      maxWidth: max(0.0, constraints.maxWidth - minEndChildAndInnerDistance),
      minHeight: constraints.minHeight,
      maxHeight: constraints.maxHeight,
    );
    startChild.layout(startChildConstraints, parentUsesSize: true);
    final double startChildWidth = startChild.size.width;

    // If the startChild used no width, we remove the gap.
    final double correctedInnerDistance = (startChildWidth == 0.0) ? 0.0 : innerDistance;

    // --- Layout endChild. ---
    // For MainAxisSize.max, endChild is forced to fill leftover width.
    // For MainAxisSize.min, endChild can take up to leftover width as needed.
    final leftover = constraints.maxWidth - startChildWidth - correctedInnerDistance;

    BoxConstraints endChildConstraints;
    if (mainAxisSize == MainAxisSize.max) {
      endChildConstraints = constraints.copyWith(minWidth: 0).tighten(width: leftover);
    } else {
      endChildConstraints = BoxConstraints(
        minWidth: 0,
        maxWidth: leftover < 0 ? 0 : leftover,
        minHeight: constraints.minHeight,
        maxHeight: constraints.maxHeight,
      );
    }

    endChild.layout(endChildConstraints, parentUsesSize: true);
    final double endChildWidth = endChild.size.width;

    // Find the tallest child:
    final double maxChildHeight = max(startChild.size.height, endChild.size.height);

    // --- Positioning. ---
    final MultiChildLayoutParentData startChildParentData =
        startChild.parentData as MultiChildLayoutParentData;
    final MultiChildLayoutParentData endChildParentData =
        endChild.parentData as MultiChildLayoutParentData;

    // In RTL, place the startChild on the far right,
    // and the endChild to its left (with the gap in between).
    startChildParentData.offset = Offset(
      constraints.maxWidth - startChildWidth,
      dy(startChild, maxChildHeight),
    );
    endChildParentData.offset = Offset(
      constraints.maxWidth - startChildWidth - correctedInnerDistance - endChildWidth,
      dy(endChild, maxChildHeight),
    );

    // Decide final width:
    // For MainAxisSize.max, we use constraints.maxWidth.
    // For MainAxisSize.min, just use the sum of both children plus the gap.
    if (mainAxisSize == MainAxisSize.max) {
      size = Size(constraints.maxWidth, maxChildHeight);
    } else {
      // The used width is the distance from the leftmost child to the rightmost child.
      final usedWidth = startChildWidth + correctedInnerDistance + endChildWidth;
      size = constraints.constrain(Size(usedWidth, maxChildHeight));
    }
  }

  void _performLayoutLtr() {
    //
    //
    // What is the minimum width the endChild can occupy?
    // At the minimum, we have the `minEndChildWidth` plus the inner-distance, except if
    // the minEndChildWidth is zero, in which case we don't add the inner-distance.
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

    // If the startChild is zero width, remove the gap.
    var correctedInnerDistance = (startChildWidth == 0.0) ? 0 : innerDistance;

    // EndChild: ---
    // For MainAxisSize.max, endChild fills leftover width.
    // For MainAxisSize.min, endChild can take up to leftover width.
    final leftover = constraints.maxWidth - startChildWidth - correctedInnerDistance;

    BoxConstraints endChildConstraints;
    if (mainAxisSize == MainAxisSize.max) {
      endChildConstraints = constraints.copyWith(minWidth: 0).tighten(width: leftover);
    } else {
      endChildConstraints = BoxConstraints(
        minWidth: 0,
        maxWidth: leftover < 0 ? 0 : leftover,
        minHeight: constraints.minHeight,
        maxHeight: constraints.maxHeight,
      );
    }

    endChild.layout(endChildConstraints, parentUsesSize: true);

    double endChildWidth = endChild.size.width;
    double maxChildHeight = max(startChild.size.height, endChild.size.height);

    // Position children.
    final MultiChildLayoutParentData startChildParentData =
        startChild.parentData as MultiChildLayoutParentData;
    startChildParentData.offset = Offset(0, dy(startChild, maxChildHeight));

    final MultiChildLayoutParentData endChildParentData =
        endChild.parentData as MultiChildLayoutParentData;
    endChildParentData.offset =
        Offset(startChildWidth + correctedInnerDistance, dy(endChild, maxChildHeight));

    // Decide final width:
    // For MainAxisSize.max, fill available width.
    // For MainAxisSize.min, match total children width (within constraints).
    if (mainAxisSize == MainAxisSize.max) {
      size = Size(constraints.maxWidth, maxChildHeight);
    } else {
      final usedWidth = startChildWidth + correctedInnerDistance + endChildWidth;
      size = constraints.constrain(Size(usedWidth, maxChildHeight));
    }
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
