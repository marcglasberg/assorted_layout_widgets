import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(
        title: const Text('NonUniformOutlineInputBorder Example', style: TextStyle(fontSize: 18)),
      ),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          child: Padding(
            padding: const Pad(all: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _children(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _children() {
    return [
      textfield('show all sides'),
      //
      textfield('hideRightSide', hideRightSide: true),
      textfield('hideBottomSide', hideBottomSide: true),
      textfield('hideLeftSide', hideLeftSide: true),
      textfield('hideTopSide', hideTopSide: true),
      //
      textfield('hideTopSide & hideRightSide', hideTopSide: true, hideRightSide: true),
      textfield('hideTopSide & hideBottomSide', hideTopSide: true, hideBottomSide: true),
      textfield('hideTopSide & hideLeftSide', hideTopSide: true, hideLeftSide: true),
      //
      textfield('hideRightSide & hideBottomSide', hideRightSide: true, hideBottomSide: true),
      textfield('hideRightSide & hideLeftSide', hideRightSide: true, hideLeftSide: true),
      //
      textfield('hideBottomSide & hideLeftSide', hideBottomSide: true, hideLeftSide: true),
      //
      textfield('show top only', hideRightSide: true, hideBottomSide: true, hideLeftSide: true),
      textfield('show right only', hideTopSide: true, hideBottomSide: true, hideLeftSide: true),
      textfield('show bottom only', hideTopSide: true, hideRightSide: true, hideLeftSide: true),
      textfield('show left only', hideTopSide: true, hideRightSide: true, hideBottomSide: true),
    ];
  }

  Widget textfield(
    String label, {
    bool hideTopSide = false,
    bool hideBottomSide = false,
    bool hideRightSide = false,
    bool hideLeftSide = false,
  }) =>
      Padding(
        padding: const Pad(bottom: 20.0),
        child: Box.g(
          child: TextField(
            style: TextStyle(fontSize: 16),
            controller: TextEditingController(text: label),
            decoration: InputDecoration(
              contentPadding: Pad(horizontal: 30, vertical: 40),
              fillColor: Colors.yellow,
              filled: true,
              enabledBorder: NonUniformOutlineInputBorder(
                  hideTopSide: hideTopSide,
                  hideBottomSide: hideBottomSide,
                  hideRightSide: hideRightSide,
                  hideLeftSide: hideLeftSide,
                  borderSide: BorderSide(width: 10),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(38),
                    topRight: Radius.circular(38),
                    bottomLeft: Radius.circular(38),
                    bottomRight: Radius.circular(38),
                  )),
            ),
          ),
        ),
      );
}
