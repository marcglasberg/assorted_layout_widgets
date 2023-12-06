import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  const Demo({ super.key });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('CaptureGestures Example')),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const Box(height: 30),
            _greenArea(),
            const Box(height: 30),
            _yellowArea(),
            const Box(height: 2000),
            //
          ],
        ),
      );

  Material _greenArea() {
    return Material(
      color: Colors.green[200],
      child: InkWell(
        highlightColor: Colors.green,
        splashColor: Colors.green,
        onTap: () {
          print('Green area tapped.');
        },
        child: CaptureGestures.only(
          child: Padding(
            padding: const Pad(vertical: 30, horizontal: 50),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Button'),
                ),
                const Box(height: 20),
                const Text('CaptureGestures.only()\n\n'
                    'This green area can be used to scroll.\n'
                    'The Button (child) feels taps.\n'
                    'The green area (parent) feels taps.'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Material _yellowArea() {
    return Material(
      color: Colors.yellow,
      child: InkWell(
        highlightColor: Colors.yellow[800],
        splashColor: Colors.yellow[800],
        onTap: () {
          print('Yellow area tapped.');
        },
        child: CaptureGestures.scroll(
          child: Padding(
            padding: const Pad(vertical: 30, horizontal: 50),
            child: Column(
              children: [
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Button'),
                  ),
                ),
                const Box(height: 20),
                const Text('CaptureGestures.scroll()\n\n'
                    'This yellow area CANNOT be used to scroll.\n'
                    'The Button (child) feels taps.\n'
                    'The yellow area (parent) feels taps.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
