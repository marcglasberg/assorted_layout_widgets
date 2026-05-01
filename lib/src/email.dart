import 'dart:core';
import 'dart:math' as math;

import 'package:flutter/services.dart';

/// While the user types an email address, this input formatter removes some
/// obviously invalid characters from the input. It does not check if the email
/// address is complete or valid. Note, you should not use this input formatter
/// if you want to allow the user to type anything just to check the validity of
/// the email address only when they finish typing.
///
/// ```
/// TextField(
///   inputFormatters: [EmailTextInputFormatter()],
/// );
/// ```
///
/// See also: [Email.isValid], which checks if an email address is valid.
///
class EmailTextInputFormatter extends TextInputFormatter {
  //
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    //
    var text = Email(newValue.text).sanitize();

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

class Email {
  /// Creates an email value from raw text.
  ///
  /// This constructor does not check if [address] is valid.
  /// Use [isValid] when you need to check the address.
  Email(this.address);

  /// The raw email address text.
  ///
  /// This value may be valid, invalid, complete, or incomplete.
  final String address;

  /// Characters allowed in the local part of a simple email address.
  ///
  /// The local part is the text before `@`.
  static const String _allowedLocalChars =
      'abcdefghijklmnopqrstuvwxyz'
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      '0123456789'
      r"!#$%&'*+/=?^_`{|}~.-";

  /// Characters allowed in the domain part of a simple email address.
  ///
  /// The domain part is the text after `@`.
  static const String _allowedDomainChars =
      'abcdefghijklmnopqrstuvwxyz'
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      '0123456789-.';

  /// Characters allowed while the user is typing an email address.
  ///
  /// This includes characters from both the local part and the domain part,
  /// plus `@`.
  static const String _allowedPartialChars =
      'abcdefghijklmnopqrstuvwxyz'
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      r"0123456789-@!#$%&'*+/=?^_`{|}~.-";

  /// Returns `true` when [address] is a valid complete email address.
  ///
  /// If [allowTopLevelDomains] is `true`, addresses like `user@example` are
  /// allowed.
  ///
  /// If [allowInternational] is `true`, international characters are allowed.
  ///
  /// **IMPORTANT**: Validating email addresses is tricky, because email providers
  /// usually don't completely agree on the rules. This method uses rules that are
  /// most commonly accepted, but the only way to be 100% sure you are not discarding
  /// an email address that could be delivered is to use a much more permissive
  /// validation and then try to send the email and see if it bounces.
  ///
  bool isValid({bool allowTopLevelDomains = false, bool allowInternational = true}) {
    return _EmailValidator(address).validate(
      allowTopLevelDomains: allowTopLevelDomains,
      allowInternational: allowInternational,
    );
  }

  /// Returns [address] with unsupported characters removed.
  /// Use this while the user is typing an email address.
  ///
  /// This is not a validator. The returned value can still be incomplete or
  /// invalid. For example, it can return `user@`.
  ///
  /// If [allowInternational] is `true`, non ASCII characters are kept.
  ///
  /// See: [EmailTextInputFormatter], which uses this to sanitize the input.
  ///
  String sanitize({bool allowInternational = true}) {
    return address
        .split('')
        .where(
          (char) => _isAllowedPartialChar(char, allowInternational: allowInternational),
        )
        .join();
  }

  /// Tries to turn [address] into a valid email address.
  ///
  /// This method first trims [address].
  ///
  /// 1. If the trimmed address is already valid, it returns the trimmed address.
  ///
  /// 2. Otherwise, it tries to fix the address by removing unsupported characters
  /// from the local part and the domain part. It does not try to fix a missing `@`
  /// or more than one `@`. The fixed address is then checked with the same rules
  /// used by [isValid], and it returns `null` if the address cannot be fixed into
  /// a valid email address.
  ///
  /// Note: This method may change the meaning of the email address.
  /// Use it only when you really want to guess what the correct address is.
  ///
  String? tryFix({bool allowTopLevelDomains = false, bool allowInternational = true}) {
    final trimmed = address.trim();

    if (Email(trimmed).isValid(
      allowTopLevelDomains: allowTopLevelDomains,
      allowInternational: allowInternational,
    )) {
      return trimmed;
    }

    final atIndex = trimmed.indexOf('@');
    if (atIndex == -1) return null;
    if (trimmed.indexOf('@', atIndex + 1) != -1) return null;

    final localPart = trimmed
        .substring(0, atIndex)
        .split('')
        .where(
          (char) => _isAllowedLocalChar(char, allowInternational: allowInternational),
        )
        .join();

    final domainPart = trimmed
        .substring(atIndex + 1)
        .split('')
        .where(
          (char) => _isAllowedDomainChar(char, allowInternational: allowInternational),
        )
        .join();

    final cleanedLocalPart = localPart.replaceAll(RegExp(r'^\.+|\.+$'), '');
    final cleanedDomainPart = domainPart.replaceAll(RegExp(r'^[.-]+|[.-]+$'), '');

    final cleaned = '$cleanedLocalPart@$cleanedDomainPart';

    if (!Email(cleaned).isValid(
      allowTopLevelDomains: allowTopLevelDomains,
      allowInternational: allowInternational,
    )) {
      return null;
    }

    return cleaned;
  }

  static bool _isAllowedPartialChar(String char, {required bool allowInternational}) {
    return _allowedPartialChars.contains(char) ||
        _isAllowedInternationalChar(char, allowInternational: allowInternational);
  }

  static bool _isAllowedLocalChar(String char, {required bool allowInternational}) {
    return _allowedLocalChars.contains(char) ||
        _isAllowedInternationalChar(char, allowInternational: allowInternational);
  }

  static bool _isAllowedDomainChar(String char, {required bool allowInternational}) {
    return _allowedDomainChars.contains(char) ||
        _isAllowedInternationalChar(char, allowInternational: allowInternational);
  }

  static bool _isAllowedInternationalChar(
    String char, {
    required bool allowInternational,
  }) {
    return allowInternational && char.codeUnitAt(0) >= 128;
  }

  @override
  String toString() => address;

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Email && other.address == address;
  }

  @override
  int get hashCode => address.hashCode;
}

class _EmailValidator {
  //
  /// See: https://github.com/fredeil/email-validator.dart
  static const _emailAtomCharacters = "!#\$%&'*+-/=?^_`{|}~";

  _EmailValidator(this.address);

  final String address;

  int _index = 0;
  _Type _domainType = _Type.none;

  /// Validate the specified email address.
  ///
  /// If [allowTopLevelDomains] is `true`, then the validator will
  /// allow addresses with top-level domains like `email@example`.
  /// Default is `false`.
  ///
  /// If [allowInternational] is `true`, then the validator
  /// will use the newer International Email standards for validating.
  /// Default is `true`.
  ///
  bool validate({bool allowTopLevelDomains = false, bool allowInternational = true}) {
    _index = 0;
    _domainType = _Type.none;

    if (address.isEmpty || address.length >= 255) {
      return false;
    }

    // Local-part = Dot-string / Quoted-string
    //       ; MAY be case-sensitive
    //
    // Dot-string = Atom *("." Atom)
    //
    // Quoted-string = DQUOTE *qcontent DQUOTE
    if (address[_index] == '"') {
      if (!_skipQuoted(allowInternational) || _index >= address.length) {
        return false;
      }
    } else {
      if (!_skipAtom(allowInternational) || _index >= address.length) {
        return false;
      }

      while (address[_index] == '.') {
        _index++;

        if (_index >= address.length) {
          return false;
        }

        if (!_skipAtom(allowInternational)) {
          return false;
        }

        if (_index >= address.length) {
          return false;
        }
      }
    }

    if (_index + 1 >= address.length || _index > 64 || address[_index++] != '@') {
      return false;
    }

    if (address[_index] != '[') {
      // domain
      if (!_skipDomain(allowTopLevelDomains, allowInternational)) {
        return false;
      }

      return _index == address.length;
    }

    // address literal
    _index++;

    // we need at least 8 more characters
    if (_index + 8 >= address.length) {
      return false;
    }

    final ipv6 = address.substring(_index - 1).toLowerCase();

    if (ipv6.contains('ipv6:')) {
      _index += 'IPv6:'.length;
      if (!_skipIPv6Literal()) {
        return false;
      }
    } else {
      if (!_skipIPv4Literal()) {
        return false;
      }
    }

    if (_index >= address.length || address[_index++] != ']') {
      return false;
    }

    return _index == address.length;
  }

  bool _isDigit(String c) {
    return c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  }

  bool _isLetter(String c) {
    return (c.codeUnitAt(0) >= 65 && c.codeUnitAt(0) <= 90) ||
        (c.codeUnitAt(0) >= 97 && c.codeUnitAt(0) <= 122);
  }

  bool _isLetterOrDigit(String c) {
    return _isLetter(c) || _isDigit(c);
  }

  bool _isAtom(String c, bool allowInternational) {
    return c.codeUnitAt(0) < 128
        ? _isLetterOrDigit(c) || _emailAtomCharacters.contains(c)
        : allowInternational;
  }

  bool _isDomain(String c, bool allowInternational) {
    if (c.codeUnitAt(0) < 128) {
      if (_isLetter(c) || c == '-') {
        _domainType = _Type.alphabetic;
        return true;
      }

      if (_isDigit(c)) {
        _domainType = _Type.numeric;
        return true;
      }

      return false;
    }

    if (allowInternational) {
      _domainType = _Type.alphabetic;
      return true;
    }

    return false;
  }

  bool _isDomainStart(String c, bool allowInternational) {
    if (c.codeUnitAt(0) < 128) {
      if (_isLetter(c)) {
        _domainType = _Type.alphabetic;
        return true;
      }

      if (_isDigit(c)) {
        _domainType = _Type.numeric;
        return true;
      }

      _domainType = _Type.none;

      return false;
    }

    if (allowInternational) {
      _domainType = _Type.alphabetic;
      return true;
    }

    _domainType = _Type.none;

    return false;
  }

  bool _skipAtom(bool allowInternational) {
    final startIndex = _index;

    while (_index < address.length && _isAtom(address[_index], allowInternational)) {
      _index++;
    }

    return _index > startIndex;
  }

  bool _skipSubDomain(bool allowInternational) {
    final startIndex = _index;

    if (!_isDomainStart(address[_index], allowInternational)) {
      return false;
    }

    _index++;

    while (_index < address.length && _isDomain(address[_index], allowInternational)) {
      _index++;
    }

    return (_index - startIndex) < 64 && address[_index - 1] != '-';
  }

  bool _skipDomain(bool allowTopLevelDomains, bool allowInternational) {
    if (!_skipSubDomain(allowInternational)) {
      return false;
    }

    if (_index < address.length && address[_index] == '.') {
      do {
        _index++;

        if (_index == address.length) {
          return false;
        }

        if (!_skipSubDomain(allowInternational)) {
          return false;
        }
      } while (_index < address.length && address[_index] == '.');
    } else if (!allowTopLevelDomains) {
      return false;
    }

    // Note: by allowing AlphaNumeric,
    // we get away with not having to support punycode.
    if (_domainType == _Type.numeric) {
      return false;
    }

    return true;
  }

  bool _skipQuoted(bool allowInternational) {
    var escaped = false;

    // skip over leading '"'
    _index++;

    while (_index < address.length) {
      if (address[_index].codeUnitAt(0) >= 128 && !allowInternational) {
        return false;
      }

      if (address[_index] == '\\') {
        escaped = !escaped;
      } else if (!escaped) {
        if (address[_index] == '"') {
          break;
        }
      } else {
        escaped = false;
      }

      _index++;
    }

    if (_index >= address.length || address[_index] != '"') {
      return false;
    }

    _index++;

    return true;
  }

  bool _skipIPv4Literal() {
    var groups = 0;

    while (_index < address.length && groups < 4) {
      final startIndex = _index;
      var value = 0;

      while (_index < address.length &&
          address[_index].codeUnitAt(0) >= 48 &&
          address[_index].codeUnitAt(0) <= 57) {
        value = (value * 10) + (address[_index].codeUnitAt(0) - 48);
        _index++;
      }

      if (_index == startIndex || _index - startIndex > 3 || value > 255) {
        return false;
      }

      groups++;

      if (groups < 4 && _index < address.length && address[_index] == '.') {
        _index++;
      }
    }

    return groups == 4;
  }

  bool _isHexDigit(String str) {
    final c = str.codeUnitAt(0);
    return (c >= 65 && c <= 70) || (c >= 97 && c <= 102) || (c >= 48 && c <= 57);
  }

  // This needs to handle the following forms:
  //
  // IPv6-addr = IPv6-full / IPv6-comp / IPv6v4-full / IPv6v4-comp
  // IPv6-hex  = 1*4HEXDIG
  // IPv6-full = IPv6-hex 7(":" IPv6-hex)
  // IPv6-comp = [IPv6-hex *5(":" IPv6-hex)] "::" [IPv6-hex *5(":" IPv6-hex)]
  //             ; The "::" represents at least 2 16-bit groups of zeros
  //             ; No more than 6 groups in addition to the "::" may be
  //             ; present
  // IPv6v4-full = IPv6-hex 5(":" IPv6-hex) ":" IPv4-address-literal
  // IPv6v4-comp = [IPv6-hex *3(":" IPv6-hex)] "::"
  //               [IPv6-hex *3(":" IPv6-hex) ":"] IPv4-address-literal
  //             ; The "::" represents at least 2 16-bit groups of zeros
  //             ; No more than 4 groups in addition to the "::" and
  //             ; IPv4-address-literal may be present
  bool _skipIPv6Literal() {
    var compact = false;
    var colons = 0;

    while (_index < address.length) {
      var startIndex = _index;

      while (_index < address.length && _isHexDigit(address[_index])) {
        _index++;
      }

      if (_index >= address.length) {
        break;
      }

      if (_index > startIndex && colons > 2 && address[_index] == '.') {
        // IPv6v4
        _index = startIndex;

        if (!_skipIPv4Literal()) {
          return false;
        }

        return compact ? colons < 6 : colons == 6;
      }

      var count = _index - startIndex;
      if (count > 4) {
        return false;
      }

      if (address[_index] != ':') {
        break;
      }

      startIndex = _index;
      while (_index < address.length && address[_index] == ':') {
        _index++;
      }

      count = _index - startIndex;
      if (count > 2) {
        return false;
      }

      if (count == 2) {
        if (compact) {
          return false;
        }

        compact = true;
        colons += 2;
      } else {
        colons++;
      }
    }

    if (colons < 2) {
      return false;
    }

    return compact ? colons < 7 : colons == 7;
  }
}

enum _Type { none, alphabetic, numeric }
