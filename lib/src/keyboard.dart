import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';

/// [KeyboardSwitch] renders different content depending on whether the system keyboard
/// is open or closed.
///
/// IMPORTANT: For this widget to work it requires a [Keyboard] ancestor. if you don't
/// have a [Keyboard] ancestor, it will throw an assertion error.
///
/// There are two ways to use it:
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
/// 2) The [KeyboardSwitch.builder] constructor takes a [builder] callback that receives
///    the current `isOpen` state, so you can build any widget you want based on it:
///
///    ```
///    KeyboardSwitch.builder(
///      (context, isOpen) => Icon(isOpen ? Icons.keyboard : Icons.keyboard_hide),
///    )
///    ```
///
class KeyboardSwitch extends StatelessWidget {
  //
  final Widget? open;
  final Widget? closed;
  final Widget Function(BuildContext context, bool isOpen)? builder;

  /// Renders [open] when the keyboard is open, and [closed] when it is closed. Both are
  /// optional, and a missing slot renders nothing.
  const KeyboardSwitch({super.key, this.open, this.closed}) : builder = null;

  /// Renders the widget returned by [builder], which receives the current `isOpen`
  /// state of the keyboard.
  const KeyboardSwitch.builder(this.builder, {super.key}) : open = null, closed = null;

  @override
  Widget build(BuildContext context) {
    final isOpen = Keyboard.isOpen(context);

    final builder = this.builder;
    if (builder != null) {
      return builder(context, isOpen);
    }

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
/// ## Other features
///
/// - [Keyboard.isOpen] and [Keyboard.isClosed] can be used to check whether the keyboard
///   is currently open or not. Example usage:
///
///   ```
///   bool isKeyboardOpen = Keyboard.isOpen(context);
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
  });

  final Widget child;
  final bool iOsCloseOnTap;
  final bool iOsCloseOnSwipe;
  final bool iOsRemoveFocusOnTap;
  final bool iOsRemoveFocusOnSwipe;
  final bool androidCloseOnTap;
  final bool androidCloseOnSwipe;
  final bool androidRemoveFocusOnTap;
  final bool androidRemoveFocusOnSwipe;

  /// Closes only the system keyboard and removes focus from any element that has focus.
  static void close({bool removeFocus = true}) {
    if (removeFocus) FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  static void open() {
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  /// Whether the keyboard is currently open. Requires a [Keyboard] ancestor.
  /// Example usage:
  /// ```
  /// bool isOpen = Keyboard.isOpen(context);
  /// ```
  ///
  static bool isOpen(BuildContext context) {
    //
    final scope = context.dependOnInheritedWidgetOfExactType<_KeyboardScope>();
    assert(
      scope != null,
      'Keyboard.isOpen() called without a Keyboard ancestor. '
      'Wrap the app (above any Scaffold) in a Keyboard widget.',
    );
    return scope!.isOpen;
  }

  /// Whether the keyboard is currently open. Requires a [Keyboard] ancestor.
  /// Example usage:
  /// ```
  /// bool isClosed = Keyboard.isClosed(context);
  /// ```
  ///
  static bool isClosed(BuildContext context) {
    //
    final scope = context.dependOnInheritedWidgetOfExactType<_KeyboardScope>();
    assert(
      scope != null,
      'Keyboard.isClosed() called without a Keyboard ancestor. '
      'Wrap the app (above any Scaffold) in a Keyboard widget.',
    );
    return !scope!.isOpen;
  }

  @override
  State<Keyboard> createState() => _KeyboardState();
}

class _KeyboardState extends State<Keyboard> with WidgetsBindingObserver {
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isOpen = _readIsOpen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final next = _readIsOpen();
    if (next != _isOpen) setState(() => _isOpen = next);
  }

  bool _readIsOpen() => View.of(context).viewInsets.bottom > 0;

  @override
  Widget build(BuildContext context) {
    return _KeyboardScope(isOpen: _isOpen, child: _withDismiss(context, widget.child));
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
      onTap: () => Keyboard.close(removeFocus: removeFocus),
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

class _KeyboardScope extends InheritedWidget {
  const _KeyboardScope({required this.isOpen, required super.child});

  final bool isOpen;

  @override
  bool updateShouldNotify(_KeyboardScope oldWidget) => isOpen != oldWidget.isOpen;
}
