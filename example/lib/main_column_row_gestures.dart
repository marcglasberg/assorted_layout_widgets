import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo()));

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('Gestures: ColumnSuper/RowSuper')),
      body: SizedBox.expand(
        child: Box(
          color: Colors.grey[300],
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: Pad(all: 24.0),
                  child: Center(
                    child: Text('This demonstrate that the GestureDetector '
                        'works as it should when applied to colum/row cells.'),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Text('normal'),
                        ColumnSuper(
                          innerDistance: -40.0,
                          outerDistance: 0.0,
                          children: [
                            box(Colors.red, 'red'),
                            box(Colors.green, 'green'),
                            box(Colors.blue, 'blue'),
                          ],
                        ),
                      ],
                    ),
                    //
                    const Box(width: 30),
                    //
                    Column(
                      children: [
                        const Text('inverted'),
                        ColumnSuper(
                          innerDistance: -40.0,
                          outerDistance: 0.0,
                          invert: true,
                          children: [
                            box(Colors.red, 'red'),
                            box(Colors.green, 'green'),
                            box(Colors.blue, 'blue'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                //
                const Box(height: 50),
                //
                Column(
                  children: [
                    Column(
                      children: [
                        const Text('normal'),
                        RowSuper(
                          innerDistance: -40.0,
                          outerDistance: 8.0,
                          children: [
                            box(Colors.red, 'red'),
                            box(Colors.green, 'green'),
                            box(Colors.blue, 'blue'),
                          ],
                        ),
                      ],
                    ),
                    //
                    const Box(height: 30),
                    //
                    Column(
                      children: [
                        const Text('inverted'),
                        RowSuper(
                          innerDistance: -40.0,
                          outerDistance: 8.0,
                          invert: true,
                          children: [
                            box(Colors.red, 'red'),
                            box(Colors.green, 'green'),
                            box(Colors.blue, 'blue'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget box(Color color, String name) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tapped ${name.toUpperCase()}',
              style: const TextStyle(fontSize: 24),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Box(width: 100, height: 100, color: color.withOpacity(0.95)),
    );
  }
}
