import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  //
  /// Builds the given [timeBuilder], and then pumps [count] frames of 1 second each,
  /// returning the tick number seen by the builder after each one of those pumps.
  Future<List<int>> _pumpSeconds(
    WidgetTester tester,
    TimeBuilder Function() timeBuilder, {
    required int count,
    DateTime? start,
  }) async {
    final ticksSeen = <int>[];

    await withClock(
      Clock.fixed(start ?? DateTime.utc(2024, 1, 1)),
      () async {
        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: timeBuilder(),
        ));

        for (int i = 0; i < count; i++) {
          await tester.pump(const Duration(seconds: 1));
          ticksSeen.add(int.parse(tester.widget<Text>(find.byType(Text)).data!));
        }
      },
    );

    return ticksSeen;
  }

  /// Simply renders the current number of ticks.
  Widget _ticksAsText({
    required BuildContext context,
    required DateTime currentTickTime,
    required DateTime initialTime,
    required int ticks,
    required bool isFinished,
  }) =>
      Text('$ticks');

  testWidgets('TimeBuilder.each with a 1 second interval ticks each second.',
      (tester) async {
    final ticks = await _pumpSeconds(
      tester,
      () => TimeBuilder.each(
          interval: const Duration(seconds: 1), builder: _ticksAsText),
      count: 5,
    );

    expect(ticks, [1, 2, 3, 4, 5]);
  });

  testWidgets('TimeBuilder.each with a 5 seconds interval ticks each 5 seconds.',
      (tester) async {
    final ticks = await _pumpSeconds(
      tester,
      () => TimeBuilder.each(
          interval: const Duration(seconds: 5), builder: _ticksAsText),
      count: 12,
    );

    // Ticks only when crossing the 5 second boundaries of the clock.
    expect(ticks, [0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2]);
  });

  testWidgets(
      'TimeBuilder.each aligns the ticks to the clock, '
      'even when it starts between boundaries.', (tester) async {
    final ticks = await _pumpSeconds(
      tester,
      () => TimeBuilder.each(
          interval: const Duration(seconds: 5), builder: _ticksAsText),
      count: 12,
      // Starts 3 seconds after a 5 second boundary.
      start: DateTime.utc(2024, 1, 1, 0, 0, 3),
    );

    expect(ticks, [0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3]);
  });

  testWidgets('TimeBuilder.each stops after the given number of ticks.',
      (tester) async {
    final ticks = await _pumpSeconds(
      tester,
      () => TimeBuilder.each(
          interval: const Duration(seconds: 1),
          numberOfTicks: 3,
          builder: _ticksAsText),
      count: 6,
    );

    // Same as `eachSecond`, `eachMinute` and `eachHour`: the last tick is the one that
    // detects the ticking is finished, and then the ticker stops for good.
    expect(ticks, [1, 2, 3, 4, 5, 5]);
  });

  testWidgets('TimeBuilder.each with a zero interval ticks in each frame.',
      (tester) async {
    final ticks = await _pumpSeconds(
      tester,
      () => TimeBuilder.each(interval: Duration.zero, builder: _ticksAsText),
      count: 3,
    );

    expect(ticks, [1, 2, 3]);
  });
}
