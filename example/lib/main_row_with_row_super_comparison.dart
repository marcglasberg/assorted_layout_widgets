import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() async => runApp(MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('Row × RowSuper Comparison')),
      body: Box(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //
              // ------------------
              //
              explanation("Row where cells are SMALLER that the available width:"),
              Row(children: [
                text("How"),
                text("are you all,"),
                text("my dearest friends?"),
              ]),
              //
              //
              explanation(
                  "RowSuper with `fill:false` (the default) where cells are SMALLER that the available width. "
                  "Similar to a Row:"),
              RowSuper(fill: false, children: [
                text("How"),
                text("are you all,"),
                text("my dearest friends?"),
              ]),
              //
              // ------------------
              //
              divider(),
              //
              explanation("Row where cells are SMALLER that the available width, but use Expanded. "
                  "It fills the whole space, but cells have the same size:"),
              Row(children: [
                Expanded(child: text("How")),
                Expanded(child: text("are you,")),
                Expanded(child: text("my dear friend?")),
              ]),
              //
              //
              explanation(
                  "RowSuper with `fill:true` where cells are SMALLER that the available width. "
                  "It fills the whole space, and cells are proportional to their content width:"),
              RowSuper(fill: true, children: [
                text("How"),
                text("are you all,"),
                text("my dearest friends?"),
              ]),
              //
              // ------------------
              //
              divider(),
              //
              explanation("Row where cells are LARGER that the available width. "
                  "It will overflow (and show the overflow warning):"),
              Row(children: [
                text("this is a very long text"),
                text("that surely won't fit the available space in a regular cell phone's screen."),
              ]),
              //
              explanation("RowSuper where cells are LARGER that the available width "
                  "(it doesn't matter if `fill:false` or `true`). "
                  "It fills the whole space, and cells are proportional to their content width:"),
              RowSuper(fill: false, children: [
                text("this is a long text"),
                text("that surely won't fit the available space in a regular cell phone's screen."),
              ]),
              //
              // ------------------
              //
              divider(),
            ],
          ),
        ),
      ),
    );
  }

  Column divider() => Column(
        children: [
          SizedBox(height: 40),
          Container(color: Colors.black, height: 1, width: double.infinity),
          SizedBox(height: 10),
        ],
      );

  Widget explanation(String text) => Padding(
        padding: const EdgeInsets.only(top: 30, left: 8.0, right: 15.0, bottom: 10),
        child: Text(text),
      );

  List<Widget> texts() => [
        text("How"),
        text("are you all,"),
        text("my dearest friends?"),
      ];

  Widget text(String text) => Box.rand(
        top: 4.0,
        bottom: 4.0,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );
}
