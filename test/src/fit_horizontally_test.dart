import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  //
  const k = Key('child');

  Widget child(double width, double height) =>
      SizedBox(key: k, width: width, height: height);

  /// Pumps the [fit] at the top-left of the screen, with a width of 100 pixels.
  Future<void> pump(WidgetTester tester, Widget fit) => tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 100, child: fit),
          ),
        ),
      );

  /// The size the child was laid out with (before being scaled).
  Size childSize(WidgetTester tester) => tester.getSize(find.byKey(k));

  /// The area the child occupies in the screen (after being scaled).
  Rect childRect(WidgetTester tester) => tester.getRect(find.byKey(k));

  Size fitSize(WidgetTester tester) => tester.getSize(find.byType(FitHorizontally));

  testWidgets("A child that fits is not scaled, and is aligned", (tester) async {
    await pump(tester, FitHorizontally(child: child(50, 20)));
    expect(fitSize(tester), const Size(100, 20));
    expect(childSize(tester), const Size(50, 20));
    expect(childRect(tester), const Rect.fromLTWH(25, 0, 50, 20));

    await pump(
      tester,
      FitHorizontally(alignment: Alignment.centerLeft, child: child(50, 20)),
    );
    expect(childRect(tester), const Rect.fromLTWH(0, 0, 50, 20));

    await pump(
      tester,
      FitHorizontally(alignment: Alignment.centerRight, child: child(50, 20)),
    );
    expect(childRect(tester), const Rect.fromLTWH(50, 0, 50, 20));
  });

  testWidgets("A child that doesn't fit shrinks horizontally", (tester) async {
    await pump(tester, FitHorizontally(child: child(120, 20)));

    expect(fitSize(tester), const Size(100, 20));
    expect(childSize(tester).width, moreOrLessEquals(120));
    expect(childRect(tester), rectMoreOrLessEquals(const Rect.fromLTWH(0, 0, 100, 20)));
  });

  testWidgets('The child only shrinks until the shrink limit', (tester) async {
    // The default limit is 67%.
    await pump(tester, FitHorizontally(child: child(200, 20)));
    expect(childSize(tester).width, moreOrLessEquals(100 / 0.67));
    expect(childRect(tester), rectMoreOrLessEquals(const Rect.fromLTWH(0, 0, 100, 20)));

    // No limit.
    await pump(tester, FitHorizontally(shrinkLimit: 0.0, child: child(200, 20)));
    expect(childSize(tester).width, moreOrLessEquals(200));
    expect(childRect(tester), rectMoreOrLessEquals(const Rect.fromLTWH(0, 0, 100, 20)));

    // Doesn't shrink at all.
    await pump(tester, FitHorizontally(shrinkLimit: 1.0, child: child(200, 20)));
    expect(childSize(tester), const Size(100, 20));
    expect(childRect(tester), const Rect.fromLTWH(0, 0, 100, 20));
  });

  testWidgets('Changing the shrink limit lays out the child again', (tester) async {
    await pump(tester, FitHorizontally(shrinkLimit: 0.5, child: child(200, 20)));
    expect(childSize(tester).width, moreOrLessEquals(200));

    await pump(tester, FitHorizontally(shrinkLimit: 0.8, child: child(200, 20)));
    expect(childSize(tester).width, moreOrLessEquals(125));
    expect(childRect(tester), rectMoreOrLessEquals(const Rect.fromLTWH(0, 0, 100, 20)));

    await pump(tester, FitHorizontally(shrinkLimit: 1.0, child: child(200, 20)));
    expect(childSize(tester).width, 100);
  });

  testWidgets('Changing fitsHeight lays out the child again', (tester) async {
    Future<void> pumpWith({required bool fitsHeight}) => tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 100,
                height: 40,
                child: FitHorizontally(
                  shrinkLimit: 1.0,
                  fitsHeight: fitsHeight,
                  child: child(50, 20),
                ),
              ),
            ),
          ),
        );

    await pumpWith(fitsHeight: false);
    final Rect notFitted = childRect(tester);
    expect(notFitted, const Rect.fromLTWH(25, 10, 50, 20));

    // The child is now scaled to fit the height, keeping its aspect ratio.
    await pumpWith(fitsHeight: true);
    expect(childSize(tester), const Size(50, 20));
    expect(childRect(tester), rectMoreOrLessEquals(const Rect.fromLTWH(0, 0, 100, 40)));

    await pumpWith(fitsHeight: false);
    expect(childRect(tester), notFitted);
  });

  testWidgets('fitsHeight gives the same result with and without a shrink limit',
      (tester) async {
    Future<void> pumpWith({required double shrinkLimit}) => tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 100,
                height: 40,
                child: FitHorizontally(
                  shrinkLimit: shrinkLimit,
                  fitsHeight: true,
                  child: child(50, 20),
                ),
              ),
            ),
          ),
        );

    // The child fits when scaled by 2, so the shrink limit makes no difference.
    await pumpWith(shrinkLimit: 0.5);
    expect(childSize(tester), const Size(50, 20));
    expect(childRect(tester), rectMoreOrLessEquals(const Rect.fromLTWH(0, 0, 100, 40)));

    await pumpWith(shrinkLimit: 1.0);
    expect(childSize(tester), const Size(50, 20));
    expect(childRect(tester), rectMoreOrLessEquals(const Rect.fromLTWH(0, 0, 100, 40)));
  });

  testWidgets('The child can be tapped where it is painted', (tester) async {
    int taps = 0;

    await pump(
      tester,
      FitHorizontally(
        child: GestureDetector(
          onTap: () => taps++,
          child: const SizedBox(width: 120, height: 20, child: ColoredBox(color: Colors.red)),
        ),
      ),
    );

    await tester.tapAt(const Offset(98, 10));
    await tester.tapAt(const Offset(2, 10));
    expect(taps, 2);
  });

  testWidgets('Works without a child', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 100, height: 50, child: FitHorizontally()),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(fitSize(tester), const Size(100, 50));
  });

  testWidgets('Can be described when the alignment is directional', (tester) async {
    await pump(
      tester,
      FitHorizontally(
        alignment: AlignmentDirectional.centerStart,
        child: child(50, 20),
      ),
    );

    expect(childRect(tester), const Rect.fromLTWH(0, 0, 50, 20));

    final renderObject = tester.renderObject(find.byType(FitHorizontally));
    expect(() => renderObject.toStringDeep(), returnsNormally);
  });
}
