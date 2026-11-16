import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

enum Edge { top, bottom, left, right }

void main() {
  //
  const double width = 300;
  const double height = 200;

  /// 10 items of 100 pixels each, so the content is 1000 pixels long and the
  /// max scroll extent is 1000 - 300 = 700 (horizontal) or 1000 - 200 = 800 (vertical).
  List<Widget> items(Axis axis, {int count = 10}) => List.generate(
        count,
        (index) => SizedBox(
          width: axis == Axis.horizontal ? 100 : null,
          height: axis == Axis.vertical ? 100 : null,
          child: Text('$index'),
        ),
      );

  Widget list({
    required Axis axis,
    ScrollController? controller,
    bool reverse = false,
    int count = 10,
    ScrollPhysics? physics,
    Key? key,
  }) =>
      ListView(
        key: key,
        scrollDirection: axis,
        controller: controller,
        reverse: reverse,
        physics: physics,
        children: items(axis, count: count),
      );

  /// Pumps the [scrollShadow] in a [width] x [height] box.
  ///
  /// By default, each call creates a fresh state, so that calling it again in the
  /// same test starts over. Use [freshState] false to keep the [ScrollShadow] state.
  Future<void> pump(
    WidgetTester tester,
    Widget scrollShadow, {
    TextDirection textDirection = TextDirection.ltr,
    bool freshState = true,
  }) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: textDirection,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            key: freshState ? UniqueKey() : null,
            width: width,
            height: height,
            child: scrollShadow,
          ),
        ),
      ),
    );
    // The first ScrollMetricsNotification is dispatched after the first frame.
    await tester.pump();
  }

  /// Records what the painter of the [shadow] draws (by default, the outermost
  /// [ScrollShadow]). Only the painter itself is recorded, not the children, so
  /// that the shadows of nested [ScrollShadow]s are not mixed up.
  ({TestRecordingCanvas canvas, Size size}) recordPaint(
    WidgetTester tester, {
    Finder? shadow,
  }) {
    final renderObject = tester.renderObject<RenderCustomPaint>(
      find
          .descendant(
            of: shadow ?? find.byType(ScrollShadow).first,
            matching: find.byType(CustomPaint),
          )
          .first,
    );
    final canvas = TestRecordingCanvas();
    renderObject.foregroundPainter!.paint(canvas, renderObject.size);
    return (canvas: canvas, size: renderObject.size);
  }

  /// The divider lines drawn by the painter, as (start, end) pairs.
  List<(Offset, Offset)> dividerLines(WidgetTester tester, {Finder? shadow}) =>
      recordPaint(tester, shadow: shadow)
          .canvas
          .invocations
          .where((invocation) => invocation.invocation.memberName == #drawLine)
          .map((invocation) => (
                invocation.invocation.positionalArguments[0] as Offset,
                invocation.invocation.positionalArguments[1] as Offset,
              ))
          .toList();

  /// The physical edges that currently show a shadow. Each shadow draws
  /// exactly one divider line along its edge, plus one shadow.
  Set<Edge> shadowEdges(WidgetTester tester, {Finder? shadow}) {
    final (:canvas, :size) = recordPaint(tester, shadow: shadow);

    final int shadowCount = canvas.invocations
        .where((invocation) => invocation.invocation.memberName == #drawShadow)
        .length;

    final edges = <Edge>{};
    for (final (p1, p2) in dividerLines(tester, shadow: shadow)) {
      if (p1.dy == p2.dy) {
        if (p1.dy == 0) edges.add(Edge.top);
        if (p1.dy == size.height) edges.add(Edge.bottom);
      } else if (p1.dx == p2.dx) {
        if (p1.dx == 0) edges.add(Edge.left);
        if (p1.dx == size.width) edges.add(Edge.right);
      }
    }

    expect(shadowCount, edges.length, reason: 'Each divider line comes with a shadow.');
    return edges;
  }

  group('Vertical scrolling (existing behavior)', () {
    //
    testWidgets('Shows the bottom shadow at the start, both in the middle, '
        'and the top shadow at the end.', (tester) async {
      final controller = ScrollController();
      await pump(tester, ScrollShadow(child: list(axis: Axis.vertical, controller: controller)));
      expect(shadowEdges(tester), {Edge.bottom});

      controller.jumpTo(400);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.top, Edge.bottom});

      controller.jumpTo(800);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.top});
    });

    testWidgets('Shows no shadows when the content fits.', (tester) async {
      await pump(tester, ScrollShadow(child: list(axis: Axis.vertical, count: 2)));
      expect(shadowEdges(tester), isEmpty);
    });

    testWidgets('With reverse, starts with the top shadow.', (tester) async {
      final controller = ScrollController();
      await pump(
        tester,
        ScrollShadow(child: list(axis: Axis.vertical, controller: controller, reverse: true)),
      );
      expect(shadowEdges(tester), {Edge.top});

      controller.jumpTo(800);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.bottom});
    });

    testWidgets('Respects alwaysOn and alwaysOff.', (tester) async {
      await pump(
        tester,
        ScrollShadow(
          topShadowVisibility: ShadowVisibility.alwaysOn,
          bottomShadowVisibility: ShadowVisibility.alwaysOff,
          child: list(axis: Axis.vertical),
        ),
      );
      expect(shadowEdges(tester), {Edge.top});
    });

    testWidgets('Uses the top/bottom paddings.', (tester) async {
      final controller = ScrollController();
      await pump(tester, ScrollShadow(child: list(axis: Axis.vertical, controller: controller)));
      controller.jumpTo(400);
      await tester.pump();

      expect(dividerLines(tester), [
        (const Offset(5, 0), const Offset(width - 14, 0)),
        (const Offset(5, height), const Offset(width - 14, height)),
      ]);
    });

  });

  group('Nested scrollables (default visibility)', () {
    //
    testWidgets(
        'A horizontal list nested in a vertical list neither adds left/right shadows '
        'nor changes the top/bottom shadows.', (tester) async {
      final outerController = ScrollController();
      final innerController = ScrollController();
      await pump(
        tester,
        ScrollShadow(
          child: ListView(
            controller: outerController,
            children: [
              SizedBox(
                height: 100,
                child: list(axis: Axis.horizontal, controller: innerController),
              ),
              ...items(Axis.vertical),
            ],
          ),
        ),
      );
      // After laying out, the nested list overflows, but has no effect.
      expect(shadowEdges(tester), {Edge.bottom});

      for (final double position in [350, 700, 0]) {
        innerController.jumpTo(position);
        await tester.pump();
        expect(shadowEdges(tester), {Edge.bottom});
      }

      outerController.jumpTo(50); // Keeps the nested list visible.
      await tester.pump();
      expect(shadowEdges(tester), {Edge.top, Edge.bottom});

      for (final double position in [350, 700, 0]) {
        innerController.jumpTo(position);
        await tester.pump();
        expect(shadowEdges(tester), {Edge.top, Edge.bottom});
      }

      outerController.jumpTo(outerController.position.maxScrollExtent);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.top});
    });

    testWidgets(
        'A vertical list nested in a horizontal list neither adds top/bottom shadows '
        'nor changes the left/right shadows.', (tester) async {
      final outerController = ScrollController();
      final innerController = ScrollController();
      await pump(
        tester,
        ScrollShadow(
          child: ListView(
            controller: outerController,
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(
                width: 100,
                child: list(axis: Axis.vertical, controller: innerController),
              ),
              ...items(Axis.horizontal),
            ],
          ),
        ),
      );
      expect(shadowEdges(tester), {Edge.right});

      for (final double position in [400, 800, 0]) {
        innerController.jumpTo(position);
        await tester.pump();
        expect(shadowEdges(tester), {Edge.right});
      }

      outerController.jumpTo(50); // Keeps the nested list visible.
      await tester.pump();
      expect(shadowEdges(tester), {Edge.left, Edge.right});

      for (final double position in [400, 800, 0]) {
        innerController.jumpTo(position);
        await tester.pump();
        expect(shadowEdges(tester), {Edge.left, Edge.right});
      }
    });

    testWidgets(
        'A ScrollShadow around a nested list shows its own shadows, '
        'without affecting the outer ScrollShadow.', (tester) async {
      final outerController = ScrollController();
      final innerController = ScrollController();
      final innerShadow = find.byKey(const Key('inner'));
      await pump(
        tester,
        ScrollShadow(
          child: ListView(
            controller: outerController,
            children: [
              SizedBox(
                height: 100,
                child: ScrollShadow(
                  key: const Key('inner'),
                  child: list(axis: Axis.horizontal, controller: innerController),
                ),
              ),
              ...items(Axis.vertical),
            ],
          ),
        ),
      );
      expect(shadowEdges(tester), {Edge.bottom});
      expect(shadowEdges(tester, shadow: innerShadow), {Edge.right});

      innerController.jumpTo(350);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.bottom});
      expect(shadowEdges(tester, shadow: innerShadow), {Edge.left, Edge.right});

      outerController.jumpTo(50);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.top, Edge.bottom});
      expect(shadowEdges(tester, shadow: innerShadow), {Edge.left, Edge.right});
    });

    testWidgets('The scrollable may be further below in the widget tree.', (tester) async {
      final controller = ScrollController();
      await pump(
        tester,
        ScrollShadow(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Expanded(child: list(axis: Axis.horizontal, controller: controller)),
              ],
            ),
          ),
        ),
      );
      expect(shadowEdges(tester), {Edge.right});

      controller.jumpTo(300);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.left, Edge.right});
    });
  });

  group('Changing the scroll axis while keeping the ScrollShadow state', () {
    //
    Future<void> pumpKeepingState(WidgetTester tester, Widget scrollShadow) =>
        pump(tester, scrollShadow, freshState: false);

    testWidgets('Replacing the child: vertical → horizontal → vertical.', (tester) async {
      await pumpKeepingState(
        tester,
        ScrollShadow(child: list(axis: Axis.vertical, key: const Key('v1'))),
      );
      final state = tester.state(find.byType(ScrollShadow));
      expect(shadowEdges(tester), {Edge.bottom});

      await pumpKeepingState(
        tester,
        ScrollShadow(child: list(axis: Axis.horizontal, key: const Key('h'))),
      );
      expect(tester.state(find.byType(ScrollShadow)), same(state));
      expect(shadowEdges(tester), {Edge.right});

      await pumpKeepingState(
        tester,
        ScrollShadow(child: list(axis: Axis.vertical, key: const Key('v2'))),
      );
      expect(tester.state(find.byType(ScrollShadow)), same(state));
      expect(shadowEdges(tester), {Edge.bottom});
    });

    testWidgets('Changing the scrollDirection of the same list.', (tester) async {
      await pumpKeepingState(tester, ScrollShadow(child: list(axis: Axis.vertical)));
      final state = tester.state(find.byType(ScrollShadow));
      expect(shadowEdges(tester), {Edge.bottom});

      await pumpKeepingState(tester, ScrollShadow(child: list(axis: Axis.horizontal)));
      expect(tester.state(find.byType(ScrollShadow)), same(state));
      expect(shadowEdges(tester), {Edge.right});

      await pumpKeepingState(tester, ScrollShadow(child: list(axis: Axis.vertical)));
      expect(tester.state(find.byType(ScrollShadow)), same(state));
      expect(shadowEdges(tester), {Edge.bottom});
    });

    testWidgets('After scrolling, no stale shadows remain from the previous axis.',
        (tester) async {
      final verticalController = ScrollController();
      final horizontalController = ScrollController();

      await pumpKeepingState(
        tester,
        ScrollShadow(
          child: list(axis: Axis.vertical, controller: verticalController, key: const Key('v')),
        ),
      );
      verticalController.jumpTo(400);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.top, Edge.bottom});

      // The horizontal content fits, so no shadows at all.
      await pumpKeepingState(
        tester,
        ScrollShadow(child: list(axis: Axis.horizontal, count: 2, key: const Key('h1'))),
      );
      expect(shadowEdges(tester), isEmpty);

      await pumpKeepingState(
        tester,
        ScrollShadow(
          child: list(
              axis: Axis.horizontal, controller: horizontalController, key: const Key('h2')),
        ),
      );
      horizontalController.jumpTo(350);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.left, Edge.right});

      // The vertical content fits, so no shadows at all.
      await pumpKeepingState(
        tester,
        ScrollShadow(child: list(axis: Axis.vertical, count: 1, key: const Key('v2'))),
      );
      expect(shadowEdges(tester), isEmpty);
    });

    testWidgets('alwaysOn and alwaysOff are kept when the axis changes.', (tester) async {
      Widget shadow(Widget child) => ScrollShadow(
            topShadowVisibility: ShadowVisibility.alwaysOn,
            bottomShadowVisibility: ShadowVisibility.alwaysOff,
            leftShadowVisibility: ShadowVisibility.alwaysOn,
            rightShadowVisibility: ShadowVisibility.alwaysOff,
            child: child,
          );

      await pumpKeepingState(tester, shadow(list(axis: Axis.vertical, key: const Key('v'))));
      expect(shadowEdges(tester), {Edge.top, Edge.left});

      await pumpKeepingState(
          tester, shadow(list(axis: Axis.horizontal, key: const Key('h'))));
      expect(shadowEdges(tester), {Edge.top, Edge.left});
    });
  });

  group('Horizontal scrolling', () {
    //
    testWidgets('LTR: Shows the right shadow at the start, both in the middle, '
        'and the left shadow at the end.', (tester) async {
      final controller = ScrollController();
      await pump(tester, ScrollShadow(child: list(axis: Axis.horizontal, controller: controller)));
      expect(shadowEdges(tester), {Edge.right});

      controller.jumpTo(350);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.left, Edge.right});

      controller.jumpTo(700);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.left});
    });

    testWidgets('RTL: Shows the left shadow at the start, and the right shadow at the end.',
        (tester) async {
      final controller = ScrollController();
      await pump(
        tester,
        ScrollShadow(child: list(axis: Axis.horizontal, controller: controller)),
        textDirection: TextDirection.rtl,
      );
      expect(shadowEdges(tester), {Edge.left});

      controller.jumpTo(350);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.left, Edge.right});

      controller.jumpTo(700);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.right});
    });

    testWidgets('LTR with reverse: Shows the left shadow at the start, '
        'and the right shadow at the end.', (tester) async {
      final controller = ScrollController();
      await pump(
        tester,
        ScrollShadow(
            child: list(axis: Axis.horizontal, controller: controller, reverse: true)),
      );
      expect(shadowEdges(tester), {Edge.left});

      controller.jumpTo(700);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.right});
    });

    testWidgets('RTL with reverse: Shows the right shadow at the start, '
        'and the left shadow at the end.', (tester) async {
      final controller = ScrollController();
      await pump(
        tester,
        ScrollShadow(
            child: list(axis: Axis.horizontal, controller: controller, reverse: true)),
        textDirection: TextDirection.rtl,
      );
      expect(shadowEdges(tester), {Edge.right});

      controller.jumpTo(700);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.left});
    });

    testWidgets('Shows no shadows when the content fits.', (tester) async {
      await pump(tester, ScrollShadow(child: list(axis: Axis.horizontal, count: 2)));
      expect(shadowEdges(tester), isEmpty);
    });

    testWidgets('Never shows the top/bottom shadows by default.', (tester) async {
      final controller = ScrollController();
      await pump(tester, ScrollShadow(child: list(axis: Axis.horizontal, controller: controller)));

      for (final double position in [0, 50, 350, 650, 700]) {
        controller.jumpTo(position);
        await tester.pump();
        final edges = shadowEdges(tester);
        expect(edges.contains(Edge.top), isFalse);
        expect(edges.contains(Edge.bottom), isFalse);
      }
    });

    testWidgets('Respects alwaysOn and alwaysOff.', (tester) async {
      await pump(
        tester,
        ScrollShadow(
          leftShadowVisibility: ShadowVisibility.alwaysOn,
          rightShadowVisibility: ShadowVisibility.alwaysOff,
          child: list(axis: Axis.horizontal),
        ),
      );
      expect(shadowEdges(tester), {Edge.left});
    });

    testWidgets('The shadow grows with the scroll distance, up to the elevation.',
        (tester) async {
      final controller = ScrollController();
      await pump(
        tester,
        ScrollShadow(
          rightShadowVisibility: ShadowVisibility.alwaysOff,
          child: list(axis: Axis.horizontal, controller: controller),
        ),
      );

      double leftElevation() {
        final shadows = recordPaint(tester)
            .canvas
            .invocations
            .where((invocation) => invocation.invocation.memberName == #drawShadow)
            .toList();
        expect(shadows, hasLength(1));
        return shadows.single.invocation.positionalArguments[2] as double;
      }

      controller.jumpTo(10);
      await tester.pump();
      expect(leftElevation(), 2.0); // 10 / 5

      controller.jumpTo(350);
      await tester.pump();
      expect(leftElevation(), 4.0); // The default elevation.
    });

    testWidgets('Uses the left/right paddings and their defaults.', (tester) async {
      final controller = ScrollController();
      await pump(tester, ScrollShadow(child: list(axis: Axis.horizontal, controller: controller)));
      controller.jumpTo(350);
      await tester.pump();

      expect(dividerLines(tester), [
        (const Offset(0, 5), const Offset(0, height - 14)),
        (const Offset(width, 5), const Offset(width, height - 14)),
      ]);

      await pump(
        tester,
        ScrollShadow(
          leftTopPadding: 1,
          leftBottomPadding: 2,
          rightTopPadding: 3,
          rightBottomPadding: 4,
          child: list(axis: Axis.horizontal, controller: controller),
        ),
      );
      controller.jumpTo(300);
      await tester.pump();

      expect(dividerLines(tester), [
        (const Offset(0, 1), const Offset(0, height - 2)),
        (const Offset(width, 3), const Offset(width, height - 4)),
      ]);
    });

    testWidgets('ScrollShadow.simple has no left/right paddings.', (tester) async {
      final controller = ScrollController();
      await pump(
        tester,
        ScrollShadow.simple(child: list(axis: Axis.horizontal, controller: controller)),
      );
      controller.jumpTo(350);
      await tester.pump();

      expect(dividerLines(tester), [
        (const Offset(0, 0), const Offset(0, height)),
        (const Offset(width, 0), const Offset(width, height)),
      ]);
    });

    testWidgets('ifHidesShadowForNegativeScroll hides the opposite shadow when overscrolled.',
        (tester) async {
      Future<Set<Edge>> edgesWhileOverscrolling({required bool ifHides}) async {
        await pump(
          tester,
          ScrollShadow(
            ifHidesShadowForNegativeScroll: ifHides,
            child: list(axis: Axis.horizontal, physics: const BouncingScrollPhysics()),
          ),
        );

        // Drag the content to the right, past its start.
        final gesture = await tester.startGesture(const Offset(150, 100));
        await gesture.moveBy(const Offset(40, 0));
        await gesture.moveBy(const Offset(40, 0));
        await tester.pump();

        final edges = shadowEdges(tester);
        await gesture.up();
        await tester.pumpAndSettle();
        return edges;
      }

      expect(await edgesWhileOverscrolling(ifHides: false), {Edge.right});
      expect(await edgesWhileOverscrolling(ifHides: true), isEmpty);
    });
  });

  group('Repaints only when the shadows change', () {
    //
    RenderCustomPaint renderShadows(WidgetTester tester) =>
        tester.renderObject<RenderCustomPaint>(
          find
              .descendant(
                of: find.byType(ScrollShadow),
                matching: find.byType(CustomPaint),
              )
              .first,
        );

    /// Scrolls to the given [pixels], and returns whether the shadows will be
    /// painted again because of it.
    Future<bool> repaintsWhenScrollingTo(
      WidgetTester tester,
      ScrollController controller,
      double pixels,
    ) async {
      controller.jumpTo(pixels);
      final bool repaints = renderShadows(tester).debugNeedsPaint;
      await tester.pump();
      return repaints;
    }

    testWidgets('Only repaints near the ends, where the shadows grow and shrink.',
        (tester) async {
      final controller = ScrollController();

      // The content is 5000 pixels long, so the max scroll extent is 4800.
      await pump(
        tester,
        ScrollShadow(child: list(axis: Axis.vertical, controller: controller, count: 50)),
      );
      expect(renderShadows(tester).debugNeedsPaint, isFalse);

      Future<bool> repaintsAt(double pixels) =>
          repaintsWhenScrollingTo(tester, controller, pixels);

      // The top shadow appears, and grows until its elevation of 4 (at 20 pixels).
      expect(await repaintsAt(5), isTrue);
      expect(await repaintsAt(10), isTrue);
      expect(await repaintsAt(20), isTrue);
      expect(shadowEdges(tester), {Edge.top, Edge.bottom});

      // Both shadows are complete, and stay the same while scrolling in the middle.
      expect(await repaintsAt(21), isFalse);
      expect(await repaintsAt(60), isFalse);
      expect(await repaintsAt(500), isFalse);
      expect(await repaintsAt(2000), isFalse);
      expect(await repaintsAt(4780), isFalse);
      expect(await repaintsAt(100), isFalse);
      expect(await repaintsAt(4780), isFalse);
      expect(shadowEdges(tester), {Edge.top, Edge.bottom});

      // The bottom shadow shrinks, and disappears.
      expect(await repaintsAt(4790), isTrue);
      expect(await repaintsAt(4795), isTrue);
      expect(await repaintsAt(4800), isTrue);
      expect(shadowEdges(tester), {Edge.top});

      // And it appears again.
      expect(await repaintsAt(4799), isTrue);
      expect(shadowEdges(tester), {Edge.top, Edge.bottom});
    });

    testWidgets('Shadows that are always on never change while scrolling.',
        (tester) async {
      final controller = ScrollController();

      await pump(
        tester,
        ScrollShadow(
          topShadowVisibility: ShadowVisibility.alwaysOn,
          bottomShadowVisibility: ShadowVisibility.alwaysOn,
          child: list(axis: Axis.vertical, controller: controller, count: 50),
        ),
      );

      expect(await repaintsWhenScrollingTo(tester, controller, 5), isFalse);
      expect(await repaintsWhenScrollingTo(tester, controller, 2000), isFalse);
      expect(await repaintsWhenScrollingTo(tester, controller, 4800), isFalse);
      expect(shadowEdges(tester), {Edge.top, Edge.bottom});
    });

    testWidgets('A larger elevation takes longer to be complete.', (tester) async {
      final controller = ScrollController();

      // With an elevation of 10, the shadow is complete at 50 pixels.
      await pump(
        tester,
        ScrollShadow(
          elevation: 10,
          child: list(axis: Axis.vertical, controller: controller, count: 50),
        ),
      );

      expect(await repaintsWhenScrollingTo(tester, controller, 20), isTrue);
      expect(await repaintsWhenScrollingTo(tester, controller, 40), isTrue);
      expect(await repaintsWhenScrollingTo(tester, controller, 50), isTrue);
      expect(await repaintsWhenScrollingTo(tester, controller, 60), isFalse);
      expect(await repaintsWhenScrollingTo(tester, controller, 3000), isFalse);
    });
  });
}
