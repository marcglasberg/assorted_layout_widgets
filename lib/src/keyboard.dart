import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';

/// [KeyboardSwitch] renders different content depending on whether the system keyboard
/// is open or closed.
///
/// IMPORTANT: For this widget to work it requires a [Keyboard] ancestor. if you don't
/// have a [Keyboard] ancestor, it will throw an assertion error.
///
/// There are three ways to use it:
///
/// 1) The default constructor takes optional [open] and [closed] widgets. The [open]
///    widget is shown when the keyboard is open, and the [closed] widget when it is
///    closed. Both are optional, and a missing slot renders nothing:
///
///    ```
///    KeyboardSwitch(
///      open: Text('Keyboard is open'),
///      closed: Text('Keyboard is closed'),
///    )
///    ```
///
///    It also takes optional [opening] and [closing] widgets, shown while the keyboard
///    is moving up or down. These take precedence over [open] and [closed]. When they
///    are missing, [open] or [closed] is shown instead, as usual:
///
///    ```
///    KeyboardSwitch(
///      open: Text('Keyboard is open'),
///      closed: Text('Keyboard is closed'),
///      opening: Text('Keyboard is opening'),
///      closing: Text('Keyboard is closing'),
///    )
///    ```
///
/// 2) The [KeyboardSwitch.builder] constructor takes a [builder] callback that receives
///    the current `isOpen` state, so you can build any widget you want based on it:
///
///    ```
///    KeyboardSwitch.builder(
///      (context, isOpen) => Icon(isOpen ? Icons.keyboard : Icons.keyboard_hide),
///    )
///    ```
///
/// 3) The [KeyboardSwitch.fractionBuilder] constructor takes a [fractionBuilder]
///    callback that receives how much the keyboard is open, from `0` (closed) to `1`
///    (fully open), and whether it's currently opening or closing. See
///    [Keyboard.openFraction]. It rebuilds on every frame while the keyboard moves, so
///    you can animate your widgets together with the keyboard:
///
///    ```
///    KeyboardSwitch.fractionBuilder(
///      (context, fraction, isOpening, isClosing) =>
///          Opacity(opacity: 1 - fraction, child: Text('Hides as the keyboard opens')),
///    )
///    ```
///
class KeyboardSwitch extends StatelessWidget {
  //
  final Widget? open;
  final Widget? closed;
  final Widget? opening;
  final Widget? closing;
  final Widget Function(BuildContext context, bool isOpen)? builder;
  final Widget Function(
    BuildContext context,
    double fraction,
    bool isOpening,
    bool isClosing,
  )?
  fractionBuilder;

  /// Renders [open] when the keyboard is open, and [closed] when it is closed. While
  /// the keyboard is moving, renders [opening] or [closing] instead, if provided. All
  /// are optional, and a missing slot renders nothing.
  const KeyboardSwitch({
    super.key,
    this.open,
    this.closed,
    this.opening,
    this.closing,
  }) : builder = null,
       fractionBuilder = null;

  /// Renders the widget returned by [builder], which receives the current `isOpen`
  /// state of the keyboard.
  const KeyboardSwitch.builder(this.builder, {super.key})
    : open = null,
      closed = null,
      opening = null,
      closing = null,
      fractionBuilder = null;

  /// Renders the widget returned by [fractionBuilder], which receives how much the
  /// keyboard is open, from `0` (closed) to `1` (fully open), and whether it's
  /// currently opening or closing. Rebuilds on every frame while the keyboard moves.
  const KeyboardSwitch.fractionBuilder(this.fractionBuilder, {super.key})
    : open = null,
      closed = null,
      opening = null,
      closing = null,
      builder = null;

  @override
  Widget build(BuildContext context) {
    //
    final fractionBuilder = this.fractionBuilder;
    if (fractionBuilder != null) {
      return fractionBuilder(
        context,
        Keyboard.openFraction(context),
        Keyboard.isOpening(context),
        Keyboard.isClosing(context),
      );
    }

    final isOpen = Keyboard.isOpen(context);

    final builder = this.builder;
    if (builder != null) {
      return builder(context, isOpen);
    }

    final opening = this.opening;
    if (opening != null && Keyboard.isOpening(context)) return opening;

    final closing = this.closing;
    if (closing != null && Keyboard.isClosing(context)) return closing;

    return isOpen ? open ?? const SizedBox.shrink() : closed ?? const SizedBox.shrink();
  }
}

/// Widget [Keyboard] must be placed near the top of the widget tree, where it has the
/// same size as the screen, for example, in `MaterialApp.builder`, above any [Scaffold].
/// For example:
///
/// ```
/// MaterialApp(
///   builder: (BuildContext context, Widget? child) =>
///     Keyboard(
///       iOsCloseOnTap: true,
///       iOsCloseOnSwipe: true,
///       iOsRemoveFocusOnTap: true,
///       child: ...,
///     ),
///   ),
/// ```
///
/// The constructor parameters are:
///
///   - Pass [iOsCloseOnTap] true to close the keyboard when the user taps an empty
///     area of the screen, on the iOS.
///   - Pass [iOsCloseOnSwipe] true to close the keyboard when the user swipes down
///     from just above the keyboard edge, on the iOS.
///   - [iOsRemoveFocusOnTap] controls whether focus is also removed from any focused
///     element when the keyboard is dismissed by a tap, on the iOS.
///   - [iOsRemoveFocusOnSwipe] controls whether focus is also removed from any focused
///     element when the keyboard is dismissed by a swipe, on the iOS.
///   - Pass [androidCloseOnTap] true to close the keyboard when the user taps an empty
///     area of the screen, on the Android.
///   - Pass [androidCloseOnSwipe] true to close the keyboard when the user swipes down
///     from just above the keyboard edge, on the Android.
///   - [androidRemoveFocusOnTap] controls whether focus is also removed from any focused
///     element when the keyboard is dismissed by a tap, on the Android.
///   - [androidRemoveFocusOnSwipe] controls whether focus is also removed from any focused
///     element when the keyboard is dismissed by a swipe, on the Android.
///
/// The default is `false` for all the above parameters.
///
///   - [closeOnTapOnlyIfKeyboardIsOpen] (default `true`) makes the close-on-tap behavior
///     ([iOsCloseOnTap] / [androidCloseOnTap]) act only when the system keyboard is
///     actually open. When the keyboard is closed, taps do nothing: the keyboard is not
///     asked to hide, and focus is not removed. Pass `false` to make taps remove focus
///     even when the keyboard is closed.
///
///   - [percentIsOpen] and [percentIsClosed] control at which point of the keyboard
///     animation [Keyboard.isOpen] and [Keyboard.isClosed] change. See their docs.
///     The default is `0` for both, meaning the keyboard is considered open as soon as
///     it starts opening, and closed only when it closes completely.
///
/// ## Recommendation
///
/// On the iOS, it's common for the keyboard to auto-dismiss when the user taps outside
/// it or swipes down from just above the keyboard edge. Usually, when the keyboard is
/// dismissed by a tap, the focused element also loses focus, but when it's dismissed by
/// a swipe, the focused element retains focus (and may re-open the keyboard if it's
/// tapped).
///
/// On the Android, the default is that the keyboard only closes when the user taps the
/// back button or executes the back gesture.
///
/// For these reasons, the recommended configuration is:
///
/// ```dart
/// Keyboard(
///   iOsCloseOnTap: true,
///   iOsCloseOnSwipe: true,
///   iOsRemoveFocusOnTap: true,
///   child: ...
/// )
/// ```
///
/// Note that, with the default `closeOnTapOnlyIfKeyboardIsOpen: true`, taps on empty
/// areas of the screen only remove focus while the system keyboard is open. This is
/// important if your app uses a custom in-app keyboard (a custom [TextInputControl] that
/// suppresses the platform keyboard). Otherwise, while the system keyboard is closed,
/// taps would still remove focus from the focused text field, hiding your in-app
/// keyboard. If you want taps to remove focus even when the keyboard is closed, pass
/// `closeOnTapOnlyIfKeyboardIsOpen: false`.
///
/// ## Other features
///
/// - [Keyboard.isOpen] and [Keyboard.isClosed] can be used to check whether the keyboard
///   is currently open or not. Example usage:
///
///   ```
///   bool isKeyboardOpen = Keyboard.isOpen(context);
///   ```
///
/// - [Keyboard.isOpening] and [Keyboard.isClosing] can be used to check whether the
///   keyboard is currently animating up or down. Example usage:
///
///   ```
///   bool isKeyboardOpening = Keyboard.isOpening(context);
///   ```
///
/// - Use [Keyboard.open] and [Keyboard.close] to
///   programmatically open and close the system keyboard. Example usage:
///
///   ```
///   // Forces the keyboard to open.
///   Keyboard.open();
///
///   // Forces the keyboard to close, and removes focus from any focused element.
///   Keyboard.close();
///
///   // Forces the keyboard to close. Keeps focus on any focused element,
///   so the keyboard may re-open if that element is tapped again.
///   Keyboard.close(removeFocus: false);
///   ```
///
/// See also:
/// - [KeyboardSwitch] for a widget that conditionally renders its child based on the
///   keyboard open/close state.
///
class Keyboard extends StatefulWidget {
  const Keyboard({
    super.key,
    required this.child,
    this.iOsCloseOnTap = false,
    this.iOsCloseOnSwipe = false,
    this.iOsRemoveFocusOnTap = false,
    this.iOsRemoveFocusOnSwipe = false,
    this.androidCloseOnTap = false,
    this.androidCloseOnSwipe = false,
    this.androidRemoveFocusOnTap = false,
    this.androidRemoveFocusOnSwipe = false,
    this.closeOnTapOnlyIfKeyboardIsOpen = true,
    this.reserveKeyboardSpaceOnDesktop = false,
    this.percentIsOpen = 0,
    this.percentIsClosed = 0,
  }) : assert(percentIsOpen >= 0 && percentIsOpen <= 1),
       assert(percentIsClosed >= 0 && percentIsClosed <= 1);

  final Widget child;
  final bool iOsCloseOnTap;
  final bool iOsCloseOnSwipe;
  final bool iOsRemoveFocusOnTap;
  final bool iOsRemoveFocusOnSwipe;
  final bool androidCloseOnTap;
  final bool androidCloseOnSwipe;
  final bool androidRemoveFocusOnTap;
  final bool androidRemoveFocusOnSwipe;

  /// This param is `true` by default, making the close-on-tap behavior ([iOsCloseOnTap]
  /// / [androidCloseOnTap]) act only when the system keyboard is actually open. When the
  /// keyboard is closed, taps do nothing: the keyboard is not asked to hide, and focus
  /// is not removed. Pass `false` to make taps remove focus even when the keyboard is
  /// closed. Note: If your app uses a custom in-app keyboard (a custom
  /// [TextInputControl] that suppresses the platform keyboard), keep this `true`, or
  /// taps would remove focus from the focused text field, hiding your in-app keyboard.
  final bool closeOnTapOnlyIfKeyboardIsOpen;

  /// This param is `false` by default. Sometimes, it's a good idea to run your app
  /// on desktop (Windows, macOS or Linux) to help develop mobile apps, since running on
  /// desktop is faster than running on a mobile device or emulator. However, when the
  /// app runs on desktop, the system keyboard never opens, so you cannot test how your
  /// app behaves when the keyboard opens and closes. To fix this, set this param to
  /// `true` and the [Keyboard] widget will install a fake keyboard (a
  /// [TextInputControl]) that shows a 275px area resembling a keyboard at the bottom of
  /// this widget whenever the mobile keyboard would open. That area slides in and out
  /// in 285ms, like a real keyboard.
  ///
  /// Like a real keyboard, the fake keyboard covers the bottom of the app, and its
  /// height is reported as the bottom of `MediaQuery.viewInsetsOf(context)`, so that a
  /// [Scaffold] resizes its body to stay above it. [Keyboard.isOpen],
  /// [Keyboard.isClosed], [Keyboard.isOpening], [Keyboard.isClosing] and
  /// [KeyboardSwitch] treat it as the keyboard. Note `View.of(context).viewInsets` is
  /// NOT affected, so code that reads the view directly won't see the fake keyboard.
  ///
  /// The physical keyboard keeps working.
  final bool reserveKeyboardSpaceOnDesktop;

  /// Controls when [Keyboard.isOpen] becomes `true` while the keyboard is opening,
  /// as a fraction (from `0` to `1`) of the height of the fully open keyboard.
  ///
  /// - `0` (the default) means the keyboard is considered open as soon as it starts
  ///   opening.
  /// - `0.5` means it's considered open when it reaches half its height.
  /// - `1` means it's considered open only when it's fully open.
  ///
  /// This value is only used while the keyboard is opening. When it's closing, see
  /// [percentIsClosed]. When the keyboard stops moving at any height above zero, it's
  /// always considered open.
  ///
  /// Note: The height of the fully open keyboard is only known after it opens once.
  /// Until then, it's estimated (336 pixels on iOS, 300 on other platforms, and 275
  /// for the fake keyboard of [reserveKeyboardSpaceOnDesktop]). So, the very first
  /// time the keyboard opens, it may be considered open a bit earlier or later than it
  /// should. The same happens the first time it opens after the device rotates.
  ///
  final double percentIsOpen;

  /// Controls when [Keyboard.isClosed] becomes `true` while the keyboard is closing,
  /// as a fraction (from `0` to `1`) of the height of the fully open keyboard.
  ///
  /// - `0` (the default) means the keyboard is considered closed only when it closes
  ///   completely.
  /// - `0.5` means it's considered closed when it goes below half its height.
  /// - `1` means it's considered closed as soon as it starts closing.
  ///
  /// This value is only used while the keyboard is closing. When it's opening, see
  /// [percentIsOpen].
  ///
  /// Note: When the keyboard gets shorter without closing (for example, when the user
  /// switches from the emoji keyboard to the text keyboard), it's not possible to know
  /// right away that it's not closing. For this reason, if you set this value above
  /// zero, the keyboard may be considered closed for a brief moment (about 100ms), until
  /// it stops moving and is considered open again.
  ///
  final double percentIsClosed;

  /// Closes only the system keyboard and removes focus from any element that has focus.
  static void close({bool removeFocus = true}) {
    if (removeFocus) FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _FakeDesktopKeyboard.active?.hide();
  }

  static void open() {
    SystemChannels.textInput.invokeMethod('TextInput.show');
    _FakeDesktopKeyboard.active?.showIfAttached();
  }

  /// Whether the keyboard is currently open. Requires a [Keyboard] ancestor.
  /// This is always the opposite of [isClosed]. See [Keyboard.percentIsOpen] to
  /// control at which point of the opening animation it becomes `true`.
  ///
  /// Example usage:
  /// ```
  /// bool isOpen = Keyboard.isOpen(context);
  /// ```
  ///
  static bool isOpen(BuildContext context) => _scope(context, 'isOpen').isOpen;

  /// Whether the keyboard is currently closed. Requires a [Keyboard] ancestor.
  /// This is always the opposite of [isOpen]. See [Keyboard.percentIsClosed] to
  /// control at which point of the closing animation it becomes `true`.
  ///
  /// Example usage:
  /// ```
  /// bool isClosed = Keyboard.isClosed(context);
  /// ```
  ///
  static bool isClosed(BuildContext context) => !_scope(context, 'isClosed').isOpen;

  /// Whether the keyboard is currently opening, meaning it's moving up and hasn't yet
  /// reached its full height. Requires a [Keyboard] ancestor.
  ///
  /// Note this is independent of [isOpen]. For example, with the default
  /// [Keyboard.percentIsOpen] of `0`, both are `true` while the keyboard is opening.
  ///
  /// On platforms that don't animate the keyboard (like Android versions before 11),
  /// the keyboard opens instantly, and this is never `true`.
  ///
  /// Example usage:
  /// ```
  /// bool isOpening = Keyboard.isOpening(context);
  /// ```
  ///
  static bool isOpening(BuildContext context) => _scope(context, 'isOpening').isOpening;

  /// Whether the keyboard is currently closing, meaning it's moving down and hasn't yet
  /// closed completely. Requires a [Keyboard] ancestor.
  ///
  /// Note this is independent of [isClosed]. For example, with the default
  /// [Keyboard.percentIsClosed] of `0`, [isClosed] is `false` while the keyboard is
  /// closing, and becomes `true` only when it closes completely.
  ///
  /// On platforms that don't animate the keyboard (like Android versions before 11),
  /// the keyboard closes instantly, and this is never `true`.
  ///
  /// Example usage:
  /// ```
  /// bool isClosing = Keyboard.isClosing(context);
  /// ```
  ///
  static bool isClosing(BuildContext context) => _scope(context, 'isClosing').isClosing;

  /// How much the keyboard is open, from `0` (closed) to `1` (fully open), as a fraction
  /// of the height of the fully open keyboard. Requires a [Keyboard] ancestor.
  ///
  /// Widgets that call this rebuild on every frame while the keyboard moves (but not
  /// while it stays still), so you can animate them together with the keyboard. See
  /// also [KeyboardSwitch.fractionBuilder].
  ///
  /// Note: The height of the fully open keyboard is only known after it opens once.
  /// Until then, it's estimated (see [Keyboard.percentIsOpen]). If the estimate is too
  /// small, the fraction reaches `1` early. If it's too large, the fraction jumps to `1`
  /// when the keyboard stops moving.
  ///
  /// Example usage:
  /// ```
  /// double fraction = Keyboard.openFraction(context);
  /// ```
  ///
  static double openFraction(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_KeyboardFractionScope>();
    assert(
      scope != null,
      'Keyboard.openFraction() called without a Keyboard ancestor. '
      'Wrap the app (above any Scaffold) in a Keyboard widget.',
    );
    return scope!.notifier!.value;
  }

  static _KeyboardScope _scope(BuildContext context, String methodName) {
    final scope = context.dependOnInheritedWidgetOfExactType<_KeyboardScope>();
    assert(
      scope != null,
      'Keyboard.$methodName() called without a Keyboard ancestor. '
      'Wrap the app (above any Scaffold) in a Keyboard widget.',
    );
    return scope!;
  }

  @override
  State<Keyboard> createState() => _KeyboardState();
}

class _KeyboardState extends State<Keyboard>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  //
  /// The height of the fully open keyboard is only known after it opens once. Until
  /// then, it's estimated as this.
  double get _estimatedMaxHeight {
    if (_fakeController != null) return _fakeKeyboardHeight;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) return 336;
    return 300;
  }

  /// When the keyboard height doesn't change for this long, the keyboard is considered
  /// to have stopped moving.
  static const Duration _settleDuration = Duration(milliseconds: 100);

  /// The current keyboard height, in logical pixels.
  double _height = 0;

  /// The height of the fully open keyboard, in logical pixels. It's updated whenever
  /// the keyboard grows above it, and whenever the keyboard stops moving while open.
  late double _maxHeight;

  /// How much the keyboard is open, from 0 to 1. Kept apart from the other state, since
  /// it changes on every frame while the keyboard moves.
  final ValueNotifier<double> _openFraction = ValueNotifier<double>(0);

  /// The view width when the keyboard state was last updated. When it changes (for
  /// example, when the device rotates), the height of the fully open keyboard may
  /// change too, so it must be measured again. Null before the first read.
  double? _viewWidth;

  bool _isOpen = false;
  bool _isOpening = false;
  bool _isClosing = false;

  /// Fires when the keyboard stops moving (its height doesn't change for a while).
  Timer? _settleTimer;

  /// Only non-null when [Keyboard.reserveKeyboardSpaceOnDesktop] is true on desktop.
  _FakeDesktopKeyboard? _fakeKeyboard;

  /// Animates the fake keyboard from closed (0) to open (1). Non-null together with
  /// [_fakeKeyboard].
  AnimationController? _fakeController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateFakeKeyboard();
    _maxHeight = _estimatedMaxHeight;
  }

  @override
  void didUpdateWidget(Keyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reserveKeyboardSpaceOnDesktop != oldWidget.reserveKeyboardSpaceOnDesktop) {
      _updateFakeKeyboard();
      _maxHeight = _estimatedMaxHeight;
      _updateKeyboardState();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // The first read. The keyboard may already be open, but it's not moving.
    if (_viewWidth == null) {
      _viewWidth = View.of(context).physicalSize.width;
      _height = _readHeight();
      if (_height > _maxHeight) _maxHeight = _height;
      _isOpen = _height > 0;
      _updateOpenFraction();
    } //
    else {
      _updateKeyboardState();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settleTimer?.cancel();
    _uninstallFakeKeyboard();
    _openFraction.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _onKeyboardMoved();
  }

  void _onKeyboardMoved() {
    if (!mounted) return;
    if (_updateKeyboardState()) setState(() {});
  }

  /// The current keyboard height (real or fake), in logical pixels.
  double _readHeight() {
    final view = View.of(context);
    final double height = view.viewInsets.bottom / view.devicePixelRatio;
    final fakeController = _fakeController;
    if (fakeController == null) return height;
    return math.max(height, fakeController.value * _fakeKeyboardHeight);
  }

  /// Reads the current keyboard height and updates the open/opening/closing state.
  /// Returns true if the state changed.
  ///
  /// While opening, the keyboard is considered open when it reaches
  /// [Keyboard.percentIsOpen] of its max height. While closing, it's considered closed
  /// when it reaches [Keyboard.percentIsClosed] of its max height. Since each
  /// percentage only applies in its own direction, open and closed never overlap.
  bool _updateKeyboardState() {
    final bool wasOpen = _isOpen;
    final bool wasOpening = _isOpening;
    final bool wasClosing = _isClosing;

    final double viewWidth = View.of(context).physicalSize.width;
    if (viewWidth != _viewWidth) {
      _viewWidth = viewWidth;
      _maxHeight = _estimatedMaxHeight;
    }

    final double previousHeight = _height;
    final double height = _readHeight();
    _height = height;

    // If the keyboard is above the max height, it's still growing, and the max is not
    // known yet. If it's exactly at the max height, it's fully open.
    final bool isAtMaxHeight = (height - _maxHeight).abs() < 0.01;
    if (height > _maxHeight) _maxHeight = height;

    if (height <= 0) {
      _settleTimer?.cancel();
      _isOpen = false;
      _isOpening = false;
      _isClosing = false;
    } //
    else if (height > previousHeight) {
      _isOpening = !isAtMaxHeight;
      _isClosing = false;
      if (height >= widget.percentIsOpen * _maxHeight) _isOpen = true;
      _restartSettleTimer();
    } //
    else if (height < previousHeight) {
      _isOpening = false;
      _isClosing = true;
      if (height <= widget.percentIsClosed * _maxHeight) _isOpen = false;
      _restartSettleTimer();
    }

    _updateOpenFraction();
    return _isOpen != wasOpen || _isOpening != wasOpening || _isClosing != wasClosing;
  }

  void _updateOpenFraction() {
    _openFraction.value = (_maxHeight > 0)
        ? (_height / _maxHeight).clamp(0.0, 1.0)
        : 0.0;
  }

  void _restartSettleTimer() {
    _settleTimer?.cancel();
    _settleTimer = (_isOpening || _isClosing)
        ? Timer(_settleDuration, _onKeyboardSettled)
        : null;
  }

  /// The keyboard stopped moving above zero, so it's fully open, and its current height
  /// is the max height. The max height may decrease here, for example, when the user
  /// switches from the emoji keyboard to the (shorter) text keyboard.
  void _onKeyboardSettled() {
    _settleTimer = null;
    if (!mounted) return;
    final double height = _readHeight();
    if (height <= 0) return;

    _height = height;
    _maxHeight = height;
    _updateOpenFraction();
    if (!_isOpen || _isOpening || _isClosing) {
      setState(() {
        _isOpen = true;
        _isOpening = false;
        _isClosing = false;
      });
    }
  }

  void _updateFakeKeyboard() {
    final bool shouldInstall =
        !kIsWeb &&
        widget.reserveKeyboardSpaceOnDesktop &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux);

    if (shouldInstall && _fakeKeyboard == null) {
      final fakeKeyboard = _FakeDesktopKeyboard();
      fakeKeyboard.isOpen.addListener(_onFakeKeyboardShowOrHide);
      _FakeDesktopKeyboard.active = fakeKeyboard;
      TextInput.setInputControl(fakeKeyboard);
      _fakeKeyboard = fakeKeyboard;
      _fakeController = AnimationController(
        vsync: this,
        duration: _fakeKeyboardDuration,
      )..addListener(_onKeyboardMoved);
    } //
    else if (!shouldInstall && _fakeKeyboard != null) {
      _uninstallFakeKeyboard();
    }
  }

  void _uninstallFakeKeyboard() {
    final fakeKeyboard = _fakeKeyboard;
    if (fakeKeyboard == null) return;
    _fakeKeyboard = null;
    fakeKeyboard.isOpen.removeListener(_onFakeKeyboardShowOrHide);
    if (_FakeDesktopKeyboard.active == fakeKeyboard) {
      _FakeDesktopKeyboard.active = null;
      TextInput.restorePlatformInputControl();
    }
    fakeKeyboard.isOpen.dispose();
    _fakeController?.dispose();
    _fakeController = null;
  }

  /// The text input may request show/hide while a frame is being built. That's fine,
  /// since this only starts the animation, and the state is updated on its ticks.
  void _onFakeKeyboardShowOrHide() {
    final fakeKeyboard = _fakeKeyboard;
    final fakeController = _fakeController;
    if (fakeKeyboard == null || fakeController == null) return;
    fakeController.animateTo(
      fakeKeyboard.isOpen.value ? 1 : 0,
      curve: _fakeKeyboardCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = _withDismiss(context, widget.child);
    final fakeController = _fakeController;
    if (fakeController != null) child = _withFakeKeyboard(child, fakeController);
    return _KeyboardScope(
      isOpen: _isOpen,
      isOpening: _isOpening,
      isClosing: _isClosing,
      child: _KeyboardFractionScope(notifier: _openFraction, child: child),
    );
  }

  static const double _fakeKeyboardHeight = 275;
  static const Duration _fakeKeyboardDuration = Duration(milliseconds: 285);

  /// Approximates the curve of the iOS keyboard animation.
  static const Curve _fakeKeyboardCurve = Cubic(0.38, 0.7, 0.125, 1.0);

  /// Like a real keyboard, the fake keyboard covers the bottom of the child, and its
  /// height is reported as the bottom of the view insets, so that a [Scaffold] resizes
  /// its body to stay above it. The child always stays as the first child of the Stack
  /// (whether the fake keyboard is open or not), so its state is preserved when the
  /// keyboard opens/closes. The keyboard slides up from the bottom when opening, and
  /// down when closing.
  Widget _withFakeKeyboard(Widget child, AnimationController fakeController) {
    return AnimatedBuilder(
      animation: fakeController,
      child: child,
      builder: (BuildContext context, Widget? child) {
        final double height = fakeController.value * _fakeKeyboardHeight;
        final MediaQueryData data =
            MediaQuery.maybeOf(context) ?? MediaQueryData.fromView(View.of(context));

        return Stack(
          fit: StackFit.passthrough,
          children: [
            MediaQuery(
              data: data.copyWith(
                viewInsets: data.viewInsets.copyWith(
                  bottom: math.max(data.viewInsets.bottom, height),
                ),
              ),
              child: child!,
            ),
            if (height > 0)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: height,
                // Clicking the fake keyboard doesn't count as a "tap outside" the text
                // field, which on desktop would remove its focus.
                child: const TextFieldTapRegion(
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      minHeight: _fakeKeyboardHeight,
                      maxHeight: _fakeKeyboardHeight,
                      child: _FakeKeyboardKeys(),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _withDismiss(BuildContext context, Widget child) {
    if (kIsWeb) return child;

    final bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;
    if (!isIOS && !isAndroid) return child;

    final bool closeOnTap = isIOS ? widget.iOsCloseOnTap : widget.androidCloseOnTap;
    final bool closeOnSwipe = isIOS ? widget.iOsCloseOnSwipe : widget.androidCloseOnSwipe;
    final bool removeFocusOnTap = isIOS
        ? widget.iOsRemoveFocusOnTap
        : widget.androidRemoveFocusOnTap;
    final bool removeFocusOnSwipe = isIOS
        ? widget.iOsRemoveFocusOnSwipe
        : widget.androidRemoveFocusOnSwipe;

    Widget result = child;
    if (closeOnTap) result = _tappingAnywhere(context, result, removeFocusOnTap);
    if (closeOnSwipe) {
      result = _swipingDownJustAboveKeyboard(context, result, removeFocusOnSwipe);
    }
    return result;
  }

  Widget _tappingAnywhere(BuildContext context, Widget content, bool removeFocus) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // Reads the height fresh at tap time (not the cached _isOpen field), so the
        // check cannot go stale between a metrics change and the next rebuild. This
        // also ignores the percentIsOpen and percentIsClosed params.
        if (widget.closeOnTapOnlyIfKeyboardIsOpen && _readHeight() <= 0) return;
        Keyboard.close(removeFocus: removeFocus);
      },
      child: content,
    );
  }

  Widget _swipingDownJustAboveKeyboard(
    BuildContext context,
    Widget content,
    bool removeFocus,
  ) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerMove: (PointerMoveEvent evt) {
        final dy = evt.delta.dy;
        if (dy <= 0.0) return;

        final fingerPosition = evt.position.dy;
        final data = MediaQuery.of(context);
        final bottom = data.viewInsets.bottom;
        final keyboardEdgePosition = data.size.height - bottom;

        // Dismiss only when the keyboard is open and the finger is crossing the
        // keyboard's top edge in this frame.
        if (bottom > 0.0 &&
            fingerPosition > keyboardEdgePosition &&
            fingerPosition - dy <= keyboardEdgePosition) {
          Keyboard.close(removeFocus: removeFocus);
        }
      },
      child: content,
    );
  }
}

/// Vaguely resembles a mobile keyboard. Each row lists the flex of its keys, and a
/// negative flex is an empty gap.
class _FakeKeyboardKeys extends StatelessWidget {
  const _FakeKeyboardKeys();

  static const List<List<int>> _rows = [
    [2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
    [-1, 2, 2, 2, 2, 2, 2, 2, 2, 2, -1],
    [3, 2, 2, 2, 2, 2, 2, 2, 3],
    [5, 10, 5],
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF2B2B2B),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(3, 8, 3, 24),
        child: Column(
          children: [
            for (final row in _rows)
              Expanded(
                child: Row(
                  children: [
                    for (final flex in row)
                      if (flex < 0)
                        Spacer(flex: -flex)
                      else
                        Expanded(
                          flex: flex,
                          child: Container(
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5A5A5A),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _KeyboardScope extends InheritedWidget {
  const _KeyboardScope({
    required this.isOpen,
    required this.isOpening,
    required this.isClosing,
    required super.child,
  });

  final bool isOpen;
  final bool isOpening;
  final bool isClosing;

  @override
  bool updateShouldNotify(_KeyboardScope oldWidget) =>
      isOpen != oldWidget.isOpen ||
      isOpening != oldWidget.isOpening ||
      isClosing != oldWidget.isClosing;
}

/// Only the widgets that depend on it rebuild when the open fraction changes, which
/// happens on every frame while the keyboard moves.
class _KeyboardFractionScope extends InheritedNotifier<ValueNotifier<double>> {
  const _KeyboardFractionScope({required super.notifier, required super.child});
}

/// Development aid used by [Keyboard.reserveKeyboardSpaceOnDesktop]. A
/// [TextInputControl] that shows no real keyboard, but reports when the mobile keyboard
/// would be open. The platform text input stays connected (with input type "none"), so
/// the physical keyboard keeps working.
class _FakeDesktopKeyboard with TextInputControl {
  //
  /// The currently installed fake keyboard, if any. Used by [Keyboard.open] and
  /// [Keyboard.close], which talk to the platform directly and would otherwise
  /// bypass this control.
  static _FakeDesktopKeyboard? active;

  final ValueNotifier<bool> isOpen = ValueNotifier<bool>(false);

  bool _isAttached = false;

  void showIfAttached() {
    if (_isAttached) show();
  }

  @override
  void attach(TextInputClient client, TextInputConfiguration configuration) {
    _isAttached = true;
  }

  // Doesn't close here: when focus moves between text fields, the old client is
  // detached and the new one attached right away. The framework calls [hide] only
  // if no new client is attached, which avoids a close/open flicker.
  @override
  void detach(TextInputClient client) {
    _isAttached = false;
  }

  @override
  void show() => isOpen.value = true;

  @override
  void hide() => isOpen.value = false;
}
