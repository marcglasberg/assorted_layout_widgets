// ignore_for_file: deprecated_member_use
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:material_ui/material_ui.dart';

void main() => runApp(const MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('FitHorizontally Baseline Example')),
      body: Box(
        // color: Colors.red[800],
        child: Center(
          child: Column(
            children: [
              const Box(height: 40),
              const Text("Row with CrossAxisAlignment.center:"),
              const Box(height: 20),
              _row(false),
              const Box(height: 70),
              const Text("Row with CrossAxisAlignment.baseline:"),
              const Box(height: 20),
              _row(true),
            ],
          ),
        ),
      ),
    );
  }

  Row _row(bool baseline) {
    return Row(
      crossAxisAlignment: baseline
          ? CrossAxisAlignment.baseline
          : CrossAxisAlignment.center,
      textBaseline: TextBaseline.alphabetic,
      children: const [
        //
        SizedBox(height: 10),
        Box.g(child: Text("Hello", style: TextStyle(fontSize: 28), maxLines: 1)),
        Box.y(
          width: 45,
          child: FitHorizontally(
            alignment: Alignment.centerLeft,
            child: Text("Hello", style: TextStyle(fontSize: 28), maxLines: 1),
          ),
        ),
        Box.g(child: Text("Hello", style: TextStyle(fontSize: 60), maxLines: 1)),
        Box.y(
          width: 56,
          child: FitHorizontally(
            alignment: Alignment.centerLeft,
            child: Text("Hello", style: TextStyle(fontSize: 60), maxLines: 1),
          ),
        ),
      ],
    );
  }
}
