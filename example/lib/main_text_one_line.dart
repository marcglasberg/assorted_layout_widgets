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
            //
            // -------------------
            //
            SizedBox(height: 10),
            Text("Text with ELLIPSIS, maxLines: 1, softWrap: false",
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("short: Lorem ipsum",
                maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis),
            SizedBox(height: 5),
            Text(
                "long: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis),
            SizedBox(height: 5),
            Text(
                "long without spaces: This is a verylongtextwithoutanyspacesthatdemonstratestheproblemwegetwhentryingtousethenativetextwidget.",
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis),
            SizedBox(height: 40),
            //
            // -------------------
            //
            TextOneLine("TextOneLine with ELLIPSIS", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            TextOneLine("short: Lorem ipsum"),
            SizedBox(height: 5),
            TextOneLine(
                "long: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."),
            SizedBox(height: 5),
            TextOneLine(
                "long without spaces: This is a verylongtextwithoutanyspacesthatdemonstratestheproblemwegetwhentryingtousethenativetextwidget.",
                overflow: TextOverflow.ellipsis),
            SizedBox(height: 40),
            //
            // -------------------
            //
            TextOneLine("TextOneLine with FADE",
                overflow: TextOverflow.fade, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            TextOneLine("short: Lorem ipsum", overflow: TextOverflow.fade),
            SizedBox(height: 5),
            TextOneLine(
              "long: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
              overflow: TextOverflow.fade,
            ),
            SizedBox(height: 5),
            TextOneLine(
                "long without spaces: This is a verylongtextwithoutanyspacesthatdemonstratestheproblemwegetwhentryingtousethenativetextwidget.",
                overflow: TextOverflow.fade),
            SizedBox(height: 40),
            //
            // -------------------
            //
            TextOneLine("TextOneLine with CLIP",
                overflow: TextOverflow.clip, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            TextOneLine("short: Lorem ipsum", overflow: TextOverflow.clip),
            SizedBox(height: 5),
            TextOneLine(
              "long: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
              overflow: TextOverflow.clip,
            ),
            SizedBox(height: 5),
            TextOneLine(
                "long without spaces: This is a verylongtextwithoutanyspacesthatdemonstratestheproblemwegetwhentryingtousethenativetextwidget.",
                overflow: TextOverflow.clip),
            //
            // -------------------
            //
          ],
        ),
      ),
    );
  }
}
