import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(
    const MaterialApp(home: Demo()),
  );
}

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  bool rtl = false;
  bool reverse = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ScrollShadow Example')),
      body: Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: Padding(
          padding: const Pad(all: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //
              Row(
                children: [
                  _switch('RTL', rtl, (value) => setState(() => rtl = value)),
                  const Box.gap(20),
                  _switch('Reverse', reverse, (value) => setState(() => reverse = value)),
                ],
              ),
              const Box.gap(20),
              //
              const Text('Vertical: top and bottom shadows'),
              const Box.gap(8),
              Expanded(
                child: ScrollShadow(
                  child: ListView.builder(
                    reverse: reverse,
                    itemCount: 30,
                    itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
                  ),
                ),
              ),
              const Box.gap(20),
              //
              const Text('Horizontal: left and right shadows'),
              const Box.gap(8),
              SizedBox(
                height: 100,
                child: ScrollShadow(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    reverse: reverse,
                    itemCount: 30,
                    itemBuilder: (context, index) => Container(
                      width: 80,
                      margin: const Pad(all: 4),
                      alignment: Alignment.center,
                      color: Colors.amber[100 * (index % 8 + 1)],
                      child: Text('$index'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _switch(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
