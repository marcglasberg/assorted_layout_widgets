import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('FitHorizontally Example')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //
              const Box(height: 10),
              const Text("Simple text:"),
              const Box(height: 10),
              //
              Container(
                alignment: Alignment.centerLeft,
                color: Colors.yellow,
                width: double.infinity,
                height: 30,
                child: text(),
              ),
              Container(
                alignment: Alignment.centerLeft,
                color: Colors.yellow,
                width: 250,
                height: 30,
                child: text(),
              ),
              Container(
                alignment: Alignment.centerLeft,
                color: Colors.yellow,
                width: 150,
                height: 30,
                child: text(),
              ),
              //
              const Box(height: 30),
              const Text("Text wrapped with FitHorizontally:"),
              const Box(height: 10),
              //
              Container(
                alignment: Alignment.centerLeft,
                color: Colors.yellow,
                width: double.infinity,
                height: 30,
                child: FitHorizontally(child: text()),
              ),
              Container(
                alignment: Alignment.centerLeft,
                color: Colors.yellow,
                width: 250,
                height: 30,
                child: FitHorizontally(child: text()),
              ),
              Container(
                alignment: Alignment.centerLeft,
                color: Colors.yellow,
                width: 150,
                height: 30,
                child: FitHorizontally(child: text()),
              ),
              const Box(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Container separator() => Container(width: 2, height: 50, color: Colors.black26);

  Text text() => const Text(
        "So long, farewell, auf Wiedersehen.",
        overflow: TextOverflow.fade,
        style: TextStyle(fontSize: 20, color: Colors.blue),
        maxLines: 1,
        softWrap: false,
      );
}
