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

void main() {
  // ============================================================
  // NULL CAPITALIZE
  // ============================================================

  group('CapitalizationTextInputFormatter(null)', () {
    final formatter = CapitalizationTextInputFormatter(null);

    test('returns the new value unchanged', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('hello WORLD'),
      );
      expect(result.text, 'hello WORLD');
    });

    test('preserves the selection unchanged', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('abc', offset: 1),
      );
      expect(result.selection.baseOffset, 1);
    });

    test('preserves the composing range unchanged', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('abc', composing: const TextRange(start: 0, end: 3)),
      );
      expect(result.composing, const TextRange(start: 0, end: 3));
    });

    test('empty input stays empty', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value(''));
      expect(result.text, '');
    });
  });

  // ============================================================
  // firstLetterUpper
  // ============================================================

  group('Capitalize.firstLetterUpper', () {
    final formatter = CapitalizationTextInputFormatter.firstLetterUppercase;

    test('static instance has the correct mode', () {
      expect(formatter.capitalize, Capitalize.firstLetterUpper);
    });

    test('empty input stays empty', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value(''));
      expect(result.text, '');
    });

    test('lowercases nothing else — only first letter changes', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('hello WORLD'),
      );
      expect(result.text, 'Hello WORLD');
    });

    test('already capitalized stays the same', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('Hello'),
      );
      expect(result.text, 'Hello');
    });

    test('single character is uppercased', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('a'),
      );
      expect(result.text, 'A');
    });

    test('leading whitespace is preserved (whitespace has no upper form)', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value(' hello'),
      );
      expect(result.text, ' hello');
    });

    test('leading non-letter is preserved unchanged', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1abc'),
      );
      expect(result.text, '1abc');
    });

    test('handles multi-codeunit grapheme as a single character', () {
      // Flag emojis are made of multiple codeunits; the formatter should not
      // split them when uppercasing the first character.
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('🇧🇷abc'),
      );
      expect(result.text, '🇧🇷abc');
    });

    test('preserves the rest of the string verbatim', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('aBcDeF'),
      );
      expect(result.text, 'ABcDeF');
    });
  });

  // ============================================================
  // uppercase
  // ============================================================

  group('Capitalize.uppercase', () {
    final formatter = CapitalizationTextInputFormatter.uppercase;

    test('static instance has the correct mode', () {
      expect(formatter.capitalize, Capitalize.uppercase);
    });

    test('empty input stays empty', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value(''));
      expect(result.text, '');
    });

    test('all lowercase becomes uppercase', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('hello world'),
      );
      expect(result.text, 'HELLO WORLD');
    });

    test('mixed case becomes uppercase', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('HeLLo'),
      );
      expect(result.text, 'HELLO');
    });

    test('already uppercase stays the same', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('HELLO'),
      );
      expect(result.text, 'HELLO');
    });

    test('digits and symbols are preserved unchanged', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('a1!b2@'),
      );
      expect(result.text, 'A1!B2@');
    });
  });

  // ============================================================
  // lowercase
  // ============================================================

  group('Capitalize.lowercase', () {
    final formatter = CapitalizationTextInputFormatter.lowercase;

    test('static instance has the correct mode', () {
      expect(formatter.capitalize, Capitalize.lowercase);
    });

    test('empty input stays empty', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value(''));
      expect(result.text, '');
    });

    test('all uppercase becomes lowercase', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('HELLO WORLD'),
      );
      expect(result.text, 'hello world');
    });

    test('mixed case becomes lowercase', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('HeLLo'),
      );
      expect(result.text, 'hello');
    });

    test('already lowercase stays the same', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('hello'),
      );
      expect(result.text, 'hello');
    });

    test('digits and symbols are preserved unchanged', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('A1!B2@'),
      );
      expect(result.text, 'a1!b2@');
    });
  });

  // ============================================================
  // title
  // ============================================================

  group('Capitalize.title', () {
    final formatter = CapitalizationTextInputFormatter.title;

    test('static instance has the correct mode', () {
      expect(formatter.capitalize, Capitalize.title);
    });

    test('empty input stays empty', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value(''));
      expect(result.text, '');
    });

    test('whitespace-only input becomes empty', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('   '),
      );
      expect(result.text, '');
    });

    test('single word is capitalized', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('hello'),
      );
      expect(result.text, 'Hello');
    });

    test('two words: both capitalized', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('hello world'),
      );
      expect(result.text, 'Hello World');
    });

    test('mid-sentence small words stay lowercase', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('the lord of the rings'),
      );
      expect(result.text, 'The Lord of the Rings');
    });

    test('first word always capitalized, even when it is a small word', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('the cat'),
      );
      expect(result.text, 'The Cat');
    });

    test('last word always capitalized, even when it is a small word', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('what is this for'),
      );
      expect(result.text, 'What Is This For');
    });

    test('mixed case input is normalized', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('hELLo WoRLD'),
      );
      expect(result.text, 'Hello World');
    });

    test('hyphenated words capitalize each part', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('mary-jane is here'),
      );
      expect(result.text, 'Mary-Jane Is Here');
    });

    test('multiple spaces between words are collapsed to single space', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('hello    world'),
      );
      expect(result.text, 'Hello World');
    });

    test('leading and trailing whitespace is trimmed', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('  hello world  '),
      );
      expect(result.text, 'Hello World');
    });

    test('all small words list — middle ones stay lowercase', () {
      // This sentence has small words in the middle.
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('jack and jill went up the hill'),
      );
      expect(result.text, 'Jack and Jill Went up the Hill');
    });

    test('preposition at end is capitalized', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('something to look up'),
      );
      expect(result.text, 'Something to Look Up');
    });

    test('input with digits keeps digits unchanged', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('chapter 1 of 2'),
      );
      expect(result.text, 'Chapter 1 of 2');
    });
  });

  // ============================================================
  // STATIC INSTANCES
  // ============================================================

  group('Static instances', () {
    test('firstLetterUppercase is a stable instance', () {
      expect(
        identical(
          CapitalizationTextInputFormatter.firstLetterUppercase,
          CapitalizationTextInputFormatter.firstLetterUppercase,
        ),
        isTrue,
      );
    });

    test('uppercase is a stable instance', () {
      expect(
        identical(
          CapitalizationTextInputFormatter.uppercase,
          CapitalizationTextInputFormatter.uppercase,
        ),
        isTrue,
      );
    });

    test('lowercase is a stable instance', () {
      expect(
        identical(
          CapitalizationTextInputFormatter.lowercase,
          CapitalizationTextInputFormatter.lowercase,
        ),
        isTrue,
      );
    });

    test('title is a stable instance', () {
      expect(
        identical(
          CapitalizationTextInputFormatter.title,
          CapitalizationTextInputFormatter.title,
        ),
        isTrue,
      );
    });

    test('different modes are not the same instance', () {
      expect(
        identical(
          CapitalizationTextInputFormatter.uppercase,
          CapitalizationTextInputFormatter.lowercase,
        ),
        isFalse,
      );
    });
  });

  // ============================================================
  // SELECTION / COMPOSING PRESERVATION
  // ============================================================

  group('Selection and composing range', () {
    test('uppercase preserves the selection offset', () {
      final result = CapitalizationTextInputFormatter.uppercase.formatEditUpdate(
        const TextEditingValue(),
        _value('hello', offset: 3),
      );
      expect(result.text, 'HELLO');
      expect(result.selection.baseOffset, 3);
    });

    test('lowercase preserves the composing range', () {
      final result = CapitalizationTextInputFormatter.lowercase.formatEditUpdate(
        const TextEditingValue(),
        _value('HELLO', composing: const TextRange(start: 0, end: 5)),
      );
      expect(result.text, 'hello');
      expect(result.composing, const TextRange(start: 0, end: 5));
    });

    test('firstLetterUppercase preserves the selection offset', () {
      final result =
          CapitalizationTextInputFormatter.firstLetterUppercase.formatEditUpdate(
        const TextEditingValue(),
        _value('hello', offset: 5),
      );
      expect(result.text, 'Hello');
      expect(result.selection.baseOffset, 5);
    });
  });
}
