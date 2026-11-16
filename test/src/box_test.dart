import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  //
  const red = Color(0xFFFF0000);
  const k = Key('child');

  /// Pumps the [box] at the top-left of the screen.
  Future<void> pump(WidgetTester tester, Widget box) => tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(alignment: Alignment.topLeft, child: box),
        ),
      );

  Size boxSize(WidgetTester tester) => tester.getSize(find.byType(Box));

  group('Build', () {
    //
    testWidgets('Has the given width, height and color', (tester) async {
      await pump(tester, const Box(width: 50, height: 30, color: red));

      expect(boxSize(tester), const Size(50, 30));
      expect(
        find.byType(Box),
        paints..rect(rect: const Rect.fromLTWH(0, 0, 50, 30), color: red),
      );
    });

    testWidgets('Box.gap is a square', (tester) async {
      await pump(tester, const Box.gap(12));
      expect(boxSize(tester), const Size(12, 12));
    });

    testWidgets('Applies the padding and the alignment to the child', (tester) async {
      await pump(
        tester,
        const Box(
          padding: Pad(left: 10, top: 20, right: 30, bottom: 40),
          child: SizedBox(key: k, width: 50, height: 30),
        ),
      );
      expect(boxSize(tester), const Size(90, 90));
      expect(tester.getTopLeft(find.byKey(k)), const Offset(10, 20));

      await pump(
        tester,
        const Box(
          width: 100,
          height: 100,
          alignment: Alignment.bottomRight,
          child: SizedBox(key: k, width: 50, height: 30),
        ),
      );
      expect(boxSize(tester), const Size(100, 100));
      expect(tester.getTopLeft(find.byKey(k)), const Offset(50, 70));
    });

    testWidgets('The padding of a box with no child may be removed', (tester) async {
      await pump(tester, const Box(padding: Pad(all: 10)));
      expect(boxSize(tester), const Size(20, 20));

      await pump(tester, const Box(padding: Pad(all: 10), removePaddingWhenNoChild: true));
      expect(boxSize(tester), const Size(800, 600));

      await pump(
        tester,
        const Box(
          padding: Pad(all: 10),
          removePaddingWhenNoChild: true,
          child: SizedBox(width: 50, height: 30),
        ),
      );
      expect(boxSize(tester), const Size(70, 50));
    });

    testWidgets('Occupies no space when not shown', (tester) async {
      await pump(tester, const Box(show: false, width: 50, height: 30, color: red));

      expect(boxSize(tester), Size.zero);
      expect(find.byType(Box), paintsNothing);
    });

    testWidgets('The color is added to the decoration', (tester) async {
      await pump(
        tester,
        const Box(
          width: 50,
          height: 30,
          color: red,
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
      );

      expect(
        find.byType(Box),
        paints
          ..rrect(
            rrect: RRect.fromLTRBR(0, 0, 50, 30, const Radius.circular(8)),
            color: red,
          ),
      );
    });
  });

  group('Copies', () {
    //
    test('The + operator replaces a single field', () {
      const box = Box(width: 50, height: 30, color: red, padding: Pad(all: 4));

      expect((box + false).show, isFalse);
      expect((box + Colors.blue).color, Colors.blue);
      expect((box + const Pad(all: 8)).padding, const Pad(all: 8));
      expect((box + Alignment.topLeft).alignment, Alignment.topLeft);

      const child = SizedBox();
      final Box withChild = box + child;
      expect(withChild.child, same(child));
      expect(withChild.width, 50);
      expect(withChild.height, 30);
      expect(withChild.color, red);
      expect(withChild.padding, const Pad(all: 4));

      expect(box + null, same(box));
      expect(() => box + 123, throwsArgumentError);
    });

    test('The copies keep removePaddingWhenNoChild', () {
      const box = Box(padding: Pad(all: 4), removePaddingWhenNoChild: true);

      expect(box.copyWith(width: 10).removePaddingWhenNoChild, isTrue);
      expect((box + Colors.blue).removePaddingWhenNoChild, isTrue);
      expect(box.add(width: 10).removePaddingWhenNoChild, isTrue);

      expect(const Box().copyWith(width: 10).removePaddingWhenNoChild, isFalse);
    });

    test('add and subtract change the width and the height', () {
      const box = Box(width: 50, height: 30);

      expect(box.add(width: 10).size, const Size(60, 30));
      expect(box.add(height: 10).size, const Size(50, 40));
      expect(box.add(width: 5, height: 10).size, const Size(55, 40));
      expect(box.add(width: -100).size, const Size(0, 30));

      expect(box.subtract(width: 10).size, const Size(40, 30));
      expect(box.subtract(height: 10).size, const Size(50, 20));
      expect(box.subtract(width: 100, height: 100).size, Size.zero);
    });
  });
}
