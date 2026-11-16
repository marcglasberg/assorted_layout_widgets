import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Extra [ScrollShadow] tests added during the review of PR #43. They complement
/// `scroll_shadow_test.dart` with: NestedScrollView, nested SingleChildScrollViews,
/// PageView, RTL with vertical lists, inner ScrollShadows in both directions, both axes
/// at the same time (TwoDimensionalScrollView, side by side lists), direction changes in
/// place, removed scrollables, layout corrections, and parameter changes.

enum Edge { top, bottom, left, right }

const double width = 300;
const double height = 200;

/// [count] items of 100 pixels each along the [axis].
List<Widget> items(Axis axis, {int count = 10}) => List.generate(
      count,
      (index) => SizedBox(
        width: axis == Axis.horizontal ? 100 : null,
        height: axis == Axis.vertical ? 100 : null,
        child: Text('$index'),
      ),
    );

Future<void> pump(
  WidgetTester tester,
  Widget child, {
  TextDirection textDirection = TextDirection.ltr,
}) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: textDirection,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: width, height: height, child: child),
      ),
    ),
  );
  // The first ScrollMetricsNotification is dispatched after the first frame.
  await tester.pump();
}

/// The physical edges where the painter of [shadow] (default: the outermost
/// [ScrollShadow]) currently draws a shadow. Only that painter is recorded, so the
/// shadows of nested [ScrollShadow]s are not mixed up.
Set<Edge> shadowEdges(WidgetTester tester, {Finder? shadow}) {
  final renderObject = tester.renderObject<RenderCustomPaint>(
    find
        .descendant(
          of: shadow ?? find.byType(ScrollShadow).first,
          matching: find.byType(CustomPaint),
        )
        .first,
  );
  final canvas = TestRecordingCanvas();
  final size = renderObject.size;
  renderObject.foregroundPainter!.paint(canvas, size);

  final edges = <Edge>{};
  for (final invocation in canvas.invocations) {
    if (invocation.invocation.memberName != #drawLine) continue;
    final p1 = invocation.invocation.positionalArguments[0] as Offset;
    final p2 = invocation.invocation.positionalArguments[1] as Offset;
    if (p1.dy == p2.dy && p1.dy == 0) edges.add(Edge.top);
    if (p1.dy == p2.dy && p1.dy == size.height) edges.add(Edge.bottom);
    if (p1.dx == p2.dx && p1.dx == 0) edges.add(Edge.left);
    if (p1.dx == p2.dx && p1.dx == size.width) edges.add(Edge.right);
  }

  final shadowCount =
      canvas.invocations.where((i) => i.invocation.memberName == #drawShadow).length;
  expect(shadowCount, edges.length, reason: 'Each divider line comes with a shadow.');
  return edges;
}

/// A header that shrinks from 150 to 50 pixels.
class _ShrinkingHeader extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 50;

  @override
  double get maxExtent => 150;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      const SizedBox.expand(child: ColoredBox(color: Color(0xFF2196F3)));

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

void main() {
  group('NestedScrollView', () {
    //
    const outerKey = Key('outer');
    const innerKey = Key('inner');
    const bodyKey = Key('body');
    final outerShadow = find.byKey(outerKey);
    final innerShadow = find.byKey(innerKey);

    /// A NestedScrollView whose pinned header shrinks from 150 to 50 pixels, with a
    /// body list of 20 items (2000 pixels). The outer scroll is the header collapsing.
    Widget nested(GlobalKey<NestedScrollViewState> key, {required bool withInnerShadow}) {
      final Widget body = ListView(key: bodyKey, children: items(Axis.vertical, count: 20));
      return ScrollShadow(
        key: outerKey,
        child: NestedScrollView(
          key: key,
          headerSliverBuilder: (_, __) => [
            SliverPersistentHeader(pinned: true, delegate: _ShrinkingHeader()),
          ],
          body: withInnerShadow ? ScrollShadow(key: innerKey, child: body) : body,
        ),
      );
    }

    Future<void> drag(WidgetTester tester, double dy) async {
      await tester.drag(find.byKey(bodyKey), Offset(0, dy));
      await tester.pumpAndSettle();
    }

    testWidgets(
        'The outer ScrollShadow follows only the header (outer) scroll. '
        'Scrolling the inner list does not change it.', (tester) async {
      final key = GlobalKey<NestedScrollViewState>();
      await pump(tester, nested(key, withInnerShadow: false));
      final outer = key.currentState!.outerController;
      final inner = key.currentState!.innerController;

      expect((outer.offset, inner.offset), (0.0, 0.0));
      expect(shadowEdges(tester), {Edge.bottom});

      // Partially collapses the header. The inner list doesn't move yet.
      await drag(tester, -60);
      expect((outer.offset, inner.offset), (60.0, 0.0));
      expect(shadowEdges(tester), {Edge.top, Edge.bottom});

      // Fully collapses the header, then scrolls the inner list.
      await drag(tester, -300);
      expect(outer.offset, outer.position.maxScrollExtent);
      expect(inner.offset, greaterThan(0));
      expect(shadowEdges(tester), {Edge.top});

      // Scrolling the inner list to the end, and back up a bit (which only moves the
      // inner list), keeps the outer shadows as they were.
      await drag(tester, -5000);
      expect(outer.offset, outer.position.maxScrollExtent);
      expect(inner.offset, inner.position.maxScrollExtent);
      expect(shadowEdges(tester), {Edge.top});

      await drag(tester, 300);
      expect(outer.offset, outer.position.maxScrollExtent);
      expect(inner.offset, greaterThan(0));
      expect(inner.offset, lessThan(inner.position.maxScrollExtent));
      expect(shadowEdges(tester), {Edge.top});
    });

    testWidgets(
        'A ScrollShadow around the inner list shows the inner shadows, '
        'independently from the outer ScrollShadow.', (tester) async {
      final key = GlobalKey<NestedScrollViewState>();
      await pump(tester, nested(key, withInnerShadow: true));
      final outer = key.currentState!.outerController;
      final inner = key.currentState!.innerController;

      expect(shadowEdges(tester, shadow: outerShadow), {Edge.bottom});
      expect(shadowEdges(tester, shadow: innerShadow), {Edge.bottom});

      await drag(tester, -60);
      expect((outer.offset, inner.offset), (60.0, 0.0));
      expect(shadowEdges(tester, shadow: outerShadow), {Edge.top, Edge.bottom});
      expect(shadowEdges(tester, shadow: innerShadow), {Edge.bottom});

      await drag(tester, -300);
      expect(outer.offset, outer.position.maxScrollExtent);
      expect(inner.offset, greaterThan(0));
      expect(shadowEdges(tester, shadow: outerShadow), {Edge.top});
      expect(shadowEdges(tester, shadow: innerShadow), {Edge.top, Edge.bottom});

      await drag(tester, -5000);
      expect(inner.offset, inner.position.maxScrollExtent);
      expect(shadowEdges(tester, shadow: outerShadow), {Edge.top});
      expect(shadowEdges(tester, shadow: innerShadow), {Edge.top});
    });
  });

  group('Nested SingleChildScrollViews', () {
    //
    testWidgets('A horizontal SingleChildScrollView inside a vertical one is ignored.',
        (tester) async {
      final innerController = ScrollController();
      await pump(
        tester,
        ScrollShadow(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SingleChildScrollView(
                  controller: innerController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(height: 50, child: Row(children: items(Axis.horizontal))),
                ),
                ...items(Axis.vertical),
              ],
            ),
          ),
        ),
      );
      expect(shadowEdges(tester), {Edge.bottom});

      for (final double position in [300, 700, 0]) {
        innerController.jumpTo(position);
        await tester.pump();
        expect(shadowEdges(tester), {Edge.bottom});
      }
    });

    testWidgets('A vertical SingleChildScrollView inside a horizontal one is ignored.',
        (tester) async {
      final innerController = ScrollController();
      await pump(
        tester,
        ScrollShadow(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  height: height,
                  child: SingleChildScrollView(
                    controller: innerController,
                    child: Column(children: items(Axis.vertical)),
                  ),
                ),
                ...items(Axis.horizontal),
              ],
            ),
          ),
        ),
      );
      expect(shadowEdges(tester), {Edge.right});

      for (final double position in [400, 800, 0]) {
        innerController.jumpTo(position);
        await tester.pump();
        expect(shadowEdges(tester), {Edge.right});
      }
    });
  });

  testWidgets(
      'A ScrollShadow around a vertical list nested in a horizontal list shows its own '
      'shadows, without affecting the outer ScrollShadow.', (tester) async {
    final outerController = ScrollController();
    final innerController = ScrollController();
    final innerShadow = find.byKey(const Key('inner'));
    await pump(
      tester,
      ScrollShadow(
        child: ListView(
          controller: outerController,
          scrollDirection: Axis.horizontal,
          children: [
            SizedBox(
              width: 100,
              child: ScrollShadow(
                key: const Key('inner'),
                child: ListView(controller: innerController, children: items(Axis.vertical)),
              ),
            ),
            ...items(Axis.horizontal),
          ],
        ),
      ),
    );
    expect(shadowEdges(tester), {Edge.right});
    expect(shadowEdges(tester, shadow: innerShadow), {Edge.bottom});

    innerController.jumpTo(400);
    await tester.pump();
    expect(shadowEdges(tester), {Edge.right});
    expect(shadowEdges(tester, shadow: innerShadow), {Edge.top, Edge.bottom});

    outerController.jumpTo(50); // Keeps the nested list visible.
    await tester.pump();
    expect(shadowEdges(tester), {Edge.left, Edge.right});
    expect(shadowEdges(tester, shadow: innerShadow), {Edge.top, Edge.bottom});
  });

  testWidgets(
      'PageView of vertical lists: the shadows follow the PageView (left/right), '
      'and the vertical lists inside the pages are ignored.', (tester) async {
    final pageController = PageController();
    final listController = ScrollController();
    await pump(
      tester,
      ScrollShadow(
        child: PageView(
          controller: pageController,
          children: [
            ListView(controller: listController, children: items(Axis.vertical)),
            ListView(children: items(Axis.vertical)),
            ListView(children: items(Axis.vertical)),
          ],
        ),
      ),
    );
    expect(shadowEdges(tester), {Edge.right});

    listController.jumpTo(400);
    await tester.pump();
    expect(shadowEdges(tester), {Edge.right});

    pageController.jumpToPage(1);
    await tester.pump();
    expect(shadowEdges(tester), {Edge.left, Edge.right});

    pageController.jumpToPage(2);
    await tester.pump();
    expect(shadowEdges(tester), {Edge.left});
  });

  group('RTL does not affect vertical lists', () {
    //
    for (final reverse in [false, true]) {
      testWidgets('reverse: $reverse', (tester) async {
        final controller = ScrollController();
        await pump(
          tester,
          ScrollShadow(
            child: ListView(
              controller: controller,
              reverse: reverse,
              children: items(Axis.vertical),
            ),
          ),
          textDirection: TextDirection.rtl,
        );
        expect(shadowEdges(tester), {if (reverse) Edge.top else Edge.bottom});

        controller.jumpTo(400);
        await tester.pump();
        expect(shadowEdges(tester), {Edge.top, Edge.bottom});

        controller.jumpTo(800);
        await tester.pump();
        expect(shadowEdges(tester), {if (reverse) Edge.bottom else Edge.top});
      });
    }
  });

  testWidgets(
      'Changing axis on the same State, from a scrolled RTL horizontal list to a '
      'reversed vertical list, leaves no left/right shadows.', (tester) async {
    final horizontalController = ScrollController();
    final verticalController = ScrollController();
    Future<void> pumpKeepingState(Widget child) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: width, height: height, child: ScrollShadow(child: child)),
          ),
        ),
      );
      await tester.pump();
    }

    await pumpKeepingState(ListView(
      key: const Key('h'),
      controller: horizontalController,
      scrollDirection: Axis.horizontal,
      children: items(Axis.horizontal),
    ));
    final state = tester.state(find.byType(ScrollShadow));
    horizontalController.jumpTo(350);
    await tester.pump();
    expect(shadowEdges(tester), {Edge.left, Edge.right});

    await pumpKeepingState(ListView(
      key: const Key('v'),
      controller: verticalController,
      reverse: true,
      children: items(Axis.vertical),
    ));
    expect(tester.state(find.byType(ScrollShadow)), same(state));
    expect(shadowEdges(tester), {Edge.top});
  });

  group('Both axes at the same time', () {
    //
    Widget grid(ScrollController vertical, ScrollController horizontal) => ScrollShadow(
          child: _Grid2D(
            verticalDetails: ScrollableDetails.vertical(controller: vertical),
            horizontalDetails: ScrollableDetails.horizontal(controller: horizontal),
            delegate: TwoDimensionalChildBuilderDelegate(
              maxXIndex: 9,
              maxYIndex: 9,
              builder: (_, vicinity) => Text('${vicinity.xIndex},${vicinity.yIndex}'),
            ),
          ),
        );

    testWidgets('TwoDimensionalScrollView shows the shadows of both axes.', (tester) async {
      final vertical = ScrollController();
      final horizontal = ScrollController();
      await pump(tester, grid(vertical, horizontal));
      expect(shadowEdges(tester), {Edge.bottom, Edge.right});

      vertical.jumpTo(300);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.top, Edge.bottom, Edge.right});

      horizontal.jumpTo(300);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.top, Edge.bottom, Edge.left, Edge.right});

      vertical.jumpTo(vertical.position.maxScrollExtent);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.top, Edge.left, Edge.right});

      horizontal.jumpTo(0);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.top, Edge.right});
    });

    testWidgets('A vertical and a horizontal list side by side show both axes.',
        (tester) async {
      final vertical = ScrollController();
      final horizontal = ScrollController();
      await pump(
        tester,
        ScrollShadow(
          child: Column(
            children: [
              Expanded(child: ListView(controller: vertical, children: items(Axis.vertical))),
              SizedBox(
                height: 60,
                child: ListView(
                  controller: horizontal,
                  scrollDirection: Axis.horizontal,
                  children: items(Axis.horizontal),
                ),
              ),
            ],
          ),
        ),
      );
      expect(shadowEdges(tester), {Edge.bottom, Edge.right});

      vertical.jumpTo(300);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.top, Edge.bottom, Edge.right});

      horizontal.jumpTo(300);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.top, Edge.bottom, Edge.left, Edge.right});
    });

    testWidgets(
        'Known limitation: two vertical lists side by side share the top/bottom shadows, '
        'and the last one to scroll wins.', (tester) async {
      final first = ScrollController();
      final second = ScrollController();
      await pump(
        tester,
        ScrollShadow(
          child: Row(
            children: [
              Expanded(child: ListView(controller: first, children: items(Axis.vertical))),
              Expanded(child: ListView(controller: second, children: items(Axis.vertical))),
            ],
          ),
        ),
      );

      first.jumpTo(400); // Middle of the first list.
      await tester.pump();
      expect(shadowEdges(tester), {Edge.top, Edge.bottom});

      second.jumpTo(800); // End of the second list.
      await tester.pump();
      expect(shadowEdges(tester), {Edge.top});
    });
  });

  testWidgets(
      'When the layout corrects the scroll position (the viewport grows in the same '
      'frame as a jump to the end), the shadows follow the corrected position.',
      (tester) async {
    final controller = ScrollController();
    Future<void> pumpWith(double header) => tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                height: 400,
                child: Column(
                  children: [
                    SizedBox(height: header),
                    Expanded(
                      child: ScrollShadow(
                        child: ListView.builder(
                          controller: controller,
                          itemCount: 30,
                          itemBuilder: (_, index) =>
                              SizedBox(height: 50, child: Text('$index')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

    await pumpWith(100);
    await tester.pump();
    final double initialMax = controller.position.maxScrollExtent;
    controller.jumpTo(initialMax);
    await pumpWith(60); // The viewport grows by 40, in the same frame as the jump.
    await tester.pumpAndSettle();
    expect(controller.position.maxScrollExtent, initialMax - 40);
    expect(controller.offset, initialMax - 40);
    expect(shadowEdges(tester), {Edge.top});

    // The viewport shrinks back, so there is content below again.
    await pumpWith(100);
    await tester.pumpAndSettle();
    expect(controller.position.maxScrollExtent, initialMax);
    expect(controller.offset, initialMax - 40);
    expect(shadowEdges(tester), {Edge.top, Edge.bottom});
  });

  group('Changing the direction in place', () {
    //
    testWidgets('Toggling RTL on the same horizontal list swaps left and right.',
        (tester) async {
      final controller = ScrollController();
      Future<void> pumpWith(TextDirection textDirection) => tester.pumpWidget(
            Directionality(
              textDirection: textDirection,
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: ScrollShadow(
                    child: ListView(
                      controller: controller,
                      scrollDirection: Axis.horizontal,
                      children: items(Axis.horizontal),
                    ),
                  ),
                ),
              ),
            ),
          );

      await pumpWith(TextDirection.ltr);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.right});

      await pumpWith(TextDirection.rtl);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.left});

      await pumpWith(TextDirection.ltr);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.right});
    });

    testWidgets('Toggling reverse on the same vertical list swaps top and bottom.',
        (tester) async {
      final controller = ScrollController();
      Future<void> pumpWith({required bool reverse}) => tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: ScrollShadow(
                    child: ListView(
                      controller: controller,
                      reverse: reverse,
                      children: items(Axis.vertical),
                    ),
                  ),
                ),
              ),
            ),
          );

      await pumpWith(reverse: false);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.bottom});

      await pumpWith(reverse: true);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.top});
    });
  });

  group('Removing the scrollable', () {
    //
    testWidgets('Replacing the child with a widget that does not scroll clears the shadows.',
        (tester) async {
      final controller = ScrollController();
      Future<void> pumpChild(Widget child) => tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: ScrollShadow(child: child),
                ),
              ),
            ),
          );

      await pumpChild(ListView(controller: controller, children: items(Axis.vertical)));
      await tester.pump();
      controller.jumpTo(400);
      await tester.pump();
      final state = tester.state(find.byType(ScrollShadow));
      expect(shadowEdges(tester), {Edge.top, Edge.bottom});

      await pumpChild(const Text('Not scrollable'));
      await tester.pump();
      expect(tester.state(find.byType(ScrollShadow)), same(state));
      expect(shadowEdges(tester), isEmpty);
    });

    testWidgets(
        'A descendant that removes the scrollable by itself (without rebuilding the '
        'ScrollShadow) also clears the shadows.', (tester) async {
      final controller = ScrollController();
      final switcherKey = GlobalKey<_ScrollableSwitcherState>();
      await pump(
        tester,
        ScrollShadow(
          child: _ScrollableSwitcher(
            key: switcherKey,
            scrollable: ListView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              children: items(Axis.horizontal),
            ),
          ),
        ),
      );
      controller.jumpTo(350);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.left, Edge.right});

      switcherKey.currentState!.hideScrollable();
      await tester.pump(); // Removes the list.
      await tester.pump(); // Repaints the shadows.
      expect(shadowEdges(tester), isEmpty);
    });

    testWidgets('Removing the ScrollShadow right after scrolling causes no errors.',
        (tester) async {
      final controller = ScrollController();
      await pump(
        tester,
        ScrollShadow(child: ListView(controller: controller, children: items(Axis.vertical))),
      );
      controller.jumpTo(400);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('Changing the parameters keeps the scroll state', () {
    //
    late ScrollController controller;

    Future<void> pumpShadow(WidgetTester tester, ScrollShadow Function(Widget) shadow) =>
        tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                height: height,
                child: shadow(
                  ListView(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    children: items(Axis.horizontal),
                  ),
                ),
              ),
            ),
          ),
        );

    /// The (color, elevation) of each drawn shadow, in paint order.
    List<(Color, double)> shadows(WidgetTester tester) {
      final renderObject = tester.renderObject<RenderCustomPaint>(
        find
            .descendant(of: find.byType(ScrollShadow), matching: find.byType(CustomPaint))
            .first,
      );
      final canvas = TestRecordingCanvas();
      renderObject.foregroundPainter!.paint(canvas, renderObject.size);
      return [
        for (final invocation in canvas.invocations)
          if (invocation.invocation.memberName == #drawShadow)
            (
              invocation.invocation.positionalArguments[1] as Color,
              invocation.invocation.positionalArguments[2] as double,
            ),
      ];
    }

    setUp(() => controller = ScrollController());

    testWidgets('Visibility.', (tester) async {
      await pumpShadow(tester, (child) => ScrollShadow(child: child));
      await tester.pump();
      controller.jumpTo(350);
      await tester.pump();
      expect(shadowEdges(tester), {Edge.left, Edge.right});

      // No scrolling after this point. The new parameters apply right away.
      await pumpShadow(
        tester,
        (child) => ScrollShadow(
          topShadowVisibility: ShadowVisibility.alwaysOn,
          rightShadowVisibility: ShadowVisibility.alwaysOff,
          child: child,
        ),
      );
      expect(shadowEdges(tester), {Edge.top, Edge.left});

      await pumpShadow(tester, (child) => ScrollShadow(child: child));
      expect(shadowEdges(tester), {Edge.left, Edge.right});
    });

    testWidgets('Colors and elevation.', (tester) async {
      await pumpShadow(tester, (child) => ScrollShadow(child: child));
      await tester.pump();
      controller.jumpTo(350);
      await tester.pump();
      expect(shadows(tester), [(Colors.black, 4.0), (Colors.black, 4.0)]);

      await pumpShadow(
        tester,
        (child) => ScrollShadow(
          leftShadowColor: Colors.red,
          rightShadowColor: Colors.blue,
          elevation: 8,
          child: child,
        ),
      );
      expect(shadows(tester), [(Colors.red, 8.0), (Colors.blue, 8.0)]);

      // The elevation is capped at 10.
      await pumpShadow(tester, (child) => ScrollShadow(elevation: 50, child: child));
      expect(shadows(tester), [(Colors.black, 10.0), (Colors.black, 10.0)]);
    });

    testWidgets('Paddings, and switching to ScrollShadow.simple.', (tester) async {
      await pumpShadow(tester, (child) => ScrollShadow(child: child));
      await tester.pump();
      controller.jumpTo(350);
      await tester.pump();

      List<double> leftDividerTopAndBottom() {
        final renderObject = tester.renderObject<RenderCustomPaint>(
          find
              .descendant(of: find.byType(ScrollShadow), matching: find.byType(CustomPaint))
              .first,
        );
        final canvas = TestRecordingCanvas();
        renderObject.foregroundPainter!.paint(canvas, renderObject.size);
        final line = canvas.invocations.firstWhere(
            (invocation) => invocation.invocation.memberName == #drawLine);
        final p1 = line.invocation.positionalArguments[0] as Offset;
        final p2 = line.invocation.positionalArguments[1] as Offset;
        return [p1.dy, p2.dy];
      }

      expect(leftDividerTopAndBottom(), [5, height - 14]);

      await pumpShadow(
        tester,
        (child) => ScrollShadow(leftTopPadding: 20, leftBottomPadding: 30, child: child),
      );
      expect(leftDividerTopAndBottom(), [20, height - 30]);

      await pumpShadow(tester, (child) => ScrollShadow.simple(child: child));
      expect(leftDividerTopAndBottom(), [0, height]);
    });

    testWidgets('ifHidesShadowForNegativeScroll, while overscrolled.', (tester) async {
      Widget list() => ListView(
            controller: controller,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            children: items(Axis.horizontal),
          );
      Future<void> pumpWith({required bool ifHides}) => tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: ScrollShadow(ifHidesShadowForNegativeScroll: ifHides, child: list()),
                ),
              ),
            ),
          );

      await pumpWith(ifHides: false);
      await tester.pump();
      final gesture = await tester.startGesture(const Offset(150, 100));
      await gesture.moveBy(const Offset(40, 0));
      await gesture.moveBy(const Offset(40, 0));
      await tester.pump();
      expect(controller.offset, lessThan(0));
      expect(shadowEdges(tester), {Edge.right});

      // Still overscrolled, without moving.
      await pumpWith(ifHides: true);
      expect(shadowEdges(tester), isEmpty);

      await pumpWith(ifHides: false);
      expect(shadowEdges(tester), {Edge.right});

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('The painter is kept, and only repaints when the appearance changes.',
        (tester) async {
      await pumpShadow(tester, (child) => ScrollShadow(child: child));
      await tester.pump();
      RenderCustomPaint renderObject() => tester.renderObject<RenderCustomPaint>(
            find
                .descendant(
                    of: find.byType(ScrollShadow), matching: find.byType(CustomPaint))
                .first,
          );
      final painter = renderObject().foregroundPainter;

      // Same appearance: no repaint needed.
      await pumpShadow(tester, (child) => ScrollShadow(child: child));
      expect(renderObject().foregroundPainter, same(painter));
      expect(renderObject().debugNeedsPaint, isFalse);

      // Different appearance: the painter asks for a repaint.
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              height: height,
              child: ScrollShadow(
                leftShadowColor: Colors.red,
                child: ListView(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  children: items(Axis.horizontal),
                ),
              ),
            ),
          ),
        ),
        phase: EnginePhase.layout, // Stops before painting.
      );
      expect(renderObject().foregroundPainter, same(painter));
      expect(renderObject().debugNeedsPaint, isTrue);
    });
  });
}

/// Shows the [scrollable] until [hideScrollable] is called. Used to remove the
/// scrollable without rebuilding the [ScrollShadow] above it.
class _ScrollableSwitcher extends StatefulWidget {
  const _ScrollableSwitcher({super.key, required this.scrollable});

  final Widget scrollable;

  @override
  State<_ScrollableSwitcher> createState() => _ScrollableSwitcherState();
}

class _ScrollableSwitcherState extends State<_ScrollableSwitcher> {
  bool _show = true;

  void hideScrollable() => setState(() => _show = false);

  @override
  Widget build(BuildContext context) =>
      _show ? widget.scrollable : const Text('Not scrollable');
}

// A minimal 2D grid of 100x100 cells, to test TwoDimensionalScrollView.

class _Grid2D extends TwoDimensionalScrollView {
  const _Grid2D({
    super.verticalDetails,
    super.horizontalDetails,
    required TwoDimensionalChildBuilderDelegate super.delegate,
  });

  @override
  Widget buildViewport(
    BuildContext context,
    ViewportOffset verticalOffset,
    ViewportOffset horizontalOffset,
  ) =>
      _Grid2DViewport(
        horizontalOffset: horizontalOffset,
        horizontalAxisDirection: horizontalDetails.direction,
        verticalOffset: verticalOffset,
        verticalAxisDirection: verticalDetails.direction,
        mainAxis: mainAxis,
        delegate: delegate as TwoDimensionalChildBuilderDelegate,
        scrollCacheExtent: scrollCacheExtent,
        clipBehavior: clipBehavior,
      );
}

class _Grid2DViewport extends TwoDimensionalViewport {
  const _Grid2DViewport({
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required TwoDimensionalChildBuilderDelegate super.delegate,
    required super.mainAxis,
    super.scrollCacheExtent,
    super.clipBehavior,
  });

  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) => _RenderGrid2D(
        horizontalOffset: horizontalOffset,
        horizontalAxisDirection: horizontalAxisDirection,
        verticalOffset: verticalOffset,
        verticalAxisDirection: verticalAxisDirection,
        mainAxis: mainAxis,
        delegate: delegate,
        childManager: context as TwoDimensionalChildManager,
        scrollCacheExtent: scrollCacheExtent,
        clipBehavior: clipBehavior,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderGrid2D renderObject) {
    renderObject
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..mainAxis = mainAxis
      ..delegate = delegate
      ..scrollCacheExtent = scrollCacheExtent
      ..clipBehavior = clipBehavior;
  }
}

class _RenderGrid2D extends RenderTwoDimensionalViewport {
  _RenderGrid2D({
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.delegate,
    required super.mainAxis,
    required super.childManager,
    super.scrollCacheExtent,
    super.clipBehavior,
  });

  @override
  void layoutChildSequence() {
    const double cell = 100;
    final builder = delegate as TwoDimensionalChildBuilderDelegate;
    final double dx = horizontalOffset.pixels;
    final double dy = verticalOffset.pixels;
    final int firstColumn = max((dx / cell).floor(), 0);
    final int lastColumn = min(((dx + viewportDimension.width) / cell).ceil(), builder.maxXIndex!);
    final int firstRow = max((dy / cell).floor(), 0);
    final int lastRow = min(((dy + viewportDimension.height) / cell).ceil(), builder.maxYIndex!);

    for (int column = firstColumn; column <= lastColumn; column++) {
      for (int row = firstRow; row <= lastRow; row++) {
        final child = buildOrObtainChildFor(ChildVicinity(xIndex: column, yIndex: row))!;
        child.layout(BoxConstraints.tight(const Size(cell, cell)));
        parentDataOf(child).layoutOffset = Offset(column * cell - dx, row * cell - dy);
      }
    }

    verticalOffset.applyContentDimensions(
        0, max(0, (builder.maxYIndex! + 1) * cell - viewportDimension.height));
    horizontalOffset.applyContentDimensions(
        0, max(0, (builder.maxXIndex! + 1) * cell - viewportDimension.width));
  }
}
