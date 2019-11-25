import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() async => runApp(MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('FitHorizontally Example')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //
            SizedBox(height: 10),
            Text("Simple text:"),
            SizedBox(height: 10),
            //
            Container(
                alignment: Alignment.centerLeft,
                color: Colors.yellow,
                child: text(),
                width: double.infinity,
                height: 30),
            Container(
                alignment: Alignment.centerLeft,
                color: Colors.yellow,
                child: text(),
                width: 250,
                height: 30),
            Container(
                alignment: Alignment.centerLeft,
                color: Colors.yellow,
                child: text(),
                width: 150,
                height: 30),
            //
            SizedBox(height: 30),
            Text("Text wrapped with FitHorizontally:"),
            SizedBox(height: 10),
            //
            Container(
                alignment: Alignment.centerLeft,
                color: Colors.yellow,
                child: FitHorizontally(child: text()),
                width: double.infinity,
                height: 30),
            Container(
                alignment: Alignment.centerLeft,
                color: Colors.yellow,
                child: FitHorizontally(child: text()),
                width: 250,
                height: 30),
            Container(
                alignment: Alignment.centerLeft,
                color: Colors.yellow,
                child: FitHorizontally(child: text()),
                width: 150,
                height: 30),
          ],
        ),
      ),
    );
  }

  Container separator() => Container(width: 2, height: 50, color: Colors.black26);

  Text text() => Text(
        "So long, farewell, auf Wiedersehen.",
        overflow: TextOverflow.fade,
        style: TextStyle(fontSize: 20, color: Colors.blue),
        maxLines: 1,
        softWrap: false,
      );
}
