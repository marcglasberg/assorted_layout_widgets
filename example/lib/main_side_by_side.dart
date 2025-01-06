import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(
        title: const Text('SideBySide Example'),
        backgroundColor: Colors.blue,
      ),
      body: SizedBox.expand(
        child: Padding(
          padding: const Pad(all: 10.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _exampleTitleAndDivider(),
                _sideBySideWith2Children(),
                _sideBySideWith3Children(),
                //
                // Uncomment to see the deprecated examples:
                // _deprecated(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _titleWithDivider(String text) {
    return SideBySide(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          textWidthBasis: TextWidthBasis.longestLine,
          style: const TextStyle(fontSize: 22),
        ),
        const Divider(color: Colors.grey, height: 30),
      ],
      gaps: [8],
      minEndChildWidth: 20,
    );
  }

  Widget _exampleTitleAndDivider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titleWithDivider("First Chapter"),
        const Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
        const Box(height: 24),
        //
        _titleWithDivider("Second Chapter"),
        const Text(
            "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium."),
        const Box(height: 24),
        //
        _titleWithDivider("Another chapter with long name"),
        const Text(
            "Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur."),
        const Box(height: 24),
        //
        _titleWithDivider("Another chapter with an extremely long chapter name"),
        const Text("Ut enim ad minima veniam, quis nostrum exercitationem ullam? "),
        //
        const Divider(height: 48),
      ],
    );
  }

  Widget _deprecated() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Deprecated"),
        const Text("SideBySide(minEndChildWidth: 0, innerDistance: 20)"),
        for (double width = 380; width >= 0; width -= 40)
          _deprecatedStartChildAndEndChild(
              width: width, minEndChildWidth: 0, innerDistance: 20),
        //
        const Box(height: 16),
        const Text("Deprecated"),
        const Text("SideBySide(minEndChildWidth: 130, innerDistance: 20)"),
        for (double width = 380; width >= 0; width -= 40)
          _deprecatedStartChildAndEndChild(
              width: width, minEndChildWidth: 130, innerDistance: 20),
        //
        const Box(height: 16),
        const Text("Deprecated"),
        const Text("SideBySide(minEndChildWidth: 50, innerDistance: 20)"),
        for (double width = 380; width >= 0; width -= 40)
          _deprecatedStartChildAndEndChild(
              width: width, minEndChildWidth: 50, innerDistance: 20),
        //
        const Divider(height: 48),
      ],
    );
  }

  Widget _sideBySideWith2Children() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("SideBySide with 2 children", style: TextStyle(fontSize: 18)),
        const Box(height: 16),
        //
        const Text("SideBySide.list(minEndChildWidth: 0, innerDistance: 20)"),
        for (double width = 380; width >= 0; width -= 40)
          _sideBySide(
            texts: ["Hello there, how are you doing?", "I'm good, thank you!"],
            width: width,
            minEndChildWidth: 0,
          ),
        //
        const Box(height: 16),
        const Text("SideBySide.list(minEndChildWidth: 130, innerDistance: 20)"),
        for (double width = 380; width >= 0; width -= 40)
          _sideBySide(
            texts: ["Hello there, how are you doing?", "I'm good, thank you!"],
            width: width,
            minEndChildWidth: 130,
          ),
        //
        const Box(height: 16),
        const Text("SideBySide.list(minEndChildWidth: 50, innerDistance: 20)"),
        for (double width = 380; width >= 0; width -= 40)
          _sideBySide(
            texts: ["Hello there, how are you doing?", "I'm good, thank you!"],
            width: width,
            minEndChildWidth: 50,
          ),
        //
        const Divider(height: 48),
      ],
    );
  }

  Widget _sideBySideWith3Children() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("SideBySide with 3 children", style: TextStyle(fontSize: 18)),
        const Box(height: 16),
        //
        const Text("SideBySide.list(minEndChildWidth: 0, innerDistance: 20)"),
        for (double width = 380; width >= 0; width -= 40)
          _sideBySide(
            texts: ["Hello there", "How are you doing?", "I'm good, thank you!"],
            width: width,
            minEndChildWidth: 0,
          ),
        //
        const Box(height: 16),
        const Text("SideBySide.list(minEndChildWidth: 130, innerDistance: 20)"),
        for (double width = 380; width >= 0; width -= 40)
          _sideBySide(
            texts: ["Hello there", "How are you doing?", "I'm good, thank you!"],
            width: width,
            minEndChildWidth: 130,
          ),
        //
        const Box(height: 16),
        const Text("SideBySide.list(minEndChildWidth: 50, innerDistance: 20)"),
        for (double width = 380; width >= 0; width -= 40)
          _sideBySide(
            texts: ["Hello there", "How are you doing?", "I'm good, thank you!"],
            width: width,
            minEndChildWidth: 50,
          ),
        //
        const Divider(height: 48),
      ],
    );
  }

  Widget _sideBySide({
    required List<String> texts,
    required double width,
    required double minEndChildWidth,
  }) {
    List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return Container(
      color: Colors.grey[300],
      width: width,
      margin: const Pad(top: 4),
      child: Row(
        children: [
          Expanded(
            child: SideBySide(
              minEndChildWidth: minEndChildWidth,
              gaps: [10, 30],
              children: [
                for (int i = 0; i < texts.length; i++)
                  Text(
                    texts[i],
                    overflow: TextOverflow.ellipsis,
                    textWidthBasis: TextWidthBasis.longestLine,
                    style: TextStyle(color: colors[i]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// This is deprecated.
  Widget _deprecatedStartChildAndEndChild({
    required double width,
    required double minEndChildWidth,
    required double innerDistance,
  }) {
    return Container(
      color: Colors.grey[300],
      width: width,
      margin: const Pad(top: 4),
      child: Row(
        children: [
          Expanded(
            child: SideBySide(
              minEndChildWidth: minEndChildWidth,
              startChild: const Text(
                "Hello there, how are you doing?",
                overflow: TextOverflow.ellipsis,
                textWidthBasis: TextWidthBasis.longestLine,
                style: TextStyle(color: Colors.red),
              ),
              endChild: const Text(
                "I'm good, thank you!",
                overflow: TextOverflow.ellipsis,
                textWidthBasis: TextWidthBasis.longestLine,
                style: TextStyle(color: Colors.blue),
              ),
              innerDistance: 20,
            ),
          ),
        ],
      ),
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
