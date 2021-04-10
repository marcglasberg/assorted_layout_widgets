import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('ButtonBarSuper Example')),
        body: Container(
          color: Colors.grey,
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Box(height: 20),
                const Text('WrapType.min'),
                const Box(height: 6),
                Container(
                  width: 300,
                  color: Colors.grey[300],
                  child: _bar(WrapFit.min),
                ),
                const Box(height: 20),
                const Text('WrapType.proportional'),
                const Box(height: 6),
                Container(
                  width: 300,
                  color: Colors.grey[300],
                  child: _bar(WrapFit.proportional),
                ) ,
                const Box(height: 20),
                const Text('WrapType.divided'),
                const Box(height: 6),
                Container(
                  width: 300,
                  color: Colors.grey[300],
                  child: _bar(WrapFit.divided),
                ) ,
                const Box(height: 20),
                const Text('WrapType.larger'),
                const Box(height: 6),
                Container(
                  width: 300,
                  color: Colors.grey[300],
                  child: _bar(WrapFit.larger),
                )
              ],
            ),
          ),
        ),
      );

  ButtonBarSuper _bar(WrapFit wrapFit) {
    return ButtonBarSuper(
            buttonTextTheme: ButtonTextTheme.primary,
            wrapType: WrapType.balanced,
            wrapFit: wrapFit,
            spacing: 5.0,
            lineSpacing: 10.0,
            buttonHeight: 48,
            buttonMinWidth: 40,
            children: [
              RaisedButton(
                  color: Colors.blue,
                  onPressed: () {},
                  child: const Text('I am a blue button like you')),
              RaisedButton(
                  color: Colors.blue,
                  onPressed: () {},
                  child: const Text('Hey')),
              RaisedButton(
                  color: Colors.blue,
                  onPressed: () {},
                  child: const Text('I am a blue button')),
            ],
          );
  }
}
