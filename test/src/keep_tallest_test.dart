import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  //
  const k = Key('child');

  /// Pumps a [KeepTallest] at the top-left of the screen, with a child of the given
  /// [childHeight]. Then pumps another frame, since the [KeepTallest] only applies
  /// the height of its child in the frame after the child is laid out.
  Future<void> pump(
    WidgetTester tester, {
    required double childHeight,
    bool shrink = false,
    double minShrinkDifference = 0,
  }) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 200,
            child: KeepTallest(
              shrink: shrink,
              minShrinkDifference: minShrinkDifference,
              child: SizedBox(key: k, height: childHeight),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  double height(WidgetTester tester) => tester.getSize(find.byType(KeepTallest)).height;

  double childHeight(WidgetTester tester) => tester.getSize(find.byKey(k)).height;

  testWidgets('Grows right away, and never shrinks', (tester) async {
    await pump(tester, childHeight: 100);
    expect(height(tester), 100);

    await pump(tester, childHeight: 300);
    expect(height(tester), 300);

    await pump(tester, childHeight: 200);
    expect(height(tester), 300);

    await pump(tester, childHeight: 0);
    expect(height(tester), 300);

    await pump(tester, childHeight: 500);
    expect(height(tester), 500);

    await pump(tester, childHeight: 100);
    expect(height(tester), 500);

    await tester.pump(const Duration(seconds: 5));
    expect(height(tester), 500);
  });

  testWidgets('A child shorter than the kept height is given that height',
      (tester) async {
    await pump(tester, childHeight: 300);
    expect(childHeight(tester), 300);

    await pump(tester, childHeight: 200);
    expect(height(tester), 300);
    expect(childHeight(tester), 300);
  });

  testWidgets('With shrink, waits and then animates down to the height of the child',
      (tester) async {
    await pump(tester, childHeight: 300, shrink: true);
    expect(height(tester), 300);

    await pump(tester, childHeight: 100, shrink: true);
    expect(height(tester), 300);

    // Still waiting (the default delay is 200ms).
    await tester.pump(const Duration(milliseconds: 150));
    expect(height(tester), 300);

    // The delay ended, and the animation starts (the default duration is 500ms).
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 250));
    expect(height(tester), inExclusiveRange(100, 300));
    expect(childHeight(tester), height(tester));

    await tester.pumpAndSettle();
    expect(height(tester), 100);
    expect(childHeight(tester), 100);
  });

  testWidgets("With shrink, doesn't shrink if the difference is too small",
      (tester) async {
    await pump(tester, childHeight: 300, shrink: true, minShrinkDifference: 50);
    await pump(tester, childHeight: 260, shrink: true, minShrinkDifference: 50);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(height(tester), 300);

    await pump(tester, childHeight: 240, shrink: true, minShrinkDifference: 50);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(height(tester), 240);
  });

  testWidgets('Applies the constraints of its parent', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 150, maxHeight: 250, maxWidth: 200),
            child: const KeepTallest(child: SizedBox(key: k, height: 100)),
          ),
        ),
      ),
    );
    await tester.pump();

    // The minimum height of the parent is applied to the child.
    expect(height(tester), 150);
    expect(childHeight(tester), 150);
  });
}
