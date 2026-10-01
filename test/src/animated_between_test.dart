import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _boxA() => const SizedBox(key: ValueKey('a'), width: 80, height: 40);

Widget _boxB() => const SizedBox(key: ValueKey('b'), width: 160, height: 90);

/// Same width as [_boxA], so an enclosing IntrinsicWidth doesn't
/// constrain the dimension that animates (height).
Widget _tallB() => const SizedBox(key: ValueKey('b'), width: 80, height: 90);

Widget _tallB2() => const SizedBox(key: ValueKey('c'), width: 80, height: 120);

Widget _wrap(Widget child) => Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: child),
    );

void main() {
  //
  testWidgets(
      'At rest inside IntrinsicWidth: '
      'no exception, and renders at the bare child size', (tester) async {
    await tester.pumpWidget(
      _wrap(IntrinsicWidth(child: AnimatedBetween(child: _boxA()))),
    );
    // Flushes the post-frame measurement callback.
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(AnimatedBetween)), const Size(80, 40));
    expect(tester.getSize(find.byType(IntrinsicWidth)), const Size(80, 40));

    final RenderBox box = tester.renderObject(find.byType(AnimatedBetween));
    expect(box.getMinIntrinsicWidth(double.infinity), 80);
    expect(box.getMaxIntrinsicWidth(double.infinity), 80);
    expect(box.getMinIntrinsicHeight(double.infinity), 40);
    expect(box.getMaxIntrinsicHeight(double.infinity), 40);
    expect(box.getDryLayout(const BoxConstraints()), const Size(80, 40));
  });

  testWidgets(
      'At rest inside RowSuper '
      '(which calls computeMaxIntrinsicWidth on children during layout): '
      'no exception, and renders at the bare child size', (tester) async {
    await tester.pumpWidget(
      _wrap(RowSuper(children: [AnimatedBetween(child: _boxA())])),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(AnimatedBetween)), const Size(80, 40));
  });

  testWidgets(
      'Mid-transition inside IntrinsicWidth: '
      'no exception, and intrinsics report the current animated box size',
      (tester) async {
    await tester.pumpWidget(
      _wrap(IntrinsicWidth(child: AnimatedBetween(child: _boxA()))),
    );
    await tester.pump();

    // Change to a child with a different key and size. The frame below
    // measures the incoming child, and its post-frame callback starts
    // the fade and size animations.
    await tester.pumpWidget(
      _wrap(IntrinsicWidth(child: AnimatedBetween(child: _tallB()))),
    );
    // First pump ticks the just-started animations at elapsed zero;
    // the second advances them to 120ms.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(tester.takeException(), isNull);

    // The ClipRect wraps the animated SizedBox, so its size is the
    // current animated box size. Height must be strictly between the
    // old (40) and new (90) child heights, i.e. mid-animation.
    final Size animatedSize = tester.getSize(find.byType(ClipRect));
    expect(animatedSize.width, 80);
    expect(animatedSize.height, greaterThan(40));
    expect(animatedSize.height, lessThan(90));

    final RenderBox box = tester.renderObject(find.byType(AnimatedBetween));
    expect(box.getMinIntrinsicWidth(double.infinity), animatedSize.width);
    expect(box.getMaxIntrinsicWidth(double.infinity), animatedSize.width);
    expect(box.getMinIntrinsicHeight(double.infinity), animatedSize.height);
    expect(box.getMaxIntrinsicHeight(double.infinity), animatedSize.height);
    expect(box.getDryLayout(const BoxConstraints()), animatedSize);

    // The intrinsic-measuring parent tracks the animated size.
    expect(tester.getSize(find.byType(IntrinsicWidth)), animatedSize);

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Null child at rest inside IntrinsicWidth: '
      'no exception, zero intrinsics, zero rendered size', (tester) async {
    await tester.pumpWidget(
      _wrap(const IntrinsicWidth(child: AnimatedBetween(child: null))),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(AnimatedBetween)), Size.zero);

    final RenderBox box = tester.renderObject(find.byType(AnimatedBetween));
    expect(box.getMinIntrinsicWidth(double.infinity), 0);
    expect(box.getMaxIntrinsicWidth(double.infinity), 0);
    expect(box.getMinIntrinsicHeight(double.infinity), 0);
    expect(box.getMaxIntrinsicHeight(double.infinity), 0);
  });

  testWidgets(
      'Full transition inside IntrinsicWidth '
      'settles at the new child natural size', (tester) async {
    await tester.pumpWidget(
      _wrap(IntrinsicWidth(child: AnimatedBetween(child: _boxA()))),
    );
    await tester.pump();

    await tester.pumpWidget(
      _wrap(IntrinsicWidth(child: AnimatedBetween(child: _boxB()))),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(AnimatedBetween)), const Size(160, 90));

    // The bare new child, rendered alone under the same constraints,
    // has that exact size.
    await tester.pumpWidget(_wrap(_boxB()));
    expect(
      tester.getSize(find.byKey(const ValueKey('b'))),
      const Size(160, 90),
    );
  });
  testWidgets(
      'onEnd is called once when a transition completes, '
      'and not when the child is first built', (tester) async {
    int calls = 0;
    void onEnd() => calls++;

    await tester.pumpWidget(_wrap(AnimatedBetween(onEnd: onEnd, child: _boxA())));
    await tester.pumpAndSettle();
    expect(calls, 0);

    await tester.pumpWidget(_wrap(AnimatedBetween(onEnd: onEnd, child: _boxB())));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(calls, 0);

    await tester.pumpAndSettle();
    expect(calls, 1);

    // Shrinking to null (showHide hide) also completes a transition.
    await tester.pumpWidget(_wrap(AnimatedBetween(onEnd: onEnd, child: null)));
    await tester.pumpAndSettle();
    expect(calls, 2);
  });

  testWidgets(
      'onEnd is called only once when a transition is interrupted '
      'by another child change', (tester) async {
    int calls = 0;
    void onEnd() => calls++;

    await tester.pumpWidget(_wrap(AnimatedBetween(onEnd: onEnd, child: _boxA())));
    await tester.pumpAndSettle();

    await tester.pumpWidget(_wrap(AnimatedBetween(onEnd: onEnd, child: _boxB())));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    await tester.pumpWidget(_wrap(AnimatedBetween(onEnd: onEnd, child: _tallB2())));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(calls, 1);
  });
}
