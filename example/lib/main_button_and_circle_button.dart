import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('Button and CircleButton Example')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Box(height: 20),
              _button(),
              Box(height: 20),
              _circleButton(),
              Box(height: 20),
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
          Text('Button',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          Box(height: 20),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Button(
                    builder: ({required bool isPressed}) {
                      return Box(
                        padding: Pad(all: 8.0),
                        color: isPressed ? Colors.blue : Colors.transparent,
                        child: Text(
                          'Click Me',
                          style: TextStyle(
                              fontSize: 23, color: isPressed ? Colors.black : Colors.white),
                        ),
                      );
                    },
                    minVisualTapDuration: Duration(milliseconds: 500),
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
                        padding: Pad(all: 8.0),
                        color: isPressed ? Colors.blue : Colors.transparent,
                        child: Text(
                          'Click Me',
                          style: TextStyle(
                              fontSize: 23, color: isPressed ? Colors.black : Colors.white),
                        ),
                      );
                    },
                    minVisualTapDuration: Duration(milliseconds: 500),
                    clickAreaMargin: const Pad(horizontal: 10.0, vertical: 45),
                    debugShowClickableArea: true,
                    onTap: () {},
                  ),
                ),
              ),
            ],
          ),
          Box(height: 20),
          Text(
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
          Text('CircleButton',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          Box(height: 20),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: CircleButton(
                    icon: Icon(Icons.shopping_cart, color: Colors.white),
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
                    icon: Icon(Icons.shopping_cart, color: Colors.white),
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
          Box(height: 20),
          Text(
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
