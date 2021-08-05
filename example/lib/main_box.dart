import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('Box Example')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
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
              example17(),
              example18(),
            ],
          ),
        ),
      ),
    );
  }

  Widget example1() => const Box(
        color: Colors.purple,
        child: Text("Test 1"),
      );

  // ignore: deprecated_member_use
  Widget example2() => const Box.r(
        child: Text("Test 2"),
      );

  // This is hidden because of show: false.
  // ignore: deprecated_member_use
  Widget example3() => const Box.g(
        show: false,
        padding: Pad(top: 20),
        child: Text("Test 3"),
      );

  // ignore: deprecated_member_use
  Widget example4() => const Box.b(
        padding: Pad(top: 10, bottom: 10),
        child: Text("Test 4"),
      );

  // This is hidden because child is null. Padding is applied.
  // ignore: deprecated_member_use
  Widget example5() => const Box.y(
        color: Colors.purple,
        padding: Pad(top: 20),
      );

  // This is the same as top:10, bottom:10.
  // ignore: deprecated_member_use
  Widget example6() => const Box.r(
        padding: Pad(vertical: 10),
        child: Text("Test 6"),
      );

  // This is the same as right:10, left:10.
  // ignore: deprecated_member_use
  Widget example7() => const Box.g(
        padding: Pad(horizontal: 10),
        child: Text("Test 7"),
      );

  // ignore: deprecated_member_use
  Widget example8() => const Box.b(
        width: 200,
        height: 100,
        child: Text("Test 8"),
      );

  // ignore: deprecated_member_use
  Widget example9() => const Box.y(
        padding: Pad(vertical: 20, horizontal: 40),
        width: 200,
        height: 100,
        child: Text("Test 9"),
      );

  // This will change color in each rebuild.
  // ignore: deprecated_member_use
  Widget example10() => const Box.rand(
        padding: Pad(vertical: 20, horizontal: 40),
        child: Text("Test 10"),
      );

  Box redBox(String text) => Box(
        color: Colors.red,
        padding: const Pad(vertical: 5, horizontal: 5),
        width: 280,
        height: 35,
        child: Text(text),
      );

  Widget example11() => Padding(
        padding: const Pad(all: 2.0),
        child: redBox('box'),
      );

  Widget example12() => Padding(
        padding: const Pad(all: 2.0),
        child: redBox('box + Colors.blue') + Colors.blue,
      );

  Widget example13() => Padding(
        padding: const Pad(all: 2.0),
        child: redBox('box + Pad(left: 10)') + Pad(left: 10),
      );

  Widget example14() => Padding(
        padding: const Pad(all: 2.0),
        child: redBox('box + Alignment.bottomRight') + Alignment.bottomRight,
      );

  Widget example15() => Padding(
        padding: const Pad(all: 2.0),
        child: const Box.b(padding: Pad(all: 8.0)) + redBox('Box.b(padding: Pad(all: 8.0)) + box'),
      );

  // Must remove padding when has no child. But has child, so don't remove padding.
  Widget example16() => const Box(
        color: Colors.red,
        padding: Pad(all: 20.0),
        removePaddingWhenNoChild: true,
        child: Text('Has padding'),
      );

  // Not visible:
  // Must remove padding when has no child. Has child, so removes padding.
  Widget example17() => const Box(
        color: Colors.green,
        padding: Pad(all: 20.0),
        removePaddingWhenNoChild: true,
      );

  // Must NOT remove padding when has no child. Has no child, but don't remove padding.
  Widget example18() => const Box(
        color: Colors.green,
        padding: Pad(all: 20.0),
        removePaddingWhenNoChild: false,
      );
}
