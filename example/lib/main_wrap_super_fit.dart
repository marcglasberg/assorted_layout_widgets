import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  //
  static const divider =
      Box(color: Colors.black, width: double.infinity, height: 2.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WrapSuper WrapFit Example')),
      body: Container(
        color: const Color(0xFFEEEEEE),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: ColumnSuper(
            innerDistance: 25.0,
            children: [
              //
              divider,
              //
              _title('A bar of 400 pixels.'),
              _wrap(WrapFit.min, [box(400, 300)]),
              _wrap(WrapFit.divided, [box(400, 300)]),
              _wrap(WrapFit.proportional, [box(400, 300)]),
              _wrap(WrapFit.larger, [box(400, 300)]),
              //
              divider,
              //
              _title('A bar of 230 pixels.'),
              _wrap(WrapFit.min, [box(230, 230)]),
              _wrap(WrapFit.divided, [box(230, 300)]),
              _wrap(WrapFit.proportional, [box(230, 300)]),
              _wrap(WrapFit.larger, [box(230, 300)]),
              //
              divider,
              //
              _title('A bar of 140 pixels and another of 220.'),
              _wrap(WrapFit.min, [box(140, 140), box(220, 220)]),
              _wrap(WrapFit.divided, [box(140, 300), box(220, 300)]),
              _wrap(WrapFit.proportional, [box(140, 300), box(220, 300)]),
              _wrap(WrapFit.larger, [box(140, 300), box(220, 300)]),
              //
              divider,
              //
              _title('Four bars: 200, 120, 60 and 80 pixels.'),
              _wrap(WrapFit.min,
                  [box(200, 200), box(120, 120), box(60, 60), box(80, 80)]),
              _wrap(WrapFit.divided,
                  [box(200, 300), box(120, 100), box(60, 100), box(80, 100)]),
              _wrap(WrapFit.proportional, [
                box(200, 300),
                box(120, (120 / (120 + 60 + 80) * 300).toInt()),
                box(60, (60 / (120 + 60 + 80) * 300).toInt()),
                box(80, (80 / (120 + 60 + 80) * 300).toInt())
              ]),
              _wrap(
                WrapFit.larger,
                [box(200, 300), box(120, 120), box(60, 90), box(80, 90)],
              ),
              //
              divider,
              //
            ],
          ),
        ),
      ),
    );
  }

  Widget _title(String text) => Text(
        '$text\nAvailable width is 300:',
        textAlign: TextAlign.center,
      );

  Widget _wrap(WrapFit wrapFit, List<Widget> children) {
    return Column(
      children: [
        Text(wrapFit.toString()),
        const Box(height: 8.0),
        Box(
          color: Colors.purple,
          padding: const Pad(all: 3.0),
          child: Box(
            width: 300,
            color: Colors.purple,
            child: WrapSuper(
              wrapFit: wrapFit,
              spacing: 3.0,
              lineSpacing: 9.0,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget box(double width, int newWidth) => Box(
        color: Colors.lightGreen,
        width: width,
        height: 30,
        child: Center(child: Text("${width.toInt()} ➜ $newWidth")),
      );
}
