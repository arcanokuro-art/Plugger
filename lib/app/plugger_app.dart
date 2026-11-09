import 'package:flutter/material.dart';

import 'package:plugger/shared/theme/palette.dart';
import 'plugger_home.dart';

class PluggerApp extends StatelessWidget {
  const PluggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plugger',
      debugShowCheckedModeBanner: false,
      theme: pluggerLightTheme(),
      home: const PluggerHome(),
    );
  }
}
