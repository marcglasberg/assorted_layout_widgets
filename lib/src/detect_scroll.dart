import "package:flutter/material.dart";

/// The [DetectScroll] can detect if the content of a Scrollable is larger than the
/// Scrollable itself, which means that the content can be scrolled, and that a scrollbar
/// is likely visible. It can also tell you the probable width of that scrollbar.
///
/// This is useful for positioning widgets relative to the scrollbar, so that the
/// scrollbar doesn't overlap them. This can be important when the scrollbar is
/// permanently visible, usually on the Web and desktop.
///
/// Note that [DetectScroll] will only detect the scrolling of its **closest** scrollable
/// descendant (a scrollable is a `SingleChildScrollView`, `ListView`, `GridView` etc).
/// Usually, you'd wrap the scrollable you care about directly with a [DetectScroll].
/// For example:
///
/// ```dart
/// DetectScroll(
///  child: SingleChildScrollView(
///     child: Column( ...
///  ...
/// );
/// ```
///
/// To get the current scroll state and the scrollbar width, descendants can call:
/// ```dart
/// bool canScroll = DetectScroll.of(context).canScroll;
/// double width = DetectScroll.of(context).scrollbarWidth;
/// ```
///
/// For example, suppose you want to add a help button to the top-right corner of a
/// scrollable, and account for the scrollbar width only if it's visible:
///
/// ```dart
/// bool canScroll = DetectScroll.of(context).canScroll;
/// double width = DetectScroll.of(context).scrollbarWidth;
///
/// return Stack(
///   children: [
///      child,
///      Positioned(
///         right: canScroll ? width : 0,
///         top: 0,
///         child: HelpButton(),
///      ),
///   ],
/// );
/// ```
///
/// Another alternative is using the optional [onChange] callback:
///
/// ```
/// DetectScroll(
///    onChange: ({
///       required bool canScroll,
///       required double width,
///    }) {
///       // Do something.
///    }
///    child: ...
/// ),
/// ```
///
/// # In more detail:
///
/// The [DetectScroll] actually only detects if its subtree can scroll, in other words,
/// that its closest descendant Scrollable has enough content so that not all of it
/// fits the available visible space, and then informs its descendants about this fact.
///
/// Note this doesn't mean there is actually a scrollbar visible, but only that the
/// content can be scrolled. For this reason, you should use it to detect scrollbars
/// only when a scrollbar is always shown when the content doesn't fit (like on the web
/// or desktop), or when you're using a custom scrollbar that is always visible.
///
/// Regarding the width of the scrollbar provided by [DetectScroll], this information
/// is calculated from the current **theme** at the [DetectScroll]. For this reason,
/// if you use this width, make sure the scrollbar is actually using this same theme.
///
class DetectScroll extends StatefulWidget {
  final Widget child;

  final void Function({
    required bool canScroll,
    required double scrollbarWidth,
  })? onChange;

  /// If true, the [DetectScroll] will cancel the [ScrollMetricsNotification] bubbling.
  /// If false, the notification  will be allowed to continue to be dispatched to further
  /// ancestors. The default is false.
  final bool cancelNotificationBubbling;

  /// The [DetectScroll] can detect if the content of a Scrollable is larger than the
  /// Scrollable itself, which means that the content can be scrolled, and that a scrollbar
  /// is likely visible. It can also tell you the probable width of that scrollbar.
  ///
  /// This is useful for positioning widgets relative to the scrollbar, so that the
  /// scrollbar doesn't overlap them. This can be important when the scrollbar is
  /// permanently visible, usually on the Web and desktop.
  ///
  /// Note that [DetectScroll] will only detect the scrolling of its **closest** scrollable
  /// descendant (a scrollable is a `SingleChildScrollView`, `ListView`, `GridView` etc).
  /// Usually, you'd wrap the scrollable you care about directly with a [DetectScroll].
  /// For example:
  ///
  /// ```dart
  /// DetectScroll(
  ///  child: SingleChildScrollView(
  ///     child: Column( ...
  ///  ...
  /// );
  /// ```
  ///
  /// To get the current scroll state and the scrollbar width, descendants can call:
  /// ```dart
  /// bool canScroll = DetectScroll.of(context).canScroll;
  /// double width = DetectScroll.of(context).scrollbarWidth;
  /// ```
  ///
  /// For example, suppose you want to add a help button to the top-right corner of a
  /// scrollable, and account for the scrollbar width only if it's visible:
  ///
  /// ```dart
  /// bool canScroll = DetectScroll.of(context).canScroll;
  /// double width = DetectScroll.of(context).scrollbarWidth;
  ///
  /// return Stack(
  ///   children: [
  ///      child,
  ///      Positioned(
  ///         right: canScroll ? width : 0,
  ///         top: 0,
  ///         child: HelpButton(),
  ///      ),
  ///   ],
  /// );
  /// ```
  ///
  /// Another alternative is using the [onChange] callback:
  ///
  /// ```
  /// DetectScroll(
  ///    onChange: ({
  ///       required bool canScroll,
  ///       required double width,
  ///    }) {
  ///       // Do something.
  ///    }
  ///    child: ...
  /// ),
  /// ```
  ///
  /// # In more detail:
  ///
  /// The [DetectScroll] actually only detects if its subtree can scroll, in other words,
  /// that its closest descendant Scrollable has enough content so that not all of it
  /// fits the available visible space, and then informs its descendants about this fact.
  ///
  /// Note this doesn't mean there is actually a scrollbar visible, but only that the
  /// content can be scrolled. For this reason, you should use it to detect scrollbars
  /// only when a scrollbar is always shown when the content doesn't fit (like on the web
  /// or desktop), or when you're using a custom scrollbar that is always visible.
  ///
  /// Regarding the width of the scrollbar provided by [DetectScroll], this information
  /// is calculated from the current **theme** at the [DetectScroll]. For this reason,
  /// if you use this width, make sure the scrollbar is actually using this same theme.
  ///
  const DetectScroll({
    Key? key,
    required this.child,
    this.onChange,
    this.cancelNotificationBubbling = false,
  }) : super(key: key);

  /// Allows descendants to get the scroll state.
  /// Example:
  /// ```
  /// bool canScroll = DetectScroll.of(context).canScroll;
  /// double width = DetectScroll.of(context).scrollbarWidth;
  /// ```
  static _DetectScrollInherited of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_DetectScrollInherited>();

    assert(inherited != null, 'No DetectScroll found in context');
    return inherited!;
  }

  @override
  State<DetectScroll> createState() => _DetectScrollState();
}

class _DetectScrollState extends State<DetectScroll> {
  late ValueNotifier<bool> canScrollNotifier;

  @override
  void initState() {
    super.initState();
    canScrollNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    canScrollNotifier.dispose();
    super.dispose();
  }

  /// If you're using the Material Scrollbar (or a theme that sets its thickness),
  /// this reads it from the current ScrollbarTheme. If you're NOT using Material,
  /// or if thickness is not set, return the default value (8.0 here).
  double get _materialScrollbarWidth {
    final scrollbarTheme = ScrollbarTheme.of(context);

    bool thumbVisibility =
        scrollbarTheme.thumbVisibility?.resolve(<WidgetState>{}) ?? true;

    bool trackVisibility =
        scrollbarTheme.trackVisibility?.resolve(<WidgetState>{}) ?? false;

    double thickness = scrollbarTheme.thickness?.resolve(<WidgetState>{}) ?? 8.0;
    double crossAxisMargin = scrollbarTheme.crossAxisMargin ?? 0.0;

    return thumbVisibility
        ? thickness + crossAxisMargin + (trackVisibility ? crossAxisMargin : 0)
        : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: _onNotification,
      child: ValueListenableBuilder<bool>(
        valueListenable: canScrollNotifier,
        builder: (_, _canScroll, __) {
          return _DetectScrollInherited(
            canScroll: _canScroll,
            scrollbarWidth: _materialScrollbarWidth,
            child: widget.child,
          );
        },
      ),
    );
  }

  bool _onNotification(ScrollMetricsNotification notification) {
    final metrics = notification.metrics;

    canScrollNotifier.value = metrics.hasContentDimensions && metrics.maxScrollExtent > 0;

    widget.onChange?.call(
      canScroll: canScrollNotifier.value,
      scrollbarWidth: _materialScrollbarWidth,
    );

    // If true, will cancel the notification bubbling. Default is false.
    return widget.cancelNotificationBubbling;
  }
}

class _DetectScrollInherited extends InheritedWidget {
  //

  /// Is true whe the content of the detected Scrollable is larger than the
  /// Scrollable itself, which means that the content can be scrolled, and that a
  /// scrollbar is likely visible (if one was configured to appear under these
  /// circumstances).
  final bool canScroll;

  /// The width of the scrollbar is calculated from the current **theme** at
  /// the [DetectScroll]. For this reason, if you use this width, make sure that the
  /// scrollbar is actually using this same theme.
  final double scrollbarWidth;

  const _DetectScrollInherited({
    Key? key,
    required Widget child,
    required this.canScroll,
    required this.scrollbarWidth,
  }) : super(key: key, child: child);

  @Deprecated("Use `canScroll` instead. The old `isScrolled` will be removed very soon.")
  bool get isScrolled => canScroll;

  @override
  bool updateShouldNotify(_DetectScrollInherited oldWidget) {
    return oldWidget.canScroll != canScroll || oldWidget.scrollbarWidth != scrollbarWidth;
  }
}
