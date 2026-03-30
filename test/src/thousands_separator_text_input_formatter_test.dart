import 'package:assorted_layout_widgets/src/thousands_separator_text_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Convenience to build a [TextEditingValue] with a collapsed caret at [offset].
TextEditingValue _value(String text, {int? offset}) {
  offset ??= text.length;
  return TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: offset),
  );
}

/// Convenience to build a [TextEditingValue] with a selection range.
TextEditingValue _selected(String text, {required int base, required int extent}) {
  return TextEditingValue(
    text: text,
    selection: TextSelection(baseOffset: base, extentOffset: extent),
  );
}

/// Simulates typing [chars] one character at a time into a field that already
/// contains [initial], using the given [formatter]. Returns the final value.
TextEditingValue _typeSequence(
  ThousandsSeparatorTextInputFormatter formatter,
  TextEditingValue initial,
  String chars,
) {
  var current = formatter.formatEditUpdate(const TextEditingValue(), initial);
  for (int i = 0; i < chars.length; i++) {
    final caret = current.selection.extentOffset;
    final newText =
        current.text.substring(0, caret) + chars[i] + current.text.substring(caret);
    final newVal = _value(newText, offset: caret + 1);
    current = formatter.formatEditUpdate(current, newVal);
  }
  return current;
}

void main() {
  late ThousandsSeparatorTextInputFormatter formatter;

  setUp(() {
    formatter = ThousandsSeparatorTextInputFormatter();
  });

  // ============================================================
  // CONSTRUCTION
  // ============================================================

  group('Construction', () {
    test('default separators', () {
      // No error thrown, default group=, decimal=.
      final f = ThousandsSeparatorTextInputFormatter();
      final result = f.formatEditUpdate(const TextEditingValue(), _value('1234'));
      expect(result.text, '1,234');
    });

    test('custom separators', () {
      final f = ThousandsSeparatorTextInputFormatter(
        groupSeparator: '.',
        decimalSeparator: ',',
      );
      final result = f.formatEditUpdate(const TextEditingValue(), _value('1234567,89'));
      expect(result.text, '1.234.567,89');
    });
  });

  // ============================================================
  // BASIC FORMATTING — integers
  // ============================================================

  group('Integer formatting', () {
    test('empty input stays empty', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value(''));
      expect(result.text, '');
      expect(result.selection.baseOffset, 0);
    });

    test('single digit', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('5'));
      expect(result.text, '5');
    });

    test('two digits', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('42'));
      expect(result.text, '42');
    });

    test('three digits — no separator', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('999'));
      expect(result.text, '999');
    });

    test('four digits — one separator', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('1234'));
      expect(result.text, '1,234');
    });

    test('six digits — one separator', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('123456'),
      );
      expect(result.text, '123,456');
    });

    test('seven digits — two separators', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1234567'),
      );
      expect(result.text, '1,234,567');
    });

    test('nine digits — two separators', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('123456789'),
      );
      expect(result.text, '123,456,789');
    });

    test('ten digits — three separators', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1234567890'),
      );
      expect(result.text, '1,234,567,890');
    });
  });

  // ============================================================
  // BASIC FORMATTING — decimals
  // ============================================================

  group('Decimal formatting', () {
    test('decimal with fractional part', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('12345.67'),
      );
      expect(result.text, '12,345.67');
    });

    test('trailing decimal separator preserved', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('123.'));
      expect(result.text, '123.');
    });

    test('trailing zeros in fractional part preserved', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('12345.60'),
      );
      expect(result.text, '12,345.60');
    });

    test('leading dot normalized to 0.', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('.5'));
      expect(result.text, '0.5');
    });

    test('lone dot normalized to 0.', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('.'));
      expect(result.text, '0.');
    });

    test('multiple decimal separators — only first kept', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('12.34.56'),
      );
      // First dot at index 2 is the decimal, second dot is ignored -> raw "12.3456"
      expect(result.text, '12.3456');
    });

    test('fractional part left unformatted', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1.123456789'),
      );
      expect(result.text, '1.123456789');
    });

    test('large integer part with decimals', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1234567.89'),
      );
      expect(result.text, '1,234,567.89');
    });
  });

  // ============================================================
  // SANITIZATION — strips non-numeric characters
  // ============================================================

  group('Sanitization', () {
    test('letters are stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('12abc34'),
      );
      expect(result.text, '1,234');
    });

    test('spaces are stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1 234'),
      );
      expect(result.text, '1,234');
    });

    test('existing group separators in input are stripped and rebuilt', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1,234,567'),
      );
      expect(result.text, '1,234,567');
    });

    test('special characters stripped', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value(r'$1,000.50!'),
      );
      expect(result.text, '1,000.50');
    });

    test('only non-numeric input becomes empty', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('abc'));
      expect(result.text, '');
    });
  });

  // ============================================================
  // CARET PLACEMENT — typing at the end
  // ============================================================

  group('Caret placement — typing at end', () {
    test('caret stays at end after formatting', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('1234'));
      expect(result.text, '1,234');
      expect(result.selection.baseOffset, 5); // after '4'
    });

    test('caret stays at end for decimal', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('12345.6'),
      );
      expect(result.text, '12,345.6');
      expect(result.selection.baseOffset, 8);
    });

    test('caret adjusts when leading zero is added', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('.5'));
      expect(result.text, '0.5');
      expect(result.selection.baseOffset, 3);
    });
  });

  // ============================================================
  // CARET PLACEMENT — typing in the middle
  // ============================================================

  group('Caret placement — typing in the middle', () {
    test('insert digit in the middle of integer', () {
      // Old: "123,456" with caret after '1' (offset 1)
      // User types '5' -> "1523,456" but raw input would be "1523456"
      final old = _value('123,456', offset: 1);
      final edited = _value('1523,456', offset: 2);
      final result = formatter.formatEditUpdate(old, edited);
      expect(result.text, '1,523,456');
      // Caret should be after the '5' we just inserted (position 3 in "1,523,456").
      expect(result.selection.baseOffset, 3);
    });

    test('insert digit before decimal point', () {
      final old = _value('12,345.67', offset: 6);
      // Insert '9' before the dot
      final edited = _value('12,3459.67', offset: 7);
      final result = formatter.formatEditUpdate(old, edited);
      expect(result.text, '123,459.67');
    });
  });

  // ============================================================
  // BACKSPACE AND DELETE near separators
  // ============================================================

  group('Backspace near separator', () {
    test('backspace on separator deletes digit to the left', () {
      // "123,456" caret after comma (offset 3) -> backspace removes comma -> "12,456"
      // The framework sends us oldValue with caret at 4, newValue with comma removed.
      final old = _value('123,456', offset: 4);
      // Backspace at offset 4 removes the comma at index 3 -> "123456"
      final newVal = _value('123456', offset: 3);
      final result = formatter.formatEditUpdate(old, newVal);
      expect(result.text, '12,456');
      // Caret should be after '2'.
      expect(result.selection.baseOffset, 2);
    });

    test('backspace in "1,234" at caret after comma deletes the 1', () {
      final old = _value('1,234', offset: 2);
      final newVal = _value('1234', offset: 1);
      final result = formatter.formatEditUpdate(old, newVal);
      // Removing '1' leaves '234' — no separator needed.
      expect(result.text, '234');
    });
  });

  group('Delete near separator', () {
    test('delete on separator deletes digit to the right', () {
      // "123,456" caret before comma (offset 3) -> delete removes comma -> "123456"
      final old = _value('123,456', offset: 3);
      final newVal = _value('123456', offset: 3);
      final result = formatter.formatEditUpdate(old, newVal);
      expect(result.text, '12,356');
      // Raw caret was at 3 (after '3'), mapped to formatted "12,356" offset 4.
      expect(result.selection.baseOffset, 4);
    });
  });

  // ============================================================
  // SELECTION (non-collapsed) handling
  // ============================================================

  group('Selection handling', () {
    test('replacing selected range with a digit', () {
      // "123,456" select "3,4" (offset 2..4) and type '9'
      final old = _selected('123,456', base: 2, extent: 4);
      final newVal = _value('129456', offset: 3);
      final result = formatter.formatEditUpdate(old, newVal);
      expect(result.text, '129,456');
    });

    test('deleting a selected range', () {
      // "123,456" select "3,45" (offset 2..5) and delete
      final old = _selected('123,456', base: 2, extent: 5);
      final newVal = _value('126', offset: 2);
      final result = formatter.formatEditUpdate(old, newVal);
      expect(result.text, '126');
    });
  });

  // ============================================================
  // PASTING
  // ============================================================

  group('Paste handling', () {
    test('paste a large number', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('9876543210'),
      );
      expect(result.text, '9,876,543,210');
    });

    test('paste with non-numeric chars is sanitized', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('USD 1,234.56'),
      );
      expect(result.text, '1,234.56');
    });

    test('paste with multiple dots keeps only first', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1.2.3.4'),
      );
      expect(result.text, '1.234');
    });
  });

  // ============================================================
  // IME COMPOSITION
  // ============================================================

  group('IME composition', () {
    test('returns newValue unchanged during active composition', () {
      final newVal = TextEditingValue(
        text: '123',
        selection: const TextSelection.collapsed(offset: 3),
        composing: const TextRange(start: 0, end: 3),
      );
      final result = formatter.formatEditUpdate(const TextEditingValue(), newVal);
      expect(result, newVal);
    });
  });

  // ============================================================
  // SEQUENTIAL TYPING SIMULATION
  // ============================================================

  group('Sequential typing', () {
    test('typing 1234567 one char at a time', () {
      final result = _typeSequence(formatter, _value(''), '1234567');
      expect(result.text, '1,234,567');
      expect(result.selection.baseOffset, 9);
    });

    test('typing 1234.56 one char at a time', () {
      final result = _typeSequence(formatter, _value(''), '1234.56');
      expect(result.text, '1,234.56');
      expect(result.selection.baseOffset, 8);
    });

    test('typing .5 one char at a time', () {
      final result = _typeSequence(formatter, _value(''), '.5');
      expect(result.text, '0.5');
      expect(result.selection.baseOffset, 3);
    });

    test('typing 0.001 one char at a time', () {
      final result = _typeSequence(formatter, _value(''), '0.001');
      expect(result.text, '0.001');
      expect(result.selection.baseOffset, 5);
    });
  });

  // ============================================================
  // EDGE CASES
  // ============================================================

  group('Edge cases', () {
    test('single zero', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('0'));
      expect(result.text, '');
    });

    test('multiple leading zeros', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('000123'),
      );
      expect(result.text, '123');
    });

    test('zero with decimal', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('0.00'));
      expect(result.text, '0.00');
    });

    test('very long integer', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('123456789012345'),
      );
      expect(result.text, '123,456,789,012,345');
    });

    test('very long fractional part', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1.000000000000000001'),
      );
      expect(result.text, '1.000000000000000001');
    });

    test('negative offset clamped', () {
      // Construct a value with a negative selection offset.
      final badVal = TextEditingValue(
        text: '123',
        selection: const TextSelection.collapsed(offset: -1),
      );
      // Should not throw — negative offset gets clamped.
      final result = formatter.formatEditUpdate(const TextEditingValue(), badVal);
      expect(result.text, '123');
    });

    test('offset beyond text length clamped', () {
      final badVal = TextEditingValue(
        text: '123',
        selection: const TextSelection.collapsed(offset: 100),
      );
      final result = formatter.formatEditUpdate(const TextEditingValue(), badVal);
      expect(result.text, '123');
      // Caret should be clamped to end.
      expect(result.selection.baseOffset, 3);
    });
  });

  // ============================================================
  // CUSTOM SEPARATORS
  // ============================================================

  group('Custom separators', () {
    test('space as group separator', () {
      final f = ThousandsSeparatorTextInputFormatter(
        groupSeparator: ' ',
        decimalSeparator: '.',
      );
      final result = f.formatEditUpdate(const TextEditingValue(), _value('1234567.89'));
      expect(result.text, '1 234 567.89');
    });

    test('dot as group separator and comma as decimal', () {
      final f = ThousandsSeparatorTextInputFormatter(
        groupSeparator: '.',
        decimalSeparator: ',',
      );
      final result = f.formatEditUpdate(const TextEditingValue(), _value('1234567,89'));
      expect(result.text, '1.234.567,89');
    });

    test('backspace near custom separator works', () {
      final f = ThousandsSeparatorTextInputFormatter(
        groupSeparator: ' ',
        decimalSeparator: '.',
      );
      final old = _value('123 456', offset: 4);
      final newVal = _value('123456', offset: 3);
      final result = f.formatEditUpdate(old, newVal);
      expect(result.text, '12 456');
    });
  });

  // ============================================================
  // COMPOSING RANGE — always empty after formatting
  // ============================================================

  group('Composing range', () {
    test('composing range is cleared after formatting', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('1234'));
      expect(result.composing, TextRange.empty);
    });
  });

  // ============================================================
  // NO-CHANGE SCENARIOS
  // ============================================================

  group('No-change scenarios', () {
    test('same old and new value with no change returns formatted', () {
      final val = _value('1,234', offset: 3);
      final result = formatter.formatEditUpdate(val, val);
      expect(result.text, '1,234');
    });
  });

  // ============================================================
  // LEADING ZEROS
  // ============================================================

  group('Leading zeros', () {
    test('"0" becomes empty', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('0'));
      expect(result.text, '');
    });

    test('"00" becomes empty', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('00'));
      expect(result.text, '');
    });

    test('"01" becomes "1"', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('01'));
      expect(result.text, '1');
    });

    test('"007" becomes "7"', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('007'));
      expect(result.text, '7');
    });

    test('"0123456" becomes "123,456"', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('0123456'),
      );
      expect(result.text, '123,456');
    });

    test('"0.5" stays "0.5"', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('0.5'));
      expect(result.text, '0.5');
    });

    test('"00.5" becomes "0.5"', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('00.5'));
      expect(result.text, '0.5');
    });

    test('"000.123" becomes "0.123"', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('000.123'),
      );
      expect(result.text, '0.123');
    });

    test('"0." stays "0."', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('0.'));
      expect(result.text, '0.');
    });

    test('"00." becomes "0."', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('00.'));
      expect(result.text, '0.');
    });

    test('"0.00" stays "0.00"', () {
      final result = formatter.formatEditUpdate(const TextEditingValue(), _value('0.00'));
      expect(result.text, '0.00');
    });

    test('typing "0" then "." then "5" produces "0.5"', () {
      final result = _typeSequence(formatter, _value(''), '0.5');
      expect(result.text, '0.5');
      expect(result.selection.baseOffset, 3);
    });

    test('typing "0" then "1" produces "1"', () {
      final result = _typeSequence(formatter, _value(''), '01');
      expect(result.text, '1');
      expect(result.selection.baseOffset, 1);
    });

    test('typing "0" alone produces empty', () {
      final result = _typeSequence(formatter, _value(''), '0');
      expect(result.text, '');
      expect(result.selection.baseOffset, 0);
    });
  });

  // ============================================================
  // ALLOWED DECIMALS
  // ============================================================

  group('allowedDecimals', () {
    test('allowedDecimals: 0 — dot is rejected', () {
      final f = ThousandsSeparatorTextInputFormatter(allowedDecimals: 0);
      final result = f.formatEditUpdate(const TextEditingValue(), _value('123.45'));
      expect(result.text, '12,345');
    });

    test('allowedDecimals: 0 — lone dot is rejected', () {
      final f = ThousandsSeparatorTextInputFormatter(allowedDecimals: 0);
      final result = f.formatEditUpdate(const TextEditingValue(), _value('.'));
      expect(result.text, '');
    });

    test('allowedDecimals: 0 — integers unaffected', () {
      final f = ThousandsSeparatorTextInputFormatter(allowedDecimals: 0);
      final result = f.formatEditUpdate(const TextEditingValue(), _value('1234567'));
      expect(result.text, '1,234,567');
    });

    test('allowedDecimals: 2 — truncates extra fractional digits', () {
      final f = ThousandsSeparatorTextInputFormatter(allowedDecimals: 2);
      final result = f.formatEditUpdate(const TextEditingValue(), _value('12345.6789'));
      expect(result.text, '12,345.67');
    });

    test('allowedDecimals: 2 — fewer digits than limit kept as-is', () {
      final f = ThousandsSeparatorTextInputFormatter(allowedDecimals: 2);
      final result = f.formatEditUpdate(const TextEditingValue(), _value('12345.6'));
      expect(result.text, '12,345.6');
    });

    test('allowedDecimals: 2 — exact limit kept as-is', () {
      final f = ThousandsSeparatorTextInputFormatter(allowedDecimals: 2);
      final result = f.formatEditUpdate(const TextEditingValue(), _value('12345.67'));
      expect(result.text, '12,345.67');
    });

    test('allowedDecimals: 2 — trailing dot preserved', () {
      final f = ThousandsSeparatorTextInputFormatter(allowedDecimals: 2);
      final result = f.formatEditUpdate(const TextEditingValue(), _value('123.'));
      expect(result.text, '123.');
    });

    test('allowedDecimals: 4 — truncates at 4', () {
      final f = ThousandsSeparatorTextInputFormatter(allowedDecimals: 4);
      final result = f.formatEditUpdate(const TextEditingValue(), _value('12.345678'));
      expect(result.text, '12.3456');
    });

    test('allowedDecimals: 1 — keeps only one fractional digit', () {
      final f = ThousandsSeparatorTextInputFormatter(allowedDecimals: 1);
      final result = f.formatEditUpdate(const TextEditingValue(), _value('99.99'));
      expect(result.text, '99.9');
    });

    test('allowedDecimals: 2 — sequential typing respects limit', () {
      final f = ThousandsSeparatorTextInputFormatter(allowedDecimals: 2);
      final result = _typeSequence(f, _value(''), '1234.5678');
      expect(result.text, '1,234.56');
      expect(result.selection.baseOffset, 8);
    });

    test('allowedDecimals: 0 — sequential typing ignores dot', () {
      final f = ThousandsSeparatorTextInputFormatter(allowedDecimals: 0);
      final result = _typeSequence(f, _value(''), '12.34');
      expect(result.text, '1,234');
    });

    test('allowedDecimals: 2 — leading dot normalized and truncated', () {
      final f = ThousandsSeparatorTextInputFormatter(allowedDecimals: 2);
      final result = f.formatEditUpdate(const TextEditingValue(), _value('.12345'));
      expect(result.text, '0.12');
    });

    test('default allowedDecimals allows many fractional digits', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        _value('1.000000000000000001'),
      );
      expect(result.text, '1.000000000000000001');
    });
  });

  // ============================================================
  // REGRESSION: separator deletion when raw text unchanged
  // ============================================================

  group('Separator deletion regression', () {
    test('non-collapsed selection skips separator deletion logic', () {
      // Old has a range selection, not a caret — the separator-deletion
      // special case should not apply.
      final old = _selected('1,234', base: 1, extent: 3);
      final newVal = _value('134', offset: 1);
      final result = formatter.formatEditUpdate(old, newVal);
      expect(result.text, '134');
    });

    test(
      'insertion that happens to not change raw text does not trigger delete logic',
      () {
        // Old: "1,234" => raw "1234". User somehow produces "1,234" again with same caret.
        // The diff shows no insertion and no removal — should just reformat.
        final old = _value('1,234', offset: 5);
        final newVal = _value('1,234', offset: 5);
        final result = formatter.formatEditUpdate(old, newVal);
        expect(result.text, '1,234');
      },
    );
  });
}
