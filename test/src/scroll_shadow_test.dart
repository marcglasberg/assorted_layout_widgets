import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
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
  }) =>
      ListView(
        scrollDirection: axis,
        controller: controller,
        reverse: reverse,
        physics: physics,
        children: items(axis, count: count),
      );

  /// Pumps the [scrollShadow] in a [width] x [height] box. Each call creates
  /// a fresh state, so that calling it again in the same test starts over.
  Future<void> pump(
    WidgetTester tester,
    Widget scrollShadow, {
    TextDirection textDirection = TextDirection.ltr,
  }) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: textDirection,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            key: UniqueKey(),
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

  /// Records what the [ScrollShadow] painter draws.
  TestRecordingCanvas recordPaint(WidgetTester tester) {
    final RenderObject renderObject = tester.renderObject(
      find
          .descendant(
            of: find.byType(ScrollShadow),
            matching: find.byType(CustomPaint),
          )
          .first,
    );
    final canvas = TestRecordingCanvas();
    renderObject.paint(TestRecordingPaintingContext(canvas), Offset.zero);
    return canvas;
  }

  /// The divider lines drawn by the painter, as (start, end) pairs.
  List<(Offset, Offset)> dividerLines(WidgetTester tester) => recordPaint(tester)
      .invocations
      .where((invocation) => invocation.invocation.memberName == #drawLine)
      .map((invocation) => (
            invocation.invocation.positionalArguments[0] as Offset,
            invocation.invocation.positionalArguments[1] as Offset,
          ))
      .toList();

  /// The physical edges that currently show a shadow. Each shadow draws
  /// exactly one divider line along its edge, plus one shadow.
  Set<Edge> shadowEdges(WidgetTester tester) {
    final canvas = recordPaint(tester);

    final int shadowCount = canvas.invocations
        .where((invocation) => invocation.invocation.memberName == #drawShadow)
        .length;

    final edges = <Edge>{};
    for (final (p1, p2) in dividerLines(tester)) {
      if (p1.dy == p2.dy) {
        if (p1.dy == 0) edges.add(Edge.top);
        if (p1.dy == height) edges.add(Edge.bottom);
      } else if (p1.dx == p2.dx) {
        if (p1.dx == 0) edges.add(Edge.left);
        if (p1.dx == width) edges.add(Edge.right);
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

    testWidgets('A nested horizontal scrollable does not affect the top/bottom shadows.',
        (tester) async {
      final verticalController = ScrollController();
      final horizontalController = ScrollController();
      await pump(
        tester,
        ScrollShadow(
          leftShadowVisibility: ShadowVisibility.alwaysOff,
          rightShadowVisibility: ShadowVisibility.alwaysOff,
          child: ListView(
            controller: verticalController,
            children: [
              SizedBox(
                height: 100,
                child: list(axis: Axis.horizontal, controller: horizontalController),
              ),
              ...items(Axis.vertical),
            ],
          ),
        ),
      );
      expect(shadowEdges(tester), {Edge.bottom});

      horizontalController.jumpTo(350);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.bottom});

      horizontalController.jumpTo(700);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.bottom});
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
}
