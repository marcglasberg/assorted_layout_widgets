import 'package:assorted_layout_widgets/src/text_input_formatters.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Convenience to build a [TextEditingValue] with a collapsed caret at [offset].
TextEditingValue _value(
  String text, {
  int? offset,
  TextRange composing = TextRange.empty,
}) {
  offset ??= text.length;
  return TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: offset),
    composing: composing,
  );
}

/// Simulates typing [chars] one character at a time into a field that already
/// contains the result of formatting [initial], using the given [formatter].
TextEditingValue _typeSequence(
  NoSpacesTextInputFormatter formatter,
  TextEditingValue initial,
  String chars,
) {
  final normalized = initial.selection.extentOffset < 0
      ? _value(initial.text)
      : initial;
  var current = formatter.formatEditUpdate(const TextEditingValue(), normalized);
  for (int i = 0; i < chars.length; i++) {
    final caret = current.selection.extentOffset < 0
        ? current.text.length
        : current.selection.extentOffset;
    final newText =
        current.text.substring(0, caret) + chars[i] + current.text.substring(caret);
    final newVal = _value(newText, offset: caret + 1);
    current = formatter.formatEditUpdate(current, newVal);
  }
  return current;
}

void main() {
  // ============================================================
  // BASIC BEHAVIOR
  // ============================================================

  group('NoSpacesTextInputFormatter — basic', () {
    final formatter = NoSpacesTextInputFormatter();

    test('empty input stays empty', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value(''));
      expect(result.text, '');
      expect(result.selection.baseOffset, 0);
    });

    test('text without whitespace passes through unchanged', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('HelloWorld'),
      );
      expect(result.text, 'HelloWorld');
      expect(result.selection.baseOffset, 10);
    });

    test('single space is removed', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('a b'),
      );
      expect(result.text, 'ab');
    });

    test('multiple spaces are all removed', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('a   b   c'),
      );
      expect(result.text, 'abc');
    });

    test('leading spaces are removed', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('   hello'),
      );
      expect(result.text, 'hello');
    });

    test('trailing spaces are removed', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('hello   '),
      );
      expect(result.text, 'hello');
    });

    test('text consisting only of spaces becomes empty', () {
      final result = formatter.formatEditUpdate(
        _value(''),
        _value('     '),
      );
      expect(result.text, '');
      expect(result.selection.baseOffset, 0);
    });
  });

  // ============================================================
  // ALL FORMS OF WHITESPACE
  // ============================================================

  group('NoSpacesTextInputFormatter — whitespace types', () {
    final formatter = NoSpacesTextInputFormatter();

    test('tab characters are removed', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('a\tb\tc'),
      );
      expect(result.text, 'abc');
    });

    test('newline characters are removed', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('a\nb\nc'),
      );
      expect(result.text, 'abc');
    });

    test('carriage returns are removed', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('a\rb\rc'),
      );
      expect(result.text, 'abc');
    });

    test('CRLF line endings are removed', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('line1\r\nline2'),
      );
      expect(result.text, 'line1line2');
    });

    test('form feed is removed', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('a\fb'),
      );
      expect(result.text, 'ab');
    });

    test('vertical tab is removed', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('a\vb'),
      );
      expect(result.text, 'ab');
    });

    test('mix of all whitespace kinds is removed', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('a b\tc\nd\re\ff\vg'),
      );
      expect(result.text, 'abcdefg');
    });

    test('non-breaking space (U+00A0) is removed', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('a b'),
      );
      expect(result.text, 'ab');
    });
  });

  // ============================================================
  // NON-WHITESPACE PRESERVATION
  // ============================================================

  group('NoSpacesTextInputFormatter — preserves non-whitespace', () {
    final formatter = NoSpacesTextInputFormatter();

    test('digits are preserved', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1 2 3 4 5'),
      );
      expect(result.text, '12345');
    });

    test('punctuation is preserved', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('a, b. c! d?'),
      );
      expect(result.text, 'a,b.c!d?');
    });

    test('symbols are preserved', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value(r'$ # @ % ^ & *'),
      );
      expect(result.text, r'$#@%^&*');
    });

    test('mixed case letters are preserved as-is', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('Hello World'),
      );
      expect(result.text, 'HelloWorld');
    });

    test('unicode letters are preserved', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('café au lait'),
      );
      expect(result.text, 'caféaulait');
    });

    test('emoji are preserved', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('hi 🎉 there'),
      );
      expect(result.text, 'hi🎉there');
    });
  });

  // ============================================================
  // COMPOSING / SELECTION
  // ============================================================

  group('NoSpacesTextInputFormatter — composing & selection', () {
    final formatter = NoSpacesTextInputFormatter();

    test('composing range is cleared', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('hello', composing: const TextRange(start: 0, end: 5)),
      );
      expect(result.composing, TextRange.empty);
    });

    test('selection is collapsed', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('hello'),
      );
      expect(result.selection.isCollapsed, isTrue);
    });
  });

  // ============================================================
  // CURSOR / OFFSET BEHAVIOR
  // ============================================================

  group('NoSpacesTextInputFormatter — cursor offset', () {
    final formatter = NoSpacesTextInputFormatter();

    test('caret stays at end after typing valid char', () {
      // Old "ab", caret at 2. User types 'c' → newValue "abc" caret=3.
      final result = formatter.formatEditUpdate(
        _value('ab'),
        _value('abc'),
      );
      expect(result.text, 'abc');
      expect(result.selection.baseOffset, 3);
    });

    test('caret clamped to text length when spaces are stripped', () {
      // Old "ab", caret at 2. User pasted "  " at the end → newValue = "ab  " caret=4.
      // Stripped text is "ab", so the caret must be clamped to <= 2.
      final result = formatter.formatEditUpdate(
        _value('ab'),
        _value('ab  '),
      );
      expect(result.text, 'ab');
      expect(result.selection.baseOffset, lessThanOrEqualTo(2));
    });

    test('caret preserved when text grows with valid chars', () {
      // Old "ac", caret at 1. User types 'b' → newValue "abc" caret=2.
      final result = formatter.formatEditUpdate(
        _value('ac', offset: 1),
        _value('abc', offset: 2),
      );
      expect(result.text, 'abc');
      expect(result.selection.baseOffset, 2);
    });

    test('caret falls back to old caret when whitespace is stripped', () {
      // Old "ab", caret at 1. User typed ' ' in the middle → newValue "a b" caret=2.
      // Stripped text is "ab" (length 2 < newValue.length 3), so we use the
      // OLD caret (1), clamped to text length 2 → 1.
      final result = formatter.formatEditUpdate(
        _value('ab', offset: 1),
        _value('a b', offset: 2),
      );
      expect(result.text, 'ab');
      expect(result.selection.baseOffset, 1);
    });
  });

  // ============================================================
  // TYPING SEQUENCES
  // ============================================================

  group('NoSpacesTextInputFormatter — typing sequences', () {
    final formatter = NoSpacesTextInputFormatter();

    test('typing letters one by one preserves them all', () {
      final result = _typeSequence(formatter, const TextEditingValue(), 'abcde');
      expect(result.text, 'abcde');
      expect(result.selection.baseOffset, 5);
    });

    test('typing only spaces never adds to text', () {
      final result = _typeSequence(formatter, const TextEditingValue(), '     ');
      expect(result.text, '');
    });

    test('typing letters interleaved with spaces drops the spaces', () {
      final result = _typeSequence(formatter, const TextEditingValue(), 'a b c d');
      expect(result.text, 'abcd');
    });

    test('typing tabs and newlines never adds to text', () {
      final result = _typeSequence(formatter, const TextEditingValue(), '\t\n\r');
      expect(result.text, '');
    });
  });

  // ============================================================
  // INSTANCE BEHAVIOR
  // ============================================================

  group('NoSpacesTextInputFormatter — instances', () {
    test('two instances behave identically', () {
      final a = NoSpacesTextInputFormatter();
      final b = NoSpacesTextInputFormatter();
      final input = _value('foo bar baz');
      expect(
        a.formatEditUpdate(const TextEditingValue(), input).text,
        b.formatEditUpdate(const TextEditingValue(), input).text,
      );
    });

    test('formatter is reusable across multiple calls', () {
      final formatter = NoSpacesTextInputFormatter();
      final r1 = formatter.formatEditUpdate(const TextEditingValue(), _value('a b'));
      final r2 = formatter.formatEditUpdate(const TextEditingValue(), _value('c d'));
      expect(r1.text, 'ab');
      expect(r2.text, 'cd');
    });
  });
}
