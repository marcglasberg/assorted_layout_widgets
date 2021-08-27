import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// /////////////////////////////////////////////////////////////////////////////////////////////////

typedef TimerWidgetBuilder = Widget Function(
    BuildContext context,

    /// The time of the current tick.
    DateTime dateTime,

    /// The number of ticks since the timer started.
    int ticks,

    /// This is false while the timer is on, and becomes true as soon as it ends.
    bool isFinished,
    );

// /////////////////////////////////////////////////////////////////////////////////////////////////

typedef CountdownWidgetBuilder = Widget Function(
    BuildContext context,

    /// The time of the current tick.
    DateTime dateTime,

    /// The number of ticks since the timer started.
    int ticks,

    /// This is false during the countdown, and becomes true as soon as it ends.
    bool isFinished, {

    /// The number of seconds in the countdown. When this gets to zero, [isFinished] will be true.
    required int countdown,
    });

// /////////////////////////////////////////////////////////////////////////////////////////////////

/// Return true if the widget should rebuild.
/// Return false if it should not rebuild.
typedef IfRebuilds = bool Function({
//
/// The current time.
required DateTime currentTime,

/// The time of the last tick (may be null for the first tick).
required DateTime? lastTime,

/// The number of ticks since the timer started.
required int ticks,
});

// /////////////////////////////////////////////////////////////////////////////////////////////////

/// Return true to end the timer.
/// Returning true here will generate one last rebuild, and then stop.
typedef IsFinished = bool Function({
//
/// This is the current time.
required DateTime currentTime,

/// This is the time of the last tick (may be null for the first tick).
required DateTime? lastTime,

/// This is the number of ticks since the timer started.
required int ticks,
});

// /////////////////////////////////////////////////////////////////////////////////////////////////

/// Very efficient timer, which rebuilds only when needed:
///
/// * Compatible with DevTools "slow animations", which reduce the speed of AnimationControllers.
/// * Compatible with clock changes, allowing for testing (skip frames to target a specific moment in time).
/// * The animation is "muted" when the widget associated with the SingleTickerProviderStateMixin is not visible.
///
/// Based on Rémi Rousselet's code: https://gist.github.com/rrousselGit/beaf7442a20ea7e2ed3f13bbd40984a8
/// See explanation here: https://dash-overflow.net/articles/why_vsync/
///
class TimeBuilder extends StatefulWidget {
  //
  final TimerWidgetBuilder builder;
  final IfRebuilds ifRebuilds;
  final IsFinished? isFinished;

  const TimeBuilder({
    Key? key,
    required this.builder,
    required this.ifRebuilds,
    this.isFinished,
  }) : super(key: key);

  /// Rebuilds in every frame.
  const TimeBuilder.animate({Key? key, required this.builder, this.isFinished})
      : ifRebuilds = _always,
        super(key: key);

  /// Creates a countdown, from the given [start] DateTime.
  /// Will call the [builder], which is a [CountdownWidgetBuilder], once per second,
  /// util the countdown reaches zero.
  ///
  /// ```
  /// TimerWidget.countdown(
  ///    reference: DateTime.now(),
  ///    builder: (BuildContext context, int seconds, bool isFinished) => ...;
  /// )
  /// ```
  ///
  ///
  factory TimeBuilder.countdown({
    Key? key,
    required DateTime start,
    required int seconds,
    required CountdownWidgetBuilder builder,
  }) {
    return TimeBuilder(
      //
      key: key,
      //
      ifRebuilds: ({
        required DateTime currentTime,
        required DateTime? lastTime,
        required int ticks,
      }) {
        return (lastTime == null || (currentTime.second != lastTime.second));
      },
      //
      isFinished: ({
        required DateTime currentTime,
        required DateTime? lastTime,
        required int ticks,
      }) {
        if (lastTime != null && (currentTime.second == lastTime.second)) return false;

        int _seconds = (start.add(Duration(seconds: seconds))).difference(currentTime).inSeconds;

        return _seconds <= 0;
      },
      //
      builder: (
          BuildContext context,
          DateTime now,
          int ticks,
          bool isFinished,
          ) {
        int _seconds = (start.add(Duration(seconds: seconds))).difference(now).inSeconds;
        return builder(context, now, ticks, isFinished, countdown: _seconds);
      },
      //
    );
  }

  /// Rebuilds each millisecond.
  const TimeBuilder.eachMillisecond({Key? key, required this.builder})
      : ifRebuilds = _eachMillisecond,
        isFinished = null,
        super(key: key);

  /// Rebuilds each second.
  /// For example, this will show a clock that rebuilds each second:
  ///
  /// ```
  /// TimerWidget.eachSecond(
  ///    builder: (BuildContext context, DateTime now, int ticks)
  ///       => ClockRenderer(dateTime: now);
  /// )
  /// ```
  /// If you pass [seconds] it will stop when reaching that number of ticks.
  ///
  TimeBuilder.eachSecond({Key? key, int? seconds, required this.builder})
      : ifRebuilds = _eachSecond,
        isFinished = _ifFinished(seconds),
        super(key: key);

  /// Rebuilds each minute.
  /// For example, this will show a clock that rebuilds each minute:
  ///
  /// ```
  /// TimerWidget.eachMinute(
  ///    builder: (BuildContext context, DateTime now, int ticks)
  ///       => ClockRenderer(dateTime: now);
  /// )
  /// ```
  /// If you pass [minutes] it will stop when reaching that number of ticks.
  ///
  TimeBuilder.eachMinute({Key? key, int? minutes, required this.builder})
      : ifRebuilds = _eachMinute,
        isFinished = _ifFinished(minutes),
        super(key: key);

  /// Rebuilds each hour.
  /// For example, this will show a clock that rebuilds each hour:
  ///
  /// ```
  /// TimerWidget.eachHour(
  ///    builder: (BuildContext context, DateTime now, int ticks)
  ///       => ClockRenderer(dateTime: now);
  /// )
  /// ```
  /// If you pass [hours] it will stop when reaching that number of ticks.
  ///
  TimeBuilder.eachHour({Key? key, int? hours, required this.builder})
      : ifRebuilds = _eachHour,
        isFinished = _ifFinished(hours),
        super(key: key);

  static bool _always({
    required DateTime currentTime,
    required DateTime? lastTime,
    required int ticks,
  }) =>
      true;

  static bool _eachMillisecond({
    required DateTime currentTime,
    required DateTime? lastTime,
    required int ticks,
  }) =>
      (lastTime == null || (currentTime.millisecond != lastTime.millisecond));

  static bool _eachSecond({
    required DateTime currentTime,
    required DateTime? lastTime,
    required int ticks,
  }) =>
      (lastTime == null || (currentTime.second != lastTime.second));

  static bool _eachMinute({
    required DateTime currentTime,
    required DateTime? lastTime,
    required int ticks,
  }) =>
      (lastTime == null || (currentTime.minute != lastTime.minute));

  static bool _eachHour({
    required DateTime currentTime,
    required DateTime? lastTime,
    required int ticks,
  }) =>
      (lastTime == null || (currentTime.hour != lastTime.hour));

  static IsFinished _ifFinished(int? numberOfTicks) => ({
    required DateTime currentTime,
    required DateTime? lastTime,
    required int ticks,
  }) =>
  (numberOfTicks != null) && (ticks > numberOfTicks);

  @override
  _TimeBuilderState createState() => _TimeBuilderState();
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

class _TimeBuilderState extends State<TimeBuilder> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late DateTime _initialTime;
  late DateTime _now;
  int _ticks = 0;

  @override
  void initState() {
    super.initState();
    _now = _initialTime = clock.now();
    _ticker = createTicker(_onTick);

    // ---

    final isFinishedBeforeEvenStarting =
        widget.isFinished?.call(currentTime: _initialTime, lastTime: null, ticks: _ticks) ?? false;

    if (!isFinishedBeforeEvenStarting) _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final currentTime = _initialTime.add(elapsed);

    final _ifRebuilds = widget.ifRebuilds(currentTime: currentTime, lastTime: _now, ticks: _ticks);

    final isFinished =
        widget.isFinished?.call(currentTime: currentTime, lastTime: _now, ticks: _ticks) ?? false;

    // Rebuild only if seconds changed (instead of every frame).
    if (_ifRebuilds || isFinished) {
      setState(() {
        _ticks++;
        _now = currentTime;
      });
    }

    // May stop the ticker.
    if (isFinished) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _now, _ticks, !_ticker.isActive);
}

// /////////////////////////////////////////////////////////////////////////////////////////////////
