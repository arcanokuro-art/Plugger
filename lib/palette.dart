import 'package:flutter/material.dart';

const pluggerViolet = Color(0xFF6956E8);
const pluggerInk = Color(0xFF202033);
const pluggerCanvas = Color(0xFFF7F7FB);

ThemeData pluggerLightTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: pluggerViolet),
  scaffoldBackgroundColor: pluggerCanvas,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: pluggerInk,
    centerTitle: false,
    elevation: 0,
  ),
);
