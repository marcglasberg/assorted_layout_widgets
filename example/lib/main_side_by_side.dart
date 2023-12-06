import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('SideBySide Example')),
      body: SizedBox.expand(
        child: Padding(
          padding: const Pad(all: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //
              _titleWithDivider("First Chapter"),
              const Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
              //
              _titleWithDivider("Second Chapter"),
              const Text(
                  "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium."),
              //
              _titleWithDivider("Another chapter with long name"),
              const Text(
                  "Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur."),
              //
              _titleWithDivider("Another chapter with an extremely long chapter name"),
              const Text("Ut enim ad minima veniam, quis nostrum exercitationem ullam? "),
              //
            ],
          ),
        ),
      ),
    );
  }

  Widget _titleWithDivider(String text) {
    //
    var sideBySide = SideBySide(
      crossAxisAlignment: CrossAxisAlignment.start,
      startChild: Text(
        text,
        textWidthBasis: TextWidthBasis.longestLine,
        style: const TextStyle(fontSize: 22),
      ),
      endChild: const Divider(color: Colors.grey, height: 30),
      innerDistance: 8,
      minEndChildWidth: 20,
    );

    return Padding(
      padding: const Pad(top: 30, bottom: 10),
      child: sideBySide,
    );
  }

  /// Note: Using a [Row] doesn't work. Uncomment to try it:
  /// Widget _titleWithDivider(String text) {
  ///   //
  ///   var sideBySide = Row(
  ///     crossAxisAlignment: CrossAxisAlignment.start,
  ///     children: [
  ///       Text(
  ///         text,
  ///         textWidthBasis: TextWidthBasis.longestLine,
  ///         style: const TextStyle(fontSize: 22),
  ///       ),
  ///       const Expanded(child: Divider(color: Colors.grey, height: 30)),
  ///     ],
  ///   );
  ///
  ///   return Padding(
  ///     padding: const Pad(top: 30, bottom: 10),
  ///     child: sideBySide,
  ///   );
  /// }
}
