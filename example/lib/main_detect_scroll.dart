// ignore_for_file: deprecated_member_use
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const HomePage(),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scrollbarTheme: _scrollbarTheme()),
      home: const Demo(),
    );
  }

  /// This theme makes the scrollbar always visible, with a thickness of 20 px.
  ScrollbarThemeData _scrollbarTheme() {
    return ScrollbarThemeData(
      thumbVisibility: MaterialStateProperty.all(true),
      trackVisibility: MaterialStateProperty.all(true),
      thickness: MaterialStateProperty.all(20.0),
      interactive: true,
      radius: const Radius.circular(8),
      minThumbLength: 32,
      trackColor: MaterialStateProperty.all(Colors.blue[100]),
      thumbColor: MaterialStateProperty.all(Colors.blue[900]),
      crossAxisMargin: 0,
      mainAxisMargin: 0,
    );
  }
}

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  int lines = 10;

  bool canScroll = false;
  double scrollbarWidth = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DetectScroll Example')),
      body: Column(
        children: [
          //
          Expanded(
            child: DetectScroll(
              onChange: _onChange,
              child: LinesOfText(lines: lines),
            ),
          ),
          //
          const Box.gap(20),
          Text('onChange gets: canScroll=$canScroll, scrollbarWidth=$scrollbarWidth'),
          const Box.gap(20),
          Padding(
            padding: const Pad(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        lines += 10;
                      });
                    },
                    child: const Text('Add lines'),
                  ),
                ),
                const Box.gap(20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        lines -= 10;
                        if (lines < 0) lines = 0;
                      });
                    },
                    child: const Text('Remove lines'),
                  ),
                ),
              ],
            ),
          ),
          const Box.gap(40),
        ],
      ),
    );
  }

  /// This callback is called whenever the scroll state changes.
  void _onChange({
    required bool canScroll,
    required double scrollbarWidth,
  }) {
    setState(() {
      this.canScroll = canScroll;
      this.scrollbarWidth = scrollbarWidth;
    });
  }
}

class LinesOfText extends StatelessWidget {
  final int lines;

  const LinesOfText({
    super.key,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Box(
      color: Colors.blue[200],
      width: double.infinity,
      child: Stack(
        children: [
          Scrollbar(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const Pad(horizontal: 12, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: List.generate(
                    lines,
                    (index) => SizedBox(
                      width: double.infinity,
                      child: Text('$lines lines of text'),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: DetectScroll.of(context).canScroll
                ? DetectScroll.of(context).scrollbarWidth
                : 0,
            child: IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                bool canScroll = DetectScroll.of(context).canScroll;
                double scrollbarWidth = DetectScroll.of(context).scrollbarWidth;

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Text(
                        'DetectScroll.of(context).canScroll = $canScroll'
                        '\n\n'
                        'DetectScroll.of(context).scrollbarWidth = $scrollbarWidth'
                        '\n\n'
                        'Note the help button will move '
                        'when the scrollbar is shown and removed.',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
