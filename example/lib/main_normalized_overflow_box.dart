import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  const Demo({super.key});

  static const text = Text("If you set your goals ridiculously high and it's a failure, "
      "you will fail above everyone else's success.");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NormalizedOverflowBox Example')),
      body: const Center(
        child: Box(
          width: 300,
          child: Column(
            children: [
              SizedBox(height: 10),
              Box(
                color: Colors.green,
                height: 105,
                width: 110,
                child: NormalizedOverflowBox(minWidth: 50, child: text),
              ),
              Box(height: 10),
              Box(
                color: Colors.blue,
                height: 105,
                width: 110,
                child: OverflowBox(minWidth: 100, child: text),
              ),
              Box(height: 10),
              Box(
                color: Colors.red,
                height: 105,
                width: 110,
                child: NormalizedOverflowBox(minWidth: 130, child: text),
              ),
              Box(height: 10),
              Box(
                color: Colors.purple,
                height: 105,
                width: 110,
                child: NormalizedOverflowBox(minWidth: 200, child: text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
