import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    //
    return Material(
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('showDialogSuper Example')),
          body: const DemoApp(),
        ),
      ),
    );
  }
}

class DemoApp extends StatefulWidget {
  const DemoApp({super.key});

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  int count = 1;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Center(child: Text("The dialog has opened $count times."))),
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialogSuper<int>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text("This dialog has opened $count times."
                              "\n\n"
                              "The counter is incremented in the `onDismissed` callback."),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, 1);
                              },
                              child: const Text("OK"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, 2);
                              },
                              child: const Text("CANCEL"),
                            )
                          ],
                        );
                      },
                      onDismissed: (int? result) {
                        if (result == 1) {
                          print("Pressed the OK button.");
                        } else if (result == 2) {
                          print("Pressed the CANCEL button.");
                        } else if (result == null) {
                          print("Dismissed with BACK or tapping the barrier.");
                        } else {
                          throw AssertionError();
                        }
                        setState(() {
                          count++;
                        });
                      });
                },
                child: const Text("Open Dialog"),
              ),
            ),
          ),
          const Expanded(child: Box()),
        ],
      ),
    );
  }
}
