// ignore_for_file: prefer_adjacent_string_concatenation, prefer_const_constructors

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

String join(String a, String b) => a + b;

void main() {
  //
  test('Comparing GlobalObjectKey', () {
    Key keyA = GlobalObjectKey('1' + '23');
    Key keyB = GlobalObjectKey('12' + '3');

    expect(keyA == keyA, isTrue);
    expect(keyA == keyB, isFalse);
  });

  test('Comparing GlobalValueKey', () {
    Key keyA = GlobalValueKey('1' + '23');
    Key keyB = GlobalValueKey('12' + '3');

    expect(keyA == keyA, isTrue);
    expect(keyA == keyB, isTrue);
  });

  test('Comparing GlobalStringKey', () {
    Key keyA = GlobalStringKey('1' + '23');
    Key keyB = GlobalStringKey('12' + '3');

    expect(keyA == keyA, isTrue);
    expect(keyA == keyB, isTrue);
  });

  test('Comparing again', () {
    expect(const GlobalObjectKey('123') == const GlobalObjectKey('123'), isTrue);
    expect(const GlobalValueKey('123') == const GlobalValueKey('123'), isTrue);
    expect(const GlobalStringKey('123') == const GlobalStringKey('123'), isTrue);

    var x = '1' + '23';
    var y = '12' + '3';

    expect(GlobalObjectKey(x) == GlobalObjectKey(x), isTrue);
    expect(GlobalObjectKey(x) == GlobalObjectKey(y), isFalse);
    expect(GlobalValueKey(x) == GlobalValueKey(y), isTrue);
    expect(GlobalStringKey(x) == GlobalStringKey(y), isTrue);
  });
}
