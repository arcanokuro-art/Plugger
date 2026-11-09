import 'package:flutter/material.dart';

import 'package:plugger/features/profile/profile_page.dart';
import 'plugger_home.dart';

class PluggerApp extends StatefulWidget {
  const PluggerApp({super.key});

  @override
  State<PluggerApp> createState() => _PluggerAppState();
}

class _PluggerAppState extends State<PluggerApp> {
  final _profile = ValueNotifier(const ProfileData());

  @override
  void dispose() {
    _profile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: _profile,
    builder: (_, data, home) => MaterialApp(
      title: 'Plugger',
      debugShowCheckedModeBanner: false,
      theme: profileTheme(data),
      themeAnimationDuration: Duration.zero,
      home: home,
    ),
    child: PluggerHome(profile: _profile),
  );
}
