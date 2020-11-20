import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() async => runApp(MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('RowSuper Alignment')),
      body: SizedBox.expand(
        child: Column(
          children: [
            //
            Box(
              color: Colors.black,
              width: double.infinity,
              child: RowSuper(
                alignment: Alignment.topLeft,
                innerDistance: 8.0,
                outerDistance: 8.0,
                children: [
                  Box.r(width: 50, height: 20),
                  Box.g(width: 50, height: 50),
                  Box.b(width: 50, height: 50),
                ],
              ),
            ),
            //
            Box(height: 10.0),
            //
            Box(
              color: Colors.black,
              width: double.infinity,
              child: RowSuper(
                alignment: Alignment.topCenter,
                innerDistance: 8.0,
                outerDistance: 8.0,
                children: [
                  Box.r(width: 50, height: 20),
                  Box.g(width: 50, height: 50),
                  Box.b(width: 50, height: 50),
                ],
              ),
            ),
            //
            Box(height: 10.0),
            //
            Box(
              color: Colors.black,
              width: double.infinity,
              child: RowSuper(
                alignment: Alignment.topRight,
                innerDistance: 8.0,
                outerDistance: 8.0,
                children: [
                  Box.r(width: 50, height: 20),
                  Box.g(width: 50, height: 50),
                  Box.b(width: 50, height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
