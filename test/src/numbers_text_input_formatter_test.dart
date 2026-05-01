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
  NumbersTextInputFormatter formatter,
  TextEditingValue initial,
  String chars,
) {
  // Normalize the initial value so the caret is never -1.
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
  // INTEGER MODE
  // ============================================================

  group('NumbersTextInputFormatter.integer', () {
    final formatter = NumbersTextInputFormatter.integer;

    test('empty input stays empty', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value(''));
      expect(result.text, '');
      expect(result.selection.baseOffset, 0);
    });

    test('single digit', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('5'));
      expect(result.text, '5');
      expect(result.selection.baseOffset, 1);
    });

    test('multiple digits are kept as-is', () {
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

    test('dots are stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1.23'),
      );
      expect(result.text, '123');
    });

    test('commas are stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1,23'),
      );
      expect(result.text, '123');
    });

    test('minus sign is stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('-42'),
      );
      expect(result.text, '42');
    });

    test('spaces are stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1 2 3'),
      );
      expect(result.text, '123');
    });

    test('symbols and special characters are stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value(r'1$2#3@4!5'),
      );
      expect(result.text, '12345');
    });

    test('input with only forbidden characters becomes empty', () {
      final result = formatter.formatEditUpdate(
        _value(''),
        _value('abc.,- '),
      );
      expect(result.text, '');
      expect(result.selection.baseOffset, 0);
    });

    test('composing range is cleared', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('123', composing: const TextRange(start: 0, end: 3)),
      );
      expect(result.composing, TextRange.empty);
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
  // DECIMAL WITH DOT MODE
  // ============================================================

  group('NumbersTextInputFormatter.decimalWithDot', () {
    final formatter = NumbersTextInputFormatter.decimalWithDot;

    test('empty input stays empty', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value(''));
      expect(result.text, '');
    });

    test('plain digits are kept', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('12345'),
      );
      expect(result.text, '12345');
    });

    test('dot is kept', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1.5'),
      );
      expect(result.text, '1.5');
    });

    test('comma is converted to dot', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1,5'),
      );
      expect(result.text, '1.5');
    });

    test('multiple commas are all converted to dots', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1,234,56'),
      );
      expect(result.text, '1.234.56');
    });

    test('mix of dots and commas — commas become dots', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1,234.56'),
      );
      expect(result.text, '1.234.56');
    });

    test('letters are stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1a2.5b'),
      );
      expect(result.text, '12.5');
    });

    test('minus sign is stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('-1.5'),
      );
      expect(result.text, '1.5');
    });

    test('spaces are stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1 . 5'),
      );
      expect(result.text, '1.5');
    });

    test('composing range is cleared', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1.5', composing: const TextRange(start: 0, end: 3)),
      );
      expect(result.composing, TextRange.empty);
    });

    test('typing comma displays as dot', () {
      final result = _typeSequence(formatter, const TextEditingValue(), '1,5');
      expect(result.text, '1.5');
    });
  });

  // ============================================================
  // DECIMAL WITH COMMA MODE
  // ============================================================

  group('NumbersTextInputFormatter.decimalWithComma', () {
    final formatter = NumbersTextInputFormatter.decimalWithComma;

    test('empty input stays empty', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value(''));
      expect(result.text, '');
    });

    test('plain digits are kept', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('12345'),
      );
      expect(result.text, '12345');
    });

    test('comma is kept', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1,5'),
      );
      expect(result.text, '1,5');
    });

    test('dot is converted to comma', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1.5'),
      );
      expect(result.text, '1,5');
    });

    test('multiple dots are all converted to commas', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1.234.56'),
      );
      expect(result.text, '1,234,56');
    });

    test('mix of dots and commas — dots become commas', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1,234.56'),
      );
      expect(result.text, '1,234,56');
    });

    test('letters are stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1a2,5b'),
      );
      expect(result.text, '12,5');
    });

    test('minus sign is stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('-1,5'),
      );
      expect(result.text, '1,5');
    });

    test('spaces are stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1 , 5'),
      );
      expect(result.text, '1,5');
    });

    test('composing range is cleared', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1,5', composing: const TextRange(start: 0, end: 3)),
      );
      expect(result.composing, TextRange.empty);
    });

    test('typing dot displays as comma', () {
      final result = _typeSequence(formatter, const TextEditingValue(), '1.5');
      expect(result.text, '1,5');
    });
  });

  // ============================================================
  // DECIMAL (LOCALE) MODE
  // ============================================================

  group('NumbersTextInputFormatter.decimal', () {
    final formatter = NumbersTextInputFormatter.decimal;
    final sep = NumbersTextInputFormatter.localeDecimalSeparator();

    test('empty input stays empty', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value(''));
      expect(result.text, '');
    });

    test('plain digits are kept', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('12345'),
      );
      expect(result.text, '12345');
    });

    test('dots and commas collapse to the locale decimal separator', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1.234,56'),
      );
      expect(result.text, '1${sep}234${sep}56');
    });

    test('typing a dot becomes the locale separator', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1.5'),
      );
      expect(result.text, '1${sep}5');
    });

    test('typing a comma becomes the locale separator', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1,5'),
      );
      expect(result.text, '1${sep}5');
    });

    test('letters are stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1a2.5b'),
      );
      expect(result.text, '12${sep}5');
    });

    test('minus sign is stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('-1.5'),
      );
      expect(result.text, '1${sep}5');
    });

    test('composing range is cleared', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1.5', composing: const TextRange(start: 0, end: 3)),
      );
      expect(result.composing, TextRange.empty);
    });
  });

  // ============================================================
  // STATIC INSTANCE IDENTITY
  // ============================================================

  group('Static instances', () {
    test('integer is a singleton instance', () {
      expect(
        identical(NumbersTextInputFormatter.integer, NumbersTextInputFormatter.integer),
        isTrue,
      );
    });

    test('decimal is a singleton instance', () {
      expect(
        identical(NumbersTextInputFormatter.decimal, NumbersTextInputFormatter.decimal),
        isTrue,
      );
    });

    test('decimalWithDot is a singleton instance', () {
      expect(
        identical(
          NumbersTextInputFormatter.decimalWithDot,
          NumbersTextInputFormatter.decimalWithDot,
        ),
        isTrue,
      );
    });

    test('decimalWithComma is a singleton instance', () {
      expect(
        identical(
          NumbersTextInputFormatter.decimalWithComma,
          NumbersTextInputFormatter.decimalWithComma,
        ),
        isTrue,
      );
    });

    test('different modes are not the same instance', () {
      expect(
        identical(
          NumbersTextInputFormatter.integer,
          NumbersTextInputFormatter.decimal,
        ),
        isFalse,
      );
      expect(
        identical(
          NumbersTextInputFormatter.decimalWithDot,
          NumbersTextInputFormatter.decimalWithComma,
        ),
        isFalse,
      );
    });
  });

  // ============================================================
  // CURSOR / OFFSET BEHAVIOR
  // ============================================================

  group('Cursor offset', () {
    test('integer: caret stays at end after typing valid digit', () {
      final formatter = NumbersTextInputFormatter.integer;
      final result = formatter.formatEditUpdate(
        _value('12'),
        _value('123'),
      );
      expect(result.text, '123');
      expect(result.selection.baseOffset, 3);
    });

    test('integer: caret clamped to text length when chars are stripped', () {
      final formatter = NumbersTextInputFormatter.integer;
      // User pasted "abc" at the end of "12" → newValue = "12abc" caret=5.
      // Stripped text is "12", so the caret must be clamped to <= 2.
      final result = formatter.formatEditUpdate(
        _value('12'),
        _value('12abc'),
      );
      expect(result.text, '12');
      expect(result.selection.baseOffset, lessThanOrEqualTo(2));
    });

    test('integer: caret in the middle is preserved when text grows', () {
      final formatter = NumbersTextInputFormatter.integer;
      // Old "13", caret at 1. User types '2' → newValue "123" caret=2.
      final result = formatter.formatEditUpdate(
        _value('13', offset: 1),
        _value('123', offset: 2),
      );
      expect(result.text, '123');
      expect(result.selection.baseOffset, 2);
    });

    test('decimalWithDot: caret advances when typing comma (converted to dot)', () {
      final formatter = NumbersTextInputFormatter.decimalWithDot;
      // Old "1", caret at 1. User types ',' → newValue "1," caret=2.
      // After formatting: "1." with caret at 2 (newValue.text.length == result.length).
      final result = formatter.formatEditUpdate(
        _value('1', offset: 1),
        _value('1,', offset: 2),
      );
      expect(result.text, '1.');
      expect(result.selection.baseOffset, 2);
    });
  });

  // ============================================================
  // localeDecimalSeparator()
  // ============================================================

  group('localeDecimalSeparator', () {
    test('returns a non-empty string', () {
      final sep = NumbersTextInputFormatter.localeDecimalSeparator();
      expect(sep, isNotEmpty);
    });

    test('result is consistent across calls', () {
      final a = NumbersTextInputFormatter.localeDecimalSeparator();
      final b = NumbersTextInputFormatter.localeDecimalSeparator();
      expect(a, b);
    });

    test('decimal mode produces the same separator as localeDecimalSeparator', () {
      final formatter = NumbersTextInputFormatter.decimal;
      final sep = NumbersTextInputFormatter.localeDecimalSeparator();
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1.5'),
      );
      // Result is "1<sep>5".
      expect(result.text.length, 3);
      expect(result.text[0], '1');
      expect(result.text[1], sep);
      expect(result.text[2], '5');
    });
  });
}
