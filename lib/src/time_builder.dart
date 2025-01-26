import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
  final TimeBuilderBuilder builder;
  final IfShouldTickAndRebuild ifShouldTickAndRebuild;
  final IsFinished? isFinished;

  /// Creates a [TimeBuilder].
  ///
  /// - Function [ifShouldTickAndRebuild] will be called for every frame, repeatedly.
  /// Whenever it returns `true`, the [TimeBuilder] will "tick" and rebuild.
  /// Note this function stops being called temporarily when the widget is in a route
  /// that is not visible, or because of an ancestor widget such as `Visibility`.
  ///
  /// - If function [isFinished] is provided, the ticking will stop definitively
  /// (and [ifShouldTickAndRebuild] won't be called anymore) when it returns `true`.
  ///
  /// - The [builder] will be called for each tick, and should return the widget to be
  /// built. Not the builder gets the current time, the initial time, the number of ticks
  /// elapsed since the [TimeBuilder] was created, and a flag indicating if the ticking
  /// is finished.
  ///
  const TimeBuilder({
    Key? key,
    required this.builder,
    required this.ifShouldTickAndRebuild,
    this.isFinished,
  }) : super(key: key);

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
      ifShouldTickAndRebuild: ({
        required DateTime currentTime,
        required DateTime? lastTickTime,
        required DateTime initialTime,
        required int ticks,
      }) {
        return (lastTickTime == null || (currentTime.second != lastTickTime.second));
      },
      //
      isFinished: ({
        required DateTime currentTime,
        required DateTime? lastTickTime,
        required DateTime initialTime,
        required int ticks,
      }) {
        if (lastTickTime != null && (currentTime.second == lastTickTime.second))
          return false;

        int _seconds =
            (start.add(Duration(seconds: seconds))).difference(currentTime).inSeconds;

        return _seconds <= 0;
      },
      builder: ({
        required BuildContext context,

        /// The time of the current tick. Same as the current time (or very similar).
        required DateTime currentTickTime,

        /// The time when the [TimeBuilder] was created.
        required DateTime initialTime,

        /// The number of ticks since the timer started.
        required int ticks,

        /// This is `false` while the [TimeBuilder] is ticking. Is `true` when finished.
        required bool isFinished,
      }) {
        int _seconds =
            (start.add(Duration(seconds: seconds))).difference(clock.now()).inSeconds;
        return builder(
          context: context,
          currentTickTime: clock.now(),
          initialTime: initialTime,
          ticks: ticks,
          isFinished: isFinished,
          countdown: _seconds,
        );
      },
      //
    );
  }

  /// Creates a [TimeBuilder] that rebuilds in every frame.
  const TimeBuilder.eachFrame({Key? key, required this.builder, this.isFinished})
      : ifShouldTickAndRebuild = _always,
        super(key: key);

  /// Creates a [TimeBuilder] that rebuilds in each millisecond.
  const TimeBuilder.eachMillisecond({Key? key, required this.builder})
      : ifShouldTickAndRebuild = _eachMillisecond,
        isFinished = null,
        super(key: key);

  // required BuildContext context,
  //
  // /// The time of the current tick. Same as the current time (or very similar).
  // required DateTime currentTickTime,
  //
  // /// The time when the [TimeBuilder] was created.
  // required DateTime initialTime,
  //
  // /// The number of ticks since the timer started.
  // required int ticks,
  //
  // /// This is `false` while the [TimeBuilder] is ticking. Is `true` when finished.
  // required bool isFinished,
  //

  /// Creates a [TimeBuilder] that rebuilds in each second.
  ///
  /// For example, this will show a clock that rebuilds each second:
  ///
  /// ```
  /// TimerWidget.eachSecond(
  ///   builder: ({ ... , required DateTime currentTickTime, ... })
  ///      => ClockRenderer(dateTime: currentTickTime);
  /// );
  /// ```
  /// If you pass [seconds] it will stop when reaching that number of ticks.
  ///
  TimeBuilder.eachSecond({Key? key, int? seconds, required this.builder})
      : ifShouldTickAndRebuild = _eachSecond,
        isFinished = _ifFinished(seconds),
        super(key: key);

  /// Creates a [TimeBuilder] that rebuilds in each minute.
  ///
  /// For example, this will show a clock that rebuilds each minute:
  ///
  /// ```
  /// TimerWidget.eachMinute(
  ///   builder: ({ ... , required DateTime currentTickTime, ... })
  ///       => ClockRenderer(dateTime: currentTickTime);
  /// )
  /// ```
  /// If you pass [minutes] it will stop when reaching that number of ticks.
  ///
  TimeBuilder.eachMinute({Key? key, int? minutes, required this.builder})
      : ifShouldTickAndRebuild = _eachMinute,
        isFinished = _ifFinished(minutes),
        super(key: key);

  /// Creates a [TimeBuilder] that rebuilds in each hour.
  ///
  /// For example, this will show a clock that rebuilds each hour:
  ///
  /// ```
  /// TimerWidget.eachHour(
  ///   builder: ({ ... , required DateTime currentTickTime, ... })
  ///       => ClockRenderer(dateTime: currentTickTime);
  /// )
  /// ```
  /// If you pass [hours] it will stop when reaching that number of ticks.
  ///
  TimeBuilder.eachHour({Key? key, int? hours, required this.builder})
      : ifShouldTickAndRebuild = _eachHour,
        isFinished = _ifFinished(hours),
        super(key: key);

  static bool _always({
    required DateTime currentTime,
    required DateTime? lastTickTime,
    required DateTime initialTime,
    required int ticks,
  }) =>
      true;

  static bool _eachMillisecond({
    required DateTime currentTime,
    required DateTime? lastTickTime,
    required DateTime initialTime,
    required int ticks,
  }) =>
      (lastTickTime == null || (currentTime.millisecond != lastTickTime.millisecond));

  static bool _eachSecond({
    required DateTime currentTime,
    required DateTime? lastTickTime,
    required DateTime initialTime,
    required int ticks,
  }) =>
      (lastTickTime == null || (currentTime.second != lastTickTime.second));

  static bool _eachMinute({
    required DateTime currentTime,
    required DateTime? lastTickTime,
    required DateTime initialTime,
    required int ticks,
  }) =>
      (lastTickTime == null || (currentTime.minute != lastTickTime.minute));

  static bool _eachHour({
    required DateTime currentTime,
    required DateTime? lastTickTime,
    required DateTime initialTime,
    required int ticks,
  }) =>
      (lastTickTime == null || (currentTime.hour != lastTickTime.hour));

  static IsFinished _ifFinished(int? numberOfTicks) => ({
        required DateTime currentTime,
        required DateTime? lastTickTime,
        required DateTime initialTime,
        required int ticks,
      }) =>
          (numberOfTicks != null) && (ticks > numberOfTicks);

  @override
  _TimeBuilderState createState() => _TimeBuilderState();
}

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

    final isFinishedBeforeEvenStarting = widget.isFinished?.call(
            currentTime: _initialTime,
            lastTickTime: null,
            initialTime: _initialTime,
            ticks: _ticks) ??
        false;

    if (!isFinishedBeforeEvenStarting) _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final currentTime = _initialTime.add(elapsed);

    final _ifRebuilds = widget.ifShouldTickAndRebuild(
      currentTime: currentTime,
      lastTickTime: _now,
      initialTime: _initialTime,
      ticks: _ticks,
    );

    final isFinished = widget.isFinished?.call(
          currentTime: currentTime,
          lastTickTime: _now,
          initialTime: _initialTime,
          ticks: _ticks,
        ) ??
        false;

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
  Widget build(BuildContext context) => widget.builder(
        context: context,
        currentTickTime: _now,
        initialTime: _initialTime,
        ticks: _ticks,
        isFinished: !_ticker.isActive,
      );
}

/// You should return the widget that should be built.
typedef TimeBuilderBuilder = Widget Function({
  required BuildContext context,

  /// The time of the current tick. Same as the current time (or very similar).
  required DateTime currentTickTime,

  /// The time when the [TimeBuilder] was created.
  required DateTime initialTime,

  /// The number of ticks since the timer started.
  required int ticks,

  /// /// This is `false` while the [TimeBuilder] is ticking. Is `true` when finished.
  required bool isFinished,
});

typedef CountdownWidgetBuilder = Widget Function({
  required BuildContext context,

  /// The time of the current tick. Same as the current time (or very similar).
  required DateTime currentTickTime,

  /// The time when the [TimeBuilder] was created.
  required DateTime initialTime,

  /// The number of ticks since the timer started.
  required int ticks,

  /// This is false during the countdown, and becomes true as soon as it ends.
  required bool isFinished,

  /// The number of seconds still remaining in the countdown.
  /// When this gets to zero, [isFinished] will be true.
  required int countdown,
});

/// You should return `true` if the [TimeBuilder] should tick and rebuild.
/// Or return `false` if it should NOT tick nor rebuild.
typedef IfShouldTickAndRebuild = bool Function({
//
  /// The current time.
  required DateTime currentTime,

  /// The time of the last tick (is `null` for the first tick).
  required DateTime? lastTickTime,

  /// The time when the [TimeBuilder] was created.
  required DateTime initialTime,

  /// The number of ticks since the [TimeBuilder] was created.
  required int ticks,
});

/// You should return `true` to end the ticking.
/// The [TimeBuilder] generate one last tick/rebuild, and then will stop.
/// Or return `false` if it is still going on.
typedef IsFinished = bool Function({
//
  /// This is the current time.
  required DateTime currentTime,

  /// This is the time of the last tick (is `null` for the first tick).
  required DateTime? lastTickTime,

  /// The time when the [TimeBuilder] was created.
  required DateTime initialTime,

  /// The number of ticks since the [TimeBuilder] was created.
  required int ticks,
});
