import 'package:assorted_layout_widgets/src/minimum_raggedness.dart';
import 'package:test/test.dart';

void main() {
  //
  ///////////////////////////////////////////////////////////////////////////////

  test('Divide no boxes.', () async {
    List<List<int>> result = MinimumRaggedness.divide([], 20, spacing: 1.0);
    expect(result, []);
  });

  ///////////////////////////////////////////////////////////////////////////////

  test('Divide boxes.', () async {
    List<List<int>> result = MinimumRaggedness.divide([14, 3, 7, 5, 7, 5], 20, spacing: 1.0);
    expect(result, [
      [0],
      [1, 2, 3],
      [4, 5]
    ]);
  });

  ///////////////////////////////////////////////////////////////////////////////

  test('Divide boxes of fractional size.', () async {
    //
    var result = MinimumRaggedness.divide([14.5, 3.3, 7.2, 5.0, 7.8, 5.2], 20.0, spacing: 1.0);
    expect(result, [
      [0],
      [1, 2, 3],
      [4, 5]
    ]);

    result = MinimumRaggedness.divide([14.5, 14.5], 29.0, spacing: 0.0);
    expect(result, [
      [0, 1],
    ]);

    result = MinimumRaggedness.divide([14.5, 14.5000000000001], 29.0, spacing: 0.0);
    expect(result, [
      [0],
      [1],
    ]);

    result = MinimumRaggedness.divide([14.5000000000001, 14.5], 29.0, spacing: 0.0);
    expect(result, [
      [0],
      [1],
    ]);

    result = MinimumRaggedness.divide([14.5, 14.5], 28.999999999, spacing: 0.0);
    expect(result, [
      [0],
      [1],
    ]);

    result = MinimumRaggedness.divide([120.53], 120.53, spacing: 0.0);
    expect(result, [
      [0],
    ]);

    result = MinimumRaggedness.divide([15, 15], 30.000001, spacing: 0.000001);
    expect(result, [
      [0, 1],
    ]);

    result = MinimumRaggedness.divide([15, 15, 15], 45.000002, spacing: 0.000001);
    expect(result, [
      [0, 1, 2],
    ]);

    result = MinimumRaggedness.divide([15, 15, 15, 15, 15, 15], 45.000002, spacing: 0.000001);
    expect(result, [
      [0, 1, 2],
      [3, 4, 5],
    ]);
  });

  ///////////////////////////////////////////////////////////////////////////////

  test('Divide boxes, some with 0 length.', () async {
    List<List<int>> result =
        MinimumRaggedness.divide([14, 0, 3, 0, 7, 5, 0, 7, 5, 0], 20, spacing: 1.0);
    expect(result, [
      [0, 1],
      [2, 3, 4, 5],
      [6, 7, 8, 9]
    ]);
  });

  ///////////////////////////////////////////////////////////////////////////////

  test('Divide boxes with maximum size.', () async {
    List<List<int>> result = MinimumRaggedness.divide([14, 13, 12], 14, spacing: 1.0);
    expect(result, [
      [0],
      [1],
      [2]
    ]);
  });

  ///////////////////////////////////////////////////////////////////////////////

  /// If a box has more than the maximum width,
  /// it is considered as having the maximum width.
  test('Divide boxes that exceed maximum size.', () async {
    List<List<int>> result = MinimumRaggedness.divide([20, 10], 15, spacing: 1.0);
    expect(result, [
      [0],
      [1],
    ]);
  });

  ///////////////////////////////////////////////////////////////////////////////

  /// If a box has more than the maximum width,
  /// it is considered as having the maximum width.
  test('Spacing different than 1.0.', () async {
    //
    // Spacing = 1.0
    List<List<int>> result = MinimumRaggedness.divide([10 - 1, 10 - 1, 10], 30, spacing: 1.0);
    expect(result, [
      [0, 1, 2],
    ]);

    // Spacing = 2.0
    result = MinimumRaggedness.divide([10 - 2, 10 - 2, 10], 30, spacing: 2.0);
    expect(result, [
      [0, 1, 2],
    ]);

    // Spacing = 3.5
    result = MinimumRaggedness.divide([10 - 3.5, 10 - 3.5, 10], 30, spacing: 3.5);
    expect(result, [
      [0, 1, 2],
    ]);

    // Spacing = 3.500000000001, doesn't fit in 1 line anymore.
    result = MinimumRaggedness.divide([10 - 3.5, 10 - 3.5, 10], 30, spacing: 3.500000000001);
    expect(result, [
      [0, 1],
      [2],
    ]);

    // Spacing = 3.5, width a bit larger doesn't fit in 1 line anymore.
    result = MinimumRaggedness.divide([10 - 3.5, 10 - 3.5, 10.000000001], 30, spacing: 3.5);
    expect(result, [
      [0, 1],
      [2],
    ]);

    // Spacing = 0.0
    result = MinimumRaggedness.divide([10, 10, 10, 15, 15], 30, spacing: 0.0);
    expect(result, [
      [0, 1, 2],
      [3, 4],
    ]);
  });

  ///////////////////////////////////////////////////////////////////////////////

  test('Divide words.', () async {
    List<String> result =
        MinimumRaggedness.divideWords("aaaaaaaaaaaaaa bbb ccccccc ddddd eeeeeee fffff", 20);
    expect(result, ['aaaaaaaaaaaaaa', 'bbb ccccccc ddddd', 'eeeeeee fffff']);
  });

  ///////////////////////////////////////////////////////////////////////////////
}
