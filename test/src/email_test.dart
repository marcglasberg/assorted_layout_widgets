import 'package:assorted_layout_widgets/src/email.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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
  group('Email.sanitize', () {
    test('removes unsupported characters but keeps supported typing characters', () {
      expect(Email('te st()@exa mple.com').sanitize(), 'test@example.com');
      expect(
        Email("u.ser+tag@example-domain.com").sanitize(),
        "u.ser+tag@example-domain.com",
      );
    });

    test('respects allowInternational', () {
      expect(Email(' pelé@exämple.com ').sanitize(), 'pelé@exämple.com');
      expect(
        Email(' pelé@exämple.com ').sanitize(allowInternational: false),
        'pel@exmple.com',
      );
    });

    test('can return incomplete or still-invalid input', () {
      expect(Email('user@').sanitize(), 'user@');
      expect(Email('a@@example').sanitize(), 'a@@example');
    });
  });

  group('Email.tryFix', () {
    test('returns trimmed input when already valid', () {
      expect(Email('  name@example.com  ').tryFix(), 'name@example.com');
      expect(Email('  user@[127.0.0.1]  ').tryFix(), 'user@[127.0.0.1]');
    });

    test('removes unsupported characters and trims boundary punctuation', () {
      expect(Email('.us!er@-exa mple.com-').tryFix(), 'us!er@example.com');
      expect(Email('.user@-example.com-').tryFix(), 'user@example.com');
    });

    test('returns null when the structure cannot be fixed', () {
      expect(Email('plainaddress').tryFix(), isNull);
      expect(Email('a@b@c.com').tryFix(), isNull);
      expect(Email('@example.com').tryFix(), isNull);
      expect(Email('bad..dots@example..com').tryFix(), isNull);
    });

    test('respects validation options while fixing', () {
      expect(
        Email(' pel é@example.com ').tryFix(allowInternational: true),
        'pelé@example.com',
      );
      expect(
        Email(' pel é@example.com ').tryFix(allowInternational: false),
        'pel@example.com',
      );
      expect(Email('name@-example-').tryFix(allowTopLevelDomains: true), 'name@example');
      expect(Email('name@-example-').tryFix(), isNull);
    });
  });

  group('Email.isValid', () {
    test('accepts common valid addresses', () {
      const validAddresses = <String>[
        'name@example.com',
        'first.last+tag@example.co.uk',
        'user@[127.0.0.1]',
        'user@[IPv6:2001:db8::1]',
        'user@123.example',
      ];

      for (final address in validAddresses) {
        expect(Email(address).isValid(), isTrue, reason: address);
      }
    });

    test('supports quoted local parts and escaped quotes', () {
      expect(Email('"quoted local"@example.com').isValid(), isTrue);
      expect(Email(r'"escaped\"quote"@example.com').isValid(), isTrue);
      expect(Email('"unterminated@example.com').isValid(), isFalse);
    });

    test('rejects malformed local parts', () {
      const invalidAddresses = <String>[
        '',
        'plainaddress',
        '.name@example.com',
        'name.@example.com',
        'bad..dots@example.com',
      ];

      for (final address in invalidAddresses) {
        expect(Email(address).isValid(), isFalse, reason: address);
      }
    });

    test('rejects malformed domains', () {
      const invalidAddresses = <String>[
        'name@example',
        'name@example..com',
        'name@-example.com',
        'name@example-.com',
        'name@example.com.',
        'name@123.456',
        'name@[256.0.0.1]',
        'name@[IPv6:12345::1]',
        'name@[IPv6:2001:::1]',
      ];

      for (final address in invalidAddresses) {
        expect(Email(address).isValid(), isFalse, reason: address);
      }
    });

    test('supports custom validation options', () {
      expect(Email('name@example').isValid(allowTopLevelDomains: true), isTrue);
      expect(Email('name@example').isValid(), isFalse);
      expect(Email('pelé@example.com').isValid(allowInternational: true), isTrue);
      expect(Email('pelé@example.com').isValid(allowInternational: false), isFalse);
    });

    test('validations do not leak parser state across calls', () {
      expect(Email('name@example.com').isValid(), isTrue);
      expect(Email('bad..dots@example.com').isValid(), isFalse);
      expect(Email('user@[127.0.0.1]').isValid(), isTrue);
      expect(Email('user@[IPv6:2001:db8::1]').isValid(), isTrue);
      expect(Email('plainaddress').isValid(), isFalse);
      expect(Email('name@example.com').isValid(), isTrue);
    });

    test('validation options stay isolated per call', () {
      expect(Email('pelé@example.com').isValid(allowInternational: true), isTrue);
      expect(Email('pelé@example.com').isValid(allowInternational: false), isFalse);
      expect(Email('name@example').isValid(allowTopLevelDomains: true), isTrue);
      expect(Email('name@example').isValid(allowTopLevelDomains: false), isFalse);
    });

    test('enforces local-part and total-length limits', () {
      final local64 = '${List.filled(64, 'a').join()}@example.com';
      final local65 = '${List.filled(65, 'a').join()}@example.com';
      final label63 = List.filled(63, 'a').join();
      final label60 = List.filled(60, 'a').join();
      final label61 = List.filled(61, 'a').join();
      final total254 = 'a@$label63.$label63.$label63.$label60';
      final total255 = 'a@$label63.$label63.$label63.$label61';

      expect(local64.length, 76);
      expect(local65.length, 77);
      expect(total254.length, 254);
      expect(total255.length, 255);

      expect(Email(local64).isValid(), isTrue);
      expect(Email(local65).isValid(), isFalse);
      expect(Email(total254).isValid(), isTrue);
      expect(Email(total255).isValid(), isFalse);
    });
  });

  group('Email value semantics', () {
    test('toString returns the original address', () {
      expect(Email('name@example.com').toString(), 'name@example.com');
    });

    test('equality and hashCode depend on address', () {
      expect(Email('name@example.com'), Email('name@example.com'));
      expect(Email('name@example.com').hashCode, Email('name@example.com').hashCode);
      expect(Email('name@example.com') == Email('other@example.com'), isFalse);
    });
  });

  group('EmailTextInputFormatter', () {
    test(
      'sanitizes pasted input and uses the old caret branch when characters are removed',
      () {
        final oldValue = _value('', offset: 0);
        final newValue = _value('te st()@exa mple.com', offset: 20);

        final result = EmailTextInputFormatter().formatEditUpdate(oldValue, newValue);

        expect(result.text, 'test@example.com');
        expect(result.selection, const TextSelection.collapsed(offset: 0));
        expect(result.composing, TextRange.empty);
      },
    );

    test('uses the new caret position when sanitization keeps the same length', () {
      final oldValue = _value('name@exam', offset: 9);
      final newValue = _value('name@example.com', offset: 12);

      final result = EmailTextInputFormatter().formatEditUpdate(oldValue, newValue);

      expect(result.text, 'name@example.com');
      expect(result.selection, const TextSelection.collapsed(offset: 12));
    });

    test('clamps the caret to the sanitized text length', () {
      final oldValue = _value('ab', offset: 10);
      final newValue = _value('ab()', offset: 4);

      final result = EmailTextInputFormatter().formatEditUpdate(oldValue, newValue);

      expect(result.text, 'ab');
      expect(result.selection, const TextSelection.collapsed(offset: 2));
    });

    test('preserves international characters allowed by Email.sanitize', () {
      final oldValue = _value('', offset: 0);
      final newValue = _value(
        'pelé@exämple.com',
        offset: 16,
        composing: const TextRange(start: 0, end: 16),
      );

      final result = EmailTextInputFormatter().formatEditUpdate(oldValue, newValue);

      expect(result.text, 'pelé@exämple.com');
      expect(result.selection, const TextSelection.collapsed(offset: 16));
      expect(result.composing, TextRange.empty);
    });
  });
}
