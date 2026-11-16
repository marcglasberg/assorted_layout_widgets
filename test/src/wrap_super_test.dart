import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  //
  const k1 = Key('1');
  const k2 = Key('2');
  const k3 = Key('3');

  /// Pumps a [WrapSuper] at the top-left of a box of the given [width].
  /// The [textDirection] is the ambient [Directionality].
  Future<void> pump(
    WidgetTester tester, {
    required WrapSuper wrapSuper,
    double width = 200,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return tester.pumpWidget(
      Directionality(
        textDirection: textDirection,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: wrapSuper),
        ),
      ),
    );
  }

  Rect rect(WidgetTester tester, Key key) => tester.getRect(find.byKey(key));

  /// Children: 50x10 and 50x30.
  const twoChildren = [
    SizedBox(key: k1, width: 50, height: 10),
    SizedBox(key: k2, width: 50, height: 30),
  ];

  group('textDirection', () {
    testWidgets('LTR places children from left to right', (tester) async {
      await pump(tester, wrapSuper: const WrapSuper(spacing: 5, children: twoChildren));
      expect(rect(tester, k1).left, 0);
      expect(rect(tester, k2).left, 55);
    });

    testWidgets('RTL (ambient) places children from right to left', (tester) async {
      await pump(
        tester,
        textDirection: TextDirection.rtl,
        wrapSuper: const WrapSuper(spacing: 5, children: twoChildren),
      );
      expect(rect(tester, k1).right, 200);
      expect(rect(tester, k2).right, 145);
    });

    testWidgets('Explicit textDirection overrides the ambient one', (tester) async {
      await pump(
        tester,
        textDirection: TextDirection.ltr,
        wrapSuper: const WrapSuper(textDirection: TextDirection.rtl, children: twoChildren),
      );
      expect(rect(tester, k1).right, 200);
      expect(rect(tester, k2).right, 150);
    });

    testWidgets('RTL keeps the line breaks, and mirrors each line', (tester) async {
      await pump(
        tester,
        width: 100,
        textDirection: TextDirection.rtl,
        wrapSuper: const WrapSuper(
          wrapType: WrapType.fit,
          children: [
            SizedBox(key: k1, width: 60, height: 10),
            SizedBox(key: k2, width: 30, height: 10),
            SizedBox(key: k3, width: 30, height: 10),
          ],
        ),
      );
      expect(rect(tester, k1), const Rect.fromLTWH(40, 0, 60, 10));
      expect(rect(tester, k2), const Rect.fromLTWH(10, 0, 30, 10));
      expect(rect(tester, k3), const Rect.fromLTWH(70, 10, 30, 10));
    });
  });

  group('alignment', () {
    Future<(double, double)> lefts(
      WidgetTester tester,
      WrapSuperAlignment alignment,
      TextDirection textDirection,
    ) async {
      await pump(
        tester,
        textDirection: textDirection,
        wrapSuper: WrapSuper(alignment: alignment, children: twoChildren),
      );
      return (rect(tester, k1).left, rect(tester, k2).left);
    }

    testWidgets('LTR', (tester) async {
      expect(await lefts(tester, WrapSuperAlignment.start, TextDirection.ltr), (0.0, 50.0));
      expect(await lefts(tester, WrapSuperAlignment.left, TextDirection.ltr), (0.0, 50.0));
      expect(await lefts(tester, WrapSuperAlignment.end, TextDirection.ltr), (100.0, 150.0));
      expect(await lefts(tester, WrapSuperAlignment.right, TextDirection.ltr), (100.0, 150.0));
      expect(await lefts(tester, WrapSuperAlignment.center, TextDirection.ltr), (50.0, 100.0));
    });

    testWidgets('RTL: start/end follow the direction, left/right do not', (tester) async {
      expect(await lefts(tester, WrapSuperAlignment.start, TextDirection.rtl), (150.0, 100.0));
      expect(await lefts(tester, WrapSuperAlignment.right, TextDirection.rtl), (150.0, 100.0));
      expect(await lefts(tester, WrapSuperAlignment.end, TextDirection.rtl), (50.0, 0.0));
      expect(await lefts(tester, WrapSuperAlignment.left, TextDirection.rtl), (50.0, 0.0));
      expect(await lefts(tester, WrapSuperAlignment.center, TextDirection.rtl), (100.0, 50.0));
    });

    testWidgets('Default is start', (tester) async {
      await pump(
        tester,
        textDirection: TextDirection.rtl,
        wrapSuper: const WrapSuper(children: twoChildren),
      );
      expect(rect(tester, k1).right, 200);
    });
  });

  group('crossAxisAlignment', () {
    Future<double> topOfShortChild(WidgetTester tester, WrapCrossAlignment alignment) async {
      await pump(
        tester,
        wrapSuper: WrapSuper(crossAxisAlignment: alignment, children: twoChildren),
      );
      expect(rect(tester, k2).top, 0); // The tallest child defines the line height.
      return rect(tester, k1).top;
    }

    testWidgets('start, center and end', (tester) async {
      expect(await topOfShortChild(tester, WrapCrossAlignment.start), 0);
      expect(await topOfShortChild(tester, WrapCrossAlignment.center), 10);
      expect(await topOfShortChild(tester, WrapCrossAlignment.end), 20);
    });

    testWidgets('Each line is aligned by its own height', (tester) async {
      await pump(
        tester,
        width: 100,
        wrapSuper: const WrapSuper(
          wrapType: WrapType.fit,
          lineSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            SizedBox(key: k1, width: 60, height: 10),
            SizedBox(key: k2, width: 40, height: 20),
            SizedBox(key: k3, width: 40, height: 6),
          ],
        ),
      );
      expect(rect(tester, k1).top, 10);
      expect(rect(tester, k2).top, 0);
      expect(rect(tester, k3).top, 24); // Second line starts at 20 + 4.
      expect(tester.getSize(find.byType(WrapSuper)), const Size(100, 30));
    });
  });

  group('Dry layout matches the actual layout', () {
    Future<void> expectDryLayoutMatches(WidgetTester tester, WrapSuper wrapSuper,
        {double width = 100}) async {
      await pump(tester, width: width, wrapSuper: wrapSuper);
      final renderBox = tester.renderObject<RenderBox>(find.byType(WrapSuper));
      expect(renderBox.getDryLayout(BoxConstraints(maxWidth: width)), renderBox.size);
      expect(renderBox.getMinIntrinsicHeight(width), renderBox.size.height);
      expect(renderBox.getMaxIntrinsicHeight(width), renderBox.size.height);
    }

    testWidgets('WrapType.balanced', (tester) async {
      // Greedy would break as [60, 30] [30], with height 40 + 40.
      // Balanced breaks as [60] [30, 30], with height 10 + 40.
      await expectDryLayoutMatches(
        tester,
        const WrapSuper(
          wrapType: WrapType.balanced,
          children: [
            SizedBox(width: 60, height: 10),
            SizedBox(width: 30, height: 40),
            SizedBox(width: 30, height: 40),
          ],
        ),
      );
      expect(tester.getSize(find.byType(WrapSuper)).height, 50);
    });

    for (final wrapFit in [WrapFit.divided, WrapFit.proportional, WrapFit.larger]) {
      testWidgets('$wrapFit, with children whose height depends on their width',
          (tester) async {
        // Each child is 50 wide by itself, but is stretched to 100 by the wrap-fit,
        // and the AspectRatio makes its height equal to its width.
        await expectDryLayoutMatches(
          tester,
          width: 200,
          WrapSuper(
            wrapFit: wrapFit,
            children: const [
              SizedBox(width: 50, child: AspectRatio(aspectRatio: 1)),
              SizedBox(width: 50, child: AspectRatio(aspectRatio: 1)),
            ],
          ),
        );
        expect(tester.getSize(find.byType(WrapSuper)), const Size(200, 100));
      });
    }

    testWidgets('No children', (tester) async {
      await expectDryLayoutMatches(tester, const WrapSuper());
      expect(tester.getSize(find.byType(WrapSuper)), const Size(100, 0));
    });
  });

  testWidgets('Max intrinsic width includes the spacing', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: IntrinsicWidth(
            child: WrapSuper(
              spacing: 5,
              children: [
                SizedBox(key: k1, width: 50, height: 10),
                SizedBox(key: k2, width: 50, height: 10),
              ],
            ),
          ),
        ),
      ),
    );
    // All children fit in a single line.
    expect(tester.getSize(find.byType(WrapSuper)), const Size(105, 10));
    expect(rect(tester, k2).topLeft, const Offset(55, 0));
  });

  testWidgets('Unbounded width puts all children in a single line', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: UnconstrainedBox(
            child: WrapSuper(
              spacing: 5,
              wrapFit: WrapFit.larger,
              children: [
                SizedBox(key: k1, width: 50, height: 10),
                SizedBox(key: k2, width: 70, height: 20),
              ],
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(WrapSuper)), const Size(125, 20));
    expect(rect(tester, k2).left, 55);
  });
}
