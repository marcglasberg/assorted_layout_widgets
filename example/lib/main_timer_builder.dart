import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

/// Based on:
/// https://dash-overflow.net/articles/why_vsync/
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TimeBuilder Widget'),
      ),
      body: SingleChildScrollView(
        child: ColumnSuper(
          separator: const Divider(thickness: 2.0),
          innerDistance: 40.0,
          outerDistance: 20.0,
          children: [
            //
            Center(
              child: ColumnSuper(
                innerDistance: 15.0,
                children: [
                  const Text("Countdown of 15 seconds, until 0:"),
                  widget1(),
                ],
              ),
            ),
            // //
            Center(
              child: ColumnSuper(
                innerDistance: 15.0,
                children: [
                  const Text("Runs once per second, for 15 seconds then stops:"),
                  widget2(),
                ],
              ),
            ),
            //
            Center(
              child: ColumnSuper(
                innerDistance: 15.0,
                children: [
                  const Text("Runs once per second:"),
                  widget3(),
                ],
              ),
            ),
            //
            Center(
              child: ColumnSuper(
                innerDistance: 15.0,
                children: [
                  const Text("Runs once per minute:"),
                  widget4(),
                ],
              ),
            ),
            //
          ],
        ),
      ),
    );
  }

  /// Given a reference dateTime, will do a countdown from [seconds] to zero.
  TimeBuilder widget1() {
    return TimeBuilder.countdown(
      //
      start: DateTime.now(),
      //
      seconds: 15,
      //
      builder: (BuildContext context, DateTime now, int ticks, bool isFinished,
          {required int countdown}) {
        print('1) countdown = $countdown, finished = $isFinished');

        return Column(
          children: [
            const Box(height: 10),
            Text(
              isFinished ? "FINISH" : countdown.toString(),
              style: const TextStyle(fontSize: 25),
            ),
            TickerRendered(ticks),
          ],
        );
      },
    );
  }

  TimeBuilder widget2() {
    return TimeBuilder.eachSecond(
      seconds: 15,
      builder: (BuildContext context, DateTime now, int ticks, bool isFinished) {
        print('2) now = $now, ticks = $ticks, finished = $isFinished');
        return ColumnSuper(
          innerDistance: 10.0,
          children: [
            ClockRenderer(dateTime: now),
            TickerRendered(ticks),
            Text(now.toString()),
          ],
        );
      },
    );
  }

  TimeBuilder widget3() {
    return TimeBuilder.eachSecond(
      builder: (BuildContext context, DateTime now, int ticks, bool isFinished) {
        print('3) now = $now, ticks = $ticks');
        return ColumnSuper(
          innerDistance: 10.0,
          children: [
            ClockRenderer(dateTime: now),
            TickerRendered(ticks),
            Text(now.toString()),
          ],
        );
      },
    );
  }

  TimeBuilder widget4() {
    return TimeBuilder.eachMinute(
      builder: (BuildContext context, DateTime now, int ticks, bool isFinished) {
        print('4) now = $now, ticks = $ticks');
        return ColumnSuper(
          innerDistance: 10.0,
          children: [
            ClockRenderer(dateTime: now),
            TickerRendered(ticks),
            Text(now.toString()),
          ],
        );
      },
    );
  }
}

class TickerRendered extends StatelessWidget {
  final int ticker;

  const TickerRendered(this.ticker, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const Pad(vertical: 10),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Box(width: 30, height: 15, color: ticker % 2 == 0 ? Colors.grey[300] : Colors.black),
          Box(width: 30, height: 15, color: ticker % 2 == 1 ? Colors.grey[300] : Colors.black),
        ],
      ),
    );
  }
}

class ClockRenderer extends StatelessWidget {
  const ClockRenderer({
    super.key,
    required this.dateTime,
  });

  final DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: FittedBox(
        child: Container(
          width: 210,
          height: 210,
          decoration: BoxDecoration(
            border: Border.all(width: 3, color: Colors.black),
            borderRadius: BorderRadius.circular(210),
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 105,
                left: 100,
                child: Transform(
                  alignment: Alignment.topCenter,
                  transform: Matrix4.rotationZ(pi + pi / 24 * 2 * dateTime.hour),
                  child: Container(height: 90, width: 5, color: Colors.black),
                ),
              ),
              Positioned(
                top: 105,
                left: 100,
                child: Transform(
                  alignment: Alignment.topCenter,
                  transform: Matrix4.rotationZ(pi + pi / 60 * 2 * dateTime.minute),
                  child: Container(height: 50, width: 5, color: Colors.grey),
                ),
              ),
              Positioned(
                top: 105,
                left: 101.5,
                child: Transform(
                  alignment: Alignment.topCenter,
                  transform: Matrix4.rotationZ(pi + pi / 60 * 2 * dateTime.second),
                  child: Container(height: 90, width: 2, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
