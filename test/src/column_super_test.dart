import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

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

  /// Pumps the [column] at the top-left of the screen, with loose constraints.
  Future<void> pump(WidgetTester tester, Widget column) => tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(alignment: Alignment.topLeft, child: column),
        ),
      );

  Rect rect(WidgetTester tester, Key key) => tester.getRect(find.byKey(key));

  Size columnSize(WidgetTester tester) => tester.getSize(find.byType(ColumnSuper));

  group('Layout', () {
    //
    testWidgets('Applies the outer and inner distances, and centers the cells',
        (tester) async {
      await pump(
        tester,
        ColumnSuper(
          outerDistance: 5,
          innerDistance: 3,
          children: [cell(k0, 100, 20), cell(k1, 60, 30), cell(k2, 80, 10)],
        ),
      );

      expect(columnSize(tester), const Size(100, 76));
      expect(rect(tester, k0), const Rect.fromLTWH(0, 5, 100, 20));
      expect(rect(tester, k1), const Rect.fromLTWH(20, 28, 60, 30));
      expect(rect(tester, k2), const Rect.fromLTWH(10, 61, 80, 10));
    });

    testWidgets('Aligns the cells horizontally', (tester) async {
      Future<void> pumpAligned(Alignment alignment) => pump(
            tester,
            ColumnSuper(
              alignment: alignment,
              children: [cell(k0, 100, 20), cell(k1, 60, 30)],
            ),
          );

      await pumpAligned(Alignment.centerLeft);
      expect(rect(tester, k1).left, 0);

      await pumpAligned(Alignment.center);
      expect(rect(tester, k1).left, 20);

      await pumpAligned(Alignment.centerRight);
      expect(rect(tester, k1).left, 40);
    });

    testWidgets('A negative inner distance overlaps the cells', (tester) async {
      await pump(
        tester,
        ColumnSuper(
          innerDistance: -5,
          children: [cell(k0, 100, 20), cell(k1, 100, 30)],
        ),
      );

      expect(columnSize(tester), const Size(100, 45));
      expect(rect(tester, k1).top, 15);
    });

    testWidgets('Null children are ignored', (tester) async {
      await pump(
        tester,
        ColumnSuper(
          innerDistance: 3,
          children: [null, cell(k0, 100, 20), null, cell(k1, 60, 30), null],
        ),
      );

      expect(columnSize(tester), const Size(100, 53));
      expect(rect(tester, k1).top, 23);
    });

    testWidgets('No children', (tester) async {
      await pump(tester, ColumnSuper(outerDistance: 5, children: const []));
      expect(columnSize(tester), Size.zero);

      // The separator is not used when there are no children.
      await pump(
        tester,
        ColumnSuper(outerDistance: 5, separator: cell(k0, 40, 2), children: const []),
      );
      expect(columnSize(tester), Size.zero);
      expect(find.byKey(k0), findsNothing);
    });

    testWidgets('Is as wide as the available width, at most', (tester) async {
      await pump(
        tester,
        SizedBox(
          width: 50,
          child: ColumnSuper(children: [cell(k0, 100, 20), cell(k1, 30, 30)]),
        ),
      );

      expect(columnSize(tester), const Size(50, 50));
      expect(rect(tester, k0), const Rect.fromLTWH(0, 0, 50, 20));
      expect(rect(tester, k1), const Rect.fromLTWH(10, 20, 30, 30));
    });
  });

  group('removeChildrenWithNoHeight', () {
    //
    List<Widget> children() => [cell(k0, 100, 20), cell(k1, 50, 0), cell(k2, 80, 10)];

    testWidgets('When false, zero height cells still get an inner distance',
        (tester) async {
      await pump(
        tester,
        ColumnSuper(outerDistance: 5, innerDistance: 3, children: children()),
      );

      expect(columnSize(tester), const Size(100, 46));
      expect(rect(tester, k2).top, 31);
    });

    testWidgets('When true, zero height cells get no inner distance', (tester) async {
      await pump(
        tester,
        ColumnSuper(
          outerDistance: 5,
          innerDistance: 3,
          removeChildrenWithNoHeight: true,
          children: children(),
        ),
      );

      expect(columnSize(tester), const Size(100, 43));
      expect(rect(tester, k1).top, 28);
      expect(rect(tester, k2).top, 28);
    });

    testWidgets('When true and all cells have zero height, there is no outer distance',
        (tester) async {
      await pump(
        tester,
        ColumnSuper(
          outerDistance: 5,
          innerDistance: 3,
          removeChildrenWithNoHeight: true,
          children: [cell(k0, 100, 0), cell(k1, 50, 0)],
        ),
      );

      expect(columnSize(tester), const Size(100, 0));
    });

    testWidgets('No separator is painted before the first cell with height',
        (tester) async {
      await pump(
        tester,
        ColumnSuper(
          innerDistance: 10,
          removeChildrenWithNoHeight: true,
          separator: cell(const Key('separator'), 40, 2, black),
          children: [
            cell(k0, 100, 0),
            cell(k1, 100, 20, green),
            cell(k2, 100, 20, blue),
          ],
        ),
      );

      // The only separator is the one between the two cells with height.
      expect(
        find.byType(ColumnSuper),
        paints
          ..rect(rect: const Rect.fromLTWH(0, 0, 100, 20), color: green)
          ..rect(rect: const Rect.fromLTWH(0, 30, 100, 20), color: blue)
          ..rect(rect: const Rect.fromLTWH(30, 24, 40, 2), color: black),
      );
    });
  });

  group('Separator and paint order', () {
    //
    ColumnSuper column({bool invert = false, bool separatorOnTop = true}) => ColumnSuper(
          innerDistance: 10,
          invert: invert,
          separatorOnTop: separatorOnTop,
          separator: cell(const Key('separator'), 40, 2, black),
          children: [
            cell(k0, 100, 20, red),
            cell(k1, 100, 20, green),
            cell(k2, 100, 20, blue),
          ],
        );

    const cell0 = Rect.fromLTWH(0, 0, 100, 20);
    const cell1 = Rect.fromLTWH(0, 30, 100, 20);
    const cell2 = Rect.fromLTWH(0, 60, 100, 20);

    // The separators are centered in the gaps between the cells.
    const separator1 = Rect.fromLTWH(30, 24, 40, 2);
    const separator2 = Rect.fromLTWH(30, 54, 40, 2);

    testWidgets('The separator occupies no space', (tester) async {
      await pump(tester, column());
      expect(columnSize(tester), const Size(100, 80));
    });

    testWidgets('Separators are painted on top of the cells', (tester) async {
      await pump(tester, column());

      expect(
        find.byType(ColumnSuper),
        paints
          ..rect(rect: cell0, color: red)
          ..rect(rect: cell1, color: green)
          ..rect(rect: separator1, color: black)
          ..rect(rect: cell2, color: blue)
          ..rect(rect: separator2, color: black),
      );
    });

    testWidgets('Separators are painted below the cells', (tester) async {
      await pump(tester, column(separatorOnTop: false));

      expect(
        find.byType(ColumnSuper),
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
      await pump(tester, column(invert: true));

      expect(
        find.byType(ColumnSuper),
        paints
          ..rect(rect: cell2, color: blue)
          ..rect(rect: cell1, color: green)
          ..rect(rect: separator2, color: black)
          ..rect(rect: cell0, color: red)
          ..rect(rect: separator1, color: black),
      );
    });

    testWidgets('Invert, with the separators below the cells', (tester) async {
      await pump(tester, column(invert: true, separatorOnTop: false));

      expect(
        find.byType(ColumnSuper),
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
            ColumnSuper(
              innerDistance: -10,
              invert: invert,
              children: [tappable('first', 100, 30), tappable('second', 100, 30)],
            ),
          );

      // The cells overlap from 20 to 30.
      await pumpOverlapped(invert: false);
      await tester.tapAt(const Offset(50, 25));
      await tester.tapAt(const Offset(50, 10));
      await tester.tapAt(const Offset(50, 40));
      expect(taps, ['second', 'first', 'second']);

      taps.clear();
      await pumpOverlapped(invert: true);
      await tester.tapAt(const Offset(50, 25));
      await tester.tapAt(const Offset(50, 10));
      await tester.tapAt(const Offset(50, 40));
      expect(taps, ['first', 'first', 'second']);
    });

    testWidgets("The separator doesn't get the taps of the cells", (tester) async {
      await pump(
        tester,
        ColumnSuper(
          innerDistance: 10,
          separator: tappable('separator', 40, 10),
          children: [tappable('first', 100, 30), tappable('second', 100, 30)],
        ),
      );

      await tester.tapAt(const Offset(5, 5));
      expect(taps, ['first']);
    });
  });

  group('Intrinsic sizes', () {
    //
    RenderBox renderColumn(WidgetTester tester) =>
        tester.renderObject<RenderBox>(find.byType(ColumnSuper));

    testWidgets('Width is the widest cell, and height includes the distances',
        (tester) async {
      await pump(
        tester,
        ColumnSuper(
          outerDistance: 5,
          innerDistance: 3,
          separator: cell(const Key('separator'), 400, 2),
          children: [cell(k0, 100, 20), cell(k1, 60, 30), cell(k2, 80, 10)],
        ),
      );

      final RenderBox render = renderColumn(tester);
      expect(render.getMinIntrinsicWidth(double.infinity), 100);
      expect(render.getMaxIntrinsicWidth(double.infinity), 100);
      expect(render.getMinIntrinsicHeight(double.infinity), 76);
      expect(render.getMaxIntrinsicHeight(double.infinity), 76);
    });

    testWidgets('Zero height cells are removed from the intrinsic height',
        (tester) async {
      await pump(
        tester,
        ColumnSuper(
          outerDistance: 5,
          innerDistance: 3,
          removeChildrenWithNoHeight: true,
          children: [cell(k0, 100, 20), cell(k1, 50, 0), cell(k2, 80, 10)],
        ),
      );

      expect(renderColumn(tester).getMaxIntrinsicHeight(double.infinity), 43);
    });

    testWidgets('Works inside IntrinsicWidth and IntrinsicHeight', (tester) async {
      await pump(
        tester,
        IntrinsicWidth(
          child: IntrinsicHeight(
            child: ColumnSuper(
              innerDistance: 3,
              children: [cell(k0, 100, 20), cell(k1, 60, 30)],
            ),
          ),
        ),
      );

      expect(columnSize(tester), const Size(100, 53));
    });
  });

  testWidgets('Updates when its parameters and children change', (tester) async {
    await pump(
      tester,
      ColumnSuper(innerDistance: 3, children: [cell(k0, 100, 20), cell(k1, 60, 30)]),
    );
    expect(columnSize(tester), const Size(100, 53));

    await pump(
      tester,
      ColumnSuper(
        innerDistance: 10,
        outerDistance: 2,
        children: [cell(k0, 100, 20), cell(k1, 60, 30), cell(k2, 120, 10)],
      ),
    );
    expect(columnSize(tester), const Size(120, 84));
    expect(rect(tester, k2), const Rect.fromLTWH(0, 72, 120, 10));
  });
}
