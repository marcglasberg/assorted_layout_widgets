import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() async => runApp(MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('RowSuper Fill Example')),
      body: Center(
        child: Column(
          children: [
            //
            SizedBox(height: 20.0),
            Text("fill: false"),
            SizedBox(height: 10.0),
            RowSuper(
              children: [
                Container(
                  alignment: Alignment.center,
                  color: Colors.red,
                  child: Text("Hello"),
                ),
                Container(
                  alignment: Alignment.center,
                  color: Colors.blue.withOpacity(0.80),
                  child: Text("Hello"),
                )
              ],
            ),
            SizedBox(height: 10.0),
            RowSuper(
              children: [
                Container(
                  alignment: Alignment.center,
                  color: Colors.red,
                  child: Text("Hello"),
                ),
                Container(
                  alignment: Alignment.center,
                  color: Colors.blue.withOpacity(0.80),
                  child: Text("This is some larger text"),
                )
              ],
            ),
            SizedBox(height: 10.0),
            RowSuper(
              children: [
                Container(
                  alignment: Alignment.center,
                  color: Colors.red,
                  child: Text("Hello"),
                ),
                Container(
                  alignment: Alignment.center,
                  color: Colors.blue.withOpacity(0.80),
                  child: Text("This is some really very, "
                      "extremely large text "
                      "that won't fit a single line at all"),
                )
              ],
            ),
            //
            // -------------------
            //
            SizedBox(height: 40.0),
            Container(width: double.infinity, height: 1.0, color: Colors.black),
            SizedBox(height: 40.0),
            Text("fill: true"),
            SizedBox(height: 10.0),
            RowSuper(
              fill: true,
              children: [
                Container(
                  alignment: Alignment.center,
                  color: Colors.red,
                  child: Text("Hello"),
                ),
                Container(
                  alignment: Alignment.center,
                  color: Colors.blue.withOpacity(0.80),
                  child: Text("Hello"),
                )
              ],
            ),
            SizedBox(height: 10.0),
            RowSuper(
              fill: true,
              children: [
                Container(
                  alignment: Alignment.center,
                  color: Colors.red,
                  child: Text("Hello"),
                ),
                Container(
                  alignment: Alignment.center,
                  color: Colors.blue.withOpacity(0.80),
                  child: Text("This is some larger text"),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            RowSuper(
              fill: true,
              children: [
                Container(
                  alignment: Alignment.center,
                  color: Colors.red,
                  child: Text("Hello"),
                ),
                Container(
                  alignment: Alignment.center,
                  color: Colors.blue.withOpacity(0.80),
                  child: Text("This is some really very, "
                      "extremely large text "
                      "that won't fit a single line at all"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
