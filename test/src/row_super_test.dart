import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'probe.dart';

void main() {
  //
  const k0 = Key('0');
  const k1 = Key('1');
  const k2 = Key('2');

  const red = Color(0xFFFF0000);
  const green = Color(0xFF00FF00);
  const blue = Color(0xFF0000FF);
  const black = Color(0xFF000000);

  /// A colored cell with a fixed size.
  Widget cell(Key key, double width, double height, [Color color = red]) => SizedBox(
        key: key,
        width: width,
        height: height,
        child: ColoredBox(color: color),
      );

  List<Widget> cells() => [cell(k0, 40, 20), cell(k1, 60, 30), cell(k2, 20, 10)];

  /// Pumps the [row] at the top-left of the screen (which is 800 x 600). If the
  /// [width] is given, the row is forced to have that width.
  Future<void> pump(WidgetTester tester, Widget row, {double? width}) =>
      tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: (width == null) ? row : SizedBox(width: width, child: row),
          ),
        ),
      );

  Rect rect(WidgetTester tester, Key key) => tester.getRect(find.byKey(key));

  Size rowSize(WidgetTester tester) => tester.getSize(find.byType(RowSuper));

  group('Layout', () {
    //
    testWidgets('Applies the outer and inner distances, and centers the cells',
        (tester) async {
      await pump(tester, RowSuper(outerDistance: 5, innerDistance: 3, children: cells()));

      expect(rowSize(tester), const Size(136, 30));
      expect(rect(tester, k0), const Rect.fromLTWH(5, 5, 40, 20));
      expect(rect(tester, k1), const Rect.fromLTWH(48, 0, 60, 30));
      expect(rect(tester, k2), const Rect.fromLTWH(111, 10, 20, 10));
    });

    testWidgets('Aligns the cells vertically', (tester) async {
      await pump(tester, RowSuper(alignment: Alignment.topCenter, children: cells()));
      expect(rect(tester, k0).top, 0);

      await pump(tester, RowSuper(alignment: Alignment.bottomCenter, children: cells()));
      expect(rect(tester, k0).top, 10);
    });

    testWidgets('MainAxisSize.max fills the width, and aligns the cells horizontally',
        (tester) async {
      Future<void> pumpAligned(Alignment alignment) => pump(
            tester,
            RowSuper(
              outerDistance: 5,
              innerDistance: 3,
              mainAxisSize: MainAxisSize.max,
              alignment: alignment,
              children: cells(),
            ),
          );

      await pumpAligned(Alignment.centerLeft);
      expect(rowSize(tester), const Size(800, 30));
      expect(rect(tester, k0).left, 5);

      await pumpAligned(Alignment.center);
      expect(rect(tester, k0).left, 337);

      await pumpAligned(Alignment.centerRight);
      expect(rect(tester, k0).left, 669);
    });

    testWidgets("Cells that don't fit shrink proportionally to their widths",
        (tester) async {
      await pump(
        tester,
        RowSuper(outerDistance: 5, innerDistance: 3, children: cells()),
        width: 70,
      );

      expect(rowSize(tester), const Size(70, 30));
      expect(rect(tester, k0), rectMoreOrLessEquals(const Rect.fromLTWH(5, 5, 18, 20)));
      expect(rect(tester, k1), rectMoreOrLessEquals(const Rect.fromLTWH(26, 0, 27, 30)));
      expect(rect(tester, k2), rectMoreOrLessEquals(const Rect.fromLTWH(56, 10, 9, 10)));
    });

    testWidgets('Fill grows the cells proportionally to their widths', (tester) async {
      await pump(
        tester,
        RowSuper(outerDistance: 5, innerDistance: 3, fill: true, children: cells()),
        width: 300,
      );

      const double scale = 284 / 120;
      expect(rowSize(tester), const Size(300, 30));
      expect(
        rect(tester, k0),
        rectMoreOrLessEquals(const Rect.fromLTWH(5, 5, 40 * scale, 20)),
      );
      expect(
        rect(tester, k1),
        rectMoreOrLessEquals(const Rect.fromLTWH(8 + 40 * scale, 0, 60 * scale, 30)),
      );
      expect(
        rect(tester, k2),
        rectMoreOrLessEquals(const Rect.fromLTWH(11 + 100 * scale, 10, 20 * scale, 10)),
      );
    });

    testWidgets('A RowSpacer gets the free space', (tester) async {
      await pump(
        tester,
        RowSuper(children: [cell(k0, 40, 20), RowSpacer(), cell(k1, 60, 30)]),
        width: 300,
      );

      expect(rowSize(tester), const Size(300, 30));
      expect(rect(tester, k0).left, 0);
      expect(rect(tester, k1).left, 240);
    });

    testWidgets('Null children are ignored', (tester) async {
      await pump(
        tester,
        RowSuper(
          innerDistance: 3,
          children: [null, cell(k0, 40, 20), null, cell(k1, 60, 30), null],
        ),
      );

      expect(rowSize(tester), const Size(103, 30));
      expect(rect(tester, k1).left, 43);
    });

    testWidgets('No children', (tester) async {
      await pump(tester, RowSuper(outerDistance: 5, children: const []));
      expect(rowSize(tester), Size.zero);

      // The separator is not used when there are no children.
      await pump(
        tester,
        RowSuper(outerDistance: 5, separator: cell(k0, 2, 16), children: const []),
      );
      expect(rowSize(tester), Size.zero);
      expect(find.byKey(k0), findsNothing);
    });

    testWidgets('fitHorizontally wraps the cells (but not the spacers)', (tester) async {
      await pump(
        tester,
        RowSuper(
          fitHorizontally: true,
          shrinkLimit: 0.5,
          children: [cell(k0, 40, 20), RowSpacer(), cell(k1, 60, 30)],
        ),
        width: 300,
      );

      final Iterable<FitHorizontally> fits =
          tester.widgetList<FitHorizontally>(find.byType(FitHorizontally));
      expect(fits.length, 2);
      expect(fits.every((fit) => fit.shrinkLimit == 0.5), isTrue);
      expect(rect(tester, k1).left, 240);
    });
  });

  group('Separator and paint order', () {
    //
    RowSuper row({bool invert = false, bool separatorOnTop = true}) => RowSuper(
          innerDistance: 10,
          invert: invert,
          separatorOnTop: separatorOnTop,
          separator: cell(const Key('separator'), 2, 16, black),
          children: [
            cell(k0, 20, 40, red),
            cell(k1, 20, 40, green),
            cell(k2, 20, 40, blue),
          ],
        );

    const cell0 = Rect.fromLTWH(0, 0, 20, 40);
    const cell1 = Rect.fromLTWH(30, 0, 20, 40);
    const cell2 = Rect.fromLTWH(60, 0, 20, 40);

    // The separators are centered in the gaps between the cells.
    const separator1 = Rect.fromLTWH(24, 12, 2, 16);
    const separator2 = Rect.fromLTWH(54, 12, 2, 16);

    testWidgets('The separator occupies no space', (tester) async {
      await pump(tester, row());
      expect(rowSize(tester), const Size(80, 40));
    });

    testWidgets('Separators are painted on top of the cells', (tester) async {
      await pump(tester, row());

      expect(
        find.byType(RowSuper),
        paints
          ..rect(rect: cell0, color: red)
          ..rect(rect: cell1, color: green)
          ..rect(rect: separator1, color: black)
          ..rect(rect: cell2, color: blue)
          ..rect(rect: separator2, color: black),
      );
    });

    testWidgets('Separators are painted below the cells', (tester) async {
      await pump(tester, row(separatorOnTop: false));

      expect(
        find.byType(RowSuper),
        paints
          ..rect(rect: separator1, color: black)
          ..rect(rect: separator2, color: black)
          ..rect(rect: cell0, color: red)
          ..rect(rect: cell1, color: green)
          ..rect(rect: cell2, color: blue),
      );
    });

    testWidgets('Invert paints the first cells on top, with the same separators',
        (tester) async {
      await pump(tester, row(invert: true));

      expect(
        find.byType(RowSuper),
        paints
          ..rect(rect: cell2, color: blue)
          ..rect(rect: cell1, color: green)
          ..rect(rect: separator2, color: black)
          ..rect(rect: cell0, color: red)
          ..rect(rect: separator1, color: black),
      );
    });

    testWidgets('Invert, with the separators below the cells', (tester) async {
      await pump(tester, row(invert: true, separatorOnTop: false));

      expect(
        find.byType(RowSuper),
        paints
          ..rect(rect: separator2, color: black)
          ..rect(rect: separator1, color: black)
          ..rect(rect: cell2, color: blue)
          ..rect(rect: cell1, color: green)
          ..rect(rect: cell0, color: red),
      );
    });
  });

  group('Hit test', () {
    //
    late List<String> taps;

    setUp(() => taps = []);

    Widget tappable(String name, double width, double height) => GestureDetector(
          onTap: () => taps.add(name),
          child: SizedBox(
            width: width,
            height: height,
            child: const ColoredBox(color: red),
          ),
        );

    testWidgets('Where the cells overlap, the cell painted on top is hit',
        (tester) async {
      Future<void> pumpOverlapped({required bool invert}) => pump(
            tester,
            RowSuper(
              innerDistance: -10,
              invert: invert,
              children: [tappable('first', 30, 100), tappable('second', 30, 100)],
            ),
          );

      // The cells overlap from 20 to 30.
      await pumpOverlapped(invert: false);
      await tester.tapAt(const Offset(25, 50));
      await tester.tapAt(const Offset(10, 50));
      await tester.tapAt(const Offset(40, 50));
      expect(taps, ['second', 'first', 'second']);

      taps.clear();
      await pumpOverlapped(invert: true);
      await tester.tapAt(const Offset(25, 50));
      await tester.tapAt(const Offset(10, 50));
      await tester.tapAt(const Offset(40, 50));
      expect(taps, ['first', 'first', 'second']);
    });

    testWidgets("The separator doesn't get the taps of the cells", (tester) async {
      await pump(
        tester,
        RowSuper(
          innerDistance: 10,
          separator: tappable('separator', 10, 40),
          children: [tappable('first', 30, 100), tappable('second', 30, 100)],
        ),
      );

      await tester.tapAt(const Offset(5, 5));
      expect(taps, ['first']);
    });
  });

  group('Intrinsic sizes', () {
    //
    testWidgets('Width includes the distances, and height is the tallest cell',
        (tester) async {
      await pump(
        tester,
        RowSuper(
          outerDistance: 5,
          innerDistance: 3,
          separator: cell(const Key('separator'), 2, 400),
          children: cells(),
        ),
      );

      final render = tester.renderObject<RenderBox>(find.byType(RowSuper));
      expect(render.getMinIntrinsicWidth(double.infinity), 136);
      expect(render.getMaxIntrinsicWidth(double.infinity), 136);
      expect(render.getMinIntrinsicHeight(double.infinity), 30);
      expect(render.getMaxIntrinsicHeight(double.infinity), 30);
    });

    testWidgets('Works inside IntrinsicWidth and IntrinsicHeight', (tester) async {
      await pump(
        tester,
        IntrinsicWidth(
          child: IntrinsicHeight(child: RowSuper(innerDistance: 3, children: cells())),
        ),
      );

      expect(rowSize(tester), const Size(126, 30));
    });
  });

  testWidgets('Updates when its parameters and children change', (tester) async {
    await pump(tester, RowSuper(innerDistance: 3, children: cells()));
    expect(rowSize(tester), const Size(126, 30));

    await pump(
      tester,
      RowSuper(
        innerDistance: 10,
        outerDistance: 2,
        children: [cell(k0, 40, 20), cell(k1, 60, 50)],
      ),
    );
    expect(rowSize(tester), const Size(114, 50));
    expect(rect(tester, k1), const Rect.fromLTWH(52, 0, 60, 50));
  });

  group('Performance', () {
    //
    testWidgets(
        'The preferred widths of the cells are only calculated again '
        'when the cells change', (tester) async {
      final log = ProbeLog();

      Future<void> pumpWith({required double width, double cellWidth = 40}) => pump(
            tester,
            RowSuper(
              children: [
                Probe(log: log, child: cell(k0, cellWidth, 20)),
                Probe(log: log, child: cell(k1, 60, 30)),
                Probe(log: log, child: cell(k2, 20, 10)),
              ],
            ),
            width: width,
          );

      // First layout: the preferred width of each of the 3 cells is calculated.
      await pumpWith(width: 300);
      expect(log.maxIntrinsicWidths, 3);

      // The available width changes, but the cells don't: Nothing is calculated again.
      log.reset();
      await pumpWith(width: 100);
      await pumpWith(width: 60);
      await pumpWith(width: 250);
      expect(log.maxIntrinsicWidths, 0);
      expect(rect(tester, k0).width, 40);

      // Only the first cell changes: Only its preferred width is calculated again.
      await pumpWith(width: 250, cellWidth: 50);
      expect(log.maxIntrinsicWidths, 1);
      expect(rect(tester, k0).width, 50);
      expect(rect(tester, k1).left, 50);
    });
  });
}
