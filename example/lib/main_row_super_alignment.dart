// ignore_for_file: deprecated_member_use
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  const Demo({super.key});

  //
  static const List<Widget> boxes = [
    Box.r(width: 50, height: 20),
    Box.g(width: 50, height: 35),
    Box.b(width: 50, height: 50),
  ];

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('RowSuper Alignment')),
      body: SizedBox.expand(
        child: Column(
          children: [
            //
            const Text("topLeft"),
            Box(
              color: Colors.black,
              width: double.infinity,
              child: RowSuper(
                alignment: Alignment.topLeft,
                innerDistance: 6.0,
                outerDistance: 20.0,
                children: boxes,
              ),
            ),
            //
            const Box(height: 4.0),
            //
            const Text("topCenter"),
            Box(
              color: Colors.black,
              width: double.infinity,
              child: RowSuper(
                alignment: Alignment.topCenter,
                innerDistance: 6.0,
                outerDistance: 20.0,
                children: boxes,
              ),
            ),
            //
            const Box(height: 4.0),
            //
            const Text("topRight"),
            Box(
              color: Colors.black,
              width: double.infinity,
              child: RowSuper(
                alignment: Alignment.topRight,
                innerDistance: 6.0,
                outerDistance: 20.0,
                children: boxes,
              ),
            ),
            //
            const Box(height: 15.0),
            //
            const Text("centerLeft"),
            Box(
              color: Colors.black,
              width: double.infinity,
              child: RowSuper(
                alignment: Alignment.centerLeft,
                outerDistance: 20.0,
                children: boxes,
              ),
            ),
            //
            const Box(height: 4.0),
            //
            const Text("center"),
            Box(
              color: Colors.black,
              width: double.infinity,
              child: RowSuper(
                alignment: Alignment.center,
                outerDistance: 20.0,
                children: boxes,
              ),
            ),
            //
            const Box(height: 4.0),
            //
            const Text("centerRight"),
            Box(
              color: Colors.black,
              width: double.infinity,
              child: RowSuper(
                alignment: Alignment.centerRight,
                outerDistance: 20.0,
                children: boxes,
              ),
            ),
            //
            const Box(height: 15.0),
            //
            const Text("bottomLeft"),
            Box(
              color: Colors.black,
              width: double.infinity,
              child: RowSuper(
                alignment: Alignment.bottomLeft,
                children: boxes,
              ),
            ),
            //
            const Box(height: 4.0),
            //
            const Text("bottomCenter"),
            Box(
              color: Colors.black,
              width: double.infinity,
              child: RowSuper(
                alignment: Alignment.bottomCenter,
                children: boxes,
              ),
            ),
            //
            const Box(height: 4.0),
            //
            const Text("bottomRight"),
            Box(
              color: Colors.black,
              width: double.infinity,
              child: RowSuper(
                alignment: Alignment.bottomRight,
                children: boxes,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
