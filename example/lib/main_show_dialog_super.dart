import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
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
  const DemoApp({Key? key}) : super(key: key);

  @override
  _DemoAppState createState() => _DemoAppState();
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
                  showDialogSuper<dynamic>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text("This dialog has opened $count times."
                              "\n\n"
                              "The counter is incremented in the `onDismissed` callback."),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, "aaa");
                              },
                              child: const Text("OK"),
                            )
                          ],
                        );
                      },
                      onDismissed: () {
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
