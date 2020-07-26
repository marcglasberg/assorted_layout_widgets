import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() async => runApp(MaterialApp(home: Demo()));

class Demo extends StatefulWidget {
  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  int itemCount;
  double height;
  double width;
  double outer;
  double inner;
  bool withSeparator;
  Alignment alignment;
  double separatorWidth;
  double parentHeight;
  bool intrinsic;

  @override
  void initState() {
    super.initState();
    itemCount = 5;
    height = width = 10.0;
    inner = 8.0;
    outer = 16.0;
    withSeparator = true;
    alignment = Alignment.center;
    separatorWidth = 1.0;
    parentHeight = null;
    intrinsic = false;
  }

  void _reset() {
    itemCount = 0;
    height = width = 10.0;
    inner = 0.0;
    outer = 0.0;
    withSeparator = true;
    alignment = Alignment.center;
    separatorWidth = 1.0;
    parentHeight = null;
    intrinsic = false;
  }

  @override
  Widget build(BuildContext context) {
    print('---');
    print('count = $itemCount');
    print('width = $height');
    print('height = $width');
    print('inner = $inner');
    print('outer = $outer');
    print('withSeparator = $withSeparator');
    print('separatorHeight = $separatorWidth');
    print('parentHeight = $parentHeight');

    return Scaffold(
      appBar: AppBar(title: const Text('RowSuper Playground')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    blueBox(),
                    if (intrinsic)
                      IntrinsicWidth(
                        child: IntrinsicHeight(child: _content()),
                      )
                    else
                      _content(),
                    blueBox(),
                  ],
                ),
              ),
            ),
          ),
          //
          Container(
            width: double.infinity,
            color: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    button("Add Item", () => itemCount++, color: Colors.green),
                    button("Reset", _reset, color: Colors.red),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    button("- Width", () => width -= (width > 0.0) ? 1.0 : 0.0),
                    button("+ Width", () => width += 1.0),
                    Box(width: 10.0),
                    button("- Height", () => height -= (height > 0.0) ? 1.0 : 0.0),
                    button("+ Height", () => height += 1.0),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    button("- Inner", () => inner -= 1.0),
                    button("+ Inner", () => inner += 1.0),
                    Text("   $inner"),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    button("- Outer", () => outer -= 1.0),
                    button("+ Outer", () => outer += 1.0),
                    Text("   $outer"),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    button("Separator ${withSeparator ? 'On' : 'Off'}",
                        () => withSeparator = !withSeparator),
                    button(
                        "- Sep",
                        withSeparator
                            ? () => separatorWidth -= (separatorWidth > 0.0) ? 1.0 : 0.0
                            : null),
                    button("+ Sep", withSeparator ? () => separatorWidth += 1.0 : null),
                    Text("   $separatorWidth"),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    button("Parent Height = $parentHeight", () {
                      if (parentHeight == null)
                        parentHeight = 70.0;
                      else if (parentHeight == 70.0)
                        parentHeight = double.infinity;
                      else if (parentHeight == double.infinity) parentHeight = null;
                    }),
                    Box(width: 10.0),
                    button("Alignment = $alignment", () {
                      if (alignment == Alignment.center)
                        alignment = Alignment.topLeft;
                      else if (alignment == Alignment.topLeft)
                        alignment = Alignment.bottomLeft;
                      else if (alignment == Alignment.bottomLeft) alignment = Alignment.center;
                    })
                  ],
                ),
                button("Intrinsic Width/Height = $intrinsic", () => intrinsic = !intrinsic),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _content() {
    return Container(
      color: Colors.yellow,
      height: parentHeight,
      child: RowSuper(
        alignment: alignment,
        separator: withSeparator ? separator() : null,
        innerDistance: inner,
        outerDistance: outer,
        children: [
          for (int i = 0; i < itemCount; i++) coloredBox(i),
        ],
      ),
    );
  }

  Widget button(String label, VoidCallback func, {Color color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: MaterialButton(
          visualDensity: VisualDensity(vertical: -1.0, horizontal: -3.0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          color: color ?? Colors.blue,
          child: Text(label),
          onPressed: (func == null) ? null : () => setState(func),
        ),
      );

  Widget separator() => Container(
        height: 100,
        width: separatorWidth,
        color: Colors.black.withOpacity(0.5),
      );

  Widget coloredBox(int index) => Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.5),
          border: Border.all(width: 0.5, color: Colors.black),
        ),
        height: height + index * 10.0,
        width: width,
      );

  Widget blueBox() => Container(
        height: 120,
        width: 15,
        color: Colors.blue.withOpacity(0.80),
      );
}
