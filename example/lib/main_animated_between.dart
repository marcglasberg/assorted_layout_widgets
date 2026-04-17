import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo(), debugShowCheckedModeBanner: false));

const String _loremIpsum =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
    'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
    'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris '
    'nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in '
    'reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla '
    'pariatur. Excepteur sint occaecat cupidatat non proident, sunt in '
    'culpa qui officia deserunt mollit anim id est laborum.';

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  bool _showLong = true;
  AnimatedBetweenMode _modeShorter = AnimatedBetweenMode.resize;
  AnimatedBetweenMode _modeLarger = AnimatedBetweenMode.fit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text('AnimatedBetween Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              const Spacer(),
              // --- AnimatedBetween transitions between the two children ---
              AnimatedBetween(
                fadeDuration: const Duration(milliseconds: 250),
                modeShorterChild: _modeShorter,
                modeLargerChild: _modeLarger,
                child: _showLong
                    ? _LongBlueBox(key: const ValueKey('long'))
                    : _ShortRedBox(key: const ValueKey('short')),
                printDebug: true,
              ),
              //
              const SizedBox(height: 32),
              const Spacer(),
              FilledButton.icon(
                icon: const Icon(Icons.swap_horiz),
                label: Text(_showLong ? 'Switch to short' : 'Switch to long'),
                onPressed: () => setState(() => _showLong = !_showLong),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tap the button to switch. Notice how the box smoothly resizes '
                'in both width and height while the content cross-fades.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const Divider(),
              const Text(
                'Mode:\n'
                '• resize: child is re-laid-out at the box size (text rewraps).\n'
                '• overflow: child stays at natural size; box clips it.\n'
                '• fit: child is scaled to match the box.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              const Text(
                'Shorter child mode:',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              SegmentedButton<AnimatedBetweenMode>(
                segments: const [
                  ButtonSegment(value: AnimatedBetweenMode.resize, label: Text('resize')),
                  ButtonSegment(
                    value: AnimatedBetweenMode.overflow,
                    label: Text('overflow'),
                  ),
                  ButtonSegment(value: AnimatedBetweenMode.fit, label: Text('fit')),
                ],
                selected: {_modeShorter},
                onSelectionChanged: (s) => setState(() => _modeShorter = s.first),
              ),
              const SizedBox(height: 8),
              const Text(
                'Larger child mode:',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              SegmentedButton<AnimatedBetweenMode>(
                segments: const [
                  ButtonSegment(value: AnimatedBetweenMode.resize, label: Text('resize')),
                  ButtonSegment(
                    value: AnimatedBetweenMode.overflow,
                    label: Text('overflow'),
                  ),
                  ButtonSegment(value: AnimatedBetweenMode.fit, label: Text('fit')),
                ],
                selected: {_modeLarger},
                onSelectionChanged: (s) => setState(() => _modeLarger = s.first),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LongBlueBox extends StatelessWidget {
  _LongBlueBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        _loremIpsum,
        style: TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
      ),
    );
  }
}

class _ShortRedBox extends StatelessWidget {
  _ShortRedBox({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          textWidthBasis: TextWidthBasis.longestLine,
          'Short line.',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
