import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main()  => runApp(MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('Box Example')),
      body: Center(
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
          ],
        ),
      ),
    );
  }

  Widget example1() => const Box(
        color: Colors.purple,
        child: Text("Test 1"),
      );

  Widget example2() => const Box.r(
        child: Text("Test 2"),
      );

  // This is hidden because of show: false.
  Widget example3() => const Box.g(
        show: false,
        padding: Pad(top: 20),
        child: Text("Test 3"),
      );

  Widget example4() => const Box.b(
        padding: Pad(top: 10, bottom: 10),
        child: Text("Test 4"),
      );

  // This is hidden because child is null. Padding is applied.
  Widget example5() => const Box.y(
        color: Colors.purple,
        padding: Pad(top: 20),
      );

  // This is the same as top:10, bottom:10.
  Widget example6() => const Box.r(
        padding: Pad(vertical: 10),
        child: Text("Test 6"),
      );

  // This is the same as right:10, left:10.
  Widget example7() => const Box.g(
        padding: Pad(horizontal: 10),
        child: Text("Test 7"),
      );

  Widget example8() => const Box.b(
        width: 200,
        height: 100,
        child: Text("Test 8"),
      );

  Widget example9() => const Box.y(
        padding: Pad(vertical: 20, horizontal: 40),
        width: 200,
        height: 100,
        child: Text("Test 9"),
      );

  // This will change color in each rebuild.
  Widget example10() => const Box.rand(
        padding: Pad(vertical: 20, horizontal: 40),
        child: Text("Test 10"),
      );
}
