import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  //
  const debugColor = Color(0xBBFF0000);

  /// Pumps the [button] at the top-left of the screen.
  Future<void> pump(WidgetTester tester, Widget button) => tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(alignment: Alignment.topLeft, child: button),
        ),
      );

  group('Button', () {
    //
    /// A 40 x 20 button, with a text that shows if it's pressed.
    Widget content({required bool isPressed}) => SizedBox(
          width: 40,
          height: 20,
          child: Text(isPressed ? 'pressed' : 'idle'),
        );

    testWidgets('Calls onTap when tapped', (tester) async {
      int taps = 0;
      await pump(tester, Button(onTap: () => taps++, builder: content));

      await tester.tap(find.byType(Button));
      expect(taps, 1);
    });

    testWidgets("Doesn't call onTap when disabled", (tester) async {
      int taps = 0;
      await pump(tester, Button(onTap: () => taps++, disable: true, builder: content));

      await tester.tap(find.byType(Button));
      expect(taps, 0);
    });

    testWidgets('Is pressed while the pointer is down', (tester) async {
      await pump(tester, Button(onTap: () {}, builder: content));
      expect(find.text('idle'), findsOneWidget);

      final gesture = await tester.startGesture(const Offset(20, 10));
      await tester.pump();
      expect(find.text('pressed'), findsOneWidget);

      await gesture.up();
      await tester.pump();
      expect(find.text('idle'), findsOneWidget);
    });

    testWidgets('Is pressed even when onTap is null', (tester) async {
      await pump(tester, Button(onTap: null, builder: content));

      final gesture = await tester.startGesture(const Offset(20, 10));
      await tester.pump();
      expect(find.text('pressed'), findsOneWidget);

      await gesture.up();
      await tester.pump();
      expect(find.text('idle'), findsOneWidget);
    });

    testWidgets('Stops being pressed when the pointer moves away', (tester) async {
      await pump(tester, Button(onTap: () {}, builder: content));

      final gesture = await tester.startGesture(const Offset(20, 10));
      await tester.pump();
      expect(find.text('pressed'), findsOneWidget);

      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();
      expect(find.text('idle'), findsOneWidget);

      await gesture.up();
    });

    testWidgets('minVisualTapDuration keeps it pressed for a while', (tester) async {
      await pump(
        tester,
        Button(
          onTap: () {},
          minVisualTapDuration: const Duration(milliseconds: 100),
          builder: content,
        ),
      );

      await tester.tap(find.byType(Button));
      await tester.pump();
      expect(find.text('pressed'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('idle'), findsOneWidget);
    });

    testWidgets('The clickAreaMargin makes the button larger', (tester) async {
      int taps = 0;

      await pump(tester, Button(onTap: () => taps++, builder: content));
      expect(tester.getSize(find.byType(Button)), const Size(40, 20));

      await pump(
        tester,
        Button(
          onTap: () => taps++,
          clickAreaMargin: const Pad(all: 10, left: 5),
          builder: content,
        ),
      );
      expect(tester.getSize(find.byType(Button)), const Size(65, 40));
      expect(tester.getTopLeft(find.byType(Text)), const Offset(15, 10));

      // The margin is clickable.
      await tester.tapAt(const Offset(2, 2));
      await tester.tapAt(const Offset(63, 38));
      expect(taps, 2);
    });

    testWidgets('The clickable area is only painted when debugging it', (tester) async {
      Widget empty({required bool isPressed}) => const SizedBox(width: 40, height: 20);

      await pump(
        tester,
        Button(onTap: () {}, clickAreaMargin: const Pad(all: 10), builder: empty),
      );
      expect(find.byType(Button), paintsNothing);
      expect(
        find.descendant(of: find.byType(Button), matching: find.byType(ColoredBox)),
        findsNothing,
      );

      await pump(
        tester,
        Button(
          onTap: () {},
          clickAreaMargin: const Pad(all: 10),
          debugShowClickableArea: true,
          builder: empty,
        ),
      );
      expect(
        find.byType(Button),
        paints..rect(rect: const Rect.fromLTWH(0, 0, 60, 40), color: debugColor),
      );
    });
  });

  group('CircleButton', () {
    //
    const blue = Color(0xFF0000FF);
    const red = Color(0xFFFF0000);
    const green = Color(0xFF00FF00);

    testWidgets('Has the given size, plus the clickAreaMargin', (tester) async {
      await pump(tester, const CircleButton(icon: SizedBox()));
      expect(tester.getSize(find.byType(CircleButton)), const Size(53.5, 50));

      await pump(
        tester,
        const CircleButton(icon: SizedBox(), size: 30, clickAreaMargin: Pad(all: 10)),
      );
      expect(tester.getSize(find.byType(CircleButton)), const Size(50, 50));

      await pump(tester, const CircleButton(icon: SizedBox(), clickAreaMargin: null));
      expect(tester.getSize(find.byType(CircleButton)), const Size(44, 44));
    });

    testWidgets('Calls onTap when tapped, including in the clickAreaMargin',
        (tester) async {
      int taps = 0;
      await pump(
        tester,
        CircleButton(
          icon: const SizedBox(),
          clickAreaMargin: const Pad(all: 10),
          onTap: () => taps++,
        ),
      );

      await tester.tap(find.byType(CircleButton));
      await tester.tapAt(const Offset(2, 2));
      expect(taps, 2);

      // The button shows it was tapped for 100ms.
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Paints a circle with the background color, or the tap color',
        (tester) async {
      await pump(
        tester,
        CircleButton(
          icon: const SizedBox(),
          clickAreaMargin: const Pad(all: 10),
          backgroundColor: blue,
          tapColor: red,
          onTap: () {},
        ),
      );
      expect(
        find.byType(CircleButton),
        paints..circle(x: 32, y: 32, radius: 22, color: blue),
      );

      final gesture = await tester.startGesture(const Offset(32, 32));
      await tester.pump();
      expect(
        find.byType(CircleButton),
        paints..circle(x: 32, y: 32, radius: 22, color: red),
      );

      await gesture.up();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        find.byType(CircleButton),
        paints..circle(x: 32, y: 32, radius: 22, color: blue),
      );
    });

    testWidgets('The builder gets the pressed state and the default content',
        (tester) async {
      final List<bool> pressedStates = [];

      await pump(
        tester,
        CircleButton(
          icon: const SizedBox(),
          clickAreaMargin: const Pad(all: 10),
          backgroundColor: blue,
          onTap: () {},
          builder: ({required isHover, required isPressed, required child}) {
            pressedStates.add(isPressed);
            return ColoredBox(color: green, child: child);
          },
        ),
      );

      // The builder wraps the circle, but not the clickAreaMargin.
      expect(tester.getSize(find.byType(CircleButton)), const Size(64, 64));
      expect(
        find.byType(CircleButton),
        paints
          ..rect(rect: const Rect.fromLTWH(10, 10, 44, 44), color: green)
          ..circle(x: 32, y: 32, radius: 22, color: blue),
      );

      final gesture = await tester.startGesture(const Offset(32, 32));
      await tester.pump();
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 100));
      expect(pressedStates, [false, true, false]);
    });

    testWidgets('The clickable area is only painted when debugging it', (tester) async {
      await pump(
        tester,
        const CircleButton(icon: SizedBox(), clickAreaMargin: Pad(all: 10)),
      );
      expect(
        find.descendant(of: find.byType(CircleButton), matching: find.byType(ColoredBox)),
        findsNothing,
      );
      expect(find.byType(CircleButton), isNot(paints..rect()));

      await pump(
        tester,
        const CircleButton(
          icon: SizedBox(),
          clickAreaMargin: Pad(all: 10),
          debugShowClickableArea: true,
        ),
      );
      expect(
        find.byType(CircleButton),
        paints..rect(rect: const Rect.fromLTWH(0, 0, 64, 64), color: debugColor),
      );
    });
  });
}
