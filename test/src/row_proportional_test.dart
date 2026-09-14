import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  //
  const k1 = Key('1');
  const k2 = Key('2');
  const k3 = Key('3');
  const k4 = Key('4');

  /// Pumps a [RowProportional] inside a box of the given [width], and returns
  /// nothing. Sizes and positions can then be checked with [tester.getSize] and
  /// [tester.getTopLeft].
  Future<void> pump(
    WidgetTester tester, {
    required List<Widget> children,
    double width = 200,
    double? reservedPadding,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: width,
            height: 100,
            child: RowProportional(
              reservedPadding: reservedPadding,
              crossAxisAlignment: crossAxisAlignment,
              textDirection: textDirection,
              children: children,
            ),
          ),
        ),
      ),
    );
  }

  double left(WidgetTester tester, Key key) => tester.getTopLeft(find.byKey(key)).dx;

  double width(WidgetTester tester, Key key) => tester.getSize(find.byKey(key)).width;

  testWidgets('Distributes space proportionally to preferred widths.',
      (tester) async {
    //
    await pump(tester, width: 200, children: const [
      SizedBox(key: k1, width: 70, height: 10),
      SizedBox(key: k2, width: 100, height: 10),
    ]);

    expect(width(tester, k1), moreOrLessEquals(200 * 70 / 170));
    expect(width(tester, k2), moreOrLessEquals(200 * 100 / 170));

    // The second child starts exactly where the first one ends.
    expect(left(tester, k2) - left(tester, k1), moreOrLessEquals(200 * 70 / 170));
  });

  testWidgets('Shrinks children proportionally when space is short.',
      (tester) async {
    //
    await pump(tester, width: 100, children: const [
      SizedBox(key: k1, width: 70, height: 10),
      SizedBox(key: k2, width: 100, height: 10),
    ]);

    expect(width(tester, k1), moreOrLessEquals(100 * 70 / 170));
    expect(width(tester, k2), moreOrLessEquals(100 * 100 / 170));
  });

  testWidgets('Expanded multiplies the preferred width by the flex.',
      (tester) async {
    //
    await pump(tester, width: 200, children: const [
      Expanded(flex: 2, child: SizedBox(key: k1, width: 70, height: 10)),
      SizedBox(key: k2, width: 100, height: 10),
    ]);

    // Weights are 140 (70 * 2) and 100.
    expect(width(tester, k1), moreOrLessEquals(200 * 140 / 240));
    expect(width(tester, k2), moreOrLessEquals(200 * 100 / 240));
  });

  testWidgets('Flexible child may be smaller than its calculated width.',
      (tester) async {
    //
    await pump(tester, width: 200, children: const [
      Flexible(child: SizedBox(key: k1, width: 50, height: 10)),
      SizedBox(key: k2, width: 50, height: 10),
    ]);

    // Each child is reserved 100 pixels, but the Flexible one only takes its
    // preferred 50 pixels, aligned to the start of its reserved space. The
    // second child still starts at 100.
    expect(width(tester, k1), 50.0);
    expect(width(tester, k2), 100.0);
    expect(left(tester, k2) - left(tester, k1), 100.0);
  });

  testWidgets('A Spacer takes the leftover space, no proportional scaling.',
      (tester) async {
    //
    await pump(tester, width: 300, children: const [
      SizedBox(key: k1, width: 70, height: 10),
      Spacer(),
      SizedBox(key: k2, width: 100, height: 10),
    ]);

    // Children get their preferred widths; the Spacer gets 300-170 = 130.
    expect(width(tester, k1), 70.0);
    expect(width(tester, k2), 100.0);
    expect(left(tester, k2) - left(tester, k1), 70.0 + 130.0);
  });

  testWidgets('Multiple Spacers divide the leftover space by their flexes.',
      (tester) async {
    //
    await pump(tester, width: 370, children: const [
      SizedBox(key: k1, width: 70, height: 10),
      Spacer(),
      SizedBox(key: k2, width: 100, height: 10),
      Spacer(flex: 3),
      SizedBox(key: k3, width: 0, height: 10),
    ]);

    // Leftover is 370-170 = 200, divided 1:3 between the spacers: 50 and 150.
    expect(width(tester, k1), 70.0);
    expect(width(tester, k2), 100.0);
    expect(left(tester, k2) - left(tester, k1), 70.0 + 50.0);
    expect(left(tester, k3) - left(tester, k1), 70.0 + 50.0 + 100.0 + 150.0);
  });

  testWidgets('With Spacers but no leftover space, children shrink instead.',
      (tester) async {
    //
    await pump(tester, width: 85, children: const [
      SizedBox(key: k1, width: 70, height: 10),
      Spacer(),
      SizedBox(key: k2, width: 100, height: 10),
    ]);

    // The Spacer gets zero, and the children shrink proportionally to fit 85.
    expect(width(tester, k1), moreOrLessEquals(85 * 70 / 170));
    expect(width(tester, k2), moreOrLessEquals(85 * 100 / 170));
    expect(left(tester, k2) - left(tester, k1), moreOrLessEquals(85 * 70 / 170));
  });

  testWidgets('FixedWidth creates immutable gaps, carved out first.',
      (tester) async {
    //
    await pump(tester, width: 200, children: const [
      SizedBox(key: k1, width: 70, height: 10),
      FixedWidth(width: 8),
      SizedBox(key: k2, width: 100, height: 10),
    ]);

    // The 8 pixel gap is carved out; the remaining 192 is distributed 70:100.
    expect(width(tester, k1), moreOrLessEquals(192 * 70 / 170));
    expect(width(tester, k2), moreOrLessEquals(192 * 100 / 170));
    expect(left(tester, k2) - left(tester, k1),
        moreOrLessEquals(192 * 70 / 170 + 8));
  });

  testWidgets('FixedWidth pins its child to the exact given width.',
      (tester) async {
    //
    await pump(tester, width: 200, children: const [
      SizedBox(key: k1, width: 70, height: 10),
      FixedWidth(width: 40, child: SizedBox(key: k2, width: 100, height: 10)),
      SizedBox(key: k3, width: 90, height: 10),
    ]);

    // The pinned child is exactly 40, ignoring its preferred 100. The remaining
    // 160 is distributed 70:90 between the other two.
    expect(width(tester, k2), 40.0);
    expect(width(tester, k1), moreOrLessEquals(160 * 70 / 160));
    expect(width(tester, k3), moreOrLessEquals(160 * 90 / 160));
  });

  testWidgets('FixedWidth without width pins the child to its preferred width.',
      (tester) async {
    //
    await pump(tester, width: 200, children: const [
      SizedBox(key: k1, width: 70, height: 10),
      FixedWidth(child: SizedBox(key: k2, width: 40, height: 10)),
      SizedBox(key: k3, width: 100, height: 10),
    ]);

    // The middle child keeps its natural 40 pixels; the remaining 160 is
    // distributed 70:100 between the other two.
    expect(width(tester, k2), 40.0);
    expect(width(tester, k1), moreOrLessEquals(160 * 70 / 170));
    expect(width(tester, k3), moreOrLessEquals(160 * 100 / 170));

    // When space is short, the fixed child still keeps its 40 pixels,
    // and only the others shrink.
    await pump(tester, width: 100, children: const [
      SizedBox(key: k1, width: 70, height: 10),
      FixedWidth(child: SizedBox(key: k2, width: 40, height: 10)),
      SizedBox(key: k3, width: 100, height: 10),
    ]);

    expect(width(tester, k2), 40.0);
    expect(width(tester, k1), moreOrLessEquals(60 * 70 / 170));
    expect(width(tester, k3), moreOrLessEquals(60 * 100 / 170));
  });

  testWidgets('FixedWidth with no parameters is a zero width box.',
      (tester) async {
    //
    await pump(tester, width: 200, children: const [
      SizedBox(key: k1, width: 70, height: 10),
      FixedWidth(),
      SizedBox(key: k2, width: 100, height: 10),
    ]);

    // Same result as if the FixedWidth was not there.
    expect(width(tester, k1), moreOrLessEquals(200 * 70 / 170));
    expect(width(tester, k2), moreOrLessEquals(200 * 100 / 170));
    expect(left(tester, k2) - left(tester, k1), moreOrLessEquals(200 * 70 / 170));
  });

  testWidgets(
      'When the fixed widths alone exceed the available space, '
      'they shrink proportionally to each other.', (tester) async {
    //
    await pump(tester, width: 60, children: const [
      SizedBox(key: k1, width: 70, height: 10),
      FixedWidth(width: 40, child: SizedBox(key: k2, height: 10)),
      FixedWidth(child: SizedBox(key: k3, width: 80, height: 10)),
    ]);

    // The fixed widths total 120 (40 + 80), but only 60 is available: the fixed
    // children shrink by half (to 20 and 40), the proportional child gets zero,
    // and nothing overflows.
    expect(width(tester, k1), 0.0);
    expect(width(tester, k2), moreOrLessEquals(20.0));
    expect(width(tester, k3), moreOrLessEquals(40.0));
    expect(left(tester, k3) - left(tester, k2), moreOrLessEquals(20.0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('FixedWidth works together with Spacers.', (tester) async {
    //
    await pump(tester, width: 300, children: const [
      SizedBox(key: k1, width: 70, height: 10),
      FixedWidth(width: 10),
      Spacer(),
      SizedBox(key: k2, width: 100, height: 10),
    ]);

    // Fixed 10 is carved out, children keep 70 and 100, Spacer gets 120.
    expect(width(tester, k1), 70.0);
    expect(width(tester, k2), 100.0);
    expect(left(tester, k2) - left(tester, k1), 70.0 + 10.0 + 120.0);
  });

  testWidgets('Unbounded width: children get their preferred widths.',
      (tester) async {
    //
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: UnconstrainedBox(
            child: RowProportional(
              key: k4,
              children: [
                SizedBox(key: k1, width: 70, height: 10),
                FixedWidth(width: 8),
                Spacer(),
                SizedBox(key: k2, width: 100, height: 10),
              ],
            ),
          ),
        ),
      ),
    );

    // Nothing to distribute: preferred widths, the fixed gap, and a zero Spacer.
    expect(width(tester, k1), 70.0);
    expect(width(tester, k2), 100.0);
    expect(tester.getSize(find.byKey(k4)).width, 70.0 + 8.0 + 100.0);
  });

  testWidgets('Expanded child with zero preferred width acts as a Spacer.',
      (tester) async {
    //
    await pump(tester, width: 300, children: [
      const SizedBox(key: k1, width: 70, height: 10),
      Expanded(child: Container(key: k2, color: const Color(0xFFFF0000))),
      const SizedBox(key: k3, width: 100, height: 10),
    ]);

    expect(width(tester, k1), 70.0);
    expect(width(tester, k2), 130.0);
    expect(width(tester, k3), 100.0);
  });

  testWidgets('Right-to-left lays out the children in reverse.', (tester) async {
    //
    await pump(tester, width: 300, textDirection: TextDirection.rtl, children: const [
      SizedBox(key: k1, width: 70, height: 10),
      Spacer(),
      SizedBox(key: k2, width: 100, height: 10),
    ]);

    // The first child is at the far right, the last at the far left.
    expect(left(tester, k1) - left(tester, k2), 100.0 + 130.0);
  });

  testWidgets('CrossAxisAlignment.baseline aligns the text baselines.',
      (tester) async {
    //
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 200,
            child: RowProportional(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('A', key: k1, style: TextStyle(fontSize: 20)),
                Text('B', key: k2, style: TextStyle(fontSize: 40)),
                SizedBox(key: k3, width: 10, height: 50),
              ],
            ),
          ),
        ),
      ),
    );

    // The test font has its baseline at 75% of the font size, so the baselines
    // are at 15 and 30 pixels. To align them, the small text shifts down 15.
    final double topA = tester.getTopLeft(find.byKey(k1)).dy;
    final double topB = tester.getTopLeft(find.byKey(k2)).dy;
    final double topBox = tester.getTopLeft(find.byKey(k3)).dy;

    expect(topA - topB, 15.0);

    // Children with no baseline are aligned to the top, like in a Row.
    expect(topBox, topB);

    // The row is as tall as its tallest child (the 50 pixel box).
    expect(tester.getSize(find.byType(RowProportional)).height, 50.0);
  });

  testWidgets('Baseline alignment works with IntrinsicHeight (dry baselines).',
      (tester) async {
    //
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 200,
            child: IntrinsicHeight(
              child: RowProportional(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('A', key: k1, style: TextStyle(fontSize: 20)),
                  Text('B', key: k2, style: TextStyle(fontSize: 40)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Baselines at 15 and 30, heights 20 and 40: the small text shifts down 15
    // (occupying 15 to 35), so the row needs max(35, 40) = 40 pixels.
    expect(tester.getSize(find.byType(RowProportional)).height, 40.0);
    expect(
      tester.getTopLeft(find.byKey(k1)).dy - tester.getTopLeft(find.byKey(k2)).dy,
      15.0,
    );
  });

  testWidgets('CrossAxisAlignment aligns the children vertically.',
      (tester) async {
    //
    await pump(tester,
        width: 200,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(key: k1, width: 70, height: 10),
          SizedBox(key: k2, width: 100, height: 50),
        ]);

    expect(tester.getTopLeft(find.byKey(k1)).dy, tester.getTopLeft(find.byKey(k2)).dy);

    await pump(tester,
        width: 200,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          SizedBox(key: k1, width: 70, height: 10),
          SizedBox(key: k2, width: 100, height: 50),
        ]);

    // Stretch forces both children to the full available height.
    expect(tester.getSize(find.byKey(k1)).height, 100.0);
    expect(tester.getSize(find.byKey(k2)).height, 100.0);
  });

  testWidgets('Without the reservedPadding, the space is divided as it always was.',
      (tester) async {
    //
    // The default must divide the space exactly like it was divided before the
    // reservedPadding existed: proportionally to the preferred widths.
    for (final double rowWidth in [50.0, 170.0, 200.0, 700.0]) {
      //
      await pump(tester, width: rowWidth, children: const [
        SizedBox(key: k1, width: 70, height: 10),
        SizedBox(key: k2, width: 100, height: 10),
      ]);

      expect(width(tester, k1), moreOrLessEquals(rowWidth * 70 / 170));
      expect(width(tester, k2), moreOrLessEquals(rowWidth * 100 / 170));

      // Passing a null reservedPadding is exactly the same thing.
      await pump(tester, width: rowWidth, reservedPadding: null, children: const [
        SizedBox(key: k1, width: 70, height: 10),
        SizedBox(key: k2, width: 100, height: 10),
      ]);

      expect(width(tester, k1), moreOrLessEquals(rowWidth * 70 / 170));
      expect(width(tester, k2), moreOrLessEquals(rowWidth * 100 / 170));
    }

    // Expanded, FixedWidth and Spacer children are also divided as before.
    await pump(tester, width: 300, children: const [
      FixedWidth(width: 50, child: SizedBox(key: k1, height: 10)),
      Expanded(flex: 2, child: SizedBox(key: k2, width: 35, height: 10)),
      Spacer(),
      SizedBox(key: k3, width: 100, height: 10),
    ]);

    // The Spacer gets 300 - 50 - 70 - 100 = 80 pixels.
    expect(width(tester, k1), 50.0);
    expect(width(tester, k2), 70.0);
    expect(width(tester, k3), 100.0);
    expect(left(tester, k3) - left(tester, k1), 50.0 + 70.0 + 80.0);
  });

  testWidgets('Even a zero reservedPadding changes the way the space is divided.',
      (tester) async {
    //
    const children = [
      SizedBox(key: k1, width: 30, height: 10),
      SizedBox(key: k2, width: 70, height: 10),
    ];

    // It's the presence of the parameter that turns the behavior on, not its value:
    // the 100 extra pixels are divided equally, and not proportionally.
    await pump(tester, width: 200, reservedPadding: 0.0, children: children);
    expect(width(tester, k1), moreOrLessEquals(80.0));
    expect(width(tester, k2), moreOrLessEquals(120.0));

    // But with no padding to keep, shrinking is proportional, as usual.
    await pump(tester, width: 50, reservedPadding: 0.0, children: children);
    expect(width(tester, k1), moreOrLessEquals(15.0));
    expect(width(tester, k2), moreOrLessEquals(35.0));
  });

  testWidgets('With the reservedPadding, the extra space is divided equally.',
      (tester) async {
    //
    // Two texts of 30 and 70 pixels, each one inside a horizontal padding of 15.
    const children = [
      SizedBox(key: k1, width: 60, height: 10),
      SizedBox(key: k2, width: 100, height: 10),
    ];

    // The natural space: the children keep their preferred widths.
    await pump(tester, width: 160, reservedPadding: 30, children: children);
    expect(width(tester, k1), moreOrLessEquals(60.0));
    expect(width(tester, k2), moreOrLessEquals(100.0));

    // More space: the 700 - 160 = 540 extra pixels are divided equally.
    await pump(tester, width: 700, reservedPadding: 30, children: children);
    expect(width(tester, k1), moreOrLessEquals(60 + 270));
    expect(width(tester, k2), moreOrLessEquals(100 + 270));

    // The paddings do not change the extra space, only the preferred widths do.
    await pump(tester, width: 700, reservedPadding: 10, children: children);
    expect(width(tester, k1), moreOrLessEquals(60 + 270));
    expect(width(tester, k2), moreOrLessEquals(100 + 270));
  });

  testWidgets('With the reservedPadding, only the rest of the children shrink.',
      (tester) async {
    //
    const children = [
      SizedBox(key: k1, width: 60, height: 10),
      SizedBox(key: k2, width: 100, height: 10),
    ];

    // 2 * 30 pixels are kept for the paddings, and the other 40 pixels are
    // divided between the texts, proportionally to 30 and 70.
    await pump(tester, width: 100, reservedPadding: 30, children: children);
    expect(width(tester, k1), moreOrLessEquals(30 + 40 * 30 / 100));
    expect(width(tester, k2), moreOrLessEquals(30 + 40 * 70 / 100));

    // If there is not enough space for the paddings, they shrink too, so that
    // the row never overflows.
    await pump(tester, width: 40, reservedPadding: 30, children: children);
    expect(width(tester, k1), moreOrLessEquals(20.0));
    expect(width(tester, k2), moreOrLessEquals(20.0));
  });

  testWidgets('The reservedPadding does not affect FixedWidth children nor Spacers.',
      (tester) async {
    //
    // The fixed widths are still carved out of the space first: 250 pixels are
    // left, which is 90 more than the natural 160, divided equally.
    await pump(tester, width: 300, reservedPadding: 30, children: const [
      FixedWidth(width: 50, child: SizedBox(key: k1, height: 10)),
      SizedBox(key: k2, width: 60, height: 10),
      SizedBox(key: k3, width: 100, height: 10),
    ]);

    expect(width(tester, k1), moreOrLessEquals(50.0));
    expect(width(tester, k2), moreOrLessEquals(60 + 45));
    expect(width(tester, k3), moreOrLessEquals(100 + 45));

    // When the spacers get leftover space there is no distribution at all, and
    // the reserved padding does nothing.
    await pump(tester, width: 300, reservedPadding: 30, children: const [
      SizedBox(key: k1, width: 60, height: 10),
      Spacer(),
      SizedBox(key: k2, width: 100, height: 10),
    ]);

    expect(width(tester, k1), moreOrLessEquals(60.0));
    expect(width(tester, k2), moreOrLessEquals(100.0));
  });

  testWidgets('The reservedPadding does not affect the natural width of the row.',
      (tester) async {
    //
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: IntrinsicWidth(
          child: RowProportional(
            reservedPadding: 30,
            children: [
              SizedBox(key: k1, width: 60, height: 10),
              SizedBox(key: k2, width: 100, height: 10),
            ],
          ),
        ),
      ),
    ));

    // The row wants 60 + 100 pixels, and the children keep their natural widths.
    expect(tester.getSize(find.byType(RowProportional)).width, 160.0);
    expect(width(tester, k1), moreOrLessEquals(60.0));
    expect(width(tester, k2), moreOrLessEquals(100.0));
  });
}
