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

/// Convenience to build a [TextEditingValue] with a non-collapsed selection.
TextEditingValue _valueWithSelection(
  String text, {
  required int baseOffset,
  required int extentOffset,
  TextRange composing = TextRange.empty,
}) {
  return TextEditingValue(
    text: text,
    selection: TextSelection(
      baseOffset: baseOffset,
      extentOffset: extentOffset,
    ),
    composing: composing,
  );
}

void main() {
  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  group('Constructor', () {
    test('accepts null', () {
      expect(StringDotLengthLimiterTextInputFormatter(null).maxLength, isNull);
    });

    test('accepts -1 (no limit)', () {
      expect(StringDotLengthLimiterTextInputFormatter(-1).maxLength, -1);
    });

    test('accepts a positive limit', () {
      expect(StringDotLengthLimiterTextInputFormatter(1).maxLength, 1);
      expect(StringDotLengthLimiterTextInputFormatter(10).maxLength, 10);
      expect(StringDotLengthLimiterTextInputFormatter(1000).maxLength, 1000);
    });

    test('asserts on zero', () {
      expect(
        () => StringDotLengthLimiterTextInputFormatter(0),
        throwsAssertionError,
      );
    });

    test('asserts on negative values other than -1', () {
      expect(
        () => StringDotLengthLimiterTextInputFormatter(-2),
        throwsAssertionError,
      );
      expect(
        () => StringDotLengthLimiterTextInputFormatter(-100),
        throwsAssertionError,
      );
    });
  });

  // ============================================================
  // truncateString — STATIC HELPER
  // ============================================================

  group('truncateString', () {
    test('returns the value unchanged when shorter than the limit', () {
      expect(
        StringDotLengthLimiterTextInputFormatter.truncateString('abc', 10),
        'abc',
      );
    });

    test('returns the value unchanged when exactly at the limit', () {
      expect(
        StringDotLengthLimiterTextInputFormatter.truncateString('abcde', 5),
        'abcde',
      );
    });

    test('returns empty when given empty', () {
      expect(
        StringDotLengthLimiterTextInputFormatter.truncateString('', 5),
        '',
      );
    });

    test('truncates plain ASCII to the limit', () {
      expect(
        StringDotLengthLimiterTextInputFormatter.truncateString('abcdef', 3),
        'abc',
      );
    });

    test('truncates to 1 character when the string is plain ASCII', () {
      expect(
        StringDotLengthLimiterTextInputFormatter.truncateString('abcdef', 1),
        'a',
      );
    });

    test('does not split a 2-codeunit emoji in half', () {
      // '😀' is one grapheme but String.length == 2.
      // With maxLength=2 the emoji fits exactly.
      expect(
        StringDotLengthLimiterTextInputFormatter.truncateString('😀ab', 2),
        '😀',
      );
    });

    test('drops a 2-codeunit emoji rather than splitting it', () {
      // With maxLength=1 the emoji does not fit, and once a grapheme is
      // skipped, the running length already exceeds the limit, so no
      // subsequent characters are added either.
      expect(
        StringDotLengthLimiterTextInputFormatter.truncateString('😀ab', 1),
        '',
      );
    });

    test('counts emoji using String.length, not user-perceived characters', () {
      // '😀😀😀' has 3 graphemes but String.length == 6.
      // With maxLength=4, only 2 emojis fit (length 2+2=4).
      expect(
        StringDotLengthLimiterTextInputFormatter.truncateString('😀😀😀', 4),
        '😀😀',
      );
    });

    test('does not split a flag emoji (4 codeunits) in half', () {
      // '🇧🇷' is one grapheme made of 2 regional indicator code points,
      // so String.length == 4. With maxLength=3 it cannot fit at all.
      expect(
        StringDotLengthLimiterTextInputFormatter.truncateString('🇧🇷abc', 3),
        '',
      );
    });

    test('keeps the flag emoji whole when it fits exactly', () {
      expect(
        StringDotLengthLimiterTextInputFormatter.truncateString('🇧🇷abc', 4),
        '🇧🇷',
      );
    });

    test('keeps the flag emoji and trailing chars that fit', () {
      expect(
        StringDotLengthLimiterTextInputFormatter.truncateString('🇧🇷abc', 6),
        '🇧🇷ab',
      );
    });
  });

  // ============================================================
  // truncate — STATIC HELPER
  // ============================================================

  group('truncate', () {
    test('returns the value unchanged when shorter than the limit', () {
      final value = _value('abc', offset: 2);
      final result = StringDotLengthLimiterTextInputFormatter.truncate(value, 10);
      expect(result, value);
    });

    test('returns the value unchanged when exactly at the limit', () {
      final value = _value('abcde', offset: 3);
      final result = StringDotLengthLimiterTextInputFormatter.truncate(value, 5);
      expect(result, value);
    });

    test('truncates the text and clamps a collapsed caret', () {
      final result = StringDotLengthLimiterTextInputFormatter.truncate(
        _value('abcdef', offset: 6),
        3,
      );
      expect(result.text, 'abc');
      expect(result.selection.baseOffset, 3);
      expect(result.selection.extentOffset, 3);
    });

    test('preserves a caret that already lies inside the truncated range', () {
      final result = StringDotLengthLimiterTextInputFormatter.truncate(
        _value('abcdef', offset: 1),
        3,
      );
      expect(result.text, 'abc');
      expect(result.selection.baseOffset, 1);
      expect(result.selection.extentOffset, 1);
    });

    test('clamps a non-collapsed selection to the truncated length', () {
      final result = StringDotLengthLimiterTextInputFormatter.truncate(
        _valueWithSelection('abcdef', baseOffset: 1, extentOffset: 5),
        3,
      );
      expect(result.text, 'abc');
      expect(result.selection.baseOffset, 1);
      expect(result.selection.extentOffset, 3);
    });

    test('clears composing range when it would be entirely outside the truncated text', () {
      final result = StringDotLengthLimiterTextInputFormatter.truncate(
        _value('abcdef', composing: const TextRange(start: 4, end: 6)),
        3,
      );
      expect(result.text, 'abc');
      expect(result.composing, TextRange.empty);
    });

    test('clamps composing range when it overlaps the truncated text', () {
      final result = StringDotLengthLimiterTextInputFormatter.truncate(
        _value('abcdef', composing: const TextRange(start: 1, end: 5)),
        3,
      );
      expect(result.text, 'abc');
      expect(result.composing, const TextRange(start: 1, end: 3));
    });

    test('clears composing range when it is collapsed', () {
      // A collapsed composing range never survives truncation, by design.
      final result = StringDotLengthLimiterTextInputFormatter.truncate(
        _value('abcdef', composing: const TextRange(start: 1, end: 1)),
        3,
      );
      expect(result.text, 'abc');
      expect(result.composing, TextRange.empty);
    });

    test('truncates without splitting a 2-codeunit emoji', () {
      final result = StringDotLengthLimiterTextInputFormatter.truncate(
        _value('😀ab', offset: 4),
        3,
      );
      // '😀' is length 2, then 'a' makes 3 — so '😀a' fits.
      expect(result.text, '😀a');
      expect(result.selection.baseOffset, 3);
      expect(result.selection.extentOffset, 3);
    });
  });

  // ============================================================
  // formatEditUpdate — NO LIMIT
  // ============================================================

  group('formatEditUpdate with no limit', () {
    test('null maxLength returns newValue unchanged', () {
      final formatter = StringDotLengthLimiterTextInputFormatter(null);
      final newValue = _value('a very long string here', offset: 5);
      final result = formatter.formatEditUpdate(const TextEditingValue(), newValue);
      expect(result, newValue);
    });

    test('-1 maxLength returns newValue unchanged', () {
      final formatter = StringDotLengthLimiterTextInputFormatter(-1);
      final newValue = _value('a very long string here', offset: 5);
      final result = formatter.formatEditUpdate(const TextEditingValue(), newValue);
      expect(result, newValue);
    });

    test('null maxLength preserves composing range', () {
      final formatter = StringDotLengthLimiterTextInputFormatter(null);
      final newValue = _value(
        'hello world',
        composing: const TextRange(start: 0, end: 5),
      );
      final result = formatter.formatEditUpdate(const TextEditingValue(), newValue);
      expect(result.composing, const TextRange(start: 0, end: 5));
    });
  });

  // ============================================================
  // formatEditUpdate — TEXT WITHIN LIMIT
  // ============================================================

  group('formatEditUpdate when text fits within the limit', () {
    final formatter = StringDotLengthLimiterTextInputFormatter(5);

    test('empty text passes through', () {
      final newValue = _value('');
      final result = formatter.formatEditUpdate(const TextEditingValue(), newValue);
      expect(result, newValue);
    });

    test('text shorter than the limit passes through', () {
      final newValue = _value('abc', offset: 2);
      final result = formatter.formatEditUpdate(const TextEditingValue(), newValue);
      expect(result, newValue);
    });

    test('text exactly at the limit passes through', () {
      final newValue = _value('abcde', offset: 5);
      final result = formatter.formatEditUpdate(const TextEditingValue(), newValue);
      expect(result, newValue);
    });

    test('preserves composing range when text fits', () {
      final newValue = _value(
        'abcd',
        composing: const TextRange(start: 1, end: 3),
      );
      final result = formatter.formatEditUpdate(const TextEditingValue(), newValue);
      expect(result.composing, const TextRange(start: 1, end: 3));
    });
  });

  // ============================================================
  // formatEditUpdate — KEEPS oldValue WHEN AT MAX
  // ============================================================

  group('formatEditUpdate keeps oldValue at the cap', () {
    final formatter = StringDotLengthLimiterTextInputFormatter(5);

    test('when oldValue is exactly at max and caret is collapsed, blocks the edit', () {
      final oldValue = _value('abcde', offset: 5);
      final newValue = _value('abcdex', offset: 6);
      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result, oldValue);
      expect(result.text, 'abcde');
      expect(result.selection.baseOffset, 5);
    });

    test('blocking works regardless of where the user inserted', () {
      final oldValue = _value('abcde', offset: 2);
      // User typed 'X' in the middle.
      final newValue = _value('abXcde', offset: 3);
      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result, oldValue);
    });

    test('does NOT keep oldValue when oldValue had a non-collapsed selection', () {
      // The old text was at the cap (length 5), but the user had a 2-char
      // selection, meaning a typed character is *replacing* — the new text
      // should be truncated, not blocked entirely.
      final oldValue = _valueWithSelection('abcde', baseOffset: 1, extentOffset: 3);
      // After replacing 'bc' with 'XY' we get 'aXYde' (still length 5 — fits).
      // To force the truncate path, simulate a paste that overflows.
      final newValue = _value('aXYZWde', offset: 5);
      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, 'aXYZW');
      expect(result.text.length, 5);
    });

    test('does NOT keep oldValue when oldValue is shorter than max', () {
      // Pasting a string longer than the cap should be truncated, even when
      // the user starts from a shorter text.
      final oldValue = _value('abc', offset: 3);
      final newValue = _value('abcdefghij', offset: 10);
      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, 'abcde');
      expect(result.text.length, 5);
    });
  });

  // ============================================================
  // formatEditUpdate — TRUNCATION
  // ============================================================

  group('formatEditUpdate truncates overlong text', () {
    final formatter = StringDotLengthLimiterTextInputFormatter(5);

    test('truncates ASCII to the limit', () {
      final result = formatter.formatEditUpdate(
        _value('a'),
        _value('abcdefgh', offset: 8),
      );
      expect(result.text, 'abcde');
      expect(result.selection.baseOffset, 5);
    });

    test('truncated result is exactly maxLength characters', () {
      final result = formatter.formatEditUpdate(
        _value(''),
        _value('1234567890', offset: 10),
      );
      expect(result.text.length, 5);
    });

    test('truncates without splitting an emoji', () {
      // '😀😀😀' has String.length == 6; truncated to 5 it should drop the
      // last emoji entirely (length 4 result), since splitting would corrupt
      // the surrogate pair.
      final result = formatter.formatEditUpdate(
        _value(''),
        _value('😀😀😀', offset: 6),
      );
      expect(result.text, '😀😀');
      expect(result.text.length, 4);
    });

    test('truncates without splitting a flag emoji', () {
      // '🇧🇷abc' is length 7; truncated to 5 keeps the flag (length 4) plus 'a'.
      final result = formatter.formatEditUpdate(
        _value(''),
        _value('🇧🇷abc', offset: 7),
      );
      expect(result.text, '🇧🇷a');
      expect(result.text.length, 5);
    });

    test('clamps caret that was past the cap into the truncated text', () {
      final result = formatter.formatEditUpdate(
        _value('abc', offset: 3),
        _value('abcdefgh', offset: 8),
      );
      expect(result.text, 'abcde');
      expect(result.selection.baseOffset, 5);
      expect(result.selection.extentOffset, 5);
    });

    test('preserves caret when it lies inside the truncated text', () {
      final result = formatter.formatEditUpdate(
        _value('abc', offset: 3),
        _value('abcdefgh', offset: 2),
      );
      expect(result.text, 'abcde');
      expect(result.selection.baseOffset, 2);
      expect(result.selection.extentOffset, 2);
    });

    test('clamps a non-collapsed selection that extends past the cap', () {
      final result = formatter.formatEditUpdate(
        _value(''),
        _valueWithSelection('abcdefgh', baseOffset: 2, extentOffset: 7),
      );
      expect(result.text, 'abcde');
      expect(result.selection.baseOffset, 2);
      expect(result.selection.extentOffset, 5);
    });

    test('clears composing range that lies past the cap', () {
      final result = formatter.formatEditUpdate(
        _value(''),
        _value('abcdefgh', composing: const TextRange(start: 6, end: 8)),
      );
      expect(result.text, 'abcde');
      expect(result.composing, TextRange.empty);
    });

    test('clamps composing range that overlaps the cap', () {
      final result = formatter.formatEditUpdate(
        _value(''),
        _value('abcdefgh', composing: const TextRange(start: 2, end: 7)),
      );
      expect(result.text, 'abcde');
      expect(result.composing, const TextRange(start: 2, end: 5));
    });
  });

  // ============================================================
  // formatEditUpdate — LIMIT OF 1
  // ============================================================

  group('formatEditUpdate with maxLength = 1', () {
    final formatter = StringDotLengthLimiterTextInputFormatter(1);

    test('one ASCII char passes through', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('a'),
      );
      expect(result.text, 'a');
    });

    test('two ASCII chars are truncated to one', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('ab', offset: 2),
      );
      expect(result.text, 'a');
    });

    test('a single 2-codeunit emoji yields empty (cannot fit, cannot split)', () {
      // Documents the actual behavior: a single emoji of String.length 2 with
      // maxLength=1 is not splittable, so the formatter drops it entirely.
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('😀', offset: 2),
      );
      expect(result.text, '');
    });
  });

  // ============================================================
  // INTEGRATION: SEQUENCE OF EDITS
  // ============================================================

  group('Sequence of edits', () {
    final formatter = StringDotLengthLimiterTextInputFormatter(3);

    test('typing past the cap repeatedly keeps text at the cap', () {
      var current = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('a'),
      );
      current = formatter.formatEditUpdate(current, _value('ab', offset: 2));
      current = formatter.formatEditUpdate(current, _value('abc', offset: 3));
      // Now at the cap; further typing should be blocked (oldValue path).
      current = formatter.formatEditUpdate(current, _value('abcd', offset: 4));
      expect(current.text, 'abc');
      current = formatter.formatEditUpdate(current, _value('abcde', offset: 5));
      expect(current.text, 'abc');
      expect(current.selection.baseOffset, 3);
    });

    test('pasting a long string truncates it to the cap', () {
      final current = formatter.formatEditUpdate(
        _value(''),
        _value('hello world', offset: 11),
      );
      expect(current.text, 'hel');
      expect(current.selection.baseOffset, 3);
    });
  });
}
