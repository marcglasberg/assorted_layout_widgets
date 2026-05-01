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
  AllowedCharsTextInputFormatter formatter,
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
  // DIGITS-ONLY PATTERN
  // ============================================================

  group('AllowedCharsTextInputFormatter — digits only [0-9]', () {
    final formatter = AllowedCharsTextInputFormatter(RegExp(r'[0-9]'));

    test('empty input stays empty', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value(''));
      expect(result.text, '');
      expect(result.selection.baseOffset, 0);
    });

    test('all digits are kept', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1234567890'),
      );
      expect(result.text, '1234567890');
    });

    test('letters are stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1a2b3c'),
      );
      expect(result.text, '123');
    });

    test('punctuation is stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1.2,3-4'),
      );
      expect(result.text, '1234');
    });

    test('spaces are stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1 2 3'),
      );
      expect(result.text, '123');
    });

    test('only forbidden characters becomes empty', () {
      final result = formatter.formatEditUpdate(
        _value(''),
        _value('abc.,- !@#'),
      );
      expect(result.text, '');
      expect(result.selection.baseOffset, 0);
    });

    test('typing digits one by one preserves them all', () {
      final result = _typeSequence(formatter, const TextEditingValue(), '12345');
      expect(result.text, '12345');
      expect(result.selection.baseOffset, 5);
    });

    test('typing forbidden chars never changes the text', () {
      final result = _typeSequence(formatter, const TextEditingValue(), 'a.b,c-d');
      expect(result.text, '');
    });
  });

  // ============================================================
  // LETTERS-ONLY PATTERN
  // ============================================================

  group('AllowedCharsTextInputFormatter — letters only [a-zA-Z]', () {
    final formatter = AllowedCharsTextInputFormatter(RegExp(r'[a-zA-Z]'));

    test('letters are kept and digits stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('Hello123World'),
      );
      expect(result.text, 'HelloWorld');
    });

    test('case is preserved', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('AbCdEf'),
      );
      expect(result.text, 'AbCdEf');
    });

    test('non-ASCII letters are stripped (accented chars not in [a-zA-Z])', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('café'),
      );
      expect(result.text, 'caf');
    });
  });

  // ============================================================
  // ALPHANUMERIC PATTERN
  // ============================================================

  group('AllowedCharsTextInputFormatter — alphanumeric [a-zA-Z0-9]', () {
    final formatter = AllowedCharsTextInputFormatter(RegExp(r'[a-zA-Z0-9]'));

    test('letters and digits are kept', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('abc123XYZ'),
      );
      expect(result.text, 'abc123XYZ');
    });

    test('symbols are stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value(r'a!b@c#1$2%'),
      );
      expect(result.text, 'abc12');
    });

    test('whitespace is stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('hello world 42'),
      );
      expect(result.text, 'helloworld42');
    });
  });

  // ============================================================
  // NEGATED PATTERN (allow everything except some chars)
  // ============================================================

  group('AllowedCharsTextInputFormatter — negated pattern [^,.]', () {
    final formatter = AllowedCharsTextInputFormatter(RegExp(r'[^,.]'));

    test('characters not in the excluded set are kept', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('abc123'),
      );
      expect(result.text, 'abc123');
    });

    test('excluded characters are stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1,234.56'),
      );
      expect(result.text, '123456');
    });
  });

  // ============================================================
  // UNICODE / GRAPHEME PATTERN
  // ============================================================

  group('AllowedCharsTextInputFormatter — unicode letter \\p{L}', () {
    final formatter = AllowedCharsTextInputFormatter(
      RegExp(r'\p{L}', unicode: true),
    );

    test('ASCII letters are kept', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('Hello'),
      );
      expect(result.text, 'Hello');
    });

    test('digits and punctuation are stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('Hello, 123!'),
      );
      expect(result.text, 'Hello');
    });

    test('accented unicode letters are kept', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('café-naïve'),
      );
      expect(result.text, 'cafénaïve');
    });

    test('non-Latin letters (e.g. Greek, Cyrillic) are kept', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('αβγ Hello мир 42'),
      );
      expect(result.text, 'αβγHelloмир');
    });
  });

  group('AllowedCharsTextInputFormatter — grapheme clusters', () {
    // Pattern allows everything (any single grapheme).
    final allowAll = AllowedCharsTextInputFormatter(RegExp(r'.', dotAll: true));

    test('emoji grapheme is preserved as a whole', () {
      final result = allowAll.formatEditUpdate(
        const TextEditingValue(),
        _value('a😀b'),
      );
      expect(result.text, 'a😀b');
    });

    test('flag emoji (multi-codepoint grapheme) is preserved as a whole', () {
      // Brazilian flag 🇧🇷 is two regional-indicator codepoints — one grapheme.
      final result = allowAll.formatEditUpdate(
        const TextEditingValue(),
        _value('x🇧🇷y'),
      );
      expect(result.text, 'x🇧🇷y');
    });

    test('emoji is stripped when pattern does not match it', () {
      final lettersOnly = AllowedCharsTextInputFormatter(RegExp(r'[a-z]'));
      final result = lettersOnly.formatEditUpdate(
        const TextEditingValue(),
        _value('a😀b🇧🇷c'),
      );
      expect(result.text, 'abc');
    });
  });

  // ============================================================
  // COMPOSING RANGE
  // ============================================================

  group('AllowedCharsTextInputFormatter — composing range', () {
    final formatter = AllowedCharsTextInputFormatter(RegExp(r'[0-9]'));

    test('composing range is cleared even when nothing changes', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('123', composing: const TextRange(start: 0, end: 3)),
      );
      expect(result.composing, TextRange.empty);
    });

    test('composing range is cleared when chars are stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1a2b3', composing: const TextRange(start: 0, end: 5)),
      );
      expect(result.text, '123');
      expect(result.composing, TextRange.empty);
    });
  });

  // ============================================================
  // CURSOR / OFFSET BEHAVIOR
  // ============================================================

  group('AllowedCharsTextInputFormatter — cursor offset', () {
    final formatter = AllowedCharsTextInputFormatter(RegExp(r'[0-9]'));

    test('caret stays at end after typing valid char', () {
      final result = formatter.formatEditUpdate(
        _value('12'),
        _value('123'),
      );
      expect(result.text, '123');
      expect(result.selection.baseOffset, 3);
    });

    test('caret clamped to text length when chars are stripped', () {
      // User pasted "abc" at the end of "12" → newValue = "12abc" caret=5.
      // Stripped text is "12", so the caret must be clamped.
      final result = formatter.formatEditUpdate(
        _value('12'),
        _value('12abc'),
      );
      expect(result.text, '12');
      expect(result.selection.baseOffset, lessThanOrEqualTo(2));
    });

    test('caret in the middle is preserved when text grows', () {
      // Old "13", caret at 1. User types '2' → newValue "123" caret=2.
      final result = formatter.formatEditUpdate(
        _value('13', offset: 1),
        _value('123', offset: 2),
      );
      expect(result.text, '123');
      expect(result.selection.baseOffset, 2);
    });

    test('typing a forbidden char keeps text unchanged and caret valid', () {
      // Old "12", caret at 2. User types 'a' → newValue "12a" caret=3.
      // Stripped text is "12", caret should be clamped.
      final result = formatter.formatEditUpdate(
        _value('12', offset: 2),
        _value('12a', offset: 3),
      );
      expect(result.text, '12');
      expect(result.selection.baseOffset, lessThanOrEqualTo(2));
    });

    test('selection collapses to a single offset', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(
          text: '123',
          selection: const TextSelection(baseOffset: 0, extentOffset: 3),
        ),
      );
      expect(result.selection.isCollapsed, isTrue);
    });
  });

  // ============================================================
  // FIELD STORAGE / IMMUTABILITY
  // ============================================================

  group('AllowedCharsTextInputFormatter — construction', () {
    test('the given allowedPattern is exposed', () {
      final pattern = RegExp(r'[a-z]');
      final formatter = AllowedCharsTextInputFormatter(pattern);
      expect(formatter.allowedPattern, same(pattern));
    });

    test('two formatters built with the same regex string filter the same', () {
      final a = AllowedCharsTextInputFormatter(RegExp(r'[0-9]'));
      final b = AllowedCharsTextInputFormatter(RegExp(r'[0-9]'));
      final input = _value('a1b2c3');
      expect(
        a.formatEditUpdate(const TextEditingValue(), input).text,
        b.formatEditUpdate(const TextEditingValue(), input).text,
      );
    });
  });
}
