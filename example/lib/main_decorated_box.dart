import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo()));

/// Here we test the Box widget with decoration.
/// If Box.color is defined, then the decoration cannot be defined, or it can
/// be defined without a color (works for BoxDecoration and ShapeDecoration only).
class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('Box with Decoration Example')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              example1(),
              const Box.gap(24),
              example2(),
              const Box.gap(24),
              example3(),
              const Box.gap(24),
              example4(),
              const Box.gap(24),
              example5(),
            ],
          ),
        ),
      ),
    );
  }

  /// Color is separate, and Box decoration without color.
  Widget example1() => const Box(
        width: 100,
        height: 100,
        child: Text("Test 1"),
        color: Colors.purple,
        // Separate color.
        decoration: BoxDecoration(
          border: Border.symmetric(
            vertical: BorderSide(color: Colors.red, width: 6),
            horizontal: BorderSide(color: Colors.green, width: 16),
          ),
        ),
      );

  /// Box decoration with color.
  Widget example2() => const Box(
        width: 100,
        height: 100,
        child: Text("Test 2"),
        decoration: BoxDecoration(
          color: Colors.yellow, // Color in decoration.
          border: Border.symmetric(
            vertical: BorderSide(color: Colors.red, width: 6),
            horizontal: BorderSide(color: Colors.green, width: 16),
          ),
        ),
      );

  /// Bor.r etc overrides the color.
  Widget example3() => const Box.r(
        width: 100,
        height: 100,
        child: Text("Test 3"),
        color: Colors.black,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.symmetric(
            vertical: BorderSide(color: Colors.red, width: 6),
            horizontal: BorderSide(color: Colors.green, width: 16),
          ),
        ),
      );

  /// Bor.r etc overrides the color in the decoration.
  Widget example4() => const Box.r(
        width: 100,
        height: 100,
        child: Text("Test 4"),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.symmetric(
            vertical: BorderSide(color: Colors.red, width: 6),
            horizontal: BorderSide(color: Colors.green, width: 16),
          ),
        ),
      );

  /// Bor.rand etc overrides the color in the decoration.
  Widget example5() => const Box.rand(
        width: 100,
        height: 100,
        child: Text("Test 5"),
        color: Colors.black,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.symmetric(
            vertical: BorderSide(color: Colors.red, width: 6),
            horizontal: BorderSide(color: Colors.green, width: 16),
          ),
        ),
      );
}
