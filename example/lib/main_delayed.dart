import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() async => runApp(MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('Delayed Example')),
      key: UniqueKey(), // Forces restart on hot reload.
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (int i = 0; i <= 100; i++)
              _delayed(i == 0 ? null : Duration(milliseconds: i * 500)),
          ],
        ),
      ),
    );
  }

  Widget _delayed(Duration delay) {
    return Delayed(
      delay: delay,
      builder: (_, bool initialized) => AnimatedOpacity(
        opacity: initialized ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: _myWidget(delay?.inMilliseconds),
      ),
    );
  }

  Widget _myWidget(int delay) {
    return Box.rand(
      height: 50.0,
      child: Center(child: Text(delay.toString())),
    );
  }
}
