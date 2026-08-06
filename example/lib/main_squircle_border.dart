import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo(), debugShowCheckedModeBanner: false));

class Demo extends StatelessWidget {
  const Demo({super.key});

  /// The whole [SuperRadius] scale, from most pointed to most round, as
  /// (name, exact value, superRadius) records. The exact value is shown only
  /// in the first section; the other sections use just the name.
  static const List<(String, String, double)> _superRadiusScale = [
    ('pointed', '-4.0', SuperRadius.pointed),
    ('squarish', '-15.0', SuperRadius.squarish),
    ('sameAsContinuous\nRectangle', '∞', SuperRadius.sameAsContinuousRectangle),
    ('squircle', '5.0', SuperRadius.squircle),
    ('fatSquircle', '4.0', SuperRadius.fatSquircle),
    ('veryFatSquircle', '3.0', SuperRadius.veryFatSquircle),
    ('fatCircle', '2.5', SuperRadius.fatCircle),
    ('circle', '2.2335625', SuperRadius.circle),
    ('chamfer', '1.0', SuperRadius.chamfer),
  ];

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(
        title: const Text('SquircleBorder Example'),
        backgroundColor: Colors.blue,
      ),
      body: SizedBox.expand(
        child: Padding(
          padding: const Pad(all: 10.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _superRadiusScaleSection(),
                _comparisonWithContinuousRectangleBorder(),
                _comparisonWithCircleAndStadium(),
                _borderSideSection(),
                _proportionalSection(),
                _proportionalScaleSection(),
                _stadiumSection(),
                _arrowWideSection(),
                _arrowTallSection(),
                _arrowButtonsSection(),
                const Box.gap(60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _superRadiusScaleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(
          'The SuperRadius scale (default constructor)',
          'All shapes below use SquircleBorder with the same fixed corner size, '
              'BorderRadius.circular(28). Only the superRadius changes, going from '
              'corners that bulge outward and look pointed, to plain circular '
              'corners, to a straight chamfer cut. Note "pointed" and "squarish" '
              'paint slightly outside their rectangle.',
        ),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final (name, value, superRadius) in _superRadiusScale)
              _item(
                '$name\n($value)',
                SquircleBorder(
                  borderRadius: BorderRadius.circular(28),
                  superRadius: superRadius,
                ),
              ),
          ],
        ),
        const Divider(height: 35),
      ],
    );
  }

  Widget _comparisonWithContinuousRectangleBorder() {
    //
    Widget item(String label, double superRadius, {bool squircleIsLarger = false}) {
      const continuous = ContinuousRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(45)),
      );
      final squircle = SquircleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(45)),
        superRadius: superRadius,
      );
      return _overlayItem(
        width: 150,
        height: 110,
        label,
        larger: squircleIsLarger ? squircle : continuous,
        smaller: squircleIsLarger ? continuous : squircle,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(
          'Compare with ContinuousRectangleBorder',
          'Both shapes use the same BorderRadius.circular(45). The larger shape '
              'is blue, and the smaller one is drawn in yellow on top of it, so '
              'wherever blue peeks out the two curves differ. With the default '
              'superRadius, SquircleBorder is identical to Flutter\'s '
              'ContinuousRectangleBorder, so no blue shows at all. "squircle" '
              'cuts the corner more than ContinuousRectangleBorder, "fatCircle" '
              'cuts it even more, and "squarish" bulges outward past it.',
        ),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            item(
              'default (∞ super radius): identical curves',
              SuperRadius.sameAsContinuousRectangle,
            ),
            item(
              'SuperRadius.squircle (yellow): cuts corners',
              SuperRadius.squircle,
            ),
            item('SuperRadius.fatCircle (yellow): rounder still', SuperRadius.fatCircle),
            item(
              'SuperRadius.squarish (blue): bulges outward',
              SuperRadius.squarish,
              squircleIsLarger: true,
            ),
          ],
        ),
        const Divider(height: 35),
      ],
    );
  }

  Widget _comparisonWithCircleAndStadium() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(
          'Compare with a real circle and a real StadiumBorder',
          'The blue shape is a SquircleBorder.stadium, and drawn in yellow on '
              'top of it is a real CircleBorder (first pair) or a real '
              'StadiumBorder (second pair). With "circle" the squircle matches '
              'the true circular arc almost exactly, so almost no blue shows. '
              'With "fatCircle" a thin blue sliver of squircle remains visible '
              'around the round ends.',
        ),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _overlayItem(
              'SuperRadius.circle (blue)\nvs real circle (yellow)',
              larger: const SquircleBorder.stadium(superRadius: SuperRadius.circle),
              smaller: const CircleBorder(),
            ),
            _overlayItem(
              'SuperRadius.fatCircle (blue) vs real c. (yellow)',
              larger: const SquircleBorder.stadium(superRadius: SuperRadius.fatCircle),
              smaller: const CircleBorder(),
            ),
            _overlayItem(
              'SuperRadius.circle (blue)\nvs real StadiumBorder (yellow)',
              larger: const SquircleBorder.stadium(superRadius: SuperRadius.circle),
              smaller: const StadiumBorder(),
              width: 180,
              height: 90,
            ),
            _overlayItem(
              'SuperRadius.fatCircle (blue)\nvs real StadiumBorder (yellow)',
              larger: const SquircleBorder.stadium(superRadius: SuperRadius.fatCircle),
              smaller: const StadiumBorder(),
              width: 180,
              height: 90,
            ),
          ],
        ),
        const Divider(height: 35),
      ],
    );
  }

  Widget _borderSideSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(
          'With a border side',
          'The border line honors BorderSide.strokeAlign. By default it is drawn '
              'fully inside the shape.',
        ),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _item(
              'inside\n(default)',
              SquircleBorder(
                borderRadius: BorderRadius.circular(28),
                superRadius: SuperRadius.squircle,
                side: const BorderSide(color: Colors.black87, width: 8),
              ),
              color: Colors.lightGreen,
            ),
            _item(
              'center',
              SquircleBorder(
                borderRadius: BorderRadius.circular(28),
                superRadius: SuperRadius.squircle,
                side: const BorderSide(
                  color: Colors.black87,
                  width: 8,
                  strokeAlign: BorderSide.strokeAlignCenter,
                ),
              ),
              color: Colors.lightGreen,
            ),
            _item(
              'outside',
              SquircleBorder(
                borderRadius: BorderRadius.circular(28),
                superRadius: SuperRadius.squircle,
                side: const BorderSide(
                  color: Colors.black87,
                  width: 8,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
              color: Colors.lightGreen,
            ),
            _item(
              'outline only\n(no fill)',
              SquircleBorder(
                borderRadius: BorderRadius.circular(28),
                superRadius: SuperRadius.squircle,
                side: const BorderSide(color: Colors.black87, width: 3),
              ),
              color: Colors.transparent,
            ),
          ],
        ),
        const Divider(height: 35),
      ],
    );
  }

  Widget _proportionalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(
          'SquircleBorder.proportional',
          'The corner size is a fraction of the shape\'s own size, so it adapts '
              'when the shape resizes. All shapes below are 200 × 80 pixels. '
              'A null factor copies the pixel size computed by the other factor, '
              'which makes the corners symmetrical (circular).',
        ),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _item(
              'widthFactor: 1.0\nheightFactor: 1.0\n(stretched squircle)',
              const SquircleBorder.proportional(widthFactor: 1.0, heightFactor: 1.0),
              width: 200,
              height: 80,
              color: Colors.purple,
            ),
            _item(
              'widthFactor: 0.5\nheightFactor: 0.8',
              const SquircleBorder.proportional(widthFactor: 0.5, heightFactor: 0.8),
              width: 200,
              height: 80,
              color: Colors.purple,
            ),
            _item(
              'widthFactor: 0.2\nheightFactor: null\n(symmetrical corners)',
              const SquircleBorder.proportional(widthFactor: 0.2),
              width: 200,
              height: 80,
              color: Colors.purple,
            ),
            _item(
              'widthFactor: null\nheightFactor: 0.8\n(symmetrical corners)',
              const SquircleBorder.proportional(heightFactor: 0.8),
              width: 200,
              height: 80,
              color: Colors.purple,
            ),
          ],
        ),
        const Divider(height: 35),
      ],
    );
  }

  Widget _proportionalScaleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(
          'SquircleBorder.proportional × SuperRadius',
          'The full SuperRadius scale on a "stretched squircle" '
              '(widthFactor: 1.0, heightFactor: 1.0), where the whole outline is '
              'one continuous curve, like an ellipse.',
        ),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final (name, _, superRadius) in _superRadiusScale)
              _item(
                width: 72,
                height: 72,
                name,
                SquircleBorder.proportional(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  superRadius: superRadius,
                ),
                color: Colors.purple,
              ),
          ],
        ),
        const Divider(height: 35),
      ],
    );
  }

  Widget _stadiumSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(
          'SquircleBorder.stadium × SuperRadius',
          'A pill: the corner radius is always half the shape\'s shortest side, '
              'like StadiumBorder. The style of the round ends still comes from '
              'superRadius: with "circle" the result is essentially a regular '
              'StadiumBorder, while the others give squircle-style ends.',
        ),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final (name, _, superRadius) in _superRadiusScale)
              _item(
                name,
                SquircleBorder.stadium(superRadius: superRadius),
                width: 130,
                height: 48,
                color: Colors.teal,
              ),
          ],
        ),
        const Divider(height: 35),
      ],
    );
  }

  Widget _arrowWideSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(
          'SquircleBorder.arrow on a WIDE shape',
          'A pill where one end is shaped as an arrow tip. On a wide shape only '
              'left and right arrows appear; top and bottom need a tall shape, so '
              'here they stay a plain pill.',
        ),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final arrow in Arrow.values)
              _item(
                _arrowLabel(arrow, worksWhenWide: true),
                SquircleBorder.arrow(arrow: arrow),
                width: 110,
                height: 42,
                color: Colors.indigo,
              ),
          ],
        ),
        const Divider(height: 35),
      ],
    );
  }

  Widget _arrowTallSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(
          'SquircleBorder.arrow on a TALL shape',
          'Same thing, on a tall shape: now only top and bottom arrows appear, '
              'and left and right stay a plain pill.',
        ),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            for (final arrow in Arrow.values)
              _item(
                _arrowLabel(arrow, worksWhenWide: false),
                SquircleBorder.arrow(arrow: arrow),
                width: 42,
                height: 90,
                color: Colors.indigo,
              ),
          ],
        ),
        const Divider(height: 35),
      ],
    );
  }

  Widget _arrowButtonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _explanation(
          'Arrow buttons in practice',
          'Since SquircleBorder is a regular ShapeBorder, it works anywhere '
              'Flutter accepts one: ShapeDecoration, Material, buttons, or '
              'clippers. Here, "previous"/"next" style ElevatedButtons.',
        ),
        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const Pad(horizontal: 28, vertical: 16),
                shape: const SquircleBorder.arrow(arrow: Arrow.left),
              ),
              onPressed: () {},
              child: const Text('Back'),
            ),
            const Box.gap(16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const Pad(horizontal: 28, vertical: 16),
                shape: const SquircleBorder.arrow(arrow: Arrow.right),
              ),
              onPressed: () {},
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }

  String _arrowLabel(Arrow arrow, {required bool worksWhenWide}) {
    final bool works = switch (arrow) {
      Arrow.none => false,
      Arrow.left || Arrow.right => worksWhenWide,
      Arrow.top || Arrow.bottom => !worksWhenWide,
    };
    if (arrow == Arrow.none) return 'Arrow.none\n(plain pill)';
    return 'Arrow.${arrow.name}${works ? '' : '\n(stays a pill)'}';
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

  /// A colored shape of the given size, with a small label below it.
  Widget _item(
    String label,
    ShapeBorder shape, {
    double width = 86,
    double height = 60,
    Color color = Colors.blue,
  }) {
    return SizedBox(
      width: width < 104 ? 104 : width,
      child: Column(
        children: [
          Container(
            width: width,
            height: height,
            decoration: ShapeDecoration(color: color, shape: shape),
          ),
          const Box.gap(6),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  /// Two solid shapes stacked for comparison: the one expected to be larger
  /// is blue, and the smaller one is drawn in yellow on top of it, so
  /// wherever blue peeks out the two curves differ.
  Widget _overlayItem(
    String label, {
    required ShapeBorder larger,
    required ShapeBorder smaller,
    double width = 110,
    double height = 110,
  }) {
    return SizedBox(
      width: width < 130 ? 130 : width,
      child: Column(
        children: [
          SizedBox(
            width: width,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: ShapeDecoration(color: Colors.blue, shape: larger),
                ),
                DecoratedBox(
                  decoration: ShapeDecoration(color: Colors.yellow, shape: smaller),
                ),
              ],
            ),
          ),
          const Box.gap(6),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
