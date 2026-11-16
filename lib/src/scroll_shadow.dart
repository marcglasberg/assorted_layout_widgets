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

/// A widget that adds shadows to the edges of a scrollable, to show that there is more
/// content to see. The shadows appear and disappear as the user scrolls.
///
/// Vertical scrollables get shadows at the top and bottom. Horizontal scrollables get
/// shadows at the left and right. The shadow always shows on the side where there is
/// more content, also when using `reverse` or a right-to-left language.
///
/// Each edge can be customized (visibility, color, padding, etc.), and the parameters
/// can be changed at any time.
///
/// ### Nested scrollables
///
/// The [ScrollShadow] follows only the scrollable closest to it. Scrollables inside
/// that one are ignored. For example, around a vertical list that has horizontal lists
/// inside, only the vertical list gets shadows. And around a `PageView`, the shadows
/// follow the pages, not the lists inside the pages.
///
/// To get shadows for an inner scrollable, wrap it with its own [ScrollShadow]. In
/// general, use one [ScrollShadow] per scrollable. The exception is a scrollable that
/// scrolls in both directions, like a `TableView`, which gets shadows on all four sides.
///
/// ### NestedScrollView
///
/// Around a `NestedScrollView`, the shadows follow only the header, not the inner list.
/// Usually, this is what you want instead:
///
/// - Wrap the inner list (the `body`) with its own [ScrollShadow], showing only the
///   bottom shadow. Its top shadow would be hidden under the header anyway.
///
/// - For the shadow below the header, use the shadow of the `SliverAppBar` itself.
///   It appears when the content starts to go under the header.
///
/// ```dart
/// NestedScrollView(
///   headerSliverBuilder: (context, innerBoxIsScrolled) => [
///     SliverAppBar(
///       pinned: true,
///       expandedHeight: 140,
///       shadowColor: Colors.black,
///       scrolledUnderElevation: 4,
///     ),
///   ],
///   body: ScrollShadow(
///     topShadowVisibility: ShadowVisibility.alwaysOff,
///     child: ListView.builder(
///       itemCount: 50,
///       itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
///     ),
///   ),
/// );
/// ```
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
  /// Defaults to 4.0. Values above 10.0 are treated as 10.0.
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
  /// If there are scrollables inside that scrollable, they are ignored. To get shadows
  /// for them, wrap them with their own [ScrollShadow].
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
  late final _ShadowPainter _shadowPainter = _ShadowPainter(widget);

  /// Whether a check for removed scrollables is scheduled for the end of the frame.
  bool _isSourceCheckScheduled = false;

  @override
  void didUpdateWidget(ScrollShadow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Applies the new parameters (visibility, colors, paddings, etc.), while keeping the
    // current scroll state, so that the shadows don't disappear until the next scroll.
    _shadowPainter.config = widget;
  }

  bool _handleScrollMetricsNotification(ScrollMetricsNotification notification) {
    // Only the closest scrollable descendants drive the shadows. Notifications
    // from scrollables nested inside them (depth > 0) are ignored.
    if (notification.depth == 0) {
      _update(notification.metrics, notification.context);
    }
    return false; // Allow the notification to continue bubbling
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    // Catch updates & overscroll, from the closest scrollable descendants only.
    if (notification.depth == 0 &&
        (notification is ScrollUpdateNotification ||
            notification is OverscrollNotification)) {
      //
      _update(notification.metrics, notification.context);
    }

    return false; // Allow the notification to continue bubbling
  }

  void _update(ScrollMetrics metrics, BuildContext? source) {
    _shadowPainter.update(metrics, source);
    _scheduleSourceCheck();
  }

  /// While some shadows are driven by a scrollable, checks at the end of each frame that
  /// the scrollable is still in the tree. If it was removed (for example, the child was
  /// replaced by a widget that doesn't scroll), its shadows are cleared. This doesn't
  /// schedule frames by itself, so it costs nothing while the app is idle.
  void _scheduleSourceCheck() {
    if (_isSourceCheckScheduled) return;
    _isSourceCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isSourceCheckScheduled = false;
      if (!mounted) return;
      _shadowPainter.clearRemovedSources();
      if (_shadowPainter.hasSources) _scheduleSourceCheck();
    });
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
    _shadowPainter.dispose();
    super.dispose();
  }
}

/// Paints the shadows of a [ScrollShadow]. The same painter is kept for the whole life
/// of the [ScrollShadow] state: when the widget changes, its new parameters are given to
/// the painter through [config], and the scroll state is kept.
class _ShadowPainter extends ChangeNotifier implements CustomPainter {
  _ShadowPainter(this._config);

  static const double _defaultShadowElevation = 4.0;
  static const double _maxShadowElevation = 10.0;

  ScrollShadow _config;

  /// The parameters of the shadows.
  ScrollShadow get config => _config;

  /// Sets the parameters of the shadows. Repaints only if their appearance changed.
  set config(ScrollShadow value) {
    final ScrollShadow oldConfig = _config;
    _config = value;
    if (!_hasSameAppearance(oldConfig, value)) _notify();
  }

  double get elevation =>
      min(_maxShadowElevation, _config.elevation ?? _defaultShadowElevation);

  // How much content there is beyond each physical edge (capped at 100).
  // The top/bottom distances come from vertical scrollables, and the
  // left/right distances come from horizontal scrollables.
  double? _topDistance;
  double? _bottomDistance;
  double? _leftDistance;
  double? _rightDistance;

  // The scrollables (their notification contexts) that set the vertical and the
  // horizontal distances. Used to know when the distances of an axis became stale.
  BuildContext? _verticalSource;
  BuildContext? _horizontalSource;

  bool _mounted = true;

  bool get mounted => _mounted;

  /// Whether some distances are driven by a scrollable which may later be removed.
  bool get hasSources => _verticalSource != null || _horizontalSource != null;

  @override
  void dispose() {
    _mounted = false;
    _verticalSource = null;
    _horizontalSource = null;
    super.dispose();
  }

  void _notify() {
    if (mounted) notifyListeners();
  }

  /// The [ScrollMetrics.axisDirection] already accounts for the scroll axis,
  /// the `reverse` flag, and the text direction (RTL), so it tells us which
  /// physical edge is the scroll "start" (where `pixels` is zero).
  ///
  /// The [source] is the scrollable that sent the metrics. The distances of the other
  /// axis are cleared when they became stale, so that no shadows remain if the
  /// scrollable changes axis (for example, when the child is rebuilt from a vertical
  /// list to a horizontal one). They are kept when they come from another scrollable
  /// which is still there, so that both axes can show shadows at the same time (for
  /// example, in a [TwoDimensionalScrollView], or with a vertical and a horizontal
  /// scrollable side by side).
  void update(ScrollMetrics metrics, BuildContext? source) {
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
        if (_isStale(_horizontalSource, source)) _clearHorizontal();
        _verticalSource = source;
      case Axis.horizontal:
        if (_isStale(_verticalSource, source)) _clearVertical();
        _horizontalSource = source;
    }

    _notify();
  }

  /// The distances of the other axis are stale if they came from this same scrollable
  /// (which then changed its axis), from a scrollable that was removed from the tree
  /// (for example, the child was replaced by a scrollable of the other axis), or from
  /// an unknown scrollable.
  static bool _isStale(BuildContext? otherSource, BuildContext? source) =>
      otherSource == null || otherSource == source || !otherSource.mounted;

  void _clearVertical() {
    _topDistance = null;
    _bottomDistance = null;
    _verticalSource = null;
  }

  void _clearHorizontal() {
    _leftDistance = null;
    _rightDistance = null;
    _horizontalSource = null;
  }

  /// Clears the distances of the scrollables that were removed from the tree.
  void clearRemovedSources() {
    bool changed = false;
    if (_verticalSource != null && !_verticalSource!.mounted) {
      _clearVertical();
      changed = true;
    }
    if (_horizontalSource != null && !_horizontalSource!.mounted) {
      _clearHorizontal();
      changed = true;
    }
    if (changed) _notify();
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintShadowIfNecessary(
      visibility: _config.topShadowVisibility,
      distance: _topDistance,
      oppositeDistance: _bottomDistance,
      draw: (shadowElevation) => _drawTopShadow(canvas, size, shadowElevation),
    );
    _paintShadowIfNecessary(
      visibility: _config.bottomShadowVisibility,
      distance: _bottomDistance,
      oppositeDistance: _topDistance,
      draw: (shadowElevation) => _drawBottomShadow(canvas, size, shadowElevation),
    );
    _paintShadowIfNecessary(
      visibility: _config.leftShadowVisibility,
      distance: _leftDistance,
      oppositeDistance: _rightDistance,
      draw: (shadowElevation) => _drawLeftShadow(canvas, size, shadowElevation),
    );
    _paintShadowIfNecessary(
      visibility: _config.rightShadowVisibility,
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
    if (_config.ifHidesShadowForNegativeScroll &&
        oppositeDistance != null &&
        oppositeDistance < 0) {
      return;
    }
    if ((distance ?? 0) > 0) {
      draw(min(elevation, distance! / 5));
    }
  }

  void _drawTopShadow(Canvas canvas, Size size, double shadowElevation) {
    final double left = _config.topLeftPadding;
    final double right = size.width - _config.topRightPadding;

    canvas.save();

    // Divider line.
    canvas.drawLine(
      Offset(left, 0),
      Offset(right, 0),
      Paint()
        ..color = _config.topShadowDividerColor
        ..strokeWidth = 0.1,
    );

    // Clip area.
    canvas.clipRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(left, 0, right, size.height / 2),
        topLeft: _config.topRadius,
        topRight: _config.topRadius,
      ),
    );

    // Shadow above top edge.
    final path = Path()
      ..moveTo(left, -20.0)
      ..lineTo(right, -20.0)
      ..lineTo(right, 0.0)
      ..lineTo(left, 0.0)
      ..close();

    canvas.drawShadow(path, _config.topShadowColor, shadowElevation, true);
    canvas.restore();
  }

  void _drawBottomShadow(Canvas canvas, Size size, double shadowElevation) {
    final double left = _config.bottomLeftPadding;
    final double right = size.width - _config.bottomRightPadding;

    canvas.save();

    // Divider line.
    canvas.drawLine(
      Offset(left, size.height),
      Offset(right, size.height),
      Paint()
        ..color = _config.bottomShadowDividerColor
        ..strokeWidth = 0.1,
    );

    // Clip area.
    canvas.clipRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(left, size.height / 2, right, size.height),
        bottomLeft: _config.bottomRadius,
        bottomRight: _config.bottomRadius,
      ),
    );

    // Shadow below bottom edge.
    final path = Path()
      ..moveTo(left, size.height + 20.0 - shadowElevation * 2)
      ..lineTo(left, size.height - shadowElevation * 2)
      ..lineTo(right, size.height - shadowElevation * 2)
      ..lineTo(right, size.height + 20.0 - shadowElevation * 2)
      ..close();

    canvas.drawShadow(path, _config.bottomShadowColor, shadowElevation, true);
    canvas.restore();
  }

  void _drawLeftShadow(Canvas canvas, Size size, double shadowElevation) {
    final double top = _config.leftTopPadding;
    final double bottom = size.height - _config.leftBottomPadding;

    canvas.save();

    // Divider line.
    canvas.drawLine(
      Offset(0, top),
      Offset(0, bottom),
      Paint()
        ..color = _config.leftShadowDividerColor
        ..strokeWidth = 0.1,
    );

    // Clip area.
    canvas.clipRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(0, top, size.width / 2, bottom),
        topLeft: _config.leftRadius,
        bottomLeft: _config.leftRadius,
      ),
    );

    // Shadow to the left of the left edge. The light source is above, so the shadow
    // doesn't spread much sideways. Like the bottom shadow, the path is moved
    // inwards a bit, so that the shadow is visible inside the clip area.
    final double inset = shadowElevation * 2;
    final path = Path()..addRect(Rect.fromLTRB(-20.0 + inset, top, inset, bottom));

    canvas.drawShadow(path, _config.leftShadowColor, shadowElevation, true);
    canvas.restore();
  }

  void _drawRightShadow(Canvas canvas, Size size, double shadowElevation) {
    final double top = _config.rightTopPadding;
    final double bottom = size.height - _config.rightBottomPadding;

    canvas.save();

    // Divider line.
    canvas.drawLine(
      Offset(size.width, top),
      Offset(size.width, bottom),
      Paint()
        ..color = _config.rightShadowDividerColor
        ..strokeWidth = 0.1,
    );

    // Clip area.
    canvas.clipRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(size.width / 2, top, size.width, bottom),
        topRight: _config.rightRadius,
        bottomRight: _config.rightRadius,
      ),
    );

    // Shadow to the right of the right edge. Moved inwards a bit, like the left shadow.
    final double inset = shadowElevation * 2;
    final path = Path()
      ..addRect(Rect.fromLTRB(size.width - inset, top, size.width + 20.0 - inset, bottom));

    canvas.drawShadow(path, _config.rightShadowColor, shadowElevation, true);
    canvas.restore();
  }

  /// Whether [a] and [b] paint the same shadows (the child and the key don't matter).
  static bool _hasSameAppearance(ScrollShadow a, ScrollShadow b) =>
      a.topRightPadding == b.topRightPadding &&
      a.topLeftPadding == b.topLeftPadding &&
      a.topRadius == b.topRadius &&
      a.bottomRightPadding == b.bottomRightPadding &&
      a.bottomLeftPadding == b.bottomLeftPadding &&
      a.bottomRadius == b.bottomRadius &&
      a.leftTopPadding == b.leftTopPadding &&
      a.leftBottomPadding == b.leftBottomPadding &&
      a.leftRadius == b.leftRadius &&
      a.rightTopPadding == b.rightTopPadding &&
      a.rightBottomPadding == b.rightBottomPadding &&
      a.rightRadius == b.rightRadius &&
      a.topShadowVisibility == b.topShadowVisibility &&
      a.bottomShadowVisibility == b.bottomShadowVisibility &&
      a.leftShadowVisibility == b.leftShadowVisibility &&
      a.rightShadowVisibility == b.rightShadowVisibility &&
      a.topShadowColor == b.topShadowColor &&
      a.bottomShadowColor == b.bottomShadowColor &&
      a.leftShadowColor == b.leftShadowColor &&
      a.rightShadowColor == b.rightShadowColor &&
      a.topShadowDividerColor == b.topShadowDividerColor &&
      a.bottomShadowDividerColor == b.bottomShadowDividerColor &&
      a.leftShadowDividerColor == b.leftShadowDividerColor &&
      a.rightShadowDividerColor == b.rightShadowDividerColor &&
      a.elevation == b.elevation &&
      a.ifHidesShadowForNegativeScroll == b.ifHidesShadowForNegativeScroll;

  /// The [ScrollShadow] state always keeps the same painter, and notifies it when
  /// something changes. This is only called if some other painter instance is given
  /// to the same [CustomPaint], so it conservatively repaints.
  @override
  bool shouldRepaint(_ShadowPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_ShadowPainter oldDelegate) => false;

  @override
  bool? hitTest(Offset position) => null;

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;
}
