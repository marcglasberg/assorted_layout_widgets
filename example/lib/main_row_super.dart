import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() async => runApp(MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('RowSuper Example')),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: RowSuper(
            innerDistance: 8.0,
            outerDistance: 8.0,
            children: [
              example1(),
              example2(),
              example3(),
              example4(),
              example5(),
              example6(),
              example7(),
              example8(),
              example9(),
              example10(),
              example11(),
              example12(),
              example13(),
              example14(),
              example15(),
              example16(),
            ],
          ),
        ),
      ),
    );
  }

  Widget example1() => Container(
        color: Colors.yellow,
        child: RowSuper(
          alignment: Alignment.center,
          invert: false,
          children: [redBox(), blueBox()],
        ),
      );

  Widget example2() => Container(
        color: Colors.yellow,
        child: RowSuper(
          outerDistance: -3,
          alignment: Alignment.center,
          invert: false,
          children: [redBox(), blueBox()],
        ),
      );

  Widget example3() => Container(
        color: Colors.yellow,
        child: RowSuper(
          alignment: Alignment.center,
          invert: false,
          innerDistance: -15,
          children: [redBox(), blueBox()],
        ),
      );

  Widget example4() => Container(
        color: Colors.yellow,
        child: RowSuper(
          alignment: Alignment.center,
          invert: true,
          innerDistance: -15,
          children: [redBox(), blueBox()],
        ),
      );

  Widget example5() => Container(
        color: Colors.yellow,
        child: RowSuper(
          alignment: Alignment.center,
          invert: false,
          outerDistance: 5,
          innerDistance: -15,
          children: [null, redBox(), null, blueBox(), null],
        ),
      );

  Widget example6() => Container(
        color: Colors.yellow,
        child: RowSuper(
          alignment: Alignment.bottomCenter,
          innerDistance: -15,
          children: [redBox(), blueBox()],
        ),
      );

  Widget example7() => Container(
        color: Colors.yellow,
        child: RowSuper(
          alignment: Alignment.topCenter,
          innerDistance: -15,
          children: [redBox(), blueBox()],
        ),
      );

  Widget example8() => Container(
        color: Colors.yellow,
        child: RowSuper(
          alignment: Alignment.topCenter,
          innerDistance: 20,
          separator: separator(),
          children: [redBox(), blueBox()],
        ),
      );

  Widget example9() => Container(
        color: Colors.yellow,
        child: RowSuper(
          alignment: Alignment.center,
          innerDistance: 20,
          separator: separator(),
          children: [redBox(), blueBox()],
        ),
      );

  Widget example10() => Container(
        color: Colors.yellow,
        child: RowSuper(
          alignment: Alignment.center,
          innerDistance: 0,
          separator: separator(),
          children: [redBox(), blueBox()],
        ),
      );

  Widget example11() => Container(
        color: Colors.yellow,
        child: RowSuper(
          alignment: Alignment.center,
          innerDistance: 0,
          separator: separator(),
          separatorOnTop: false,
          children: [redBox(), blueBox()],
        ),
      );

  Widget example12() => Container(
        color: Colors.yellow,
        child: RowSuper(
          alignment: Alignment.center,
          innerDistance: -45,
          separatorOnTop: false,
          children: [
            Text("Text", style: TextStyle(fontSize: 50, color: Colors.red)),
            Text("Text", style: TextStyle(fontSize: 50, color: Colors.blue)),
            Text("Text", style: TextStyle(fontSize: 50, color: Colors.green)),
          ],
        ),
      );

  Widget example13() => Container(
        color: Colors.yellow,
        child: RowSuper(
          alignment: Alignment.center,
          innerDistance: -45,
          invert: true,
          separatorOnTop: false,
          children: [
            Text("Text", style: TextStyle(fontSize: 50, color: Colors.red)),
            Text("Text", style: TextStyle(fontSize: 50, color: Colors.blue)),
            Text("Text", style: TextStyle(fontSize: 50, color: Colors.green)),
          ],
        ),
      );

  Widget example14() => Container(
        color: Colors.yellow,
        child: RowSuper(
          alignment: Alignment.center,
          innerDistance: 0,
          separator: Container(
            height: 200,
            width: 1,
            color: Colors.black,
          ),
          separatorOnTop: false,
          children: [
            Text("Text", style: TextStyle(fontSize: 50, color: Colors.red)),
            Text("Text", style: TextStyle(fontSize: 50, color: Colors.blue)),
            Text("Text", style: TextStyle(fontSize: 50, color: Colors.green)),
          ],
        ),
      );

  Widget example15() => Container(
        color: Colors.yellow,
        child: RowSuper(
          alignment: Alignment.center,
          innerDistance: 0,
          separator: Container(
            height: 200,
            width: 40,
            color: Colors.black,
          ),
          separatorOnTop: false,
          children: [
            Text("Text", style: TextStyle(fontSize: 50, color: Colors.red)),
            Text("Text", style: TextStyle(fontSize: 50, color: Colors.blue)),
            Text("Text", style: TextStyle(fontSize: 50, color: Colors.green)),
          ],
        ),
      );

  Widget example16() => Container(
        color: Colors.yellow,
        child: RowSuper(
          alignment: Alignment.center,
          innerDistance: 0,
          separator: Container(
            height: 200,
            width: 40,
            color: Colors.black,
          ),
          separatorOnTop: true,
          children: [
            Text("Text", style: TextStyle(fontSize: 50, color: Colors.red)),
            Text("Text", style: TextStyle(fontSize: 50, color: Colors.blue)),
            Text("Text", style: TextStyle(fontSize: 50, color: Colors.green)),
          ],
        ),
      );

  Widget separator() => Container(
        width: 14,
        height: 70,
        color: Colors.black.withOpacity(0.5),
      );

  Widget redBox() => Container(
        width: 50,
        height: 50,
        color: Colors.red,
      );

  Widget blueBox() => Container(
        width: 30,
        height: 70,
        color: Colors.blue.withOpacity(0.80),
      );
}
