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

/// Convenience to build a [TextEditingValue] with a non-collapsed selection
/// from [base] to [extent].
TextEditingValue _ranged(
  String text, {
  required int base,
  required int extent,
  TextRange composing = TextRange.empty,
}) {
  return TextEditingValue(
    text: text,
    selection: TextSelection(baseOffset: base, extentOffset: extent),
    composing: composing,
  );
}

void main() {
  final formatter = AlwaysAtTheEndTextInputFormatter.instance;

  // ============================================================
  // SINGLETON
  // ============================================================

  group('Singleton', () {
    test('instance is identical across accesses', () {
      expect(
        identical(
          AlwaysAtTheEndTextInputFormatter.instance,
          AlwaysAtTheEndTextInputFormatter.instance,
        ),
        isTrue,
      );
    });
  });

  // ============================================================
  // CARET AT END (newValue is accepted)
  // ============================================================

  group('Caret at end of newValue', () {
    test('typing the first character keeps the new text', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('a'),
      );
      expect(result.text, 'a');
      expect(result.selection.baseOffset, 1);
      expect(result.selection.extentOffset, 1);
      expect(result.selection.isCollapsed, isTrue);
    });

    test('appending a character at the end keeps the new text', () {
      final result = formatter.formatEditUpdate(
        _value('hello'),
        _value('hello!'),
      );
      expect(result.text, 'hello!');
      expect(result.selection.baseOffset, 6);
    });

    test('replacing text entirely with caret at end keeps the new text', () {
      final result = formatter.formatEditUpdate(
        _value('hello'),
        _value('world'),
      );
      expect(result.text, 'world');
      expect(result.selection.baseOffset, 5);
    });

    test('deleting from the end keeps the new text', () {
      final result = formatter.formatEditUpdate(
        _value('hello'),
        _value('hell'),
      );
      expect(result.text, 'hell');
      expect(result.selection.baseOffset, 4);
    });

    test('deleting all text keeps the empty new text', () {
      final result = formatter.formatEditUpdate(
        _value('hello'),
        _value(''),
      );
      expect(result.text, '');
      expect(result.selection.baseOffset, 0);
    });

    test('empty old and empty new — produces empty with caret at 0', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value(''),
      );
      expect(result.text, '');
      expect(result.selection.baseOffset, 0);
      expect(result.selection.extentOffset, 0);
    });
  });

  // ============================================================
  // CARET NOT AT END (newValue is rejected, oldValue is restored)
  // ============================================================

  group('Caret not at end of newValue', () {
    test('caret at start of newValue reverts to oldValue', () {
      final result = formatter.formatEditUpdate(
        _value('hello'),
        _value('hello!', offset: 0),
      );
      expect(result.text, 'hello');
      expect(result.selection.baseOffset, 5);
    });

    test('caret in the middle of newValue reverts to oldValue', () {
      final result = formatter.formatEditUpdate(
        _value('hello'),
        _value('heXllo', offset: 3),
      );
      expect(result.text, 'hello');
      expect(result.selection.baseOffset, 5);
    });

    test('caret one char before end of newValue reverts to oldValue', () {
      final result = formatter.formatEditUpdate(
        _value('hello'),
        _value('helloX', offset: 5),
      );
      expect(result.text, 'hello');
      expect(result.selection.baseOffset, 5);
    });

    test('non-collapsed selection (full text) reverts to oldValue', () {
      final result = formatter.formatEditUpdate(
        _value('hello'),
        _ranged('helloX', base: 0, extent: 6),
      );
      expect(result.text, 'hello');
      expect(result.selection.baseOffset, 5);
      expect(result.selection.extentOffset, 5);
      expect(result.selection.isCollapsed, isTrue);
    });

    test('non-collapsed selection ending before end reverts to oldValue', () {
      final result = formatter.formatEditUpdate(
        _value('hello'),
        _ranged('helloX', base: 2, extent: 4),
      );
      expect(result.text, 'hello');
      expect(result.selection.baseOffset, 5);
    });

    test('selection where base is at end but extent is not — reverts', () {
      final result = formatter.formatEditUpdate(
        _value('hello'),
        _ranged('helloX', base: 6, extent: 3),
      );
      expect(result.text, 'hello');
      expect(result.selection.baseOffset, 5);
    });

    test('reverting from empty oldValue produces empty result', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('abc', offset: 1),
      );
      expect(result.text, '');
      expect(result.selection.baseOffset, 0);
    });

    test('caret at -1 in newValue is treated as not-at-end and reverts', () {
      final result = formatter.formatEditUpdate(
        _value('hello'),
        const TextEditingValue(text: 'helloX'),
      );
      expect(result.text, 'hello');
      expect(result.selection.baseOffset, 5);
    });
  });

  // ============================================================
  // RESULT ALWAYS HAS COLLAPSED CARET AT END
  // ============================================================

  group('Result selection invariants', () {
    test('selection is always collapsed at end when accepting newValue', () {
      final result = formatter.formatEditUpdate(
        _value('a'),
        _value('abc'),
      );
      expect(result.selection.isCollapsed, isTrue);
      expect(result.selection.baseOffset, result.text.length);
    });

    test('selection is always collapsed at end when reverting', () {
      final result = formatter.formatEditUpdate(
        _value('hello', offset: 2),
        _value('hello!', offset: 0),
      );
      // Reverted to oldValue's text, but caret is forced to end of that text.
      expect(result.text, 'hello');
      expect(result.selection.isCollapsed, isTrue);
      expect(result.selection.baseOffset, 5);
    });

    test('selection is collapsed at 0 for empty result', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value(''),
      );
      expect(result.selection.isCollapsed, isTrue);
      expect(result.selection.baseOffset, 0);
    });
  });

  // ============================================================
  // COMPOSING RANGE
  // ============================================================

  group('Composing range', () {
    test('composing is cleared when accepting newValue', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('abc', composing: const TextRange(start: 0, end: 3)),
      );
      expect(result.text, 'abc');
      expect(result.composing, TextRange.empty);
    });

    test('composing is cleared when reverting to oldValue', () {
      final result = formatter.formatEditUpdate(
        _value('hello', composing: const TextRange(start: 0, end: 5)),
        _value('helloX', offset: 3),
      );
      expect(result.text, 'hello');
      expect(result.composing, TextRange.empty);
    });

    test('composing is cleared even when both old and new have empty composing', () {
      final result = formatter.formatEditUpdate(
        _value('a'),
        _value('ab'),
      );
      expect(result.composing, TextRange.empty);
    });
  });

  // ============================================================
  // UNICODE / EMOJI
  // ============================================================

  group('Unicode handling', () {
    test('appending an emoji at the end is accepted', () {
      // The emoji "😀" is 2 UTF-16 code units, so caret at length=2 is fine.
      final result = formatter.formatEditUpdate(
        _value(''),
        _value('😀'),
      );
      expect(result.text, '😀');
      expect(result.selection.baseOffset, '😀'.length);
    });

    test('caret in the middle of an emoji-bearing string reverts', () {
      final result = formatter.formatEditUpdate(
        _value('hi'),
        _value('hi😀', offset: 2),
      );
      expect(result.text, 'hi');
      expect(result.selection.baseOffset, 2);
    });

    test('multi-byte chars: caret at end (in code units) is accepted', () {
      final text = 'café';
      final result = formatter.formatEditUpdate(
        _value('caf'),
        _value(text),
      );
      expect(result.text, text);
      expect(result.selection.baseOffset, text.length);
    });
  });

  // ============================================================
  // SIMULATED TYPING SEQUENCE
  // ============================================================

  group('Simulated typing', () {
    test('typing characters one by one at the end always keeps them', () {
      var current = const TextEditingValue();
      for (final ch in 'hello'.split('')) {
        final next = _value(current.text + ch);
        current = formatter.formatEditUpdate(current, next);
      }
      expect(current.text, 'hello');
      expect(current.selection.baseOffset, 5);
    });

    test('typing in the middle is silently rejected and caret jumps to end', () {
      // Start with "abc", caret at end.
      var current = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('abc'),
      );
      // User moves caret to position 1 and types 'X' → newValue = "aXbc", caret=2.
      // Caret is not at end (length=4), so the change must be rejected.
      final next = _value('aXbc', offset: 2);
      current = formatter.formatEditUpdate(current, next);

      expect(current.text, 'abc');
      expect(current.selection.baseOffset, 3);
      expect(current.selection.isCollapsed, isTrue);
    });
  });
}
