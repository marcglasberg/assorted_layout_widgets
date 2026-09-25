import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Demonstrates [Keyboard.reserveKeyboardSpaceOnDesktop]. Run it on desktop (Windows,
/// macOS or Linux): tapping a
/// text field opens a black "space for the keyboard" area at the bottom, as the mobile
/// keyboard would. [Keyboard.isOpen] and [KeyboardSwitch] detect it, and the physical
/// keyboard keeps working.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (BuildContext context, Widget? child) =>
          Keyboard(reserveKeyboardSpaceOnDesktop: true, child: child!),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  static bool get _isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keyboard space on desktop')),
      body: _isDesktop ? _content(context) : _notDesktopError(),
    );
  }

  Widget _notDesktopError() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Error: this example only works on desktop (Windows, macOS or Linux).\n\n'
          'The reserveKeyboardSpaceOnDesktop parameter of Keyboard '
          'has no effect on other platforms.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontSize: 18),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Tap a text field to open the keyboard space. '
                'Tap outside or press the button to close it. '
                'You can still type with your physical keyboard.',
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'First field',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Second field',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              // TextFieldTapRegion: clicking the buttons doesn't count as a "tap
              // outside" the text field, which on desktop would remove its focus.
              // ExcludeFocus: the buttons themselves never take focus (not even
              // with Tab).
              TextFieldTapRegion(
                child: ExcludeFocus(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton(
                        onPressed: () => Keyboard.close(),
                        child: const Text('Keyboard.close()'),
                      ),
                      ElevatedButton(
                        onPressed: () => Keyboard.close(removeFocus: false),
                        child: const Text('Keyboard.close(removeFocus: false)'),
                      ),
                      ElevatedButton(
                        onPressed: () => Keyboard.open(),
                        child: const Text('Keyboard.open()'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Pinned at the bottom, so it's visible right above the keyboard space.
        KeyboardSwitch.builder(
          (context, isOpen) => Container(
            color: isOpen ? Colors.green : Colors.grey.shade300,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(isOpen ? Icons.keyboard : Icons.keyboard_hide),
                const SizedBox(width: 12),
                Text('Keyboard.isOpen: $isOpen', style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
