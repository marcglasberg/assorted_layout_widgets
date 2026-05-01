import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:characters/characters.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// [CapitalizationTextInputFormatter] is a [TextInputFormatter] that capitalizes text
/// as the user types, according to the specified [Capitalize] option:
///
/// - [Capitalize.firstLetterUpper]: Capitalizes only the first letter of the text.
/// - [Capitalize.uppercase]: Capitalizes all letters of the text.
/// - [Capitalize.lowercase]: Converts all letters of the text to lowercase.
/// - [Capitalize.title]: Capitalizes the first letter of each word in the text
///   (approximation of English title case).
///
class CapitalizationTextInputFormatter extends TextInputFormatter {
  //
  final Capitalize? capitalize;

  static final firstLetterUppercase = CapitalizationTextInputFormatter(
    Capitalize.firstLetterUpper,
  );

  static final uppercase = CapitalizationTextInputFormatter(Capitalize.uppercase);

  static final lowercase = CapitalizationTextInputFormatter(Capitalize.lowercase);

  /// English title case (approximation).
  static final title = CapitalizationTextInputFormatter(Capitalize.title);

  CapitalizationTextInputFormatter(this.capitalize);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return (capitalize == null) //
        ? newValue
        : newValue.copyWith(text: newValue.text.capitalize(capitalize));
  }
}

/// [NumbersTextInputFormatter] is a [TextInputFormatter] that allows only numbers to be
/// typed, with four options:
///
/// - [NumbersTextInputFormatter.integer]: Only digits (0 to 9) can be typed.
///
/// - [NumbersTextInputFormatter.decimal]: Only digits (0 to 9), plus dot or comma can
///   be typed. Whichever the user types is converted to the current locale's decimal
///   separator.
///
/// - [NumbersTextInputFormatter.decimalWithDot]: Only digits (0 to 9), plus dot or
///   comma can be typed, but commas are always converted to dots.
///
/// - [NumbersTextInputFormatter.decimalWithComma]: Only digits (0 to 9), plus dot or
///   comma can be typed, but dots are always converted to commas.
///
class NumbersTextInputFormatter extends TextInputFormatter {
  //
  /// Allows only typing numbers 0-9.
  static final integer = NumbersTextInputFormatter._(_NumbersMode.integer);

  /// Allows only typing numbers 0-9, plus dot or comma,
  /// but if the user types a dot or a comma it will always be converted
  /// to the current decimal separator (depending on the locale).
  static final decimal = NumbersTextInputFormatter._(_NumbersMode.decimalLocale);

  /// Allows only typing numbers 0-9, plus dot or comma,
  /// but if the user types a comma it will always appear as a dot.
  static final decimalWithDot = NumbersTextInputFormatter._(_NumbersMode.decimalDot);

  /// Allows only typing numbers 0-9, plus dot or comma,
  /// but if the user types a dot it will always appear as a comma.
  static final decimalWithComma = NumbersTextInputFormatter._(_NumbersMode.decimalComma);

  final _NumbersMode _mode;

  NumbersTextInputFormatter._(this._mode);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    //
    String text;
    switch (_mode) {
      case _NumbersMode.integer:
        text = newValue.text.onlyInts();
        break;
      case _NumbersMode.decimalLocale:
        final sep = localeDecimalSeparator();
        text = newValue.text.onlyIntsDotComma();
        text = (sep == ',') ? text.replaceAll('.', ',') : text.replaceAll(',', '.');
        break;
      case _NumbersMode.decimalDot:
        text = newValue.text.onlyIntsDotComma().replaceAll(',', '.');
        break;
      case _NumbersMode.decimalComma:
        text = newValue.text.onlyIntsDotComma().replaceAll('.', ',');
        break;
    }

    int offset = newValue.text.length <= text.length
        ? math.min(newValue.selection.baseOffset, text.length)
        : math.min(oldValue.selection.baseOffset, text.length);

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }

  /// Returns the default decimal separator for the current platform locale.
  ///
  /// This uses locale data from `intl`, so it handles regional variants like
  /// `de_CH`, `en_ZA`, and `es_MX`.
  ///
  /// Note 1: this reflects the default separator for the locale. It may not reflect
  /// OS-level number-format overrides.
  ///
  /// Note 2: this may return a separator other than , or . for some locales,
  /// such as Arabic locales.
  static String localeDecimalSeparator() {
    final locale = ui.PlatformDispatcher.instance.locale;
    final localeName = _intlLocaleName(locale);

    return NumberFormat.decimalPattern(localeName).symbols.DECIMAL_SEP;
  }

  static String _intlLocaleName(ui.Locale locale) {
    final scriptCode = locale.scriptCode;
    final countryCode = locale.countryCode;

    return [
      locale.languageCode,
      if (scriptCode != null && scriptCode.isNotEmpty) scriptCode,
      if (countryCode != null && countryCode.isNotEmpty) countryCode,
    ].join('_');
  }
}

enum _NumbersMode { integer, decimalLocale, decimalDot, decimalComma }

/// [AllowedCharsTextInputFormatter] is a [TextInputFormatter] that allows only characters
/// that match the given [allowedPattern].
///
/// The pattern is matched against each grapheme cluster of the input
/// individually, so it should describe a single character (e.g. `[0-9]`,
/// `[a-zA-Z]`, `[\p{L}]`). For unicode property classes like `\p{L}` the
/// `RegExp` must be created with `unicode: true`.
///
class AllowedCharsTextInputFormatter extends TextInputFormatter {
  //
  final RegExp allowedPattern;

  AllowedCharsTextInputFormatter(this.allowedPattern);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    //
    final buf = StringBuffer();
    for (final char in newValue.text.characters) {
      if (allowedPattern.hasMatch(char)) buf.write(char);
    }
    final text = buf.toString();

    int offset = newValue.text.length <= text.length
        ? math.min(newValue.selection.baseOffset, text.length)
        : math.min(oldValue.selection.baseOffset, text.length);

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }
}

/// [NoSpacesTextInputFormatter] is a [TextInputFormatter] that prevents the user from
/// typing any spaces (including tabs and newlines). It removes all whitespace characters
/// from the input.
class NoSpacesTextInputFormatter extends TextInputFormatter {
  //
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    //
    var text = newValue.text.removeSpaces();

    int offset = newValue.text.length <= text.length
        ? math.min(newValue.selection.baseOffset, text.length)
        : math.min(oldValue.selection.baseOffset, text.length);

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }
}

/// [AlwaysAtTheEndTextInputFormatter] is a [TextInputFormatter] that forces the cursor
/// to always stay at the end of what is being typed.
///
/// Note, just adding [AlwaysAtTheEndTextInputFormatter] does not prevent text
/// selections, and does not prevent the user to move the cursor using the keyboard
/// arrows. However, if the user types a character when not at the end, the text
/// remains unchanged and the cursor goes to the end of the text.
///
/// ---
///
/// You can improve this by adding two more changes to your code:
///
/// 1. Add `enableInteractiveSelection: false` to the TextField, which will
/// prevent long press selection, copy/paste menu, and selection handles.
///
/// 2. Create a `controller` and add the following code to your widget's `initState()`,
/// which will prevent the cursor from moving horizontally with the keyboard arrows:
///
/// ```
/// final controller = TextEditingController();
///
/// bool _fixingSelection = false;
///
/// @override
/// void initState() {
///   super.initState();
///
///   controller.addListener(() {
///     if (_fixingSelection) return;
///
///     final textLength = controller.text.length;
///     final selection = controller.selection;
///
///     if (!selection.isCollapsed || selection.baseOffset != textLength) {
///       _fixingSelection = true;
///       controller.selection = TextSelection.collapsed(offset: textLength);
///       _fixingSelection = false;
///     }
///   });
/// }
/// ```
///
/// Then:
///
/// ```
/// TextField(
///   controller: controller,
///   enableInteractiveSelection: false,
///   inputFormatters: [
///     AlwaysAtTheEndTextInputFormatter.instance,
///   ],
/// )
/// ```
///
class AlwaysAtTheEndTextInputFormatter extends TextInputFormatter {
  //
  static final instance = AlwaysAtTheEndTextInputFormatter._();

  AlwaysAtTheEndTextInputFormatter._();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    //
    if ((newValue.selection.baseOffset != newValue.text.length) ||
        (newValue.selection.extentOffset != newValue.text.length))
      newValue = oldValue;

    return newValue.copyWith(
      selection: TextSelection.collapsed(offset: newValue.text.length),
      composing: TextRange.empty,
    );
  }
}

/// [StringDotLengthLimiterTextInputFormatter] is a [TextInputFormatter] that limits
/// text by [String.length], not user-perceived characters (grapheme clusters).
///
/// The important detail is that it counts with [String.length], but when it cuts text,
/// it walks user-visible characters (with the `characters` package), so it does not
/// split an emoji or combined character in half.
///
/// Use [StringDotLengthLimiterTextInputFormatter] when the allowed length of some
/// text is based on Dart's [String.length], such as when a server, database, or
/// file format has that same limit.
///
/// This is different from Flutter's native [LengthLimitingTextInputFormatter],
/// which counts user-visible characters using the `characters` package, not
/// [String.length]. Because of that, Flutter's formatter may result in text that
/// does not really fit the limit of [String.length], and may even allow text that
/// exceeds that limit. For example, if the limit is 10, Flutter's formatter may
/// allow 10 emojis, which can be more than 10 characters in [String.length].
/// This can cause issues if you are trying to enforce a limit based on [String.length],
/// such as when a server or database has that same limit.
///
/// Note, when using [StringDotLengthLimiterTextInputFormatter] you should not show the
/// normal character count to the user in the UI, because what the user sees is not
/// the real limit.
///
class StringDotLengthLimiterTextInputFormatter extends TextInputFormatter {
  //
  /// Creates a formatter that prevents the insertion of more characters than a
  /// limit. The [maxLength] must be null, -1 or greater than zero. If it is null or -1,
  /// then no limit is enforced.
  StringDotLengthLimiterTextInputFormatter(this.maxLength)
    : assert(maxLength == null || maxLength == -1 || maxLength > 0);

  /// The limit on the number of [String.length] characters that this formatter
  /// will allow. The value must be null or greater than zero. If it is null or -1,
  /// then no limit is enforced.
  final int? maxLength;

  /// Truncate the given String to [maxLength] using [String.length]
  /// (not user-perceived characters).
  ///
  /// See also:
  ///  * [Dart's characters package](https://pub.dev/packages/characters).
  ///  * [Dart's documentation on runes and grapheme clusters](https://dart.dev/guides/language/language-tour#runes-and-grapheme-clusters).
  static String truncateString(String value, int maxLength) {
    //
    // If the text fits the available space, use it all.
    if (value.length <= maxLength)
      return value;
    //
    // If the text doesn't fit the available space, we must cut it,
    // but do not cut a grapheme in half.
    else {
      List<String> chars = [];
      int length = 0;
      for (String char in value.characters) {
        length += char.length;
        if (length <= maxLength) {
          chars.add(char);
        }
      }
      return chars.join();
    }
  }

  /// Truncate the given TextEditingValue to maxLength using [String.length]
  /// (not user-perceived characters).
  ///
  /// See also:
  ///  * [Dart's characters package](https://pub.dev/packages/characters).
  ///  * [Dart's documentation on runes and grapheme clusters](https://dart.dev/guides/language/language-tour#runes-and-grapheme-clusters).
  static TextEditingValue truncate(TextEditingValue value, int maxLength) {
    //
    // If the text fits the available space, use it all.
    if (value.text.length <= maxLength)
      return value;
    //
    // If the text doesn't fit the available space, we must cut it,
    // but do not cut a grapheme in half.
    else {
      String truncated = truncateString(value.text, maxLength);

      return TextEditingValue(
        text: truncated,
        selection: value.selection.copyWith(
          baseOffset: math.min(value.selection.start, truncated.length),
          extentOffset: math.min(value.selection.end, truncated.length),
        ),
        composing:
            !value.composing.isCollapsed && truncated.length > value.composing.start
            ? TextRange(
                start: value.composing.start,
                end: math.min(value.composing.end, truncated.length),
              )
            : TextRange.empty,
      );
    }
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int? maxLength = this.maxLength;

    if (maxLength == null || maxLength == -1 || (newValue.text.length <= maxLength)) {
      return newValue;
    }

    assert(maxLength > 0);

    // If already at the maximum and tried to enter even more, and has no
    // selection, keep the old value.
    if (oldValue.text.length == maxLength && oldValue.selection.isCollapsed) {
      return oldValue;
    }

    // Enforced to return a truncated value.
    return truncate(newValue, maxLength);
  }
}

enum Capitalize { firstLetterUpper, uppercase, lowercase, title }

extension _StringTextInputFormatterUtils on String {
  String capitalize(Capitalize? capitalize) {
    if (capitalize == null || isEmpty) return this;

    switch (capitalize) {
      case Capitalize.firstLetterUpper:
        final chars = characters;
        return chars.first.toUpperCase() + chars.skip(1).string;
      //
      case Capitalize.uppercase:
        return toUpperCase();
      //
      case Capitalize.lowercase:
        return toLowerCase();
      //
      case Capitalize.title:
        return toTitleCase(this);
    }
  }

  static final _patternAllCharsExceptDigits = RegExp('[^0-9]');
  static final _patternAllCharsExceptDigitsDotOrComma = RegExp('[^0-9.,]');
  static final _allSpaces = RegExp(r'\s');

  /// Returns only digits 0-9 (also removes dot, comma, and minus sign).
  String onlyInts() => replaceAll(_patternAllCharsExceptDigits, '');

  /// Returns only digits 0-9, dot, or comma (also removes minus sign).
  String onlyIntsDotComma() => replaceAll(_patternAllCharsExceptDigitsDotOrComma, '');

  String removeSpaces() => replaceAll(_allSpaces, "");

  /// Converts the given text to title case, following common English
  /// title capitalization rules. This is an approximation. A better
  /// implementation requires AI or a comprehensive list of exceptions.
  String toTitleCase(String text) {
    final smallWords = {
      'a',
      'an',
      'the',
      'and',
      'but',
      'or',
      'nor',
      'for',
      'so',
      'yet',
      'as',
      'at',
      'by',
      'in',
      'of',
      'on',
      'per',
      'to',
      'up',
      'via',
    };

    final words = text.trim().split(RegExp(r'\s+'));

    if (words.isEmpty || words.first.isEmpty) {
      return '';
    }

    String capitalizeWord(String word) {
      if (word.isEmpty) return word;

      return word
          .split('-')
          .map((part) {
            if (part.isEmpty) return part;
            return part[0].toUpperCase() + part.substring(1).toLowerCase();
          })
          .join('-');
    }

    return words
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final word = entry.value;
          final lower = word.toLowerCase();

          final isFirst = index == 0;
          final isLast = index == words.length - 1;

          if (!isFirst && !isLast && smallWords.contains(lower)) {
            return lower;
          }

          return capitalizeWord(word);
        })
        .join(' ');
  }
}
