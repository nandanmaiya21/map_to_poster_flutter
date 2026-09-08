import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();
  static const displayXL = TextStyle(
    fontFamily: 'BebasNeue',
    fontSize: 72,
    height: 0.85,
    letterSpacing: 1.5,
  );

  static const displayLarge = TextStyle(
    fontFamily: 'BebasNeue',
    fontSize: 48,
    height: 0.9,
    letterSpacing: 1,
  );

  static const headingLarge = TextStyle(
    fontFamily: 'BarlowCondensed',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
  );

  static const headingMedium = TextStyle(
    fontFamily: 'BarlowCondensed',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 1,
  );

  static const technical = TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: 10,
    letterSpacing: 1.2,
  );

  static const body = TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: 13,
    height: 1.6,
  );

  static const label = TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: 9,
    letterSpacing: 1.5,
  );
}
