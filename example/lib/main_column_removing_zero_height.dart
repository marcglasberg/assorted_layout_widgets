import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  const Demo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ColumnSuper Remove Children')),
      body: Column(
        children: [
          const Padding(
            padding: Pad(all: 20),
            child:
                Text("Click the colored boxes to turn their height to zero (they keep their width)."
                    "\n\n"
                    "The left column has removeChildrenWithNoHeight: false"
                    "\n\n"
                    "The right column has removeChildrenWithNoHeight: true"),
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  ColoredColumn(removeChildrenWithNoHeight: false),
                  Box(width: 50),
                  ColoredColumn(removeChildrenWithNoHeight: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget coloredBox(Color color, double height) => Container(
        color: color.withOpacity(0.8),
        width: 50,
        height: height,
      );
}

class ColoredColumn extends StatefulWidget {
  final bool removeChildrenWithNoHeight;

  const ColoredColumn({required this.removeChildrenWithNoHeight});

  @override
  _ColoredColumnState createState() => _ColoredColumnState();
}

class _ColoredColumnState extends State<ColoredColumn> {
  static const separator = Box(width: 80, height: 3, color: Colors.black38);

  Set<int> zeroHeight = {};

  @override
  Widget build(BuildContext context) {
    return Box(
      color: Colors.black12,
      child: ColumnSuper(
        separator: separator,
        innerDistance: 20,
        outerDistance: 10,
        removeChildrenWithNoHeight: widget.removeChildrenWithNoHeight,
        children: [
          coloredBox(0, Colors.red, zeroHeight.contains(0) ? 0 : 10),
          coloredBox(1, Colors.green, zeroHeight.contains(1) ? 0 : 30),
          coloredBox(2, Colors.blue, zeroHeight.contains(2) ? 0 : 130),
          coloredBox(3, Colors.purple, zeroHeight.contains(3) ? 0 : 90),
          coloredBox(4, Colors.orange, zeroHeight.contains(4) ? 0 : 60),
        ],
      ),
    );
  }

  Widget coloredBox(int index, Color color, double height) => GestureDetector(
        onTap: () {
          setState(() {
            zeroHeight.add(index);
          });
        },
        child: Container(
          color: color.withOpacity(0.8),
          width: 50 + index * 20,
          height: height,
        ),
      );
}
