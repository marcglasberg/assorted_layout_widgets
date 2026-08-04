import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({
  required FocusNode focusNode,
  bool closeOnTapOnlyIfKeyboardIsOpen = false,
}) {
  return MaterialApp(
    builder: (BuildContext context, Widget? child) => Keyboard(
      iOsCloseOnTap: true,
      iOsRemoveFocusOnTap: true,
      closeOnTapOnlyIfKeyboardIsOpen: closeOnTapOnlyIfKeyboardIsOpen,
      child: child!,
    ),
    home: Scaffold(
      body: Column(
        children: [
          TextField(focusNode: focusNode),
        ],
      ),
    ),
  );
}

/// Taps a point in the empty area below the text field, where no descendant
/// gesture recognizer claims the tap, so the Keyboard's own GestureDetector wins.
Future<void> _tapEmptyArea(WidgetTester tester) async {
  await tester.tapAt(const Offset(400, 300));
  await tester.pump();
}

void main() {
  //
  testWidgets(
      'closeOnTapOnlyIfKeyboardIsOpen: true, keyboard closed (insets 0): '
      'tapping an empty area does NOT unfocus the focused text field',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      tester.view.viewInsets = FakeViewPadding.zero;
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        _app(focusNode: focusNode, closeOnTapOnlyIfKeyboardIsOpen: true),
      );

      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      await _tapEmptyArea(tester);

      expect(focusNode.hasFocus, isTrue);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets(
      'closeOnTapOnlyIfKeyboardIsOpen: true, keyboard open (insets > 0): '
      'tapping an empty area DOES unfocus the focused text field', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        _app(focusNode: focusNode, closeOnTapOnlyIfKeyboardIsOpen: true),
      );

      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      await _tapEmptyArea(tester);

      expect(focusNode.hasFocus, isFalse);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets(
      'Default (closeOnTapOnlyIfKeyboardIsOpen: false), keyboard closed (insets 0): '
      'tapping an empty area still unfocuses (current behavior is preserved)',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      tester.view.viewInsets = FakeViewPadding.zero;
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(_app(focusNode: focusNode));

      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      await _tapEmptyArea(tester);

      expect(focusNode.hasFocus, isFalse);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets(
      'closeOnTapOnlyIfKeyboardIsOpen: true reads the insets fresh at tap time: '
      'after the keyboard closes, a tap no longer unfocuses', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        _app(focusNode: focusNode, closeOnTapOnlyIfKeyboardIsOpen: true),
      );

      // The keyboard closes (e.g. a custom TextInputControl suppresses it).
      tester.view.viewInsets = FakeViewPadding.zero;

      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      await _tapEmptyArea(tester);

      expect(focusNode.hasFocus, isTrue);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
