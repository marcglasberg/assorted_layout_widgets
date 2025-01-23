import "dart:math";

import "package:assorted_layout_widgets/assorted_layout_widgets.dart";
import "package:flutter/material.dart";

/// The [ShadowVisibility] defines the behavior of shadows applied to the `top` and
/// `bottom` edges of a scrollable widget, based on the scroll state and content
/// dimensions. This applies independently to the `top` and `bottom` edges, allowing
/// different shadow behaviors for each.
///
/// - `whenScrolled`: The shadow is displayed only when there is overflow content in the
///   respective direction, indicating that more content can be revealed by scrolling.
///   If the content fits entirely within the viewport, the shadow will not be shown.
///
/// - `alwaysOn`: The shadow is always visible, regardless of the scroll state or content
///   size. This provides a consistent appearance at the edge of the scrollable area.
///
/// - `alwaysOff`: The shadow is never displayed, even if there is overflow content.
///   Use this to completely disable shadow effects for the respective edge.
///
enum ShadowVisibility {
  /// The shadow is displayed only when there is overflow content in the respective
  /// direction. For example, a top shadow appears when the content is scrolled
  /// downward, indicating that more content exists above the visible area.
  whenScrolled,

  /// The shadow is always visible, regardless of the scroll position or content size.
  /// This is useful for emphasizing boundaries or providing a consistent aesthetic.
  alwaysOn,

  /// The shadow is never displayed, even if the content exceeds the viewport.
  /// This is ideal for cases where shadows are not needed or desired.
  alwaysOff,
}

/// A widget that adds shadows to the top and bottom edges of a scrollable area
/// to visually indicate overflow content.
///
/// The [ScrollShadow] is designed to dynamically display shadows at the edges of
/// a scrollable widget based on the scroll state and content size. Shadows help
/// provide a visual cue that more content is available in a particular direction.
///
/// The visibility, padding, color, and other aspects of the shadows can be customized
/// independently for the top and bottom edges.
///
/// ### Example Usage
/// ```dart
/// ScrollShadow(
///   topShadowVisibility: ShadowVisibility.whenScrolled,
///   bottomShadowVisibility: ShadowVisibility.alwaysOn,
///   topShadowColor: Colors.black45,
///   bottomShadowColor: Colors.black45,
///   child: ListView.builder(
///     itemCount: 50,
///     itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
///   ),
/// );
/// ```
class ScrollShadow extends StatefulWidget {
  //

  /// Default padding applied to the right side of the shadow for top and bottom edges.
  static const double defaultRightPadding = 14.0;

  /// Default padding applied to the left side of the shadow for top and bottom edges.
  static const double defaultLeftPadding = 5.0;

  /// Default radius used for rounding the shadow's corners.
  static const Radius defaultRadius = Radius.circular(4.0);

  /// Padding applied to the right side of the top shadow.
  final double topRightPadding;

  /// Padding applied to the left side of the top shadow.
  final double topLeftPadding;

  /// Radius used for rounding the top shadow's corners.
  final Radius topRadius;

  /// Padding applied to the right side of the bottom shadow.
  final double bottomRightPadding;

  /// Padding applied to the left side of the bottom shadow.
  final double bottomLeftPadding;

  /// Radius used for rounding the bottom shadow's corners.
  final Radius bottomRadius;

  /// Controls the visibility behavior of the top shadow.
  ///
  /// Options:
  /// - [ShadowVisibility.whenScrolled]: Displays the shadow only when content overflows.
  /// - [ShadowVisibility.alwaysOn]: Always displays the shadow.
  /// - [ShadowVisibility.alwaysOff]: Never displays the shadow.
  final ShadowVisibility topShadowVisibility;

  /// Controls the visibility behavior of the bottom shadow.
  ///
  /// Options:
  /// - [ShadowVisibility.whenScrolled]: Displays the shadow only when the content overflows.
  /// - [ShadowVisibility.alwaysOn]: Always displays the shadow.
  /// - [ShadowVisibility.alwaysOff]: Never displays the shadow.
  final ShadowVisibility bottomShadowVisibility;

  /// The color of the top shadow.
  ///
  /// Defaults to [Colors.black].
  final Color topShadowColor;

  /// The color of the bottom shadow.
  ///
  /// Defaults to [Colors.black].
  final Color bottomShadowColor;

  /// The divider color that appears along the top edge of the shadow.
  ///
  /// Defaults to a semi-transparent black.
  final Color topShadowDividerColor;

  /// The divider color that appears along the bottom edge of the shadow.
  ///
  /// Defaults to a semi-transparent black.
  final Color bottomShadowDividerColor;

  /// The elevation of the shadows, which determines their intensity and blur radius.
  ///
  /// Higher values produce more prominent and softer shadows.
  /// Defaults to 4.0.
  final double? elevation;

  /// If `true`, hides the shadow when the scroll position is negative (overscrolled).
  ///
  /// Defaults to `false`.
  final bool ifHidesShadowForNegativeScroll;

  /// The child widget wrapped by the `ScrollShadow`.
  ///
  /// Typically, this is directly the scrollable widget such as `ListView`,
  /// `SingleChildScrollView`, or `GridView`, but the scrollable can be
  /// further below in the widget tree.
  final Widget? child;

  /// A widget that adds shadows to the top and bottom edges of a scrollable area
  /// to visually indicate overflow content.
  ///
  /// The [ScrollShadow] is designed to dynamically display shadows at the edges of
  /// a scrollable widget based on the scroll state and content size. Shadows help
  /// provide a visual cue that more content is available in a particular direction.
  ///
  /// The visibility, padding, color, and other aspects of the shadows can be customized
  /// independently for the top and bottom edges.
  ///
  /// ### Example Usage
  /// ```dart
  /// ScrollShadow(
  ///   topShadowVisibility: ShadowVisibility.whenScrolled,
  ///   bottomShadowVisibility: ShadowVisibility.alwaysOn,
  ///   topShadowColor: Colors.black45,
  ///   bottomShadowColor: Colors.black45,
  ///   child: ListView.builder(
  ///     itemCount: 50,
  ///     itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
  ///   ),
  /// );
  /// ```
  const ScrollShadow({
    required this.child,
    double? topRightPadding,
    double? topLeftPadding,
    Radius? topRadius,
    double? bottomRightPadding,
    double? bottomLeftPadding,
    Radius? bottomRadius,
    this.topShadowVisibility = ShadowVisibility.whenScrolled,
    this.bottomShadowVisibility = ShadowVisibility.whenScrolled,
    this.topShadowColor = Colors.black,
    this.bottomShadowColor = Colors.black,
    this.topShadowDividerColor = const Color(0xD0000000),
    this.bottomShadowDividerColor = const Color(0xD0000000),
    this.elevation,
    this.ifHidesShadowForNegativeScroll = false,
    super.key,
  })  : topRightPadding = topRightPadding ?? defaultRightPadding,
        topLeftPadding = topLeftPadding ?? defaultLeftPadding,
        topRadius = topRadius ?? defaultRadius,
        bottomRightPadding = bottomRightPadding ?? defaultRightPadding,
        bottomLeftPadding = bottomLeftPadding ?? defaultLeftPadding,
        bottomRadius = bottomRadius ?? defaultRadius;

  const ScrollShadow.simple({
    required this.child,
    this.topRightPadding = 0.0,
    this.topLeftPadding = 0.0,
    this.topRadius = Radius.zero,
    this.bottomRightPadding = 0.0,
    this.bottomLeftPadding = 0.0,
    this.bottomRadius = Radius.zero,
    this.topShadowVisibility = ShadowVisibility.whenScrolled,
    this.bottomShadowVisibility = ShadowVisibility.whenScrolled,
    this.topShadowColor = Colors.black,
    this.bottomShadowColor = Colors.black,
    this.topShadowDividerColor = const Color(0xD0000000),
    this.bottomShadowDividerColor = const Color(0xD0000000),
    this.elevation,
    this.ifHidesShadowForNegativeScroll = false,
    super.key,
  });

  @override
  State<ScrollShadow> createState() => _ScrollShadowState();
}

class _ScrollShadowState extends State<ScrollShadow> {
  _ShadowPainter? _shadowPainter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _shadowPainter = _buildShadowPainter();
  }

  _ShadowPainter _buildShadowPainter() {
    return _ShadowPainter(
      topRightPadding: widget.topRightPadding,
      topLeftPadding: widget.topLeftPadding,
      topRadius: widget.topRadius,
      bottomRightPadding: widget.bottomRightPadding,
      bottomLeftPadding: widget.bottomLeftPadding,
      bottomRadius: widget.bottomRadius,
      topShadowVisibility: widget.topShadowVisibility,
      bottomShadowVisibility: widget.bottomShadowVisibility,
      topShadowColor: widget.topShadowColor,
      bottomShadowColor: widget.bottomShadowColor,
      topShadowDividerColor: widget.topShadowDividerColor,
      bottomShadowDividerColor: widget.bottomShadowDividerColor,
      elevation: widget.elevation,
      ifHidesShadowForNegativeScroll: widget.ifHidesShadowForNegativeScroll,
    );
  }

  /// Determine if the scrollable is reversed based on the `axisDirection`
  /// from `ScrollMetrics`.
  bool _isReverse(ScrollMetrics metrics) {
    return metrics.axisDirection == AxisDirection.up ||
        metrics.axisDirection == AxisDirection.left;
  }

  bool _handleScrollMetricsNotification(ScrollMetricsNotification notification) {
    final isReversed = _isReverse(notification.metrics);
    _shadowPainter?.update(notification.metrics, isReversed);
    return false; // Allow the notification to continue bubbling
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    // Catch updates & overscroll.
    if (notification is ScrollUpdateNotification ||
        notification is OverscrollNotification) {
      //
      final isReversed = _isReverse(notification.metrics);
      _shadowPainter?.update(notification.metrics, isReversed);
    }

    return false; // Allow the notification to continue bubbling
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: _handleScrollMetricsNotification,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: RepaintBoundary(
          child: CustomPaint(
            foregroundPainter: _shadowPainter,
            child: RepaintBoundary(
              child: DetectScroll(
                cancelNotificationBubbling: false,
                child: widget.child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _shadowPainter?.dispose();
    super.dispose();
  }
}

class _ShadowPainter extends ChangeNotifier implements CustomPainter {
  static const double _defaultShadowElevation = 4.0;

  _ShadowPainter({
    required this.topRightPadding,
    required this.topLeftPadding,
    this.topRadius,
    this.bottomRightPadding,
    this.bottomLeftPadding,
    this.bottomRadius,
    double? elevation,
    this.topShadowVisibility = ShadowVisibility.whenScrolled,
    this.bottomShadowVisibility = ShadowVisibility.whenScrolled,
    this.topShadowColor = Colors.black,
    this.bottomShadowColor = Colors.black,
    this.topShadowDividerColor = const Color(0xD0000000),
    this.bottomShadowDividerColor = const Color(0xD0000000),
    this.ifHidesShadowForNegativeScroll = false,
  }) : elevation = (elevation == null ? _defaultShadowElevation : min(10.0, elevation));

  final double topRightPadding;
  final double topLeftPadding;
  final double? bottomRightPadding;
  final double? bottomLeftPadding;
  final Radius? topRadius;
  final Radius? bottomRadius;
  final double elevation;
  final ShadowVisibility topShadowVisibility;
  final ShadowVisibility bottomShadowVisibility;
  final Color topShadowColor;
  final Color bottomShadowColor;
  final Color topShadowDividerColor;
  final Color bottomShadowDividerColor;
  final bool ifHidesShadowForNegativeScroll;

  bool reverse = false;
  double? _topDistance;
  double? _bottomDistance;
  bool _mounted = true;

  bool get mounted => _mounted;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void update(ScrollMetrics metrics, bool reverse) {
    this.reverse = reverse;

    if (!reverse) {
      _topDistance = min(metrics.pixels, 100.0);
      _bottomDistance = metrics.maxScrollExtent.isFinite
          ? min(metrics.maxScrollExtent - metrics.pixels, 100.0)
          : 100.0;
    } else {
      _bottomDistance = min(metrics.pixels, 100.0);
      _topDistance = metrics.maxScrollExtent.isFinite
          ? min(metrics.maxScrollExtent - metrics.pixels, 100.0)
          : 100.0;
    }

    if (mounted) notifyListeners();
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintTopShadowIfNecessary(canvas, size);
    _paintBottomShadowIfNecessary(canvas, size);
  }

  void _paintTopShadowIfNecessary(Canvas canvas, Size size) {
    if (topShadowVisibility == ShadowVisibility.alwaysOff) return;
    if (topShadowVisibility == ShadowVisibility.alwaysOn) {
      _drawTopShadow(canvas, size, elevation);
      return;
    }
    // ShadowVisibility.whenScrolled
    if (ifHidesShadowForNegativeScroll &&
        _bottomDistance != null &&
        _bottomDistance! < 0) {
      return;
    }
    if ((_topDistance ?? 0) > 0) {
      final topElevation = min(elevation, _topDistance! / 5);
      _drawTopShadow(canvas, size, topElevation);
    }
  }

  void _paintBottomShadowIfNecessary(Canvas canvas, Size size) {
    if (bottomShadowVisibility == ShadowVisibility.alwaysOff) return;
    if (bottomShadowVisibility == ShadowVisibility.alwaysOn) {
      _drawBottomShadow(canvas, size, elevation);
      return;
    }
    // ShadowVisibility.whenScrolled
    if (ifHidesShadowForNegativeScroll && _topDistance != null && _topDistance! < 0) {
      return;
    }
    if ((_bottomDistance ?? 0) > 0) {
      final bottomElevation = min(elevation, _bottomDistance! / 5);
      _drawBottomShadow(canvas, size, bottomElevation);
    }
  }

  void _drawTopShadow(Canvas canvas, Size size, double shadowElevation) {
    canvas.save();

    // Divider line.
    canvas.drawLine(
      Offset(topLeftPadding, 0),
      Offset(size.width - topRightPadding, 0),
      Paint()
        ..color = topShadowDividerColor
        ..strokeWidth = 0.1,
    );

    // Clip area.
    canvas.clipRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(
          topLeftPadding,
          0,
          size.width - topRightPadding,
          size.height / 2,
        ),
        topLeft: topRadius ?? Radius.zero,
        topRight: topRadius ?? Radius.zero,
      ),
    );

    // Shadow above top edge.
    final path = Path()
      ..moveTo(topLeftPadding, -20.0)
      ..lineTo(size.width - topRightPadding, -20.0)
      ..lineTo(size.width - topRightPadding, 0.0)
      ..lineTo(topLeftPadding, 0.0)
      ..close();

    canvas.drawShadow(path, topShadowColor, shadowElevation, true);
    canvas.restore();
  }

  void _drawBottomShadow(Canvas canvas, Size size, double shadowElevation) {
    canvas.save();
    // Divider line.
    canvas.drawLine(
      Offset(bottomLeftPadding ?? 0, size.height),
      Offset(size.width - (bottomRightPadding ?? 0), size.height),
      Paint()
        ..color = bottomShadowDividerColor
        ..strokeWidth = 0.1,
    );

    // Clip area.
    canvas.clipRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(
          bottomLeftPadding ?? 0,
          size.height / 2,
          size.width - (bottomRightPadding ?? 0),
          size.height,
        ),
        bottomLeft: bottomRadius ?? Radius.zero,
        bottomRight: bottomRadius ?? Radius.zero,
      ),
    );

    // Shadow below bottom edge.
    final path = Path()
      ..moveTo(bottomLeftPadding ?? 0, size.height + 20.0 - shadowElevation * 2)
      ..lineTo(bottomLeftPadding ?? 0, size.height - shadowElevation * 2)
      ..lineTo(size.width - (bottomRightPadding ?? 0), size.height - shadowElevation * 2)
      ..lineTo(size.width - (bottomRightPadding ?? 0),
          size.height + 20.0 - shadowElevation * 2)
      ..close();

    canvas.drawShadow(path, bottomShadowColor, shadowElevation, true);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShadowPainter oldDelegate) {
    return topRightPadding != oldDelegate.topRightPadding ||
        topLeftPadding != oldDelegate.topLeftPadding ||
        bottomRightPadding != oldDelegate.bottomRightPadding ||
        bottomLeftPadding != oldDelegate.bottomLeftPadding ||
        topRadius != oldDelegate.topRadius ||
        bottomRadius != oldDelegate.bottomRadius ||
        elevation != oldDelegate.elevation;
  }

  @override
  bool shouldRebuildSemantics(_ShadowPainter oldDelegate) => false;

  @override
  bool? hitTest(Offset position) => null;

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;
}
