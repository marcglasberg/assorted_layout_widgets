import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() async => runApp(MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('RowSpacer Example')),
      body: Column(
        children: <Widget>[
          //
          SizedBox(height: 10),
          //
          Container(
            color: Colors.yellow,
            child: RowSuper(
              children: [
                text1(),
                text2(),
              ],
            ),
          ),
          //
          SizedBox(height: 10),
          //
          Container(
            color: Colors.yellow,
            child: RowSuper(
              children: [
                text1(),
                text2(),
                RowSpacer(),
              ],
            ),
          ),
          //
          SizedBox(height: 10),
          //
          Container(
            color: Colors.yellow,
            child: RowSuper(
              mainAxisSize: MainAxisSize.max,
              children: [
                text1(),
                text2(),
              ],
            ),
          ),
          //
          SizedBox(height: 10),
          //
          Container(
            width: 165.0,
            color: Colors.yellow,
            child: RowSuper(
              children: [
                RowSpacer(),
                text1(),
                RowSpacer(),
                text2(),
                RowSpacer(),
              ],
            ),
          ),
          //
          SizedBox(height: 10),
          //
          Container(
            width: 165.0,
            color: Colors.yellow,
            child: RowSuper(
              fitHorizontally: true,
              children: [
                RowSpacer(),
                text1(),
                RowSpacer(),
                text2(),
                RowSpacer(),
              ],
            ),
          ),
          //
          SizedBox(height: 10),
          Container(width: double.infinity, height: 2.0, color: Colors.black),
          SizedBox(height: 10),
          //
          // ------------
          //
          Container(
            color: Colors.yellow,
            child: RowSuper(
              alignment: Alignment.bottomRight,
              innerDistance: 5.0,
              children: <Widget>[
                Container(
                  color: Colors.orange,
                  child: RowSuper(
                    alignment: Alignment.topRight,
                    children: [
                      text1(),
                      text2(),
                    ],
                  ),
                ),
                RowSpacer(),
                box1(),
                box2(),
              ],
            ),
          ),
          //
        ],
      ),
    );
  }

  Container text1() => Container(
        child: Text("Hello!",
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(fontSize: 27.0)),
        color: Colors.red,
      );

  Container text2() => Container(
        child: Text("How are you doing?",
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(fontSize: 20.0)),
        color: Colors.blue,
      );

  Container box1() => Container(width: 30, height: 40, color: Colors.green);

  Container box2() => Container(width: 30, height: 50, color: Colors.purple);
}
