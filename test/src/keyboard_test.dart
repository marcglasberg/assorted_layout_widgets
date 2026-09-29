import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;

/// When [closeOnTapOnlyIfKeyboardIsOpen] is null, uses the Keyboard's default.
Widget _app({
  required FocusNode focusNode,
  bool? closeOnTapOnlyIfKeyboardIsOpen,
}) {
  return MaterialApp(
    builder: (BuildContext context, Widget? child) =>
        (closeOnTapOnlyIfKeyboardIsOpen == null)
            ? Keyboard(
                iOsCloseOnTap: true,
                iOsRemoveFocusOnTap: true,
                child: child!,
              )
            : Keyboard(
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

class _KeyboardFlags {
  bool isOpen = false;
  bool isClosed = false;
  bool isOpening = false;
  bool isClosing = false;
  double viewInsetsBottom = 0;
  double openFraction = 0;

  @override
  String toString() => 'isOpen: $isOpen, isClosed: $isClosed, '
      'isOpening: $isOpening, isClosing: $isClosing, '
      'viewInsetsBottom: $viewInsetsBottom, openFraction: $openFraction';
}

Widget _flagsApp({
  required _KeyboardFlags flags,
  double percentIsOpen = 0,
  double percentIsClosed = 0,
  bool reserveKeyboardSpaceOnDesktop = false,
  FocusNode? focusNode,
}) {
  return MaterialApp(
    builder: (BuildContext context, Widget? child) => Keyboard(
      percentIsOpen: percentIsOpen,
      percentIsClosed: percentIsClosed,
      reserveKeyboardSpaceOnDesktop: reserveKeyboardSpaceOnDesktop,
      child: child!,
    ),
    // Reads the MediaQuery outside the Scaffold, which removes the view insets.
    home: Builder(builder: (BuildContext context) {
      flags
        ..isOpen = Keyboard.isOpen(context)
        ..isClosed = Keyboard.isClosed(context)
        ..isOpening = Keyboard.isOpening(context)
        ..isClosing = Keyboard.isClosing(context)
        ..viewInsetsBottom = MediaQuery.viewInsetsOf(context).bottom
        ..openFraction = Keyboard.openFraction(context);
      return Scaffold(
        body: Column(
          children: [if (focusNode != null) TextField(focusNode: focusNode)],
        ),
      );
    }),
  );
}

/// Moves the (real) keyboard to the given height, in logical pixels.
Future<void> _setKeyboardHeight(WidgetTester tester, double height) async {
  tester.view.viewInsets = FakeViewPadding(bottom: height);
  await tester.pump();
}

/// A realistic frame duration. The default of `pumpAndSettle` (100ms) is long enough for
/// the Keyboard to consider, between two frames, that the keyboard stopped moving.
const _frame = Duration(milliseconds: 16);

/// Waits long enough for the Keyboard to consider that the keyboard stopped moving.
Future<void> _waitKeyboardSettle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 200));
}

void _expectFlags(
  _KeyboardFlags flags, {
  required bool isOpen,
  bool isOpening = false,
  bool isClosing = false,
}) {
  expect(
    (flags.isOpen, flags.isClosed, flags.isOpening, flags.isClosing),
    (isOpen, !isOpen, isOpening, isClosing),
    reason: flags.toString(),
  );
}

void _keyboardStateTests() {
  //
  /// Runs the test on the iOS (or on the given platform).
  void testWidgets(
    String description,
    Future<void> Function(WidgetTester tester) body, {
    TargetPlatform platform = TargetPlatform.iOS,
  }) {
    flutter_test.testWidgets(description, (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      try {
        await body(tester);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  Future<_KeyboardFlags> pumpFlagsApp(
    WidgetTester tester, {
    double percentIsOpen = 0,
    double percentIsClosed = 0,
  }) async {
    tester.view.viewInsets = FakeViewPadding.zero;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final flags = _KeyboardFlags();
    await tester.pumpWidget(_flagsApp(
      flags: flags,
      percentIsOpen: percentIsOpen,
      percentIsClosed: percentIsClosed,
    ));
    return flags;
  }

  /// Opens the keyboard up to 300 pixels, and closes it, so that its max height is known.
  Future<void> openAndCloseOnce(WidgetTester tester) async {
    for (final h in [100.0, 200.0, 300.0]) {
      await _setKeyboardHeight(tester, h);
    }
    await _waitKeyboardSettle(tester);
    for (final h in [200.0, 100.0, 0.0]) {
      await _setKeyboardHeight(tester, h);
    }
  }

  testWidgets('Default percents: open as soon as it starts opening, '
      'closed only when it closes completely', (tester) async {
    final flags = await pumpFlagsApp(tester);
    _expectFlags(flags, isOpen: false);

    // First opening: the max height is not known yet, so it keeps opening until it
    // stops moving.
    await _setKeyboardHeight(tester, 50);
    _expectFlags(flags, isOpen: true, isOpening: true);
    await _setKeyboardHeight(tester, 200);
    _expectFlags(flags, isOpen: true, isOpening: true);
    await _setKeyboardHeight(tester, 300);
    _expectFlags(flags, isOpen: true, isOpening: true);
    await _waitKeyboardSettle(tester);
    _expectFlags(flags, isOpen: true);

    await _setKeyboardHeight(tester, 250);
    _expectFlags(flags, isOpen: true, isClosing: true);
    await _setKeyboardHeight(tester, 1);
    _expectFlags(flags, isOpen: true, isClosing: true);
    await _setKeyboardHeight(tester, 0);
    _expectFlags(flags, isOpen: false);

    // Second opening: stops opening as soon as it reaches the known max height.
    await _setKeyboardHeight(tester, 150);
    _expectFlags(flags, isOpen: true, isOpening: true);
    await _setKeyboardHeight(tester, 300);
    _expectFlags(flags, isOpen: true);
  });

  testWidgets('percentIsOpen 1 and percentIsClosed 1: open only when fully open, '
      'closed as soon as it starts closing', (tester) async {
    final flags = await pumpFlagsApp(tester, percentIsOpen: 1, percentIsClosed: 1);
    await openAndCloseOnce(tester);
    _expectFlags(flags, isOpen: false);

    await _setKeyboardHeight(tester, 150);
    _expectFlags(flags, isOpen: false, isOpening: true);
    await _setKeyboardHeight(tester, 299);
    _expectFlags(flags, isOpen: false, isOpening: true);
    await _setKeyboardHeight(tester, 300);
    _expectFlags(flags, isOpen: true);

    await _setKeyboardHeight(tester, 299);
    _expectFlags(flags, isOpen: false, isClosing: true);

    // Changes its mind, and opens again.
    await _setKeyboardHeight(tester, 299.5);
    _expectFlags(flags, isOpen: false, isOpening: true);
    await _setKeyboardHeight(tester, 300);
    _expectFlags(flags, isOpen: true);

    await _setKeyboardHeight(tester, 0);
    _expectFlags(flags, isOpen: false);
  });

  testWidgets('percentIsOpen 0.5 and percentIsClosed 0.5: '
      'open/closed at half the max height', (tester) async {
    final flags = await pumpFlagsApp(tester, percentIsOpen: 0.5, percentIsClosed: 0.5);
    await openAndCloseOnce(tester);

    await _setKeyboardHeight(tester, 149);
    _expectFlags(flags, isOpen: false, isOpening: true);
    await _setKeyboardHeight(tester, 150);
    _expectFlags(flags, isOpen: true, isOpening: true);
    await _setKeyboardHeight(tester, 300);
    _expectFlags(flags, isOpen: true);

    await _setKeyboardHeight(tester, 151);
    _expectFlags(flags, isOpen: true, isClosing: true);
    await _setKeyboardHeight(tester, 150);
    _expectFlags(flags, isOpen: false, isClosing: true);
    await _setKeyboardHeight(tester, 0);
    _expectFlags(flags, isOpen: false);
  });

  testWidgets('percentIsOpen 0 and percentIsClosed 1: '
      'open as soon as it starts opening, closed as soon as it starts closing',
      (tester) async {
    final flags = await pumpFlagsApp(tester, percentIsOpen: 0, percentIsClosed: 1);
    await openAndCloseOnce(tester);

    await _setKeyboardHeight(tester, 1);
    _expectFlags(flags, isOpen: true, isOpening: true);
    await _setKeyboardHeight(tester, 300);
    _expectFlags(flags, isOpen: true);
    await _setKeyboardHeight(tester, 299);
    _expectFlags(flags, isOpen: false, isClosing: true);
    await _setKeyboardHeight(tester, 0);
    _expectFlags(flags, isOpen: false);
  });

  testWidgets('When the keyboard gets shorter and stops, it stops closing, '
      'and the shorter height becomes the max height', (tester) async {
    final flags = await pumpFlagsApp(tester, percentIsOpen: 1, percentIsClosed: 1);
    await openAndCloseOnce(tester);

    await _setKeyboardHeight(tester, 300);
    _expectFlags(flags, isOpen: true);

    // For example, switches from the emoji keyboard to the text keyboard.
    await _setKeyboardHeight(tester, 260);
    _expectFlags(flags, isOpen: false, isClosing: true);
    await _waitKeyboardSettle(tester);
    _expectFlags(flags, isOpen: true);

    await _setKeyboardHeight(tester, 0);
    await _setKeyboardHeight(tester, 200);
    _expectFlags(flags, isOpen: false, isOpening: true);
    await _setKeyboardHeight(tester, 260);
    _expectFlags(flags, isOpen: true);
  });

  testWidgets('When the view width changes (device rotates), '
      'the max height is measured again', (tester) async {
    final flags = await pumpFlagsApp(tester, percentIsOpen: 1);
    await openAndCloseOnce(tester);

    tester.view.physicalSize = Size(
      tester.view.physicalSize.height,
      tester.view.physicalSize.width,
    );
    await tester.pump();

    // The known max of 300 is forgotten, and the estimate (336 on the iOS) is used
    // again. So 200 is not yet 100% open, until the keyboard stops moving.
    await _setKeyboardHeight(tester, 200);
    _expectFlags(flags, isOpen: false, isOpening: true);
    await _waitKeyboardSettle(tester);
    _expectFlags(flags, isOpen: true);
  });

  testWidgets('A keyboard that is already open when the app starts '
      'is open, and not moving', (tester) async {
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final flags = _KeyboardFlags();
    await tester.pumpWidget(_flagsApp(flags: flags));
    _expectFlags(flags, isOpen: true);
  });

  testWidgets('A keyboard that opens and closes instantly (no animation) '
      'is never opening or closing', (tester) async {
    final flags = await pumpFlagsApp(tester, percentIsOpen: 1, percentIsClosed: 1);
    await openAndCloseOnce(tester);

    await _setKeyboardHeight(tester, 300);
    _expectFlags(flags, isOpen: true);
    await _setKeyboardHeight(tester, 0);
    _expectFlags(flags, isOpen: false);
  });

  testWidgets('reserveKeyboardSpaceOnDesktop: the fake keyboard animates, '
      'and reports its height in the MediaQuery view insets', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    final flags = _KeyboardFlags();

    await tester.pumpWidget(_flagsApp(
      flags: flags,
      focusNode: focusNode,
      reserveKeyboardSpaceOnDesktop: true,
    ));
    _expectFlags(flags, isOpen: false);
    expect(flags.viewInsetsBottom, 0);

    focusNode.requestFocus();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    _expectFlags(flags, isOpen: true, isOpening: true);
    expect(flags.viewInsetsBottom, greaterThan(0));
    expect(flags.viewInsetsBottom, lessThan(275));

    // The max height of the fake keyboard is known from the start, so it stops opening
    // as soon as it reaches it, without waiting for it to stop moving.
    await tester.pumpAndSettle(_frame);
    _expectFlags(flags, isOpen: true);
    expect(flags.viewInsetsBottom, 275);
    expect(flags.openFraction, 1.0);

    focusNode.unfocus();
    await tester.pump();
    // The first frame of the animation only starts the ticker.
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    _expectFlags(flags, isOpen: true, isClosing: true);
    expect(flags.viewInsetsBottom, greaterThan(0));
    expect(flags.viewInsetsBottom, lessThan(275));

    await tester.pumpAndSettle(_frame);
    _expectFlags(flags, isOpen: false);
    expect(flags.viewInsetsBottom, 0);

    // Uninstalls the fake keyboard before the platform override is reset.
    await tester.pumpWidget(const SizedBox());
  }, platform: TargetPlatform.windows);

  testWidgets('openFraction: uses the estimated max height (336 on the iOS) until '
      'the keyboard stops moving, and then the real one', (tester) async {
    final flags = await pumpFlagsApp(tester);
    expect(flags.openFraction, 0.0);

    await _setKeyboardHeight(tester, 168);
    expect(flags.openFraction, 0.5);
    await _setKeyboardHeight(tester, 300);
    expect(flags.openFraction, 300 / 336);

    // Stops moving: 300 is the real max height.
    await _waitKeyboardSettle(tester);
    expect(flags.openFraction, 1.0);

    await _setKeyboardHeight(tester, 150);
    expect(flags.openFraction, 0.5);
    await _setKeyboardHeight(tester, 0);
    expect(flags.openFraction, 0.0);
  });

  testWidgets('openFraction: the estimated max height is 300 on the Android',
      (tester) async {
    final flags = await pumpFlagsApp(tester);
    await _setKeyboardHeight(tester, 150);
    expect(flags.openFraction, 0.5);
    await _setKeyboardHeight(tester, 0);
  }, platform: TargetPlatform.android);
}

void _keyboardSwitchTests() {
  //
  Future<void> pumpSwitch(WidgetTester tester, Widget keyboardSwitch) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    tester.view.viewInsets = FakeViewPadding.zero;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      builder: (BuildContext context, Widget? child) => Keyboard(child: child!),
      home: Center(child: keyboardSwitch),
    ));
  }

  testWidgets('The opening and closing slots are shown while the keyboard moves',
      (tester) async {
    try {
      await pumpSwitch(
        tester,
        const KeyboardSwitch(
          open: Text('open'),
          closed: Text('closed'),
          opening: Text('opening'),
          closing: Text('closing'),
        ),
      );
      expect(find.text('closed'), findsOneWidget);

      await _setKeyboardHeight(tester, 100);
      expect(find.text('opening'), findsOneWidget);
      await _waitKeyboardSettle(tester);
      expect(find.text('open'), findsOneWidget);

      await _setKeyboardHeight(tester, 50);
      expect(find.text('closing'), findsOneWidget);
      await _setKeyboardHeight(tester, 0);
      expect(find.text('closed'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('Without the opening and closing slots, shows open and closed',
      (tester) async {
    try {
      await pumpSwitch(
        tester,
        const KeyboardSwitch(open: Text('open'), closed: Text('closed')),
      );
      expect(find.text('closed'), findsOneWidget);

      // With the default percentIsOpen 0, it's open as soon as it starts opening.
      await _setKeyboardHeight(tester, 100);
      expect(find.text('open'), findsOneWidget);
      await _waitKeyboardSettle(tester);

      // With the default percentIsClosed 0, it's open until it closes completely.
      await _setKeyboardHeight(tester, 50);
      expect(find.text('open'), findsOneWidget);
      await _setKeyboardHeight(tester, 0);
      expect(find.text('closed'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('The fractionBuilder rebuilds on every frame while the keyboard moves, '
      'but the builder only when isOpen changes', (tester) async {
    try {
      int builds = 0;
      int fractionBuilds = 0;
      double? lastFraction;
      bool? lastIsOpening;
      bool? lastIsClosing;

      await pumpSwitch(
        tester,
        Column(
          children: [
            KeyboardSwitch.builder((context, isOpen) {
              builds++;
              return const SizedBox();
            }),
            KeyboardSwitch.fractionBuilder((context, fraction, isOpening, isClosing) {
              fractionBuilds++;
              lastFraction = fraction;
              lastIsOpening = isOpening;
              lastIsClosing = isClosing;
              return const SizedBox();
            }),
          ],
        ),
      );
      expect((builds, fractionBuilds), (1, 1));

      await _setKeyboardHeight(tester, 84);
      expect((builds, fractionBuilds), (2, 2)); // isOpen changed.
      expect((lastFraction, lastIsOpening, lastIsClosing), (0.25, true, false));

      await _setKeyboardHeight(tester, 168);
      await _setKeyboardHeight(tester, 252);
      expect((builds, fractionBuilds), (2, 4));
      expect(lastFraction, 0.75);

      // Nothing moves, nothing rebuilds.
      await tester.pump();
      await tester.pump();
      expect((builds, fractionBuilds), (2, 4));

      await _setKeyboardHeight(tester, 336);
      expect((lastFraction, lastIsOpening, lastIsClosing), (1.0, false, false));

      await _setKeyboardHeight(tester, 168);
      expect((lastFraction, lastIsOpening, lastIsClosing), (0.5, false, true));
      await _setKeyboardHeight(tester, 0);
      expect((lastFraction, lastIsOpening, lastIsClosing), (0.0, false, false));
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

void main() {
  //
  group('Keyboard state', _keyboardStateTests);
  group('KeyboardSwitch', _keyboardSwitchTests);

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
      'Default (closeOnTapOnlyIfKeyboardIsOpen: true), keyboard closed (insets 0): '
      'tapping an empty area does NOT unfocus the focused text field', (tester) async {
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

      expect(focusNode.hasFocus, isTrue);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets(
      'closeOnTapOnlyIfKeyboardIsOpen: false, keyboard closed (insets 0): '
      'tapping an empty area still unfocuses', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      tester.view.viewInsets = FakeViewPadding.zero;
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        _app(focusNode: focusNode, closeOnTapOnlyIfKeyboardIsOpen: false),
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
