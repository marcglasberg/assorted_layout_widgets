import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  const Demo({ super.key });

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('Button and CircleButton Example')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const Box(height: 20),
              _button(),
              const Box(height: 20),
              _circleButton(),
              const Box(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Box _button() {
    return Box(
      padding: const EdgeInsets.all(16.0),
      color: Colors.indigo,
      child: Column(
        children: [
          const Text('Button',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const Box(height: 20),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Button(
                    builder: ({required bool isPressed}) {
                      return Box(
                        padding: const Pad(all: 8.0),
                        color: isPressed ? Colors.blue : Colors.transparent,
                        child: Text(
                          'Click Me',
                          style: TextStyle(
                              fontSize: 23, color: isPressed ? Colors.black : Colors.white),
                        ),
                      );
                    },
                    minVisualTapDuration: const Duration(milliseconds: 500),
                    clickAreaMargin: const Pad(horizontal: 10.0, vertical: 45),
                    onTap: () {},
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Button(
                    builder: ({required bool isPressed}) {
                      return Box(
                        padding: const Pad(all: 8.0),
                        color: isPressed ? Colors.blue : Colors.transparent,
                        child: Text(
                          'Click Me',
                          style: TextStyle(
                              fontSize: 23, color: isPressed ? Colors.black : Colors.white),
                        ),
                      );
                    },
                    minVisualTapDuration: const Duration(milliseconds: 500),
                    clickAreaMargin: const Pad(horizontal: 10.0, vertical: 45),
                    debugShowClickableArea: true,
                    onTap: () {},
                  ),
                ),
              ),
            ],
          ),
          const Box(height: 20),
          const Text(
            'Button(\n'
            '    builder: ({required bool isPressed}) => ...\n'
            '    minVisualTapDuration: Duration(milliseconds: 500),\n'
            '    clickAreaMargin: Pad(horizontal: 10.0, vertical: 45),\n'
            '    debugShowClickableArea: false / true',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Box _circleButton() {
    return Box(
      padding: const EdgeInsets.all(16.0),
      color: Colors.indigo,
      child: Column(
        children: [
          const Text('CircleButton',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const Box(height: 20),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: CircleButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    clickAreaMargin: const Pad(left: 30, right: 50, vertical: 20),
                    backgroundColor: Colors.white30,
                    tapColor: Colors.black,
                    border: Border.all(width: 1, color: Colors.black),
                    size: 56,
                    onTap: () {},
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: CircleButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    clickAreaMargin: const Pad(left: 50, right: 30, vertical: 20),
                    debugShowClickableArea: true,
                    backgroundColor: Colors.white30,
                    tapColor: Colors.black,
                    border: Border.all(width: 1, color: Colors.black),
                    size: 56,
                    onTap: () {},
                  ),
                ),
              ),
            ],
          ),
          const Box(height: 20),
          const Text(
            'CircleButton(\n'
            '    icon: Icon(Icons.shopping_cart, color: Colors.white),\n'
            '    backgroundColor: Colors.white30,\n'
            '    tapColor: Colors.black,\n'
            '    border: Border.all(width: 1, color: Colors.black),\n'
            '    size: 56,\n'
            '    onTap: () {},\n'
            '    clickAreaMargin: Pad(left: 50, right: 30, vertical: 20),\n'
            '    debugShowClickableArea: false / true',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
