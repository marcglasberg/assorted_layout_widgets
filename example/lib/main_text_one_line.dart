import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('TextOneLine Example')),
      key: UniqueKey(), // Forces restart on hot reload.
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            IntrinsicHeight(child: TextOneLine("ELLIPSIS", style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(height: 10),
            IntrinsicWidth(child: TextOneLine("short: Lorem ipsum")),
            SizedBox(height: 10),
            IntrinsicWidth(child: IntrinsicHeight(child: TextOneLine("medium: Lorem ipsum dolor sit amet, consectetur adipiscing elit"))),
            SizedBox(height: 10),
            TextOneLine(
                "long: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."),
            SizedBox(height: 20),
            //
            TextOneLine("FADE", overflow: TextOverflow.fade, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextOneLine("short: Lorem ipsum", overflow: TextOverflow.fade),
            SizedBox(height: 10),
            TextOneLine("medium: Lorem ipsum dolor sit amet, consectetur adipiscing elit", overflow: TextOverflow.fade),
            SizedBox(height: 10),
            TextOneLine(
              "long: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
              overflow: TextOverflow.fade,
            ),
            SizedBox(height: 20),
            //
            TextOneLine("CLIP", overflow: TextOverflow.clip, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextOneLine("short: Lorem ipsum", overflow: TextOverflow.clip),
            SizedBox(height: 10),
            TextOneLine("medium: Lorem ipsum dolor sit amet, consectetur adipiscing elit", overflow: TextOverflow.clip),
            SizedBox(height: 10),
            TextOneLine(
              "long: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
              overflow: TextOverflow.clip,
            ),
          ],
        ),
      ),
    );
  }
}
