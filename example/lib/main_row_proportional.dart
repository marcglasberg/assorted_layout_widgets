import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo(), debugShowCheckedModeBanner: false));

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(
        title: const Text('RowProportional Example'),
        backgroundColor: Colors.blue,
      ),
      body: SizedBox.expand(
        child: Padding(
          padding: const Pad(all: 10.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _proportionalDistribution(),
                _comparisonWithRow(),
                _expandedMultipliesByTheFlex(),
                _flexibleMayBeSmaller(),
                _spacerTakesTheLeftoverSpace(),
                _fixedWidthGaps(),
                _fixedWidthPinsAChild(),
                _fixedWidthAtPreferredWidth(),
                _textChildren(),
                const Box.gap(400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _proportionalDistribution() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(
          'Proportional distribution',
          'Children want to be 30 and 100 pixels wide. They keep this proportion.',
        ),
        BoxAnimatingWidth(
          minWidth: 40,
          child: RowProportional(
            children: [_block(30, Colors.red), _block(100, Colors.blue)],
          ),
        ),
        const Divider(height: 25),
      ],
    );
  }

  Widget _comparisonWithRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(
          'Compare with Row + Expanded',
          'Ignores preferred widths, and divides the space 50:50.',
        ),
        BoxAnimatingWidth(
          minWidth: 40,
          child: Row(
            children: [
              Expanded(child: _block(30, Colors.red)),
              Expanded(child: _block(100, Colors.blue)),
            ],
          ),
        ),
        const Divider(height: 25),
      ],
    );
  }

  Widget _expandedMultipliesByTheFlex() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(
          'Expanded multiplies by the flex',
          'Wrapping the red child in Expanded(flex: 2) makes it count '
              'as 30 × 2 = 60 width.',
        ),
        BoxAnimatingWidth(
          minWidth: 40,
          child: RowProportional(
            children: [
              Expanded(flex: 2, child: _block(30, Colors.red, '30 × 2')),
              _block(100, Colors.blue),
            ],
          ),
        ),
        const Divider(height: 25),
      ],
    );
  }

  Widget _flexibleMayBeSmaller() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(
          'Flexible may be smaller',
          'The green child gets space proportionally to 70, but since it\'s wrapped '
              'in a Flexible, it won\'t grow beyond its preferred 70 pixels.',
        ),
        BoxAnimatingWidth(
          minWidth: 40,
          child: RowProportional(
            children: [
              Flexible(child: _block(70, Colors.green)),
              _block(100, Colors.blue),
            ],
          ),
        ),
        const Divider(height: 25),
      ],
    );
  }

  Widget _spacerTakesTheLeftoverSpace() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(
          'Spacer takes the leftover space',
          'With a Spacer, children get exactly their preferred widths and the Spacer gets the rest. '
              'When no space is left, the Spacer disappears and the children shrink proportionally.',
        ),
        BoxAnimatingWidth(
          minWidth: 100,
          child: RowProportional(
            children: [_block(70, Colors.red), const Spacer(), _block(100, Colors.blue)],
          ),
        ),
        const Divider(height: 25),
      ],
    );
  }

  Widget _fixedWidthGaps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(
          'FixedWidth with width and without a child creates gaps',
          'The 8 and 20 pixel gaps never change. Others scale proportionally.',
        ),
        BoxAnimatingWidth(
          minWidth: 60,
          child: RowProportional(
            children: [
              _block(70, Colors.red),
              const FixedWidth(width: 8),
              _block(100, Colors.blue),
              const FixedWidth(width: 20),
              _block(50, Colors.green),
            ],
          ),
        ),
        const Divider(height: 25),
      ],
    );
  }

  Widget _fixedWidthPinsAChild() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(
          'FixedWidth with width',
          'The orange child has 60 pixels, no matter what. The others scale.',
        ),
        BoxAnimatingWidth(
          minWidth: 80,
          child: RowProportional(
            children: [
              _block(70, Colors.red),
              FixedWidth(width: 60, child: _block(100, Colors.orange, '60')),
              _block(100, Colors.blue),
            ],
          ),
        ),
        const Divider(height: 25),
      ],
    );
  }

  Widget _fixedWidthAtPreferredWidth() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(
          'FixedWidth without a width',
          'If you don\'t provide the width, the child is fixed at its preferred '
              'width. The reddish "Some text" keeps exactly the width that fits '
              'it, while the others scale. If not even the fixed '
              'widths fit, they shrink too, so the row never overflows.',
        ),
        BoxAnimatingWidth(
          minWidth: 55,
          child: RowProportional(
            children: [
              _text('Hello!', Colors.green),
              FixedWidth(child: _text('Some text', Colors.red)),
              _text('How are you doing today?', Colors.blue),
            ],
          ),
        ),
        const Divider(height: 25),
      ],
    );
  }

  Widget _textChildren() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(
          'Text children',
          'Texts are measured by their single-line width. '
              'If allowed to wrap, they do it only when they don\'t fit in a single line.',
        ),
        BoxAnimatingWidth(
          minWidth: 55,
          child: RowProportional(
            children: [
              _text('Hello!', Colors.green),
              FixedWidth(child: _text('Some text', Colors.red, wrap: true)),
              _text('How are you doing today?', Colors.blue),
            ],
          ),
        ),
        const Divider(height: 25),
      ],
    );
  }

  Widget _explanation(String title, String text) {
    return Padding(
      padding: const Pad(top: 7, bottom: 8),
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

  /// A colored block that wants to be [width] pixels wide.
  /// The label shows its preferred width, so you can compare it with the width
  /// it actually got.
  Widget _block(double width, MaterialColor color, [String? label]) {
    return Container(
      width: width,
      height: 27,
      color: color,
      alignment: Alignment.center,
      child: Text(
        label ?? width.toInt().toString(),
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }

  /// A text with a colored background, so you can see the space it was given.
  Widget _text(String text, MaterialColor color, {bool wrap = false}) {
    return Container(
      color: color.shade100,
      padding: const Pad(vertical: 8),
      child: Text(
        text,
        maxLines: wrap ? 2 : 1,
        softWrap: wrap,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
