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
                _example(WrapType.fit, WrapFit.min),
                _example(WrapType.fit, WrapFit.proportional),
                _example(WrapType.fit, WrapFit.divided),
                _example(WrapType.fit, WrapFit.larger),
                _example(WrapType.balanced, WrapFit.min),
                _example(WrapType.balanced, WrapFit.proportional),
                _example(WrapType.balanced, WrapFit.divided),
                _example(WrapType.balanced, WrapFit.larger),
                const Box(height: 20),
              ],
            ),
          ),
        ),
      );

  Column _example(WrapType wrapType, WrapFit wrapFit) {
    return Column(
      children: [
        const Box(height: 22),
        Text('$wrapType | $wrapFit'),
        const Box(height: 5),
        Container(
          width: 300,
          color: Colors.grey[300],
          child: _bar(wrapType, wrapFit),
        ),
      ],
    );
  }

  ButtonBarSuper _bar(WrapType wrapType, WrapFit wrapFit) {
    return ButtonBarSuper(
      buttonTextTheme: ButtonTextTheme.primary,
      wrapType: wrapType,
      wrapFit: wrapFit,
      spacing: 2.0,
      lineSpacing: 10.0,
      buttonHeight: 48,
      buttonMinWidth: 40,
      children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.blue),
            onPressed: () {},
            child: const Text('I am a blue button like you')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Colors.blue),
          onPressed: () {},
          child: const Text('Hey'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Colors.blue),
          onPressed: () {},
          child: const Text('I am a blue button, ok?'),
        ),
      ],
    );
  }
}
