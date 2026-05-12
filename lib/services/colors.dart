import 'package:flutter/material.dart';

const contactColors = [
  Color(0xFFFF6B6B),
  Color(0xFF4ECDC4),
  Color(0xFF45B7D1),
  Color(0xFF96CEB4),
  Color(0xFFDDA0DD),
  Color(0xFFFFEAA7),
  Color(0xFF74B9FF),
  Color(0xFFF8B500),
  Color(0xFFA29BFE),
  Color(0xFFFF8A80),
];

Color getContactColor(int index) => contactColors[index % contactColors.length];
