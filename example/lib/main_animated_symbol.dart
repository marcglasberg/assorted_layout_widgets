import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo(), debugShowCheckedModeBanner: false));

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  //
  /// The symbol shown by all the animated sections below.
  /// Changing it animates every [AnimatedSymbol] on the screen.
  SymbolType _symbol = SymbolType.plus;

  void _next() => setState(() {
    _symbol = SymbolType.values[(_symbol.index + 1) % SymbolType.values.length];
  });

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(
        title: const Text('AnimatedSymbol Example'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          _symbolSelector(),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const Pad(all: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _allSymbolsSection(),
                  _animationSection(),
                  _colonSection(),
                  _colorSection(),
                  _widthRatioSection(),
                  _minMaxWidthSection(),
                  _paddingSection(),
                  _widthAndHeightSection(),
                  _durationSection(),
                  const Box.gap(60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Buttons (always visible) to choose the symbol used by the animated sections.
  Widget _symbolSelector() {
    return Padding(
      padding: const Pad(horizontal: 10, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final symbol in SymbolType.values)
            ChoiceChip(
              label: Text(symbol.name),
              selected: _symbol == symbol,
              onSelected: (_) => setState(() => _symbol = symbol),
            ),
          ElevatedButton(onPressed: _next, child: const Text('Next')),
        ],
      ),
    );
  }

  Widget _allSymbolsSection() {
    return _section(
      'The six symbols',
      'AnimatedSymbol(symbol, color) draws one of the SymbolType values: '
          'plus, minus, times, check, equals and colon. The symbol is always square, and '
          'fills the space available to it.',
      [
        for (final symbol in SymbolType.values)
          _item(
            'SymbolType.${symbol.name}',
            AnimatedSymbol(symbol, Colors.blue, width: 60, height: 60),
          ),
      ],
    );
  }

  Widget _animationSection() {
    return _section(
      'Animating between symbols',
      'Each symbol is made of two bars. When the symbol changes, the bars '
          'rotate, move and resize to form the new symbol. Tap the big symbol '
          'below (or use the buttons at the top) to change it. '
          'All other examples below also use the selected symbol.',
      [
        GestureDetector(
          onTap: _next,
          child: Container(
            color: Colors.grey[200],
            child: AnimatedSymbol(_symbol, Colors.blue, width: 150, height: 150),
          ),
        ),
      ],
    );
  }

  Widget _colonSection() {
    return _section(
      'Animating to and from the colon',
      'The colon is made of two circles. When changing to the colon, the two '
          'bars first move and turn into small squares, where the circles will '
          'be. Then the circles appear behind the squares, and the squares '
          'shrink until they disappear, so that the squares seem to become '
          'circles. Changing from the colon does the same, in reverse. '
          'This takes twice the duration. Tap each symbol below to toggle it '
          'between the colon and another symbol. A slow duration is used here, '
          'so that you can see each step.',
      [
        for (final symbol in SymbolType.values)
          if (symbol != SymbolType.colon) _ColonToggle(other: symbol),
      ],
    );
  }

  Widget _colorSection() {
    return _section(
      'color',
      'The second positional parameter is the color of the symbol.',
      [
        for (final (name, color) in const [
          ('Colors.red', Colors.red),
          ('Colors.green', Colors.green),
          ('Colors.orange', Colors.orange),
          ('Colors.black', Colors.black),
        ])
          _item(name, AnimatedSymbol(_symbol, color, width: 60, height: 60)),
      ],
    );
  }

  Widget _widthRatioSection() {
    return _section(
      'widthRatio',
      'The line width is proportional to the size of the symbol. '
          'The widthRatio (default 0.15) is the line width divided '
          'by the symbol size. The check symbol adjusts its shape to the '
          'line width, and was designed for ratios between 0.15 and 0.4. '
          'For the equals, the gap between the bars is also the line width. '
          'For the colon, it is the circle diameter (which is also the gap '
          'between the circles) divided by the symbol size.',
      [
        for (final ratio in const [0.05, 0.10, 0.15, 0.25, 0.40])
          _item(
            'widthRatio: $ratio',
            AnimatedSymbol(
              _symbol,
              Colors.blue,
              width: 60,
              height: 60,
              lineWidthRatio: ratio,
            ),
          ),
      ],
    );
  }

  Widget _minMaxWidthSection() {
    //
    Widget row(String title, {double? minLineWidth, double? maxLineWidth}) {
      return Padding(
        padding: const Pad(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const Box.gap(6),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                for (final size in const [16.0, 32.0, 64.0, 128.0])
                  _item(
                    'size $size',
                    AnimatedSymbol(
                      _symbol,
                      Colors.blue,
                      width: size,
                      height: size,
                      minLineWidth: minLineWidth,
                      maxLineWidth: maxLineWidth,
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(
          'minLineWidth and maxLineWidth',
          'Since the line width is proportional to the symbol size, small '
              'symbols get very thin lines, and large symbols get very thick '
              'lines. Use minLineWidth and maxLineWidth to limit the line '
              'width, in pixels. For the colon, they limit the circle diameter '
              '(and the gap between the circles). Note: minLineWidth may slightly '
              'distort the check symbol.',
        ),
        row('No limits (default)'),
        row('minLineWidth: 4', minLineWidth: 4),
        row('maxLineWidth: 6', maxLineWidth: 6),
        row('minLineWidth: 4, maxLineWidth: 6', minLineWidth: 4, maxLineWidth: 6),
        const Divider(height: 35),
      ],
    );
  }

  Widget _paddingSection() {
    return _section(
      'padding',
      'The padding is applied inside the width and height, so larger '
          'paddings make the symbol smaller. The grey area shows the size of '
          'the widget.',
      [
        for (final padding in const [0.0, 8.0, 16.0, 24.0])
          _item(
            'padding: $padding',
            Container(
              color: Colors.grey[200],
              child: AnimatedSymbol(
                _symbol,
                Colors.blue,
                width: 80,
                height: 80,
                padding: Pad(all: padding),
              ),
            ),
          ),
        _item(
          'Pad(left: 40)',
          Container(
            color: Colors.grey[200],
            child: AnimatedSymbol(
              _symbol,
              Colors.blue,
              width: 80,
              height: 80,
              padding: const Pad(left: 40),
            ),
          ),
        ),
      ],
    );
  }

  Widget _widthAndHeightSection() {
    return _section(
      'width and height',
      'The width and height are optional. The symbol is always square, '
          'uses the smaller dimension, and is centered. When width and height '
          'are not given, the symbol fills the available space. The grey area '
          'shows the size of the widget.',
      [
        for (final (label, width, height) in const [
          ('width: 40, height: 40', 40.0, 40.0),
          ('width: 120, height: 40', 120.0, 40.0),
          ('width: 40, height: 120', 40.0, 120.0),
        ])
          _item(
            label,
            Container(
              color: Colors.grey[200],
              child: AnimatedSymbol(_symbol, Colors.blue, width: width, height: height),
            ),
          ),
        _item(
          'No width/height,\ninside a 100x70 SizedBox',
          Container(
            color: Colors.grey[200],
            child: SizedBox(
              width: 100,
              height: 70,
              child: AnimatedSymbol(_symbol, Colors.blue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _durationSection() {
    return _section(
      'duration',
      'The duration of the animation between symbols (default 300 '
          'milliseconds). Change the symbol to compare them. '
          'Use Duration.zero to disable the animation.',
      [
        for (final (label, duration) in const [
          ('Duration.zero', Duration.zero),
          ('100 ms', Duration(milliseconds: 100)),
          ('300 ms (default)', Duration(milliseconds: 300)),
          ('500 ms', Duration(milliseconds: 500)),
          ('1 second', Duration(seconds: 1)),
          ('3 seconds', Duration(seconds: 3)),
        ])
          _item(
            label,
            GestureDetector(
              onTap: _next,
              child: AnimatedSymbol(
                _symbol,
                Colors.blue,
                width: 60,
                height: 60,
                duration: duration,
              ),
            ),
          ),
      ],
    );
  }

  Widget _section(String title, String text, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(title, text),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: children,
        ),
        const Divider(height: 35),
      ],
    );
  }

  Widget _explanation(String title, String text) {
    return Padding(
      padding: const Pad(top: 7, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Box.gap(4),
          Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        ],
      ),
    );
  }

  /// The given widget, with a small label below it.
  Widget _item(String label, Widget child) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const Box.gap(4),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

/// Toggles between the colon and the [other] symbol, when tapped.
class _ColonToggle extends StatefulWidget {
  final SymbolType other;

  const _ColonToggle({required this.other});

  @override
  State<_ColonToggle> createState() => _ColonToggleState();
}

class _ColonToggleState extends State<_ColonToggle> {
  bool _isColon = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isColon = !_isColon),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.grey[200],
            child: AnimatedSymbol(
              _isColon ? SymbolType.colon : widget.other,
              Colors.blue,
              width: 80,
              height: 80,
              duration: const Duration(milliseconds: 800),
            ),
          ),
          const Box.gap(4),
          Text(
            '${widget.other.name} ⇄ colon',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
