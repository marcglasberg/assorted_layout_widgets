// ScrollShadow: manual test page, with every feature and every known limitation.
//
// HOW TO RUN (from the `example` directory):
//
//     flutter run -t lib/main_scroll_shadow_manual_test.dart -d windows
//
// (or `-d chrome`, `-d macos`, or a connected phone/emulator).
//
// HOW TO USE
//
// - Pick a scenario in the dropdown at the top. Each scenario shows a short yellow box
//   explaining what to do and what you should see.
//
// - The "RTL" and "Reverse" switches at the top apply to most scenarios (Reverse is
//   ignored in the NestedScrollView, PageView and 2D scenarios).
//
// - Above each list, a live label says which shadows are EXPECTED right now. It's
//   computed from the list's own ScrollController (its pixels, max scroll extent and
//   axis direction), independently of ScrollShadow. Compare it with what you SEE.
//
// - The "Start", "Middle" and "End" buttons jump each list, to check the limits.
//
// - With a mouse you can drag the lists (mouse drag is enabled in this demo), use the
//   wheel, or shift+wheel for horizontal lists.
//
// - In scenarios with more than one ScrollShadow, the OUTER ScrollShadow uses RED
//   shadows and the INNER ScrollShadow uses BLUE shadows, so that you can tell them
//   apart. Everywhere else the default (black) shadows are used, unless you change
//   them in the "Parameters" scenario.
//
// WHAT TO CHECK
//
//  1. Vertical: bottom shadow at the start, top + bottom in the middle, top at the end.
//     Reverse swaps top and bottom. RTL changes nothing. The list that fits: no shadows.
//
//  2. Horizontal: right shadow at the start (LTR), left + right in the middle, left at
//     the end. RTL or Reverse swaps left and right (RTL + Reverse swaps them back). The
//     list that fits: no shadows. No top/bottom shadows ever appear.
//
//  3. Horizontal lists inside a vertical list, and
//  4. Vertical lists inside a horizontal list: scrolling an inner list NEVER changes the
//     RED shadows. An inner list wrapped by its own ScrollShadow shows BLUE shadows.
//
//  5. Axis switch and removal: the ScrollShadow keeps the same State (the id doesn't
//     change). After switching the axis, only the shadows of the new axis are shown.
//     After removing the scrollable (from the parent, or from inside), no shadows.
//
//  6. NestedScrollView: RED (outer) follows only the shrinking header. BLUE (inner)
//     follows only the inner list. BLUE's top shadow is drawn at the top of the body,
//     which is hidden under the collapsed header, so it is never seen. Use the
//     "Recommended setup" button: no RED, BLUE with only the bottom shadow, and the
//     shadow below the header comes from the SliverAppBar itself.
//
//  7. PageView of vertical lists (BEHAVIOR CHANGE): the shadows follow the pages
//     (left/right), and the vertical lists inside the pages are ignored.
//
//  8. Both axes: a 2D grid (TwoDimensionalScrollView) and a vertical + horizontal list
//     side by side show the shadows of both axes at the same time.
//
//  9. Parameters: every parameter can be changed live, and is applied immediately,
//     without scrolling, and without losing the current shadows.
//
// 10. Known limitations: what still doesn't work as one could expect. See the scenario.
//
import 'dart:math';
import 'dart:ui' show PointerDeviceKind;

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      // Allows dragging the lists with the mouse, on desktop and web.
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      home: const Demo(),
    ),
  );
}

const Color outerColor = Colors.red;
const Color innerColor = Colors.blue;

enum Scenario {
  vertical('1. Vertical'),
  horizontal('2. Horizontal'),
  horizontalInVertical('3. Horizontal in vertical'),
  verticalInHorizontal('4. Vertical in horizontal'),
  axisSwitch('5. Axis switch / removal'),
  nestedScrollView('6. NestedScrollView'),
  pageView('7. PageView (behavior change)'),
  bothAxes('8. Both axes (2D, side by side)'),
  parameters('9. Parameters (live)'),
  limitations('10. Known limitations');

  const Scenario(this.title);

  final String title;
}

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  Scenario scenario = Scenario.vertical;
  bool rtl = false;
  bool reverse = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ScrollShadow manual test')),
      body: Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const Pad(horizontal: 12, top: 4),
              child: Wrap(
                spacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 320,
                    child: Row(
                      children: [
                        const Text('Scenario: '),
                        Expanded(
                          child: DropdownButton<Scenario>(
                            key: const Key('scenario'),
                            isExpanded: true,
                            value: scenario,
                            items: [
                              for (final s in Scenario.values)
                                DropdownMenuItem(value: s, child: Text(s.title)),
                            ],
                            onChanged: (s) => setState(() => scenario = s ?? scenario),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _LabeledSwitch('RTL', rtl, (value) => setState(() => rtl = value)),
                  _LabeledSwitch(
                      'Reverse', reverse, (value) => setState(() => reverse = value)),
                ],
              ),
            ),
            _Instructions(_instructions(scenario)),
            Expanded(
              child: Padding(
                padding: const Pad(horizontal: 12, bottom: 12),
                // A new key per scenario, so that each scenario starts fresh.
                child: KeyedSubtree(
                  key: ValueKey(scenario),
                  child: _scenario(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scenario() => switch (scenario) {
        Scenario.vertical => _VerticalScenario(reverse: reverse),
        Scenario.horizontal => _HorizontalScenario(reverse: reverse),
        Scenario.horizontalInVertical => _HorizontalInVerticalScenario(reverse: reverse),
        Scenario.verticalInHorizontal => _VerticalInHorizontalScenario(reverse: reverse),
        Scenario.axisSwitch => _AxisSwitchScenario(reverse: reverse),
        Scenario.nestedScrollView => const _NestedScrollViewScenario(),
        Scenario.pageView => const _PageViewScenario(),
        Scenario.bothAxes => _BothAxesScenario(reverse: reverse),
        Scenario.parameters => _ParametersScenario(reverse: reverse),
        Scenario.limitations => _LimitationsScenario(reverse: reverse),
      };

  String _instructions(Scenario scenario) => switch (scenario) {
        Scenario.vertical => 'Default ScrollShadow around vertical lists. '
            'Expected: bottom shadow at the start, top + bottom in the middle, top at the '
            'end. Reverse swaps top and bottom; RTL changes nothing. '
            'The list that fits shows no shadows.',
        Scenario.horizontal => 'Default ScrollShadow around horizontal lists. '
            'Expected (LTR): right shadow at the start, left + right in the middle, left at '
            'the end. RTL or Reverse swaps left/right (both together swap them back), also '
            'when toggled while scrolled. The list that fits shows no shadows. '
            'Never top/bottom shadows.',
        Scenario.horizontalInVertical =>
          'Outer vertical list (RED shadows) containing horizontal lists. '
              'Scroll rows A and B in every direction: the RED shadows must NOT change, and '
              'no RED left/right shadows may appear. Row B has its own BLUE shadows.',
        Scenario.verticalInHorizontal =>
          'Outer horizontal list (RED shadows) containing vertical lists. '
              'Scroll columns A and B: the RED shadows must NOT change, and no RED top/bottom '
              'shadows may appear. Column B has its own BLUE shadows.',
        Scenario.axisSwitch => 'One ScrollShadow whose child changes. Scroll to the middle, '
            'then switch the axis (both buttons), toggle "Content fits", and remove the '
            'scrollable (from the parent, or from a widget inside). Expected: the State id '
            'never changes; only the shadows of the current axis are shown; with the '
            'scrollable removed, NO shadows.',
        Scenario.nestedScrollView =>
          'NestedScrollView with a shrinking header. RED = outer ScrollShadow, around the '
              'NestedScrollView. BLUE = inner ScrollShadow, around the body list. '
              'Expected: RED follows only the header (bottom while it can still collapse, '
              'top once it started collapsing). BLUE follows only the inner list. With the '
              'header collapsed, scrolling the inner list does not change RED. BLUE top is '
              'never seen: it is drawn at the top of the body, hidden under the collapsed '
              'header. "Header shadow" is the SliverAppBar own shadow (not ScrollShadow): '
              'it appears below the header exactly when the content starts going under it. '
              '"Recommended setup" = no RED, BLUE bottom only, header shadow on.',
        Scenario.pageView => 'BEHAVIOR CHANGE. Default ScrollShadow around a PageView whose '
            'pages are vertical lists. Expected: left/right shadows following the pages; '
            'scrolling a page vertically shows NO top/bottom shadows (before this version '
            'it did). Turn on "ScrollShadow inside each page" for BLUE top/bottom shadows.',
        Scenario.bothAxes => 'Two closest scrollables in different axes. Top: a 2D grid '
            '(TwoDimensionalScrollView, drag diagonally). Bottom: a vertical and a '
            'horizontal list side by side, under ONE ScrollShadow. Expected: the shadows of '
            'both axes at the same time (up to 4 edges).',
        Scenario.parameters => 'Change any parameter while the list is scrolled to the '
            'middle. Expected: the change is visible immediately, without scrolling, and '
            'the label below always matches. Elevation above 10 looks like 10. With '
            '"Hide for negative scroll", overscroll (drag past the start with bouncing '
            'physics) and the opposite shadow disappears.',
        Scenario.limitations => 'KNOWN LIMITATIONS (by design). A: two vertical lists side '
            'by side under one ScrollShadow share top/bottom: the last one to scroll wins. '
            'B: a horizontal list inside a SingleChildScrollView that does NOT scroll is '
            'still ignored (it is nested). C: compare the look of left/right shadows with '
            'top/bottom ones.',
      };
}

// ---------------------------------------------------------------------------------------
// 1. Vertical.

class _VerticalScenario extends StatefulWidget {
  const _VerticalScenario({required this.reverse});

  final bool reverse;

  @override
  State<_VerticalScenario> createState() => _VerticalScenarioState();
}

class _VerticalScenarioState extends State<_VerticalScenario> {
  final long = ScrollController();
  final fits = ScrollController();

  @override
  void dispose() {
    long.dispose();
    fits.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _Panel(
            title: 'Long list (30 items)',
            controls: [_Controls('Expected', long)],
            child: ScrollShadow(
              child: _list(Axis.vertical, long, reverse: widget.reverse, count: 30),
            ),
          ),
        ),
        const Box.gap(12),
        Expanded(
          child: _Panel(
            title: 'Content fits (3 items)',
            controls: [_Controls('Expected', fits)],
            child: ScrollShadow(
              child: _list(Axis.vertical, fits, reverse: widget.reverse, count: 3),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------------------
// 2. Horizontal.

class _HorizontalScenario extends StatefulWidget {
  const _HorizontalScenario({required this.reverse});

  final bool reverse;

  @override
  State<_HorizontalScenario> createState() => _HorizontalScenarioState();
}

class _HorizontalScenarioState extends State<_HorizontalScenario> {
  final long = ScrollController();
  final fits = ScrollController();

  @override
  void dispose() {
    long.dispose();
    fits.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: 170,
          child: _Panel(
            title: 'Long list (30 items)',
            controls: [_Controls('Expected', long)],
            child: ScrollShadow(
              child: _list(Axis.horizontal, long, reverse: widget.reverse, count: 30),
            ),
          ),
        ),
        const Box.gap(16),
        SizedBox(
          height: 170,
          child: _Panel(
            title: 'Content fits (2 items)',
            controls: [_Controls('Expected', fits)],
            child: ScrollShadow(
              child: _list(Axis.horizontal, fits, reverse: widget.reverse, count: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------------------
// 3. Horizontal lists inside a vertical list.

class _HorizontalInVerticalScenario extends StatefulWidget {
  const _HorizontalInVerticalScenario({required this.reverse});

  final bool reverse;

  @override
  State<_HorizontalInVerticalScenario> createState() => _HorizontalInVerticalScenarioState();
}

class _HorizontalInVerticalScenarioState extends State<_HorizontalInVerticalScenario> {
  final outer = ScrollController();
  final rowA = ScrollController();
  final rowB = ScrollController();

  @override
  void dispose() {
    outer.dispose();
    rowA.dispose();
    rowB.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Outer vertical list (RED)',
      controls: [
        _Controls('RED outer expected', outer, color: outerColor),
        _Controls('Row A (no own ScrollShadow), alone would expect', rowA),
        _Controls('BLUE row B expected', rowB, color: innerColor),
      ],
      child: _colored(
        outerColor,
        ListView(
          controller: outer,
          reverse: widget.reverse,
          children: [
            const _Caption('Row A: horizontal list WITHOUT its own ScrollShadow.'),
            SizedBox(
              height: 80,
              child: _list(Axis.horizontal, rowA, reverse: widget.reverse, count: 20),
            ),
            const _Caption('Row B: horizontal list WITH its own (BLUE) ScrollShadow.'),
            SizedBox(
              height: 80,
              child: _colored(
                innerColor,
                _list(Axis.horizontal, rowB, reverse: widget.reverse, count: 20),
              ),
            ),
            const _Caption('Vertical items of the outer list:'),
            for (int i = 0; i < 15; i++) _Tile(index: i, axis: Axis.vertical),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------
// 4. Vertical lists inside a horizontal list.

class _VerticalInHorizontalScenario extends StatefulWidget {
  const _VerticalInHorizontalScenario({required this.reverse});

  final bool reverse;

  @override
  State<_VerticalInHorizontalScenario> createState() => _VerticalInHorizontalScenarioState();
}

class _VerticalInHorizontalScenarioState extends State<_VerticalInHorizontalScenario> {
  final outer = ScrollController();
  final columnA = ScrollController();
  final columnB = ScrollController();

  @override
  void dispose() {
    outer.dispose();
    columnA.dispose();
    columnB.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget column(String title, Widget child) => SizedBox(
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [_Caption(title), Expanded(child: child)],
          ),
        );

    return _Panel(
      title: 'Outer horizontal list (RED)',
      controls: [
        _Controls('RED outer expected', outer, color: outerColor),
        _Controls('Column A (no own ScrollShadow), alone would expect', columnA),
        _Controls('BLUE column B expected', columnB, color: innerColor),
      ],
      child: _colored(
        outerColor,
        ListView(
          controller: outer,
          scrollDirection: Axis.horizontal,
          reverse: widget.reverse,
          children: [
            column(
              'A: no own shadow',
              _list(Axis.vertical, columnA, reverse: widget.reverse, count: 20),
            ),
            const Box.gap(8),
            column(
              'B: BLUE shadow',
              _colored(
                innerColor,
                _list(Axis.vertical, columnB, reverse: widget.reverse, count: 20),
              ),
            ),
            const Box.gap(8),
            for (int i = 0; i < 15; i++) _Tile(index: i, axis: Axis.horizontal),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------
// 5. The same ScrollShadow (same State), whose child changes axis, or is removed.

class _AxisSwitchScenario extends StatefulWidget {
  const _AxisSwitchScenario({required this.reverse});

  final bool reverse;

  @override
  State<_AxisSwitchScenario> createState() => _AxisSwitchScenarioState();
}

class _AxisSwitchScenarioState extends State<_AxisSwitchScenario> {
  final shadowKey = GlobalKey();
  final switcherKey = GlobalKey<_ScrollableSwitcherState>();
  final controller = ScrollController();
  Axis axis = Axis.vertical;
  int childGeneration = 0;
  bool fits = false;
  bool removedByParent = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _toggleAxis({required bool replaceChild}) => setState(() {
        axis = (axis == Axis.vertical) ? Axis.horizontal : Axis.vertical;
        if (replaceChild) childGeneration++;
      });

  @override
  Widget build(BuildContext context) {
    final bool removedFromInside = !(switcherKey.currentState?.isShowing ?? true);

    return _Panel(
      title: 'Current axis: ${axis.name}',
      controls: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () => _toggleAxis(replaceChild: false),
              child: const Text('Switch axis (same list element)'),
            ),
            OutlinedButton(
              onPressed: () => _toggleAxis(replaceChild: true),
              child: const Text('Switch axis + replace child (new key)'),
            ),
            _LabeledSwitch('Content fits', fits, (value) => setState(() => fits = value)),
            _LabeledSwitch(
              'Remove scrollable (from the parent)',
              removedByParent,
              (value) => setState(() => removedByParent = value),
            ),
            OutlinedButton(
              onPressed: () {
                // Only the switcher rebuilds, not the ScrollShadow.
                switcherKey.currentState?.toggle();
                setState(() {}); // Just to update the labels of this panel.
              },
              child: Text(removedFromInside
                  ? 'Show scrollable again (from inside)'
                  : 'Remove scrollable (from inside)'),
            ),
          ],
        ),
        _StateIdLabel(shadowKey),
        if (removedByParent || removedFromInside)
          const Text(
            'Expected: NO shadows (the scrollable was removed).',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          )
        else
          _Controls('Expected', controller),
      ],
      child: ScrollShadow(
        key: shadowKey,
        child: removedByParent
            ? const Center(child: Text('Not scrollable (replaced by the parent)'))
            : _ScrollableSwitcher(
                key: switcherKey,
                scrollable: _list(
                  axis,
                  controller,
                  key: ValueKey(childGeneration),
                  reverse: widget.reverse,
                  count: fits ? 2 : 30,
                ),
              ),
      ),
    );
  }
}

/// Shows the [scrollable], or a text instead. Toggling it rebuilds only this widget,
/// not the [ScrollShadow] above it.
class _ScrollableSwitcher extends StatefulWidget {
  const _ScrollableSwitcher({super.key, required this.scrollable});

  final Widget scrollable;

  @override
  State<_ScrollableSwitcher> createState() => _ScrollableSwitcherState();
}

class _ScrollableSwitcherState extends State<_ScrollableSwitcher> {
  bool isShowing = true;

  void toggle() => setState(() => isShowing = !isShowing);

  @override
  Widget build(BuildContext context) => isShowing
      ? widget.scrollable
      : const Center(child: Text('Not scrollable (removed from inside)'));
}

// ---------------------------------------------------------------------------------------
// 6. A real NestedScrollView, with a shrinking header and an inner list.

class _NestedScrollViewScenario extends StatefulWidget {
  const _NestedScrollViewScenario();

  @override
  State<_NestedScrollViewScenario> createState() => _NestedScrollViewScenarioState();
}

class _NestedScrollViewScenarioState extends State<_NestedScrollViewScenario> {
  final nestedKey = GlobalKey<NestedScrollViewState>();
  final outer = ScrollController();
  ScrollController? inner;
  bool outerShadow = true;
  bool innerShadow = true;
  bool innerBottomOnly = false;
  bool headerShadow = false;

  static const Map<String, ShadowVisibility> _bottomOnly = {
    'top': ShadowVisibility.alwaysOff,
    'bottom': ShadowVisibility.whenScrolled,
    'left': ShadowVisibility.whenScrolled,
    'right': ShadowVisibility.whenScrolled,
  };

  @override
  void initState() {
    super.initState();
    // The inner controller is created by the NestedScrollView.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => inner = nestedKey.currentState?.innerController);
    });
  }

  @override
  void dispose() {
    outer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = ListView.builder(
      itemCount: 40,
      itemBuilder: (context, index) => ListTile(title: Text('Inner item $index')),
    );

    final Widget nestedScrollView = NestedScrollView(
      key: nestedKey,
      controller: outer,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          pinned: true,
          automaticallyImplyLeading: false,
          expandedHeight: 140,
          backgroundColor: Colors.indigo.shade100,
          // The SliverAppBar's own shadow, not a ScrollShadow. A pinned SliverAppBar
          // uses scrolledUnderElevation once the content starts going under it.
          // shadowColor is needed because in Material 3 it defaults to transparent.
          shadowColor: headerShadow ? Colors.black : Colors.transparent,
          scrolledUnderElevation: headerShadow ? 4.0 : 0.0,
          flexibleSpace: const FlexibleSpaceBar(title: Text('Shrinking header')),
        ),
      ],
      body: !innerShadow
          ? body
          : innerBottomOnly
              ? ScrollShadow(
                  topShadowVisibility: ShadowVisibility.alwaysOff,
                  bottomShadowColor: innerColor,
                  leftShadowColor: innerColor,
                  rightShadowColor: innerColor,
                  child: body,
                )
              : _colored(innerColor, body),
    );

    return _Panel(
      title: 'NestedScrollView',
      controls: [
        Wrap(
          spacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _LabeledSwitch(
              'Outer ScrollShadow (RED)',
              outerShadow,
              (value) => setState(() => outerShadow = value),
            ),
            _LabeledSwitch(
              'Inner ScrollShadow (BLUE)',
              innerShadow,
              (value) => setState(() => innerShadow = value),
            ),
            _LabeledSwitch(
              'BLUE: bottom only',
              innerBottomOnly,
              (value) => setState(() => innerBottomOnly = value),
            ),
            _LabeledSwitch(
              'Header shadow (SliverAppBar)',
              headerShadow,
              (value) => setState(() => headerShadow = value),
            ),
            OutlinedButton(
              onPressed: () => setState(() {
                outerShadow = false;
                innerShadow = true;
                innerBottomOnly = true;
                headerShadow = true;
              }),
              child: const Text('Recommended setup'),
            ),
          ],
        ),
        _Controls(
          outerShadow ? 'RED outer (header) expected' : 'Outer (no ScrollShadow), alone',
          outer,
          color: outerShadow ? outerColor : null,
        ),
        if (inner != null)
          _Controls(
            innerShadow ? 'BLUE inner list expected' : 'Inner list (no own shadow), alone',
            inner!,
            color: innerShadow ? innerColor : null,
            visibility: innerShadow && innerBottomOnly ? _bottomOnly : null,
          ),
      ],
      child: outerShadow ? _colored(outerColor, nestedScrollView) : nestedScrollView,
    );
  }
}

// ---------------------------------------------------------------------------------------
// 7. A PageView of vertical lists (behavior change).

class _PageViewScenario extends StatefulWidget {
  const _PageViewScenario();

  @override
  State<_PageViewScenario> createState() => _PageViewScenarioState();
}

class _PageViewScenarioState extends State<_PageViewScenario> {
  final pages = PageController();
  final page0 = ScrollController();
  bool shadowInsidePages = false;

  @override
  void dispose() {
    pages.dispose();
    page0.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget page(int index) {
      final Widget list = ListView.builder(
        controller: index == 0 ? page0 : null,
        primary: false,
        itemCount: 30,
        itemBuilder: (context, i) => ListTile(title: Text('Page $index, item $i')),
      );
      return shadowInsidePages ? _colored(innerColor, list) : list;
    }

    return _Panel(
      title: 'ScrollShadow (default) around a PageView with 3 pages',
      controls: [
        _LabeledSwitch(
          'ScrollShadow inside each page (BLUE)',
          shadowInsidePages,
          (value) => setState(() => shadowInsidePages = value),
        ),
        _Controls('Outer (PageView) expected', pages),
        _Controls(
          shadowInsidePages ? 'BLUE page 0 expected' : 'Page 0 list (ignored), alone',
          page0,
          color: shadowInsidePages ? innerColor : null,
        ),
      ],
      child: ScrollShadow(
        child: PageView(
          controller: pages,
          children: [page(0), page(1), page(2)],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------
// 8. Both axes at the same time: a 2D grid, and two lists side by side.

class _BothAxesScenario extends StatefulWidget {
  const _BothAxesScenario({required this.reverse});

  final bool reverse;

  @override
  State<_BothAxesScenario> createState() => _BothAxesScenarioState();
}

class _BothAxesScenarioState extends State<_BothAxesScenario> {
  final gridVertical = ScrollController();
  final gridHorizontal = ScrollController();
  final sideVertical = ScrollController();
  final sideHorizontal = ScrollController();

  @override
  void dispose() {
    gridVertical.dispose();
    gridHorizontal.dispose();
    sideVertical.dispose();
    sideHorizontal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _Panel(
            title: 'A. 2D grid (TwoDimensionalScrollView). Expected = both labels together.',
            controls: [
              _Controls('Vertical axis expected', gridVertical),
              _Controls('Horizontal axis expected', gridHorizontal),
            ],
            child: ScrollShadow(
              child: _Grid2D(
                verticalDetails: ScrollableDetails.vertical(controller: gridVertical),
                horizontalDetails: ScrollableDetails.horizontal(controller: gridHorizontal),
                diagonalDragBehavior: DiagonalDragBehavior.free,
                delegate: TwoDimensionalChildBuilderDelegate(
                  maxXIndex: 19,
                  maxYIndex: 19,
                  builder: (_, vicinity) => Container(
                    margin: const Pad(all: 2),
                    alignment: Alignment.center,
                    color: Colors.primaries[(vicinity.xIndex + vicinity.yIndex) %
                            Colors.primaries.length]
                        .shade100,
                    child: Text('${vicinity.xIndex},${vicinity.yIndex}'),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Box.gap(12),
        Expanded(
          child: _Panel(
            title: 'B. Vertical + horizontal lists side by side, under ONE ScrollShadow.',
            controls: [
              _Controls('Vertical list expected', sideVertical),
              _Controls('Horizontal list expected', sideHorizontal),
            ],
            child: ScrollShadow(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _list(Axis.vertical, sideVertical,
                        reverse: widget.reverse, count: 30),
                  ),
                  SizedBox(
                    height: 70,
                    child: _list(Axis.horizontal, sideHorizontal,
                        reverse: widget.reverse, count: 30),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------------------
// 9. Every parameter, changed live.

class _ParametersScenario extends StatefulWidget {
  const _ParametersScenario({required this.reverse});

  final bool reverse;

  @override
  State<_ParametersScenario> createState() => _ParametersScenarioState();
}

class _ParametersScenarioState extends State<_ParametersScenario> {
  final controller = ScrollController();
  Axis axis = Axis.horizontal;
  bool simple = false;
  bool bouncing = true;
  bool ifHides = false;
  bool useElevation = false;
  double elevation = 4;
  bool usePadding = false;
  double padding = 20;
  bool useRadius = false;
  double radius = 12;
  Color shadowColor = Colors.black;
  Color dividerColor = const Color(0xD0000000);
  final Map<String, ShadowVisibility> visibility = {
    'top': ShadowVisibility.whenScrolled,
    'bottom': ShadowVisibility.whenScrolled,
    'left': ShadowVisibility.whenScrolled,
    'right': ShadowVisibility.whenScrolled,
  };

  @override
  void initState() {
    super.initState();
    // Starts in the middle, so that both shadows of the axis are visible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) controller.jumpTo(controller.position.maxScrollExtent / 2);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _shadow(Widget child) {
    final double? p = usePadding ? padding : null;
    final Radius? r = useRadius ? Radius.circular(radius) : null;
    final double? e = useElevation ? elevation : null;

    if (simple) {
      return ScrollShadow.simple(
        topLeftPadding: p ?? 0,
        topRightPadding: p ?? 0,
        bottomLeftPadding: p ?? 0,
        bottomRightPadding: p ?? 0,
        leftTopPadding: p ?? 0,
        leftBottomPadding: p ?? 0,
        rightTopPadding: p ?? 0,
        rightBottomPadding: p ?? 0,
        topRadius: r ?? Radius.zero,
        bottomRadius: r ?? Radius.zero,
        leftRadius: r ?? Radius.zero,
        rightRadius: r ?? Radius.zero,
        topShadowVisibility: visibility['top']!,
        bottomShadowVisibility: visibility['bottom']!,
        leftShadowVisibility: visibility['left']!,
        rightShadowVisibility: visibility['right']!,
        topShadowColor: shadowColor,
        bottomShadowColor: shadowColor,
        leftShadowColor: shadowColor,
        rightShadowColor: shadowColor,
        topShadowDividerColor: dividerColor,
        bottomShadowDividerColor: dividerColor,
        leftShadowDividerColor: dividerColor,
        rightShadowDividerColor: dividerColor,
        elevation: e,
        ifHidesShadowForNegativeScroll: ifHides,
        child: child,
      );
    }

    return ScrollShadow(
      topLeftPadding: p,
      topRightPadding: p,
      bottomLeftPadding: p,
      bottomRightPadding: p,
      leftTopPadding: p,
      leftBottomPadding: p,
      rightTopPadding: p,
      rightBottomPadding: p,
      topRadius: r,
      bottomRadius: r,
      leftRadius: r,
      rightRadius: r,
      topShadowVisibility: visibility['top']!,
      bottomShadowVisibility: visibility['bottom']!,
      leftShadowVisibility: visibility['left']!,
      rightShadowVisibility: visibility['right']!,
      topShadowColor: shadowColor,
      bottomShadowColor: shadowColor,
      leftShadowColor: shadowColor,
      rightShadowColor: shadowColor,
      topShadowDividerColor: dividerColor,
      bottomShadowDividerColor: dividerColor,
      leftShadowDividerColor: dividerColor,
      rightShadowDividerColor: dividerColor,
      elevation: e,
      ifHidesShadowForNegativeScroll: ifHides,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget colorChoice(String label, Color value, List<(String, Color)> options,
            ValueChanged<Color> onChanged) =>
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text('$label: ')),
            DropdownButton<Color>(
              value: value,
              items: [
                for (final (name, color) in options)
                  DropdownMenuItem(value: color, child: Text(name)),
              ],
              onChanged: (c) => setState(() => onChanged(c ?? value)),
            ),
          ],
        );

    Widget slider(String label, bool enabled, double value, double max,
            ValueChanged<bool> onEnabled, ValueChanged<double> onChanged) =>
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(value: enabled, onChanged: (v) => setState(() => onEnabled(v ?? false))),
            Flexible(
              child: Text(enabled ? '$label: ${value.toStringAsFixed(1)}' : '$label: default'),
            ),
            SizedBox(
              width: 110,
              child: Slider(
                value: value,
                max: max,
                onChanged: enabled ? (v) => setState(() => onChanged(v)) : null,
              ),
            ),
          ],
        );

    return _Panel(
      title: 'Live parameters (the ScrollShadow keeps the same State)',
      controls: [
        Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SegmentedButton<Axis>(
              segments: const [
                ButtonSegment(value: Axis.vertical, label: Text('Vertical')),
                ButtonSegment(value: Axis.horizontal, label: Text('Horizontal')),
              ],
              selected: {axis},
              onSelectionChanged: (s) => setState(() => axis = s.first),
            ),
            _LabeledSwitch('ScrollShadow.simple', simple, (v) => setState(() => simple = v)),
            _LabeledSwitch(
                'Bouncing physics', bouncing, (v) => setState(() => bouncing = v)),
            _LabeledSwitch(
                'Hide for negative scroll', ifHides, (v) => setState(() => ifHides = v)),
          ],
        ),
        Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final edge in visibility.keys)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text('$edge: ')),
                  DropdownButton<ShadowVisibility>(
                    value: visibility[edge],
                    items: [
                      for (final v in ShadowVisibility.values)
                        DropdownMenuItem(value: v, child: Text(v.name)),
                    ],
                    onChanged: (v) => setState(() => visibility[edge] = v ?? visibility[edge]!),
                  ),
                ],
              ),
          ],
        ),
        Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            colorChoice('Shadow color', shadowColor, const [
              ('black', Colors.black),
              ('red', Colors.red),
              ('blue', Colors.blue),
              ('green', Colors.green),
            ], (c) => shadowColor = c),
            colorChoice('Divider color', dividerColor, const [
              ('default', Color(0xD0000000)),
              ('red', Colors.red),
              ('transparent', Colors.transparent),
            ], (c) => dividerColor = c),
          ],
        ),
        Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            slider('Elevation (max 10)', useElevation, elevation, 14,
                (v) => useElevation = v, (v) => elevation = v),
            slider('Paddings', usePadding, padding, 60, (v) => usePadding = v,
                (v) => padding = v),
            slider('Radius', useRadius, radius, 30, (v) => useRadius = v, (v) => radius = v),
          ],
        ),
        _Controls('Expected', controller, visibility: visibility, ifHides: ifHides),
      ],
      child: _shadow(
        ListView.builder(
          controller: controller,
          scrollDirection: axis,
          reverse: widget.reverse,
          physics: bouncing
              ? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())
              : null,
          itemCount: 30,
          itemBuilder: (context, index) => _Tile(index: index, axis: axis),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------
// 10. Known limitations.

class _LimitationsScenario extends StatefulWidget {
  const _LimitationsScenario({required this.reverse});

  final bool reverse;

  @override
  State<_LimitationsScenario> createState() => _LimitationsScenarioState();
}

class _LimitationsScenarioState extends State<_LimitationsScenario> {
  final first = ScrollController();
  final second = ScrollController();
  final nested = ScrollController();
  final horizontal = ScrollController();
  final vertical = ScrollController();

  @override
  void dispose() {
    first.dispose();
    second.dispose();
    nested.dispose();
    horizontal.dispose();
    vertical.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: 300,
          child: _Panel(
            title: 'A. Two vertical lists side by side, under ONE ScrollShadow. Scroll the '
                'left list to the middle, then the right one to the end: only "top" stays '
                '(the last one wins). Workaround: one ScrollShadow per list.',
            controls: [
              _Controls('Left list alone would expect', first),
              _Controls('Right list alone would expect', second),
            ],
            child: ScrollShadow(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _list(Axis.vertical, first, reverse: widget.reverse, count: 30),
                  ),
                  const Box.gap(8),
                  Expanded(
                    child: _list(Axis.vertical, second, reverse: widget.reverse, count: 30),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Box.gap(16),
        SizedBox(
          height: 200,
          child: _Panel(
            title: 'B. A horizontal list inside a SingleChildScrollView whose content fits '
                '(it cannot scroll). Scrolling the horizontal list shows NO shadows: it is '
                'nested, so it is ignored. Workaround: wrap it with its own ScrollShadow.',
            controls: [
              _Controls('Horizontal list (ignored) alone would expect', nested),
            ],
            child: ScrollShadow(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Caption('This SingleChildScrollView fits, so it does not scroll.'),
                    SizedBox(
                      height: 70,
                      child: _list(Axis.horizontal, nested,
                          reverse: widget.reverse, count: 30),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Box.gap(16),
        SizedBox(
          height: 170,
          child: _Panel(
            title: 'C. Visual check: the left/right shadows (left panel) should look like '
                'the top/bottom ones (right panel). Both are scrolled to the middle with '
                'Middle.',
            controls: [
              _Controls('Horizontal', horizontal),
              _Controls('Vertical', vertical),
            ],
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ScrollShadow(
                    child: _list(Axis.horizontal, horizontal,
                        reverse: widget.reverse, count: 30),
                  ),
                ),
                const Box.gap(12),
                Expanded(
                  child: ScrollShadow(
                    child: _list(Axis.vertical, vertical, reverse: widget.reverse, count: 30),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------------------
// Helpers.

/// A ScrollShadow with all 4 shadows in the given [color].
Widget _colored(Color color, Widget child) => ScrollShadow(
      topShadowColor: color,
      bottomShadowColor: color,
      leftShadowColor: color,
      rightShadowColor: color,
      child: child,
    );

Widget _list(
  Axis axis,
  ScrollController controller, {
  Key? key,
  required bool reverse,
  required int count,
}) =>
    ListView.builder(
      key: key,
      controller: controller,
      scrollDirection: axis,
      reverse: reverse,
      itemCount: count,
      itemBuilder: (context, index) => _Tile(index: index, axis: axis),
    );

class _Tile extends StatelessWidget {
  const _Tile({required this.index, required this.axis});

  final int index;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: axis == Axis.horizontal ? 90 : null,
      height: axis == Axis.vertical ? 50 : null,
      margin: const Pad(all: 3),
      alignment: Alignment.center,
      color: Colors.primaries[index % Colors.primaries.length].shade100,
      child: Text('$index'),
    );
  }
}

/// Which shadows a lone [ScrollShadow] around this scrollable should show, from its
/// physical edges. This is computed independently of [ScrollShadow], from the scroll
/// position itself, following the documented rules:
///
/// - `alwaysOn` edges are always shown, and `alwaysOff` edges never.
/// - A `whenScrolled` edge is shown when there's content beyond it. Edges of the other
///   axis have no content beyond them.
/// - With [ifHides], while overscrolled at one end, the `whenScrolled` shadow at the
///   other end is hidden.
List<String> _expectedEdges(
  ScrollPosition position, {
  Map<String, ShadowVisibility>? visibility,
  bool ifHides = false,
}) {
  final double before = position.pixels;
  final double after = position.maxScrollExtent - position.pixels;
  final (String start, String end) = switch (position.axisDirection) {
    AxisDirection.down => ('top', 'bottom'),
    AxisDirection.up => ('bottom', 'top'),
    AxisDirection.right => ('left', 'right'),
    AxisDirection.left => ('right', 'left'),
  };

  bool shows(String edge) {
    final v = visibility?[edge] ?? ShadowVisibility.whenScrolled;
    if (v == ShadowVisibility.alwaysOn) return true;
    if (v == ShadowVisibility.alwaysOff) return false;
    if (edge == start) return before > 0 && !(ifHides && after < 0);
    if (edge == end) return after > 0 && !(ifHides && before < 0);
    return false; // An edge of the other axis.
  }

  return [
    for (final edge in const ['top', 'bottom', 'left', 'right'])
      if (shows(edge)) edge,
  ];
}

/// A live label with the expected shadows of the [controller]'s scrollable, followed by
/// buttons to jump to its start, middle and end.
class _Controls extends StatefulWidget {
  const _Controls(
    this.label,
    this.controller, {
    this.color,
    this.visibility,
    this.ifHides = false,
  });

  final String label;
  final ScrollController controller;
  final Color? color;
  final Map<String, ShadowVisibility>? visibility;
  final bool ifHides;

  @override
  State<_Controls> createState() => _ControlsState();
}

class _ControlsState extends State<_Controls> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
    _rebuildAfterLayout();
  }

  @override
  void didUpdateWidget(_Controls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_changed);
      widget.controller.addListener(_changed);
    }
    // The scroll metrics may change during the next layout (for example, after
    // switching the axis or the number of items).
    _rebuildAfterLayout();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  /// When the list scrolls, the label is rebuilt right away and again after the next
  /// layout, because the layout may still correct the scroll position and extent.
  void _changed() {
    if (!mounted) return;
    setState(() {});
    _rebuildAfterLayout();
  }

  void _rebuildAfterLayout() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });

  void _jump(double Function(ScrollPosition position) to) {
    final controller = widget.controller;
    if (controller.hasClients && controller.positions.length == 1) {
      controller.jumpTo(to(controller.position));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    String text;
    if (!controller.hasClients) {
      text = '(not attached)';
    } else if (controller.positions.length != 1 ||
        !controller.position.hasContentDimensions) {
      text = '(not available)';
    } else {
      final position = controller.position;
      final edges = _expectedEdges(
        position,
        visibility: widget.visibility,
        ifHides: widget.ifHides,
      );
      text = '${edges.isEmpty ? 'NO shadows' : edges.join(' + ')}'
          '   (${position.axisDirection.name}, '
          '${position.pixels.toStringAsFixed(0)} / '
          '${position.maxScrollExtent.toStringAsFixed(0)})';
    }

    final Widget label = Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text.rich(
        TextSpan(children: [
          TextSpan(text: '${widget.label}: '),
          TextSpan(text: text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, color: widget.color),
      ),
    );

    final Widget buttons = FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SmallButton('Start', () => _jump((p) => p.minScrollExtent)),
          _SmallButton('Middle', () => _jump((p) => p.maxScrollExtent / 2)),
          _SmallButton('End', () => _jump((p) => p.maxScrollExtent)),
        ],
      ),
    );

    // A fixed height, so that a longer or shorter label never changes the size of the
    // list below it (which would change its scroll extent). When narrow, the buttons go
    // below the label.
    return LayoutBuilder(
      builder: (context, constraints) => (constraints.maxWidth >= 360)
          ? SizedBox(
              height: 48,
              child: Row(children: [Expanded(child: label), buttons]),
            )
          : SizedBox(
              height: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: label),
                  SizedBox(
                    height: 32,
                    child: Align(alignment: AlignmentDirectional.centerEnd, child: buttons),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Shows the identity of the State of the widget with the given [GlobalKey].
class _StateIdLabel extends StatefulWidget {
  const _StateIdLabel(this.stateKey);

  final GlobalKey stateKey;

  @override
  State<_StateIdLabel> createState() => _StateIdLabelState();
}

class _StateIdLabelState extends State<_StateIdLabel> {
  @override
  void initState() {
    super.initState();
    _rebuildAfterLayout();
  }

  @override
  void didUpdateWidget(_StateIdLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _rebuildAfterLayout();
  }

  void _rebuildAfterLayout() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });

  @override
  Widget build(BuildContext context) {
    final state = widget.stateKey.currentState;
    final id = (state == null) ? '-' : '#${identityHashCode(state).toRadixString(16)}';
    return Text(
      'ScrollShadow State id: $id   (must never change in this scenario)',
      style: const TextStyle(fontSize: 13),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.controls, required this.child});

  final String title;
  final List<Widget> controls;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // On small screens, the controls scroll (without any ScrollShadow), so that the
    // list being tested keeps at least about half of the space.
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight * 0.45),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ...controls,
                ],
              ),
            ),
          ),
          const Box.gap(6),
          Expanded(child: ColoredBox(color: Colors.grey.shade100, child: child)),
        ],
      ),
    );
  }
}

class _Instructions extends StatelessWidget {
  const _Instructions(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const Pad(horizontal: 12, bottom: 8),
      padding: const Pad(all: 10),
      color: Colors.amber.shade100,
      constraints: const BoxConstraints(maxHeight: 110),
      child: SingleChildScrollView(
        child: Text(text, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const Pad(all: 6),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      );
}

class _SmallButton extends StatelessWidget {
  const _SmallButton(this.label, this.onPressed);

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const Pad(horizontal: 4),
          minimumSize: const Size(0, 30),
        ),
        onPressed: onPressed,
        child: Text(label),
      );
}

class _LabeledSwitch extends StatelessWidget {
  const _LabeledSwitch(this.label, this.value, this.onChanged);

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => GestureDetector(
        // Tapping the label also toggles the switch.
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(label)),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      );
}

// ---------------------------------------------------------------------------------------
// A minimal 2D grid of 100x100 cells (a TwoDimensionalScrollView), for scenario 8.

class _Grid2D extends TwoDimensionalScrollView {
  const _Grid2D({
    super.verticalDetails,
    super.horizontalDetails,
    super.diagonalDragBehavior,
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
