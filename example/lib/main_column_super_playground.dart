import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo()));

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  late int itemCount;
  late double width;
  late double height;
  late double outer;
  late double inner;
  late bool withSeparator;
  late Alignment alignment;
  late double separatorHeight;
  late double? parentWidth;
  late bool intrinsic;

  @override
  void initState() {
    super.initState();
    itemCount = 5;
    width = height = 10.0;
    inner = 8.0;
    outer = 16.0;
    withSeparator = true;
    alignment = Alignment.center;
    separatorHeight = 1.0;
    parentWidth = null;
    intrinsic = false;
  }

  void _reset() {
    itemCount = 0;
    width = height = 10.0;
    inner = 0.0;
    outer = 0.0;
    withSeparator = true;
    alignment = Alignment.center;
    separatorHeight = 1.0;
    parentWidth = null;
    intrinsic = false;
  }

  @override
  Widget build(BuildContext context) {
    print('---');
    print('count = $itemCount');
    print('width = $width');
    print('height = $height');
    print('inner = $inner');
    print('outer = $outer');
    print('withSeparator = $withSeparator');
    print('separatorHeight = $separatorHeight');

    return Scaffold(
      appBar: AppBar(title: const Text('ColumnSuper Playground')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
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
                    const Box(width: 10.0),
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
                            ? () => separatorHeight -= (separatorHeight > 0.0) ? 1.0 : 0.0
                            : null),
                    button("+ Sep", withSeparator ? () => separatorHeight += 1.0 : null),
                    Text("   $separatorHeight"),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    button("Parent Width = $parentWidth", () {
                      if (parentWidth == null) {
                        parentWidth = 70.0;
                      } else if (parentWidth == 70.0) {
                        parentWidth = double.infinity;
                      } else if (parentWidth == double.infinity) {
                        parentWidth = null;
                      }
                    }),
                    const Box(width: 10.0),
                    button("Alignment = $alignment", () {
                      if (alignment == Alignment.center) {
                        alignment = Alignment.topLeft;
                      } else if (alignment == Alignment.topLeft) {
                        alignment = Alignment.topRight;
                      } else if (alignment == Alignment.topRight) {
                        alignment = Alignment.center;
                      }
                    }),
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
      width: parentWidth,
      child: ColumnSuper(
        alignment: alignment,
        separator: withSeparator ? separator() : null,
        innerDistance: inner,
        outerDistance: outer,
        removeChildrenWithNoHeight: true,
        children: [
          for (int i = 0; i < itemCount; i++) coloredBox(i),
        ],
      ),
    );
  }

  Widget button(String label, VoidCallback? func, {Color color = Colors.blue}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: MaterialButton(
          visualDensity: const VisualDensity(vertical: -1.0, horizontal: -3.0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          color: color,
          onPressed: (func == null) ? null : () => setState(func),
          child: Text(label),
        ),
      );

  Widget separator() => Container(
        width: 100,
        height: separatorHeight,
        color: Colors.black.withOpacity(0.5),
      );

  Widget coloredBox(int index) => Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.5),
          border: Border.all(width: 0.5, color: Colors.black),
        ),
        width: width + index * 10.0,
        height: height,
      );

  Widget blueBox() => Container(
        width: 120,
        height: 15,
        color: Colors.blue.withOpacity(0.80),
      );
}
