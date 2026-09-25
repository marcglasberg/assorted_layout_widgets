import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter/scheduler.dart';
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
///   - Pass [closeOnTapOnlyIfKeyboardIsOpen] true to make the close-on-tap behavior
///     ([iOsCloseOnTap] / [androidCloseOnTap]) act only when the system keyboard is
///     actually open. When the keyboard is closed, taps do nothing: the keyboard is not
///     asked to hide, and focus is not removed.
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
/// However, if your app uses a custom in-app keyboard (a custom [TextInputControl] that
/// suppresses the platform keyboard), also pass `closeOnTapOnlyIfKeyboardIsOpen: true`.
/// Otherwise, while the system keyboard is closed, taps on empty areas of the screen
/// would still remove focus from the focused text field, hiding your in-app keyboard:
///
/// ```dart
/// Keyboard(
///   iOsCloseOnTap: true,
///   iOsCloseOnSwipe: true,
///   iOsRemoveFocusOnTap: true,
///   closeOnTapOnlyIfKeyboardIsOpen: true,
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
    this.closeOnTapOnlyIfKeyboardIsOpen = true,
    this.reserveKeyboardSpaceOnDesktop = false,
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
  final bool closeOnTapOnlyIfKeyboardIsOpen;

  /// This param is `false` by default. Sometimes, it's a good idea to run your app
  /// on desktop (Windows, macOS or Linux) to help develop mobile apps, since running on
  /// desktop is faster than running on a mobile device or emulator. However, when the
  /// app runs on desktop, the system keyboard never opens, so you cannot test how your app behaves when the
  /// keyboard opens and closes. To fix this, set this param to `true` and the [Keyboard]
  /// widget will install a fake keyboard (a [TextInputControl]) that shows a 275px black
  /// area at the bottom of this widget whenever the mobile keyboard would open.
  /// [Keyboard.isOpen] and [KeyboardSwitch] treat that area as the keyboard.
  /// The physical keyboard keeps working.
  final bool reserveKeyboardSpaceOnDesktop;

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

  /// Only non-null when [Keyboard.reserveKeyboardSpaceOnDesktop] is true on desktop.
  _FakeDesktopKeyboard? _fakeKeyboard;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateFakeKeyboard();
  }

  @override
  void didUpdateWidget(Keyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reserveKeyboardSpaceOnDesktop != oldWidget.reserveKeyboardSpaceOnDesktop) {
      _updateFakeKeyboard();
      _isOpen = _readIsOpen();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isOpen = _readIsOpen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _uninstallFakeKeyboard();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _refreshIsOpen();
  }

  void _refreshIsOpen() {
    final next = _readIsOpen();
    if (next != _isOpen) setState(() => _isOpen = next);
  }

  bool _readIsOpen() =>
      View.of(context).viewInsets.bottom > 0 || (_fakeKeyboard?.isOpen.value ?? false);

  void _updateFakeKeyboard() {
    final bool shouldInstall =
        !kIsWeb &&
        widget.reserveKeyboardSpaceOnDesktop &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux);

    if (shouldInstall && _fakeKeyboard == null) {
      final fakeKeyboard = _FakeDesktopKeyboard();
      fakeKeyboard.isOpen.addListener(_onFakeKeyboardChanged);
      _FakeDesktopKeyboard.active = fakeKeyboard;
      TextInput.setInputControl(fakeKeyboard);
      _fakeKeyboard = fakeKeyboard;
    } //
    else if (!shouldInstall && _fakeKeyboard != null) {
      _uninstallFakeKeyboard();
    }
  }

  void _uninstallFakeKeyboard() {
    final fakeKeyboard = _fakeKeyboard;
    if (fakeKeyboard == null) return;
    _fakeKeyboard = null;
    fakeKeyboard.isOpen.removeListener(_onFakeKeyboardChanged);
    if (_FakeDesktopKeyboard.active == fakeKeyboard) {
      _FakeDesktopKeyboard.active = null;
      TextInput.restorePlatformInputControl();
    }
    fakeKeyboard.isOpen.dispose();
  }

  void _onFakeKeyboardChanged() {
    if (!mounted) return;
    // The text input may request show/hide while a frame is being built. In that case,
    // defer the rebuild to after the frame, since setState is not allowed during build.
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _refreshIsOpen();
      });
    } else {
      _refreshIsOpen();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = _withDismiss(context, widget.child);
    if (_fakeKeyboard != null) child = _withFakeKeyboardSpace(child);
    return _KeyboardScope(isOpen: _isOpen, child: child);
  }

  /// The child always stays as the first child of the Column (whether the fake
  /// keyboard is open or not), so its state is preserved when the space opens/closes.
  Widget _withFakeKeyboardSpace(Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: child),
        if (_fakeKeyboard?.isOpen.value ?? false)
          const SizedBox(
            height: 275,
            child: ColoredBox(
              color: Colors.black,
              child: Center(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: DefaultTextStyle(
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    child: Text('space for the keyboard'),
                  ),
                ),
              ),
            ),
          ),
      ],
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
        // Reads the insets fresh at tap time (not the cached _isOpen field), so the
        // check cannot go stale between a metrics change and the next rebuild.
        if (widget.closeOnTapOnlyIfKeyboardIsOpen && !_readIsOpen()) return;
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

class _KeyboardScope extends InheritedWidget {
  const _KeyboardScope({required this.isOpen, required super.child});

  final bool isOpen;

  @override
  bool updateShouldNotify(_KeyboardScope oldWidget) => isOpen != oldWidget.isOpen;
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
