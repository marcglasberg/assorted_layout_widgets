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
        child: Container(
          height: 150,
          width: 110,
          color: Colors.yellow,
          child: RowSuper(
//            alignment: Alignment.center,

            separator: Container(width: 2, height: 70, color: Colors.black38),
            innerDistance: 12.0,
//            outerDistance: 8.0,
            children: [
              Text("Text", style: TextStyle(fontSize: 50, color: Colors.red)),
              Text("Text", style: TextStyle(fontSize: 50, color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }
}
