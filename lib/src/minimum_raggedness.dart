import 'dart:collection';

import 'dart:math';

class MinimumRaggedness {
  //

  /// Given some [boxWidths], break it into the smallest possible number
  /// of lines such as each line has width not larger than [maxWidth].
  /// It also minimizes the difference between width of each line,
  /// achieving a "balanced" result.
  /// Optionally accepts a [spacing] between boxes.
  ///
  static List<List<int>> divide(List<num> boxWidths, num maxWidth, {num spacing = 0.0}) {
    //
    // ---

    /// TODO: Fix this:
    /// Terrible hack ahead:
    /// I translated this algorithm from Python (https://xxyxyz.org/line-breaking/)
    /// without really taking the time to understand it.
    /// It was originally for monospace text, so it only works for spacing 1.0.
    /// To make this work for any spacing I am dividing all widths by the provided spacing.
    /// And instead of spacing zero I use a very small one.
    if (spacing != 1.0) {
      if (spacing == 0.0) spacing = 0.000001;
      boxWidths = boxWidths.map((w) => w / spacing).toList();
      maxWidth = maxWidth / spacing;
    }

    // ---

    int count = boxWidths.length;
    List<num> offsets = [0];

    for (num boxWidth in boxWidths) {
      offsets.add(offsets.last + min(boxWidth, maxWidth));
    }

    List<num> minimum = [0]..addAll(List<num>.filled(count, 9223372036854775807));
    List<int> breaks = List<int>.filled(count + 1, 0);

    num cost(int i, int j) {
      num width = offsets[j] - offsets[i] + j - i - 1;
      if (width > maxWidth)
        return 9223372036854775806;
      else
        return minimum[i] + pow(maxWidth - width, 2);
    }

    void search(int i0, int j0, int i1, int j1) {
      Queue<List<int>> stack = Queue()..add([i0, j0, i1, j1]);

      while (stack.isNotEmpty) {
        List<int> info = stack.removeLast();
        i0 = info[0];
        j0 = info[1];
        i1 = info[2];
        j1 = info[3];

        if (j0 < j1) {
          int j = (j0 + j1) ~/ 2;

          for (int i = i0; i < i1; i++) {
            num c = cost(i, j);
            if (c <= minimum[j]) {
              minimum[j] = c;
              breaks[j] = i;
            }
          }

          stack.add([breaks[j], j + 1, i1, j1]);
          stack.add([i0, j0, breaks[j] + 1, j]);
        }
      }
    }

    int n = count + 1;
    int i = 0;
    int offset = 0;

    while (true) {
      int r = min(n, pow(2, i + 1));
      int edge = pow(2, i) + offset;
      search(0 + offset, edge, edge, r + offset);
      num x = minimum[r - 1 + offset];

      bool flag = true;
      for (int j = pow(2, i); j < r - 1; j++) {
        num y = cost(j + offset, r - 1 + offset);
        if (y <= x) {
          n -= j;
          i = 0;
          offset += j;
          flag = false;
          break;
        }
      }

      if (flag) {
        if (r == n) break;
        i = i + 1;
      }
    }

    int j = count;

    List<List<int>> indexes = [];

    while (j > 0) {
      int i = breaks[j];
      indexes.add(List<int>.generate(j - i, (index) => index + i));
      j = i;
    }

    return indexes.reversed.toList();
  }

  /// Given some [text], breaks it into the smallest possible number of lines
  /// such as each line has width not larger than [maxWidthInChars] chars.
  /// It also minimizes the difference between width of each line,
  /// achieving a "balanced" result.
  ///
  static List<String> divideWords(String text, int maxWidthInChars) {
    List<String> words = text.split(" ");
    List<int> boxes = words.map((word) => word.length).toList();

    List<List<num>> divided = divide(boxes, maxWidthInChars, spacing: 1.0);

    List<String> result = [];

    for (List<num> partList in divided) {
      String text = partList.map((part) => words[part]).join(" ");
      result.add(text);
    }

    return result;
  }
}
