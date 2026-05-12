import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_call2/services/colors.dart';

void main() {
  test('contactColors has 10 entries', () {
    expect(contactColors.length, 10);
  });

  test('getContactColor wraps around', () {
    expect(getContactColor(0), contactColors[0]);
    expect(getContactColor(10), contactColors[0]);
    expect(getContactColor(15), contactColors[5]);
  });
}
