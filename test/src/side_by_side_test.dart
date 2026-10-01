import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  //
  const k1 = Key('1');
  const k2 = Key('2');
  const k3 = Key('3');

  /// Pumps a [SideBySide] at the top-left of a 200x100 box. The [SideBySide] gets
  /// loose constraints, so it may be shorter than 100 pixels.
  Future<void> pump(
    WidgetTester tester, {
    required List<Widget> children,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection textDirection = TextDirection.ltr,
    TextBaseline? textBaseline,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 200,
            height: 100,
            child: Align(
              alignment: Alignment.topLeft,
              child: SideBySide(
                crossAxisAlignment: crossAxisAlignment,
                textDirection: textDirection,
                textBaseline: textBaseline,
                mainAxisSize: mainAxisSize,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Pumps a [SideBySide] inside a [Column], where the available height is unbounded.
  Future<void> pumpInColumn(
    WidgetTester tester, {
    required List<Widget> children,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    return tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SideBySide(crossAxisAlignment: crossAxisAlignment, children: children),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double top(WidgetTester tester, Key key) => tester.getTopLeft(find.byKey(key)).dy;

  double height(WidgetTester tester, Key key) => tester.getSize(find.byKey(key)).height;

  Size sideBySideSize(WidgetTester tester) =>
      tester.getSize(find.byType(SideBySide).first);

  testWidgets('CrossAxisAlignment start, end and center.', (tester) async {
    //
    const children = [
      SizedBox(key: k1, width: 30, height: 10),
      SizedBox(key: k2, width: 30, height: 50),
    ];

    await pump(tester, crossAxisAlignment: CrossAxisAlignment.start, children: children);
    expect(top(tester, k1), 0.0);
    expect(top(tester, k2), 0.0);
    expect(sideBySideSize(tester), const Size(200, 50));

    await pump(tester, crossAxisAlignment: CrossAxisAlignment.end, children: children);
    expect(top(tester, k1), 40.0);
    expect(top(tester, k2), 0.0);

    await pump(tester, crossAxisAlignment: CrossAxisAlignment.center, children: children);
    expect(top(tester, k1), 20.0);
    expect(top(tester, k2), 0.0);
  });

  testWidgets('CrossAxisAlignment.stretch fills the available height.', (tester) async {
    //
    await pump(
      tester,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        SizedBox(key: k1, width: 30),
        SizedBox(key: k2, width: 30),
        SizedBox(key: k3, width: 30, height: 10),
      ],
    );

    expect(height(tester, k1), 100.0);
    expect(height(tester, k2), 100.0);
    expect(height(tester, k3), 100.0);
    expect(top(tester, k1), 0.0);
    expect(top(tester, k3), 0.0);
    expect(sideBySideSize(tester), const Size(200, 100));
  });

  testWidgets('CrossAxisAlignment.stretch, with unbounded height, '
      'stretches the children to the tallest one.', (tester) async {
    //
    await pumpInColumn(
      tester,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        SizedBox(key: k1, width: 30, height: 10),
        SizedBox(key: k2, width: 30, height: 50),
        SizedBox(key: k3, width: 30, height: 20),
      ],
    );

    expect(height(tester, k1), 50.0);
    expect(height(tester, k2), 50.0);
    expect(height(tester, k3), 50.0);
    expect(top(tester, k1), top(tester, k2));
    expect(top(tester, k3), top(tester, k2));
    expect(sideBySideSize(tester), const Size(200, 50));
  });

  testWidgets('CrossAxisAlignment.stretch works with a single child.', (tester) async {
    //
    await pump(
      tester,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [SizedBox(key: k1, width: 30, height: 10)],
    );

    expect(height(tester, k1), 100.0);
  });

  testWidgets('CrossAxisAlignment.baseline aligns the text baselines.', (tester) async {
    //
    await pump(
      tester,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: const [
        Text('A', key: k1, style: TextStyle(fontSize: 20)),
        Text('B', key: k2, style: TextStyle(fontSize: 40)),
        SizedBox(key: k3, width: 10, height: 50),
      ],
    );

    // The test font has its baseline at 75% of the font size, so the baselines
    // are at 15 and 30 pixels. To align them, the small text shifts down 15.
    expect(top(tester, k1) - top(tester, k2), 15.0);

    // Children with no baseline are aligned to the top, like in a Row.
    expect(top(tester, k3), top(tester, k2));

    // As tall as its tallest child (the 50 pixel box).
    expect(sideBySideSize(tester).height, 50.0);
  });

  testWidgets(
    'CrossAxisAlignment.baseline may make the widget taller than its tallest child.',
    (tester) async {
      //
      await pump(
        tester,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: const [
          // Baseline at 15, height 70.
          Column(
            key: k1,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('A', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10, height: 50),
            ],
          ),
          // Baseline at 30, height 40.
          Text('B', key: k2, style: TextStyle(fontSize: 40)),
        ],
      );

      // The column shifts down 15, so it ends at 15 + 70 = 85.
      expect(top(tester, k1), 15.0);
      expect(top(tester, k2), 0.0);
      expect(sideBySideSize(tester).height, 85.0);
    },
  );

  testWidgets('CrossAxisAlignment.baseline requires a textBaseline.', (tester) async {
    //
    expect(
      () => SideBySide(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        children: const [SizedBox(), SizedBox()],
      ),
      throwsAssertionError,
    );
  });

  testWidgets('RTL with MainAxisSize.min keeps the children inside the widget.', (
    tester,
  ) async {
    //
    await pump(
      tester,
      textDirection: TextDirection.rtl,
      mainAxisSize: MainAxisSize.min,
      children: const [
        SizedBox(key: k1, width: 30, height: 10),
        SizedBox(key: k2, width: 40, height: 10),
      ],
    );

    final Rect rect = tester.getRect(find.byType(SideBySide).first);
    expect(rect.width, 70.0);

    // The first child is on the right, and the last child on the left.
    expect(tester.getRect(find.byKey(k1)).right, rect.right);
    expect(tester.getRect(find.byKey(k2)).left, rect.left);
  });
}
