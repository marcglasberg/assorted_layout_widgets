import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NonUniformRoundedRectangleBorder Example',
          style: TextStyle(fontSize: 15),
        ),
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
      button('show all sides'),
      //
      button('hideRightSide', hideRightSide: true),
      button('hideBottomSide', hideBottomSide: true),
      button('hideLeftSide', hideLeftSide: true),
      button('hideTopSide', hideTopSide: true),
      //
      button('hideTopSide & hideRightSide', hideTopSide: true, hideRightSide: true),
      button('hideTopSide & hideBottomSide', hideTopSide: true, hideBottomSide: true),
      button('hideTopSide & hideLeftSide', hideTopSide: true, hideLeftSide: true),
      //
      button('hideRightSide & hideBottomSide', hideRightSide: true, hideBottomSide: true),
      button('hideRightSide & hideLeftSide', hideRightSide: true, hideLeftSide: true),
      //
      button('hideBottomSide & hideLeftSide', hideBottomSide: true, hideLeftSide: true),
      //
      button('show top only', hideRightSide: true, hideBottomSide: true, hideLeftSide: true),
      button('show right only', hideTopSide: true, hideBottomSide: true, hideLeftSide: true),
      button('show bottom only', hideTopSide: true, hideRightSide: true, hideLeftSide: true),
      button('show left only', hideTopSide: true, hideRightSide: true, hideBottomSide: true),
    ];
  }

  Widget button(
    String label, {
    bool hideTopSide = false,
    bool hideBottomSide = false,
    bool hideRightSide = false,
    bool hideLeftSide = false,
  }) =>
      Padding(
        padding: const Pad(bottom: 20.0),
        child: Box(
          height: 70,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shadowColor: Colors.transparent,
              backgroundColor: Colors.lightGreen,
              foregroundColor: Colors.white,
              textStyle: TextStyle(fontSize: 18),
              shape: shape(hideTopSide, hideBottomSide, hideRightSide, hideLeftSide),
            ),
            onPressed: () {},
            child: Text(label),
          ),
        ),
      );

  NonUniformRoundedRectangleBorder shape(
    bool hideTopSide,
    bool hideBottomSide,
    bool hideRightSide,
    bool hideLeftSide,
  ) {
    return NonUniformRoundedRectangleBorder(
      side: BorderSide(color: Colors.black87, width: 15.0),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      hideTopSide: hideTopSide,
      hideBottomSide: hideBottomSide,
      hideRightSide: hideRightSide,
      hideLeftSide: hideLeftSide,
    );
  }
}
