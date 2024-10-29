import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';

/// Wrap your widget tree with a [KeyboardDismiss] so that:
///
/// 1) In iOS, if [iOS] is true (the default), the keyboard will follow iOS's default behavior:
/// - Keyboard closes when the user taps an empty area of the screen.
/// - Keyboard closes when the user swipes down from just above the keyboard edge.
/// - Any focused element will lose focus.
///
/// 2) In Android, the default behavior is that the keyboard only closes when the user taps
/// the back button or executes the back gesture. However, if you want, you can force the
/// Android to follow some iOS behaviors:
/// - Pass [androidCloseWhenTap] true, if you want the keyboard to close when the user taps an
///   empty area of the screen.
/// - Pass [androidCloseWhenSwipe] true, if you want the keyboard to close when the user swipes
///   down from just above the keyboard edge.
/// - Pass [androidLoseFocus] true, if you want any focused element will lose focus.
///
/// # Placement
///
/// The [KeyboardDismiss] must be put in a place where it has the same size of the screen.
///
/// For example, if you use a [Scaffold], the [KeyboardDismiss] should be *above* the scaffold, and
/// not inside the scaffold's body.
///
/// A good place to put the [KeyboardDismiss] widget is in the [MaterialApp.builder] method.
/// For example:
///
/// ```
/// MaterialApp(
///   builder: (BuildContext context, Widget? child) => KeyboardDismiss(child: child);
/// ```
///
class KeyboardDismiss extends StatelessWidget {
  //
  final Widget child;
  final bool iOS;
  final bool androidCloseWhenTap, androidCloseWhenSwipe, androidLoseFocus;

  const KeyboardDismiss({
    Key? key,
    required this.child,
    this.iOS = true,
    this.androidCloseWhenTap = false,
    this.androidCloseWhenSwipe = false,
    this.androidLoseFocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //
    // WEB ------
    if (kIsWeb) {
      // Don't do anything for web.
      return child;
    }
    //
    else {
      // IOS ---------
      if (defaultTargetPlatform == TargetPlatform.iOS && iOS)
        return swipingDownJustAboveKeyboard(context, tappingAnywhere(context, child));
      //
      // ANDROID -----
      else if (defaultTargetPlatform == TargetPlatform.android) {
        //
        if (androidCloseWhenTap && androidCloseWhenSwipe)
          return swipingDownJustAboveKeyboard(context, tappingAnywhere(context, child));
        //
        else if (androidCloseWhenSwipe)
          return swipingDownJustAboveKeyboard(context, child);
        //
        else if (androidCloseWhenTap)
          return tappingAnywhere(context, child);
        //
        else
          return child;
      }
      //
      // OTHERS ------
      else {
        // Don't do anything for other platforms.
        return child;
      }
    }
  }

  GestureDetector tappingAnywhere(BuildContext context, Widget content) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => keyboardDismiss(context),
      child: content,
    );
  }

  Listener swipingDownJustAboveKeyboard(BuildContext context, Widget content) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerMove: (PointerMoveEvent evt) {
        //
        double dy = evt.delta.dy;

        // If the user is swiping down.
        if (dy > 0.0) {
          //
          var fingerPosition = evt.position.dy;

          MediaQueryData data = MediaQuery.of(context);
          double height = data.size.height;
          double bottom = data.viewInsets.bottom;
          double keyboardEdgePosition = height - bottom;

          /// Close the keyboard if the keyboard is open (bottom > 0.0)
          /// and the user finger is passing through the bottom 16 pixels above the keyboard.
          if (bottom > 0.0 &&
              (fingerPosition > keyboardEdgePosition) &&
              (fingerPosition - dy <= keyboardEdgePosition)) _keyboardDismiss(context);
        }
      },
      child: content,
    );
  }

  void _keyboardDismiss(BuildContext context) {
    //
    if (defaultTargetPlatform == TargetPlatform.iOS)
      keyboardDismiss(context, ifRemovesFocus: true);
    //
    else if (defaultTargetPlatform == TargetPlatform.android)
      keyboardDismiss(context, ifRemovesFocus: androidLoseFocus);
    //
    else {
      // Don't do anything for other platforms.
    }
  }

  /// Closes the keyboard.
  /// If [ifRemovesFocus] is true (the default) it also removes focus from whatever widget has it.
  static void keyboardDismiss(BuildContext context, {bool ifRemovesFocus = true}) {
    /// How to Dismiss the Keyboard in Flutter the Right Way.
    /// https://flutterigniter.com/dismiss-keyboard-form-lose-focus/

    if (ifRemovesFocus) FocusScope.of(context).requestFocus(FocusNode());
    SystemChannels.textInput.invokeMethod<dynamic>('TextInput.hide');
  }
}
