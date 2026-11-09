import 'package:flutter/material.dart';

const pluggerViolet = Color(0xFF6956E8);
const pluggerInk = Color(0xFF202033);
const pluggerCanvas = Colors.white;

ThemeData pluggerLightTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: pluggerViolet).copyWith(surface: Colors.white),
  scaffoldBackgroundColor: pluggerCanvas,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: pluggerInk,
    centerTitle: false,
    elevation: 0,
  ),
);
