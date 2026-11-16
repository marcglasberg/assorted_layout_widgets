import "dart:math";

import "package:assorted_layout_widgets/assorted_layout_widgets.dart";
import "package:material_ui/material_ui.dart";

/// The [ShadowVisibility] defines the behavior of the shadow applied to one edge
/// (`top`, `bottom`, `left` or `right`) of a scrollable widget, based on the scroll
/// state and content dimensions. This applies independently to each edge, allowing
/// different shadow behaviors for each.
///
/// - `whenScrolled`: The shadow is displayed only when there is overflow content in the
///   respective direction, indicating that more content can be revealed by scrolling.
///   If the content fits entirely within the viewport, the shadow will not be shown.
///   The `top` and `bottom` edges react to vertical scrollables, while the `left` and
///   `right` edges react to horizontal scrollables.
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

/// A widget that adds shadows to the edges of a scrollable area to visually
/// indicate overflow content.
///
/// The [ScrollShadow] is designed to dynamically display shadows at the edges of
/// a scrollable widget based on the scroll state and content size. Shadows help
/// provide a visual cue that more content is available in a particular direction.
///
/// Vertical scrollables show shadows at the `top` and `bottom` edges, and horizontal
/// scrollables show shadows at the `left` and `right` edges. The edges are physical,
/// so the scroll direction, the text direction (RTL), and `reverse` are all taken into
/// account: the shadow always appears at the edge where more content can be revealed.
///
/// The visibility, padding, color, and other aspects of the shadows can be customized
/// independently for each edge.
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
///
/// ### Horizontal Example
/// ```dart
/// ScrollShadow(
///   leftShadowColor: Colors.black45,
///   rightShadowColor: Colors.black45,
///   child: ListView.builder(
///     scrollDirection: Axis.horizontal,
///     itemCount: 50,
///     itemBuilder: (context, index) => SizedBox(width: 100, child: Text('Item $index')),
///   ),
/// );
/// ```
class ScrollShadow extends StatefulWidget {
  //

  /// Default padding applied to the right side of the shadow for top and bottom edges.
  static const double defaultRightPadding = 14.0;

  /// Default padding applied to the left side of the shadow for top and bottom edges.
  static const double defaultLeftPadding = 5.0;

  /// Default padding applied to the top side of the shadow for left and right edges.
  static const double defaultTopPadding = 5.0;

  /// Default padding applied to the bottom side of the shadow for left and right edges.
  /// It's larger than [defaultTopPadding] to leave room for a horizontal scrollbar.
  static const double defaultBottomPadding = 14.0;

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

  /// Padding applied to the top side of the left shadow.
  final double leftTopPadding;

  /// Padding applied to the bottom side of the left shadow.
  final double leftBottomPadding;

  /// Radius used for rounding the left shadow's corners.
  final Radius leftRadius;

  /// Padding applied to the top side of the right shadow.
  final double rightTopPadding;

  /// Padding applied to the bottom side of the right shadow.
  final double rightBottomPadding;

  /// Radius used for rounding the right shadow's corners.
  final Radius rightRadius;

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

  /// Controls the visibility behavior of the left shadow, for horizontal scrollables.
  ///
  /// Options:
  /// - [ShadowVisibility.whenScrolled]: Displays the shadow only when content overflows.
  /// - [ShadowVisibility.alwaysOn]: Always displays the shadow.
  /// - [ShadowVisibility.alwaysOff]: Never displays the shadow.
  final ShadowVisibility leftShadowVisibility;

  /// Controls the visibility behavior of the right shadow, for horizontal scrollables.
  ///
  /// Options:
  /// - [ShadowVisibility.whenScrolled]: Displays the shadow only when content overflows.
  /// - [ShadowVisibility.alwaysOn]: Always displays the shadow.
  /// - [ShadowVisibility.alwaysOff]: Never displays the shadow.
  final ShadowVisibility rightShadowVisibility;

  /// The color of the top shadow.
  ///
  /// Defaults to [Colors.black].
  final Color topShadowColor;

  /// The color of the bottom shadow.
  ///
  /// Defaults to [Colors.black].
  final Color bottomShadowColor;

  /// The color of the left shadow.
  ///
  /// Defaults to [Colors.black].
  final Color leftShadowColor;

  /// The color of the right shadow.
  ///
  /// Defaults to [Colors.black].
  final Color rightShadowColor;

  /// The divider color that appears along the top edge of the shadow.
  ///
  /// Defaults to a semi-transparent black.
  final Color topShadowDividerColor;

  /// The divider color that appears along the bottom edge of the shadow.
  ///
  /// Defaults to a semi-transparent black.
  final Color bottomShadowDividerColor;

  /// The divider color that appears along the left edge of the shadow.
  ///
  /// Defaults to a semi-transparent black.
  final Color leftShadowDividerColor;

  /// The divider color that appears along the right edge of the shadow.
  ///
  /// Defaults to a semi-transparent black.
  final Color rightShadowDividerColor;

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
  ///
  /// Only the closest scrollable descendant drives the shadows. Scrollables
  /// nested inside it are ignored. To show shadows for a nested scrollable,
  /// wrap it with its own [ScrollShadow].
  final Widget? child;

  /// A widget that adds shadows to the edges of a scrollable area to visually
  /// indicate overflow content.
  ///
  /// The [ScrollShadow] is designed to dynamically display shadows at the edges of
  /// a scrollable widget based on the scroll state and content size. Shadows help
  /// provide a visual cue that more content is available in a particular direction.
  ///
  /// Vertical scrollables show shadows at the `top` and `bottom` edges, and horizontal
  /// scrollables show shadows at the `left` and `right` edges. The edges are physical,
  /// so the scroll direction, the text direction (RTL), and `reverse` are all taken
  /// into account: the shadow always appears at the edge where more content can be
  /// revealed.
  ///
  /// The visibility, padding, color, and other aspects of the shadows can be customized
  /// independently for each edge.
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
    double? leftTopPadding,
    double? leftBottomPadding,
    Radius? leftRadius,
    double? rightTopPadding,
    double? rightBottomPadding,
    Radius? rightRadius,
    this.topShadowVisibility = ShadowVisibility.whenScrolled,
    this.bottomShadowVisibility = ShadowVisibility.whenScrolled,
    this.leftShadowVisibility = ShadowVisibility.whenScrolled,
    this.rightShadowVisibility = ShadowVisibility.whenScrolled,
    this.topShadowColor = Colors.black,
    this.bottomShadowColor = Colors.black,
    this.leftShadowColor = Colors.black,
    this.rightShadowColor = Colors.black,
    this.topShadowDividerColor = const Color(0xD0000000),
    this.bottomShadowDividerColor = const Color(0xD0000000),
    this.leftShadowDividerColor = const Color(0xD0000000),
    this.rightShadowDividerColor = const Color(0xD0000000),
    this.elevation,
    this.ifHidesShadowForNegativeScroll = false,
    super.key,
  })  : topRightPadding = topRightPadding ?? defaultRightPadding,
        topLeftPadding = topLeftPadding ?? defaultLeftPadding,
        topRadius = topRadius ?? defaultRadius,
        bottomRightPadding = bottomRightPadding ?? defaultRightPadding,
        bottomLeftPadding = bottomLeftPadding ?? defaultLeftPadding,
        bottomRadius = bottomRadius ?? defaultRadius,
        leftTopPadding = leftTopPadding ?? defaultTopPadding,
        leftBottomPadding = leftBottomPadding ?? defaultBottomPadding,
        leftRadius = leftRadius ?? defaultRadius,
        rightTopPadding = rightTopPadding ?? defaultTopPadding,
        rightBottomPadding = rightBottomPadding ?? defaultBottomPadding,
        rightRadius = rightRadius ?? defaultRadius;

  const ScrollShadow.simple({
    required this.child,
    this.topRightPadding = 0.0,
    this.topLeftPadding = 0.0,
    this.topRadius = Radius.zero,
    this.bottomRightPadding = 0.0,
    this.bottomLeftPadding = 0.0,
    this.bottomRadius = Radius.zero,
    this.leftTopPadding = 0.0,
    this.leftBottomPadding = 0.0,
    this.leftRadius = Radius.zero,
    this.rightTopPadding = 0.0,
    this.rightBottomPadding = 0.0,
    this.rightRadius = Radius.zero,
    this.topShadowVisibility = ShadowVisibility.whenScrolled,
    this.bottomShadowVisibility = ShadowVisibility.whenScrolled,
    this.leftShadowVisibility = ShadowVisibility.whenScrolled,
    this.rightShadowVisibility = ShadowVisibility.whenScrolled,
    this.topShadowColor = Colors.black,
    this.bottomShadowColor = Colors.black,
    this.leftShadowColor = Colors.black,
    this.rightShadowColor = Colors.black,
    this.topShadowDividerColor = const Color(0xD0000000),
    this.bottomShadowDividerColor = const Color(0xD0000000),
    this.leftShadowDividerColor = const Color(0xD0000000),
    this.rightShadowDividerColor = const Color(0xD0000000),
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
      leftTopPadding: widget.leftTopPadding,
      leftBottomPadding: widget.leftBottomPadding,
      leftRadius: widget.leftRadius,
      rightTopPadding: widget.rightTopPadding,
      rightBottomPadding: widget.rightBottomPadding,
      rightRadius: widget.rightRadius,
      topShadowVisibility: widget.topShadowVisibility,
      bottomShadowVisibility: widget.bottomShadowVisibility,
      leftShadowVisibility: widget.leftShadowVisibility,
      rightShadowVisibility: widget.rightShadowVisibility,
      topShadowColor: widget.topShadowColor,
      bottomShadowColor: widget.bottomShadowColor,
      leftShadowColor: widget.leftShadowColor,
      rightShadowColor: widget.rightShadowColor,
      topShadowDividerColor: widget.topShadowDividerColor,
      bottomShadowDividerColor: widget.bottomShadowDividerColor,
      leftShadowDividerColor: widget.leftShadowDividerColor,
      rightShadowDividerColor: widget.rightShadowDividerColor,
      elevation: widget.elevation,
      ifHidesShadowForNegativeScroll: widget.ifHidesShadowForNegativeScroll,
    );
  }

  bool _handleScrollMetricsNotification(ScrollMetricsNotification notification) {
    // Only the closest scrollable descendant drives the shadows. Notifications
    // from scrollables nested inside it (depth > 0) are ignored.
    if (notification.depth == 0) {
      _shadowPainter?.update(notification.metrics);
    }
    return false; // Allow the notification to continue bubbling
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    // Catch updates & overscroll, from the closest scrollable descendant only.
    if (notification.depth == 0 &&
        (notification is ScrollUpdateNotification ||
            notification is OverscrollNotification)) {
      //
      _shadowPainter?.update(notification.metrics);
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
    required this.leftTopPadding,
    required this.leftBottomPadding,
    required this.leftRadius,
    required this.rightTopPadding,
    required this.rightBottomPadding,
    required this.rightRadius,
    double? elevation,
    this.topShadowVisibility = ShadowVisibility.whenScrolled,
    this.bottomShadowVisibility = ShadowVisibility.whenScrolled,
    this.leftShadowVisibility = ShadowVisibility.whenScrolled,
    this.rightShadowVisibility = ShadowVisibility.whenScrolled,
    this.topShadowColor = Colors.black,
    this.bottomShadowColor = Colors.black,
    this.leftShadowColor = Colors.black,
    this.rightShadowColor = Colors.black,
    this.topShadowDividerColor = const Color(0xD0000000),
    this.bottomShadowDividerColor = const Color(0xD0000000),
    this.leftShadowDividerColor = const Color(0xD0000000),
    this.rightShadowDividerColor = const Color(0xD0000000),
    this.ifHidesShadowForNegativeScroll = false,
  }) : elevation = (elevation == null ? _defaultShadowElevation : min(10.0, elevation));

  final double topRightPadding;
  final double topLeftPadding;
  final double? bottomRightPadding;
  final double? bottomLeftPadding;
  final double leftTopPadding;
  final double leftBottomPadding;
  final double rightTopPadding;
  final double rightBottomPadding;
  final Radius? topRadius;
  final Radius? bottomRadius;
  final Radius leftRadius;
  final Radius rightRadius;
  final double elevation;
  final ShadowVisibility topShadowVisibility;
  final ShadowVisibility bottomShadowVisibility;
  final ShadowVisibility leftShadowVisibility;
  final ShadowVisibility rightShadowVisibility;
  final Color topShadowColor;
  final Color bottomShadowColor;
  final Color leftShadowColor;
  final Color rightShadowColor;
  final Color topShadowDividerColor;
  final Color bottomShadowDividerColor;
  final Color leftShadowDividerColor;
  final Color rightShadowDividerColor;
  final bool ifHidesShadowForNegativeScroll;

  // How much content there is beyond each physical edge (capped at 100).
  // The top/bottom distances come from vertical scrollables, and the
  // left/right distances come from horizontal scrollables.
  double? _topDistance;
  double? _bottomDistance;
  double? _leftDistance;
  double? _rightDistance;
  bool _mounted = true;

  bool get mounted => _mounted;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  /// The [ScrollMetrics.axisDirection] already accounts for the scroll axis,
  /// the `reverse` flag, and the text direction (RTL), so it tells us which
  /// physical edge is the scroll "start" (where `pixels` is zero).
  ///
  /// The distances of the other axis are cleared, so that no stale shadows
  /// remain if the scrollable changes axis (for example, when the child is
  /// rebuilt from a vertical list to a horizontal one).
  void update(ScrollMetrics metrics) {
    final double distanceBefore = min(metrics.pixels, 100.0);
    final double distanceAfter = metrics.maxScrollExtent.isFinite
        ? min(metrics.maxScrollExtent - metrics.pixels, 100.0)
        : 100.0;

    switch (metrics.axisDirection) {
      case AxisDirection.down:
        _topDistance = distanceBefore;
        _bottomDistance = distanceAfter;
      case AxisDirection.up:
        _bottomDistance = distanceBefore;
        _topDistance = distanceAfter;
      case AxisDirection.right:
        _leftDistance = distanceBefore;
        _rightDistance = distanceAfter;
      case AxisDirection.left:
        _rightDistance = distanceBefore;
        _leftDistance = distanceAfter;
    }

    switch (metrics.axis) {
      case Axis.vertical:
        _leftDistance = null;
        _rightDistance = null;
      case Axis.horizontal:
        _topDistance = null;
        _bottomDistance = null;
    }

    if (mounted) notifyListeners();
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintShadowIfNecessary(
      visibility: topShadowVisibility,
      distance: _topDistance,
      oppositeDistance: _bottomDistance,
      draw: (shadowElevation) => _drawTopShadow(canvas, size, shadowElevation),
    );
    _paintShadowIfNecessary(
      visibility: bottomShadowVisibility,
      distance: _bottomDistance,
      oppositeDistance: _topDistance,
      draw: (shadowElevation) => _drawBottomShadow(canvas, size, shadowElevation),
    );
    _paintShadowIfNecessary(
      visibility: leftShadowVisibility,
      distance: _leftDistance,
      oppositeDistance: _rightDistance,
      draw: (shadowElevation) => _drawLeftShadow(canvas, size, shadowElevation),
    );
    _paintShadowIfNecessary(
      visibility: rightShadowVisibility,
      distance: _rightDistance,
      oppositeDistance: _leftDistance,
      draw: (shadowElevation) => _drawRightShadow(canvas, size, shadowElevation),
    );
  }

  void _paintShadowIfNecessary({
    required ShadowVisibility visibility,
    required double? distance,
    required double? oppositeDistance,
    required void Function(double shadowElevation) draw,
  }) {
    if (visibility == ShadowVisibility.alwaysOff) return;
    if (visibility == ShadowVisibility.alwaysOn) {
      draw(elevation);
      return;
    }
    // ShadowVisibility.whenScrolled
    if (ifHidesShadowForNegativeScroll &&
        oppositeDistance != null &&
        oppositeDistance < 0) {
      return;
    }
    if ((distance ?? 0) > 0) {
      draw(min(elevation, distance! / 5));
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

  void _drawLeftShadow(Canvas canvas, Size size, double shadowElevation) {
    final double top = leftTopPadding;
    final double bottom = size.height - leftBottomPadding;

    canvas.save();

    // Divider line.
    canvas.drawLine(
      Offset(0, top),
      Offset(0, bottom),
      Paint()
        ..color = leftShadowDividerColor
        ..strokeWidth = 0.1,
    );

    // Clip area.
    canvas.clipRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(0, top, size.width / 2, bottom),
        topLeft: leftRadius,
        bottomLeft: leftRadius,
      ),
    );

    // Shadow to the left of the left edge. The light source is above, so the shadow
    // doesn't spread much sideways. Like the bottom shadow, the path is moved
    // inwards a bit, so that the shadow is visible inside the clip area.
    final double inset = shadowElevation * 2;
    final path = Path()..addRect(Rect.fromLTRB(-20.0 + inset, top, inset, bottom));

    canvas.drawShadow(path, leftShadowColor, shadowElevation, true);
    canvas.restore();
  }

  void _drawRightShadow(Canvas canvas, Size size, double shadowElevation) {
    final double top = rightTopPadding;
    final double bottom = size.height - rightBottomPadding;

    canvas.save();

    // Divider line.
    canvas.drawLine(
      Offset(size.width, top),
      Offset(size.width, bottom),
      Paint()
        ..color = rightShadowDividerColor
        ..strokeWidth = 0.1,
    );

    // Clip area.
    canvas.clipRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(size.width / 2, top, size.width, bottom),
        topRight: rightRadius,
        bottomRight: rightRadius,
      ),
    );

    // Shadow to the right of the right edge. Moved inwards a bit, like the left shadow.
    final double inset = shadowElevation * 2;
    final path = Path()
      ..addRect(Rect.fromLTRB(size.width - inset, top, size.width + 20.0 - inset, bottom));

    canvas.drawShadow(path, rightShadowColor, shadowElevation, true);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShadowPainter oldDelegate) {
    return topRightPadding != oldDelegate.topRightPadding ||
        topLeftPadding != oldDelegate.topLeftPadding ||
        bottomRightPadding != oldDelegate.bottomRightPadding ||
        bottomLeftPadding != oldDelegate.bottomLeftPadding ||
        leftTopPadding != oldDelegate.leftTopPadding ||
        leftBottomPadding != oldDelegate.leftBottomPadding ||
        rightTopPadding != oldDelegate.rightTopPadding ||
        rightBottomPadding != oldDelegate.rightBottomPadding ||
        topRadius != oldDelegate.topRadius ||
        bottomRadius != oldDelegate.bottomRadius ||
        leftRadius != oldDelegate.leftRadius ||
        rightRadius != oldDelegate.rightRadius ||
        elevation != oldDelegate.elevation;
  }

  @override
  bool shouldRebuildSemantics(_ShadowPainter oldDelegate) => false;

  @override
  bool? hitTest(Offset position) => null;

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;
}
