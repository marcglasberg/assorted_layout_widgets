import 'package:flutter/services.dart';

/// The [ThousandsSeparatorTextInputFormatter] is a [TextInputFormatter] that formats
/// numeric input with thousands separators while the user types, and preserves the caret
/// or selection as naturally as possible.
///
/// This formatter is intended for text fields that accept:
///
/// * integer values like `123456` -> `123,456`
/// * decimal values like `123456.32` -> `123,456.32`
///
///
/// ## Features
/// 
/// * Adds thousands separators as you type.
/// * When digits are inserted or deleted, including in the middle, separators are
///   recalculated (re-positioned).
/// * You can add a fractional part by typing a dot `.` and then more digits.
/// * Only digits and one decimal dot are kept. Commas, minus signs, and other characters
///   are ignored.
/// * If a dot already exists and you type another one to the right, the new one is
///   ignored.
/// * If a dot already exists and you type another one to the left, the left one is kept
///   and the old right one is dropped.
/// * It tries to keep the caret or selection in the natural place after reformatting.
/// * It has special handling for Backspace just to the right of a thousands separator
///   and Delete just to the left of one, so those keys delete the neighboring digit
///   instead of appearing to do nothing.
/// * If the input starts with `.,` it normalizes it to `0.`.
///   For example, `.5` becomes `0.5`.
/// * Limit the fractional part to [allowedDecimals] digits.
/// * Prevent leading zeroes on the left.
///
///
/// ## Details
///
/// The integer part is grouped using [groupSeparator], and the fractional part,
/// if present, is left exactly as typed after the first [decimalSeparator].
///
/// Example behavior:
///
/// * `1` -> `1`
/// * `1234` -> `1,234`
/// * `12345.6` -> `12,345.6`
/// * `12345.60` -> `12,345.60`
/// * `.5` -> `0.5`
///
/// This formatter also handles editing in the middle of the text, not only at
/// the end. For example, if the field contains `123,456.32`, the user places
/// the caret between `1` and `2`, and types `5`, the result becomes
/// `1,523,456.32`, and the caret stays immediately after the inserted `5`.
///
///
/// ## How it works
///
/// The formatter treats the visible text and the numeric value as two different
/// representations:
///
/// * the formatted text shown in the field, such as `1,234,567.89`
/// * a raw numeric text without grouping separators, such as `1234567.89`
///
/// On each edit, it performs these steps:
///
/// 1. Sanitize the user's edited text into raw numeric text.
///    Only digits and a single decimal separator are kept.
/// 2. Convert the current selection from formatted text offsets into raw text
///    offsets.
/// 3. Rebuild the formatted text from the raw text by inserting grouping
///    separators into the integer part.
/// 4. Convert the selection back from raw offsets into formatted offsets.
/// 5. Return a new [TextEditingValue] with the formatted text and corrected
///    selection.
///
/// The important idea is that the selection is mapped through the raw text,
/// instead of trying to guess its final visible position directly. This makes
/// caret placement much more reliable when separators are inserted or removed
/// during formatting.
///
///
/// ## Caret and selection mapping
///
/// Caret placement is based on text boundaries, not characters. A string of
/// length `N` has `N + 1` valid caret positions. The formatter builds mapping
/// tables between:
///
/// * formatted text boundaries -> raw text boundaries
/// * raw text boundaries -> formatted text boundaries
///
/// Because of that, both collapsed selections, meaning a caret, and non
/// collapsed selections, meaning highlighted ranges, can be handled using the
/// same logic.
///
/// This is especially useful when:
///
/// * typing in the middle of the number
/// * replacing a selected range
/// * pasting text
/// * editing values that already contain grouping separators
///
///
/// ## Special handling for Backspace and Delete near separators
///
/// Grouping separators are formatting characters only. They do not exist in the
/// raw numeric value. Because of that, deleting a comma naively would appear to
/// do nothing, since the formatter would simply insert it again when rebuilding
/// the formatted text.
///
/// To avoid that, the formatter compares [oldValue] and [newValue] and tries to
/// recover the user's intent when the only removed characters are grouping
/// separators and the raw numeric value did not actually change.
///
/// Two important cases are handled:
///
/// * Backspace immediately to the right of a grouping separator
/// * Delete immediately to the left of a grouping separator
///
/// In those cases, the formatter interprets the edit as a request to delete the
/// adjacent digit in raw space, then reformats the result.
///
/// Example:
///
/// * `123,456`, caret after `,`, Backspace -> `12,456`
/// * `123,456`, caret before `,`, Delete -> `12,356`
///
/// This makes deletion feel much closer to what users expect in a formatted
/// numeric field.
///
///
/// ## Composition and IME behavior
///
/// If the input method is currently composing text, the formatter returns
/// [newValue] unchanged. This avoids interfering with active IME composition,
/// which is important for correct text input behavior on mobile keyboards and
/// some international input methods.
///
///
/// ## Normalization rules
///
/// The formatter applies a few normalization rules:
///
/// * Only digits are kept, plus the first decimal separator.
/// * Additional decimal separators are ignored.
/// * If the input starts with the decimal separator, it is normalized to a
///   leading zero. For example, `.5` becomes `0.5`.
/// * Grouping separators in the input are ignored during parsing and are always
///   rebuilt from the raw value.
///
///
/// ## Scope and assumptions
///
/// This formatter is designed for numeric text entry with:
///
/// * ASCII digits `0` through `9`
/// * a single character grouping separator
/// * a single character decimal separator
///
/// It does not attempt to support:
///
/// * negative numbers
/// * scientific notation
/// * locale specific digits
/// * currency symbols
/// * arbitrary user text
///
/// Direct string indexing is used internally, which is safe for this formatter
/// because it intentionally works only with simple ASCII numeric input and
/// single character separators.
///
///
/// ## Typical usage
///
/// ```dart
/// TextField(
///   keyboardType: const TextInputType.numberWithOptions(decimal: true),
///   inputFormatters: [
///     GroupedDecimalInputFormatter(),
///   ],
/// )
/// ```
///
/// By default, this formatter uses `,` as the grouping separator and `.` as the
/// decimal separator.
///
class ThousandsSeparatorTextInputFormatter extends TextInputFormatter {
  ThousandsSeparatorTextInputFormatter({
    this.groupSeparator = ',',
    this.decimalSeparator = '.',
    this.allowedDecimals = 1000,
  }) : assert(groupSeparator.length == 1),
       assert(decimalSeparator.length == 1),
       assert(groupSeparator != decimalSeparator),
       assert(allowedDecimals >= 0);

  final String groupSeparator;
  final String decimalSeparator;
  final int allowedDecimals;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Do not interfere with active IME composition.
    if (!newValue.composing.isCollapsed) {
      return newValue;
    }

    final oldSanitized = _sanitize(oldValue.text);
    final newSanitized = _sanitize(newValue.text);

    String targetRawText = newSanitized.rawText;
    _RawSelection targetRawSelection = _RawSelection(
      baseOffset: _inputOffsetToRawOffset(
        inputToRaw: newSanitized.inputToRaw,
        inputOffset: newValue.selection.baseOffset,
        inputLength: newValue.text.length,
        rawLength: newSanitized.rawText.length,
      ),
      extentOffset: _inputOffsetToRawOffset(
        inputToRaw: newSanitized.inputToRaw,
        inputOffset: newValue.selection.extentOffset,
        inputLength: newValue.text.length,
        rawLength: newSanitized.rawText.length,
      ),
      affinity: newValue.selection.affinity,
      isDirectional: newValue.selection.isDirectional,
    );

    final interpretedDelete = _maybeInterpretSeparatorDeletion(
      oldValue: oldValue,
      newValue: newValue,
      oldSanitized: oldSanitized,
      newSanitized: newSanitized,
    );

    if (interpretedDelete != null) {
      targetRawText = interpretedDelete.rawText;
      targetRawSelection = interpretedDelete.selection;
    }

    // Strip leading zeros from the integer part.
    final decIdx = targetRawText.indexOf(decimalSeparator);
    final intEnd = decIdx >= 0 ? decIdx : targetRawText.length;
    int leadingZeros = 0;
    while (leadingZeros < intEnd && targetRawText[leadingZeros] == '0') {
      leadingZeros++;
    }
    if (leadingZeros > 0) {
      targetRawText = targetRawText.substring(leadingZeros);
      targetRawSelection = _RawSelection(
        baseOffset: _clamp(
          targetRawSelection.baseOffset - leadingZeros,
          0,
          targetRawText.length,
        ),
        extentOffset: _clamp(
          targetRawSelection.extentOffset - leadingZeros,
          0,
          targetRawText.length,
        ),
        affinity: targetRawSelection.affinity,
        isDirectional: targetRawSelection.isDirectional,
      );
    }

    // Normalize ".5" to "0.5".
    if (targetRawText.startsWith(decimalSeparator)) {
      targetRawText = '0$targetRawText';
      targetRawSelection = _RawSelection(
        baseOffset: targetRawSelection.baseOffset + 1,
        extentOffset: targetRawSelection.extentOffset + 1,
        affinity: targetRawSelection.affinity,
        isDirectional: targetRawSelection.isDirectional,
      );
    }

    final formatted = _formatRaw(targetRawText);

    return TextEditingValue(
      text: formatted.text,
      selection: TextSelection(
        baseOffset: _rawOffsetToFormattedOffset(
          rawToFormatted: formatted.rawToFormatted,
          rawOffset: targetRawSelection.baseOffset,
        ),
        extentOffset: _rawOffsetToFormattedOffset(
          rawToFormatted: formatted.rawToFormatted,
          rawOffset: targetRawSelection.extentOffset,
        ),
        affinity: targetRawSelection.affinity,
        isDirectional: targetRawSelection.isDirectional,
      ),
      composing: TextRange.empty,
    );
  }

  _InterpretedDelete? _maybeInterpretSeparatorDeletion({
    required TextEditingValue oldValue,
    required TextEditingValue newValue,
    required _SanitizeResult oldSanitized,
    required _SanitizeResult newSanitized,
  }) {
    // This special case is only for caret deletes.
    if (!oldValue.selection.isCollapsed || !newValue.selection.isCollapsed) {
      return null;
    }

    // If raw text changed, then a real numeric edit already happened.
    if (oldSanitized.rawText != newSanitized.rawText) {
      return null;
    }

    // No visible change means nothing to reinterpret.
    if (oldValue.text == newValue.text) {
      return null;
    }

    final diff = _diff(oldValue.text, newValue.text);

    // We only care about deletions of grouping separators.
    if (diff.inserted.isNotEmpty || diff.removed.isEmpty) {
      return null;
    }
    if (!_containsOnlyGroupSeparators(diff.removed)) {
      return null;
    }

    final oldCaret = oldValue.selection.extentOffset;
    final oldRawCaret = _inputOffsetToRawOffset(
      inputToRaw: oldSanitized.inputToRaw,
      inputOffset: oldCaret,
      inputLength: oldValue.text.length,
      rawLength: oldSanitized.rawText.length,
    );

    // Case 1: Backspace removed separator immediately before the caret.
    if (diff.oldEnd == oldCaret) {
      if (oldRawCaret <= 0) {
        return null;
      }

      final newRawText = _removeRawRange(
        oldSanitized.rawText,
        oldRawCaret - 1,
        oldRawCaret,
      );

      return _InterpretedDelete(
        rawText: newRawText,
        selection: _RawSelection.collapsed(
          offset: oldRawCaret - 1,
          affinity: newValue.selection.affinity,
        ),
      );
    }

    // Case 2: Delete removed separator immediately after the caret.
    if (diff.oldStart == oldCaret) {
      if (oldRawCaret >= oldSanitized.rawText.length) {
        return null;
      }

      final newRawText = _removeRawRange(
        oldSanitized.rawText,
        oldRawCaret,
        oldRawCaret + 1,
      );

      return _InterpretedDelete(
        rawText: newRawText,
        selection: _RawSelection.collapsed(
          offset: oldRawCaret,
          affinity: newValue.selection.affinity,
        ),
      );
    }

    return null;
  }

  _SanitizeResult _sanitize(String input) {
    final buffer = StringBuffer();
    final inputToRaw = List<int>.filled(input.length + 1, 0);

    bool sawDecimalSeparator = false;
    int fractionalDigits = 0;
    inputToRaw[0] = 0;

    for (int i = 0; i < input.length; i++) {
      final ch = input[i];
      final isDigit = _isDigit(ch);
      final isDecimal = ch == decimalSeparator &&
          !sawDecimalSeparator &&
          allowedDecimals > 0;

      if (isDigit || isDecimal) {
        if (isDecimal) {
          sawDecimalSeparator = true;
        } else if (sawDecimalSeparator) {
          fractionalDigits++;
          if (fractionalDigits > allowedDecimals) {
            inputToRaw[i + 1] = buffer.length;
            continue;
          }
        }
        buffer.write(ch);
      }

      inputToRaw[i + 1] = buffer.length;
    }

    return _SanitizeResult(
      rawText: buffer.toString(),
      inputToRaw: inputToRaw,
    );
  }

  _FormatResult _formatRaw(String raw) {
    if (raw.isEmpty) {
      return _FormatResult(
        text: '',
        rawToFormatted: const [0],
      );
    }

    final decimalIndex = raw.indexOf(decimalSeparator);
    final hasDecimal = decimalIndex >= 0;

    final integerPart = hasDecimal ? raw.substring(0, decimalIndex) : raw;
    final fractionalPart = hasDecimal ? raw.substring(decimalIndex + 1) : '';

    final buffer = StringBuffer();
    final rawToFormatted = List<int>.filled(raw.length + 1, 0);

    int rawOffset = 0;
    rawToFormatted[0] = 0;

    for (int i = 0; i < integerPart.length; i++) {
      final remaining = integerPart.length - i;

      if (i > 0 && remaining % 3 == 0) {
        buffer.write(groupSeparator);
      }

      buffer.write(integerPart[i]);
      rawOffset++;
      rawToFormatted[rawOffset] = buffer.length;
    }

    if (hasDecimal) {
      buffer.write(decimalSeparator);
      rawOffset++;
      rawToFormatted[rawOffset] = buffer.length;

      for (int i = 0; i < fractionalPart.length; i++) {
        buffer.write(fractionalPart[i]);
        rawOffset++;
        rawToFormatted[rawOffset] = buffer.length;
      }
    }

    return _FormatResult(
      text: buffer.toString(),
      rawToFormatted: rawToFormatted,
    );
  }

  _Diff _diff(String oldText, String newText) {
    int prefix = 0;
    final minLength = oldText.length < newText.length ? oldText.length : newText.length;

    while (prefix < minLength && oldText[prefix] == newText[prefix]) {
      prefix++;
    }

    int oldEnd = oldText.length;
    int newEnd = newText.length;

    while (oldEnd > prefix &&
        newEnd > prefix &&
        oldText[oldEnd - 1] == newText[newEnd - 1]) {
      oldEnd--;
      newEnd--;
    }

    return _Diff(
      oldStart: prefix,
      oldEnd: oldEnd,
      newStart: prefix,
      newEnd: newEnd,
      removed: oldText.substring(prefix, oldEnd),
      inserted: newText.substring(prefix, newEnd),
    );
  }

  bool _containsOnlyGroupSeparators(String text) {
    for (int i = 0; i < text.length; i++) {
      if (text[i] != groupSeparator) {
        return false;
      }
    }
    return true;
  }

  String _removeRawRange(String raw, int start, int end) {
    return raw.substring(0, start) + raw.substring(end);
  }

  int _inputOffsetToRawOffset({
    required List<int> inputToRaw,
    required int inputOffset,
    required int inputLength,
    required int rawLength,
  }) {
    if (inputOffset < 0) {
      return rawLength;
    }

    final clamped = _clamp(inputOffset, 0, inputLength);
    return inputToRaw[clamped];
  }

  int _rawOffsetToFormattedOffset({
    required List<int> rawToFormatted,
    required int rawOffset,
  }) {
    final clamped = _clamp(rawOffset, 0, rawToFormatted.length - 1);
    return rawToFormatted[clamped];
  }

  bool _isDigit(String ch) {
    final code = ch.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  int _clamp(int value, int min, int max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}

class _RawSelection {
  _RawSelection({
    required this.baseOffset,
    required this.extentOffset,
    required this.affinity,
    required this.isDirectional,
  });

  _RawSelection.collapsed({
    required int offset,
    required this.affinity,
  }) : baseOffset = offset,
       extentOffset = offset,
       isDirectional = false;

  final int baseOffset;
  final int extentOffset;
  final TextAffinity affinity;
  final bool isDirectional;
}

class _InterpretedDelete {
  _InterpretedDelete({
    required this.rawText,
    required this.selection,
  });

  final String rawText;
  final _RawSelection selection;
}

class _SanitizeResult {
  _SanitizeResult({
    required this.rawText,
    required this.inputToRaw,
  });

  final String rawText;
  final List<int> inputToRaw;
}

class _FormatResult {
  _FormatResult({
    required this.text,
    required this.rawToFormatted,
  });

  final String text;
  final List<int> rawToFormatted;
}

class _Diff {
  _Diff({
    required this.oldStart,
    required this.oldEnd,
    required this.newStart,
    required this.newEnd,
    required this.removed,
    required this.inserted,
  });

  final int oldStart;
  final int oldEnd;
  final int newStart;
  final int newEnd;
  final String removed;
  final String inserted;
}
